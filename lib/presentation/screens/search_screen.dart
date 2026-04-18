import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/itunes_service.dart';
import '../../domain/entities/song.dart';
import '../providers/search_provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'details_screen.dart';

/// Main search screen.
///
/// Allows the user to search the iTunes catalogue by artist, album, or song,
/// toggle explicit content filtering, and browse results.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(SearchProvider provider) {
    FocusScope.of(context).unfocus();
    provider.search(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: Column(
            children: [
              _GradientHeader(
                controller: _controller,
                onSearch: () => _onSearch(provider),
                provider: provider,
              ),
              Expanded(child: _ResultsList(provider: provider)),
            ],
          ),
        );
      },
    );
  }
}

// ── Gradient header (AppBar + search + filters) ────────────────────────────

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({
    required this.controller,
    required this.onSearch,
    required this.provider,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;
  final SearchProvider provider;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient =
        isDark ? AppTheme.darkHeaderGradient : AppTheme.lightHeaderGradient;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Column(
        children: [
          SizedBox(height: topPadding + 8),
          // ── Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.music_note_rounded,
                    color: Colors.white, size: 28),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'UniTune',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Theme toggle
                Consumer<ThemeProvider>(
                  builder: (_, themeProvider, __) => IconButton(
                    icon: Icon(
                      themeProvider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: Colors.white,
                    ),
                    tooltip: themeProvider.isDark ? 'Light mode' : 'Dark mode',
                    onPressed: themeProvider.toggle,
                  ),
                ),
                // Playlist button
                IconButton(
                  icon: const Icon(Icons.queue_music_rounded,
                      color: Colors.white),
                  tooltip: 'My Playlist',
                  onPressed: () =>
                      Navigator.pushNamed(context, '/playlist'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ── Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search artists, albums, songs…',
                      hintStyle:
                          TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Colors.white.withValues(alpha: 0.8)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                            color: Colors.white, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                    ),
                    onSubmitted: (_) => onSearch(),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onSearch,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.search_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ── Filter chips + explicit switch
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _TypeChip(
                  label: 'Song',
                  icon: Icons.music_note_rounded,
                  value: SearchType.song,
                  groupValue: provider.searchType,
                  onSelected: provider.setSearchType,
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: 'Artist',
                  icon: Icons.person_rounded,
                  value: SearchType.artist,
                  groupValue: provider.searchType,
                  onSelected: provider.setSearchType,
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: 'Album',
                  icon: Icons.album_rounded,
                  value: SearchType.album,
                  groupValue: provider.searchType,
                  onSelected: provider.setSearchType,
                ),
                const SizedBox(width: 16),
                // Explicit filter chip
                FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.explicit_rounded,
                        size: 14,
                        color: provider.allowExplicit
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Explicit',
                        style: TextStyle(
                          color: provider.allowExplicit
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  selected: provider.allowExplicit,
                  onSelected: provider.setAllowExplicit,
                  selectedColor: Colors.white.withValues(alpha: 0.3),
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  side: BorderSide(
                    color: provider.allowExplicit
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final SearchType value;
  final SearchType groupValue;
  final ValueChanged<SearchType> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return FilterChip(
      avatar: Icon(
        icon,
        size: 14,
        color: selected ? Colors.white : Colors.white.withValues(alpha: 0.7),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.7),
          fontSize: 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: selected,
      onSelected: (v) {
        if (v) onSelected(value);
      },
      selectedColor: Colors.white.withValues(alpha: 0.3),
      backgroundColor: Colors.white.withValues(alpha: 0.12),
      side: BorderSide(
        color: selected
            ? Colors.white.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.25),
      ),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }
}

// ── Results list ───────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.provider});

  final SearchProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_music_rounded,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for your favorite music',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: provider.results.length,
      itemBuilder: (context, index) {
        final song = provider.results[index];
        return _SongTile(song: song);
      },
    );
  }
}

// ── Song tile ──────────────────────────────────────────────────────────────

class _SongTile extends StatelessWidget {
  const _SongTile({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.read<PlaylistProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final inPlaylist = playlistProvider.contains(song.trackId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailsScreen(song: song)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _AlbumArtThumbnail(url: song.artworkUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.trackName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.albumName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  if (song.isExplicit) const _ExplicitBadge(),
                  IconButton(
                    icon: Icon(
                      inPlaylist
                          ? Icons.playlist_add_check_rounded
                          : Icons.playlist_add_rounded,
                      color: inPlaylist
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    tooltip:
                        inPlaylist ? 'In playlist' : 'Add to playlist',
                    onPressed: inPlaylist
                        ? null
                        : () {
                            playlistProvider.addSong(song);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '"${song.trackName}" added to playlist'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small widgets ──────────────────────────────────────────────────────────

class _AlbumArtThumbnail extends StatelessWidget {
  const _AlbumArtThumbnail({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null) return const _PlaceholderArt(size: 52);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url!,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _PlaceholderArt(size: 52),
      ),
    );
  }
}

class _PlaceholderArt extends StatelessWidget {
  const _PlaceholderArt({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.music_note_rounded,
          size: size * 0.5, color: color.withValues(alpha: 0.5)),
    );
  }
}

class _ExplicitBadge extends StatelessWidget {
  const _ExplicitBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.error.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        'E',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

