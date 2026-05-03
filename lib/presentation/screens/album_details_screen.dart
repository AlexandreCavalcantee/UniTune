import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../data/services/itunes_service.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/song.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class AlbumDetailsScreen extends StatefulWidget {
  const AlbumDetailsScreen({super.key, required this.album});

  final Album album;

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  late final AudioPlayer _player;
  final ItunesService _itunesService = ItunesService();

  bool _isLoading = true;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _audioError;
  List<Song> _tracks = [];
  int? _selectedTrackIndex;
  String? _errorMessage;

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
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _tracks = await _itunesService.fetchAlbumTracks(
        collectionId: widget.album.collectionId,
      );
    } catch (_) {
      _errorMessage = 'Não foi possível carregar as faixas do álbum.';
      _tracks = [];
    } finally {
      if (mounted) {
        _isLoading = false;
        setState(() {});
      }
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

  Future<void> _toggleTrackPlayback(int index) async {
    final track = _tracks[index];
    if (track.previewUrl == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preview unavailable for this track.')),
        );
      }
      return;
    }

    if (_selectedTrackIndex == index) {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
      return;
    }

    try {
      await _player.setUrl(track.previewUrl!);
      _selectedTrackIndex = index;
      await _player.play();
      if (mounted) setState(() => _audioError = null);
    } catch (_) {
      if (mounted) {
        setState(() => _audioError = 'Não foi possível reproduzir o preview.');
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _player.dispose();
    _itunesService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppTheme.darkHeaderGradient : AppTheme.lightHeaderGradient;
    final releaseDate = widget.album.releaseDate;
    final priceText = widget.album.collectionPrice != null
        ? '\$${widget.album.collectionPrice!.toStringAsFixed(2)}'
        : 'Price unavailable';
    final releaseText = releaseDate != null
        ? releaseDate.toLocal().toIso8601String().split('T').first
        : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
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
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            widget.album.artworkUrl,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF353438),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.album_rounded,
                                size: 72,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.album.collectionName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.album.artistName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      if (widget.album.primaryGenreName.isNotEmpty)
                        _InfoChip(
                          icon: Icons.category_rounded,
                          label: widget.album.primaryGenreName,
                          color: colorScheme.primary,
                        ),
                      _InfoChip(
                        icon: Icons.calendar_today_rounded,
                        label: releaseText ?? 'Unknown date',
                        color: colorScheme.onSurface.withOpacity(0.35),
                      ),
                      _InfoChip(
                        icon: Icons.music_note_rounded,
                        label: '${widget.album.trackCount} tracks',
                        color: colorScheme.onSurface.withOpacity(0.35),
                      ),
                      _InfoChip(
                        icon: Icons.attach_money_rounded,
                        label: priceText,
                        color: colorScheme.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_selectedTrackIndex != null && _tracks.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview: ${_tracks[_selectedTrackIndex!].trackName}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Slider(
                          value: _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble()),
                          max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1,
                          onChanged: (value) async {
                            await _player.seek(Duration(milliseconds: value.toInt()));
                          },
                          activeColor: colorScheme.primary,
                          inactiveColor: Colors.white.withOpacity(0.12),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: TextStyle(color: Colors.white.withOpacity(0.55)),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: TextStyle(color: Colors.white.withOpacity(0.55)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = _tracks[index];
                  final isSelected = index == _selectedTrackIndex;
                  final priceLabel = track.trackPrice != null
                      ? '\$${track.trackPrice!.toStringAsFixed(2)}'
                      : 'Price unavailable';

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        tileColor: const Color(0xFF1E1E22),
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? colorScheme.primary
                              : Colors.white.withOpacity(0.08),
                          child: Icon(
                            isSelected && _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: isSelected ? colorScheme.onPrimary : Colors.white,
                          ),
                        ),
                        title: Text(
                          track.trackName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          priceLabel,
                          style: TextStyle(color: Colors.white.withOpacity(0.55)),
                        ),
                        trailing: track.previewUrl == null
                            ? const Text(
                                'No preview',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              )
                            : null,
                        onTap: () => _toggleTrackPlayback(index),
                      ),
                      const SizedBox(height: 6),
                    ],
                  );
                },
                childCount: _tracks.length,
              ),
            ),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
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
