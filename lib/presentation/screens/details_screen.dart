import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/entities/song.dart';
import '../providers/playlist_provider.dart';
import 'package:provider/provider.dart';

/// Detailed view for a single [Song].
///
/// Displays the album art, song metadata, a 30-second audio preview player,
/// and lets the user add/remove the track from the local playlist.
class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.song});

  final Song song;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final AudioPlayer _player;
  bool _isLoading = false;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _audioError;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.playerStateStream.listen(_onPlayerStateChanged);
    _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _player.durationStream.listen((dur) {
      if (mounted) setState(() => _duration = dur ?? Duration.zero);
    });
    if (widget.song.previewUrl != null) {
      _initAudio();
    }
  }

  Future<void> _initAudio() async {
    setState(() => _isLoading = true);
    try {
      await _player.setUrl(widget.song.previewUrl!);
    } catch (_) {
      if (mounted) setState(() => _audioError = 'Preview unavailable.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onPlayerStateChanged(PlayerState state) {
    if (!mounted) return;
    setState(() {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _position = Duration.zero;
        _player.seek(Duration.zero);
      }
    });
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    final inPlaylist = playlistProvider.contains(widget.song.trackId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Details'),
        actions: [
          IconButton(
            icon: Icon(inPlaylist ? Icons.playlist_add_check : Icons.playlist_add),
            tooltip: inPlaylist ? 'Remove from playlist' : 'Add to playlist',
            onPressed: () async {
              if (inPlaylist) {
                final song = playlistProvider.songs
                    .firstWhere((s) => s.trackId == widget.song.trackId);
                if (song.id != null) {
                  await playlistProvider.removeSong(song.id!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Removed from playlist')),
                    );
                  }
                }
              } else {
                await playlistProvider.addSong(widget.song);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to playlist')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Album art ─────────────────────────────────────────────────
            _AlbumArt(url: widget.song.artworkUrl),
            const SizedBox(height: 20),

            // ── Track info ────────────────────────────────────────────────
            Text(
              widget.song.trackName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.song.artistName,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.song.albumName,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (widget.song.genre != null) ...[
              const SizedBox(height: 4),
              Chip(label: Text(widget.song.genre!)),
            ],
            if (widget.song.isExplicit) ...[
              const SizedBox(height: 4),
              const Chip(
                label: Text('Explicit'),
                backgroundColor: Colors.red,
                labelStyle: TextStyle(color: Colors.white),
              ),
            ],
            const SizedBox(height: 24),

            // ── Audio player ──────────────────────────────────────────────
            if (widget.song.previewUrl == null)
              const Text(
                'No preview available for this track.',
                style: TextStyle(color: Colors.grey),
              )
            else
              _AudioPlayer(
                isLoading: _isLoading,
                isPlaying: _isPlaying,
                position: _position,
                duration: _duration,
                error: _audioError,
                onToggle: _togglePlayback,
                onSeek: (pos) => _player.seek(pos),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Album art ──────────────────────────────────────────────────────────────

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.7;
    if (url == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.album, size: size * 0.4, color: Colors.grey[600]),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: Colors.grey[300],
          child:
              Icon(Icons.album, size: size * 0.4, color: Colors.grey[600]),
        ),
      ),
    );
  }
}

// ── Audio player ────────────────────────────────────────────────────────────

class _AudioPlayer extends StatelessWidget {
  const _AudioPlayer({
    required this.isLoading,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onToggle,
    required this.onSeek,
    this.error,
  });

  final bool isLoading;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onToggle;
  final ValueChanged<Duration> onSeek;
  final String? error;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Text(error!, style: const TextStyle(color: Colors.red));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '30-second Preview',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(_format(position),
                  style: const TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: duration.inMilliseconds > 0
                      ? position.inMilliseconds
                          .clamp(0, duration.inMilliseconds)
                          .toDouble()
                      : 0,
                  max: duration.inMilliseconds > 0
                      ? duration.inMilliseconds.toDouble()
                      : 1,
                  onChanged: (v) =>
                      onSeek(Duration(milliseconds: v.toInt())),
                ),
              ),
              Text(_format(duration),
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
          isLoading
              ? const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(),
                )
              : IconButton(
                  iconSize: 48,
                  icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
                  onPressed: onToggle,
                ),
        ],
      ),
    );
  }
}
