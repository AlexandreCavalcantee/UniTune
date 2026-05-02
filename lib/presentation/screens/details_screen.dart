import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/entities/song.dart';
import '../providers/playlist_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
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

  double get artSize => MediaQuery.of(context).size.width * 0.6;

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    final inPlaylist = playlistProvider.contains(widget.song.trackId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient =
        isDark ? AppTheme.darkHeaderGradient : AppTheme.lightHeaderGradient;
    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient app bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              // Theme toggle
              Consumer<ThemeProvider>(
                builder: (_, themeProvider, __) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(
                      icon: Icon(
                        themeProvider.isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: themeProvider.toggle,
                    ),
                  ),
                ),
              ),
              // Playlist button
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: Icon(
                      inPlaylist
                          ? Icons.playlist_add_check_rounded
                          : Icons.playlist_add_rounded,
                      color: inPlaylist ? colorScheme.tertiary : Colors.white,
                      size: 18,
                    ),
                    tooltip: inPlaylist
                        ? 'Remove from playlist'
                        : 'Add to playlist',
                    onPressed: () async {
                      if (inPlaylist) {
                        final song = playlistProvider.songs.firstWhere(
                            (s) => s.trackId == widget.song.trackId);
                        if (song.id != null) {
                          await playlistProvider.removeSong(song.id!);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Removed from playlist')),
                            );
                          }
                        }
                      } else {
                        await playlistProvider.addSong(widget.song);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Added to playlist')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(gradient: gradient),
                child: SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Hero(
                        tag: 'artwork_${widget.song.trackId}',
                        child: _AlbumArt(
                          url: widget.song.artworkUrl,
                          size: artSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Song info & player ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Track name
                  Text(
                    widget.song.trackName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  // Artist
                  Text(
                    widget.song.artistName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  // Album
                  Text(
                    widget.song.albumName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Badges row
                  Wrap(
                    spacing: 8,
                    children: [
                      if (widget.song.genre != null)
                        _InfoChip(
                          icon: Icons.category_rounded,
                          label: widget.song.genre!,
                          color: colorScheme.primary,
                        ),
                      if (widget.song.isExplicit)
                        _InfoChip(
                          icon: Icons.explicit_rounded,
                          label: 'Explicit',
                          color: colorScheme.error,
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Audio player ─────────────────────────────────────
                  if (widget.song.previewUrl == null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.music_off_rounded,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.4)),
                          const SizedBox(width: 8),
                          Text(
                            'No preview available',
                            style: TextStyle(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
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
          ),
        ],
      ),
    );
  }
}

// ── Info chip ──────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Album art ──────────────────────────────────────────────────────────────

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (url == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(Icons.album_rounded,
            size: size * 0.4, color: Colors.white.withValues(alpha: 0.6)),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: DecoratedBox(
          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
          child: Image.network(
            url!,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              width: size,
              height: size,
              color: colorScheme.surfaceContainerHighest,
              child: Icon(Icons.album_rounded,
                  size: size * 0.4,
                  color: colorScheme.onSurface.withValues(alpha: 0.4)),
            ),
          ),
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
    final colorScheme = Theme.of(context).colorScheme;

    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                color: colorScheme.error, size: 20),
            const SizedBox(width: 8),
            Text(error!,
                style: TextStyle(color: colorScheme.error, fontSize: 14)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.headphones_rounded,
                  size: 14,
                  color: colorScheme.primary.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(
                '30-second Preview',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary.withValues(alpha: 0.8),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Seek bar
          Row(
            children: [
              Text(_format(position),
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  )),
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
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  )),
            ],
          ),
          // Play/pause
          isLoading
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkHeaderGradient
                        : AppTheme.lightHeaderGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    iconSize: 32,
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    onPressed: onToggle,
                  ),
                ),
        ],
      ),
    );
  }
}

