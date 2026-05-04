import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/playlist.dart';
import '../providers/playlist_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'details_screen.dart';

class PlaylistDetailsScreen extends StatelessWidget {
  const PlaylistDetailsScreen({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaylistProvider>();
    final current = provider.playlists.firstWhere(
      (p) => p.id == playlist.id,
      orElse: () => playlist,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppTheme.darkHeaderGradient : AppTheme.lightHeaderGradient;
    final colorScheme = Theme.of(context).colorScheme;
    final artworkUrl = current.songs.isNotEmpty ? current.songs.first.artworkUrl : null;
    final trackCount = current.songs.length;
    final trackLabel = trackCount == 1 ? '1 música' : '$trackCount músicas';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        if (artworkUrl != null)
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                artworkUrl,
                                width: 220,
                                height: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholderArt(colorScheme),
                              ),
                            ),
                          )
                        else
                          Center(child: _buildPlaceholderArt(colorScheme)),
                        const SizedBox(height: 18),
                        Text(
                          current.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          trackCount > 0 ? trackLabel : 'Playlist vazia',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (current.songs.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Nenhuma música nesta playlist. Volte para Search e adicione algumas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = current.songs[index];
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tileColor: const Color(0xFF1E1E22),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: song.artworkUrl == null
                              ? Container(
                                  width: 52,
                                  height: 52,
                                  color: const Color(0xFF131316),
                                  child: Icon(Icons.album_rounded,
                                      color: colorScheme.onSurface.withValues(alpha: 0.35)),
                                )
                              : Image.network(
                                  song.artworkUrl!,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 52,
                                    height: 52,
                                    color: const Color(0xFF131316),
                                    child: Icon(Icons.album_rounded,
                                        color: colorScheme.onSurface.withValues(alpha: 0.35)),
                                  ),
                                ),
                        ),
                        title: Text(
                          song.trackName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '${song.artistName} • ${song.albumName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.chevron_right_rounded,
                              color: colorScheme.primary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailsScreen(song: song),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailsScreen(song: song),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                    ],
                  );
                },
                childCount: current.songs.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderArt(ColorScheme cs) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(Icons.headphones_rounded,
          color: cs.primary.withValues(alpha: 0.6), size: 72),
    );
  }
}
