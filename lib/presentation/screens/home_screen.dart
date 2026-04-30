import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/song.dart';
import '../providers/playlist_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/mini_player_bar.dart';

/// Home screen that mirrors the provided HTML layout order:
/// top app bar → search → horizontal cards → bento grid → list → bottom nav.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSearch() {
    final q = _searchController.text.trim();
    Navigator.pushNamed(context, '/search', arguments: q.isEmpty ? null : q);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _TopBar(
              onAvatarTap: () {},
              onToggleTheme: context.read<ThemeProvider>().toggle,
            ),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _HomeBody(
                    searchController: _searchController,
                    onSearch: _openSearch,
                  ),
                  const _PlaceholderTab(
                    title: 'Search',
                    subtitle: 'Use the search field on Home.',
                    icon: Icons.search_rounded,
                  ),
                  const _PlaceholderTab(
                    title: 'Library',
                    subtitle: 'Open your saved playlist.',
                    icon: Icons.library_music_rounded,
                  ),
                  const _PlaceholderTab(
                    title: 'Broadcast',
                    subtitle: 'Suggestions for the radio live here.',
                    icon: Icons.settings_input_antenna_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayerBar(),
            AppBottomNav(
              currentIndex: _tabIndex,
              onTap: (i) async {
                if (i == 2) {
                  Navigator.pushNamed(context, '/playlist');
                  return;
                }
                if (i == 1) {
                  _openSearch();
                  return;
                }
                setState(() => _tabIndex = i);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openSearch,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        child: const Icon(Icons.search_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onAvatarTap,
    required this.onToggleTheme,
  });

  final VoidCallback onAvatarTap;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(18, top + 10, 18, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: cs.outline.withValues(alpha: 0.35)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.radio_rounded, color: cs.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'UniRadio',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: onToggleTheme,
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onAvatarTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.primary, width: 2),
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.searchController,
    required this.onSearch,
  });

  final TextEditingController searchController;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final playlist = context.watch<PlaylistProvider>().songs;
    final horizontal = playlist.take(10).toList(growable: false);
    final w = MediaQuery.sizeOf(context).width;
    final isCompact = w < 420;
    final side = isCompact ? 14.0 : 18.0;
    final cardWidth = (w - side * 2) * (isCompact ? 0.78 : 0.60);
    final clampedCardWidth = cardWidth.clamp(200.0, 260.0);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(side, 16, side, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search section
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.55)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search artists or tracks...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onSearch,
                  icon: Icon(Icons.arrow_forward_rounded, color: cs.primary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // Recommended for Today
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recommended for Today',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'SEE ALL',
                  style: TextStyle(
                    color: cs.primary,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: horizontal.isEmpty ? 3 : horizontal.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final song = horizontal.isEmpty
                    ? null
                    : horizontal[i];
                return _TrackCard(song: song, width: clampedCardWidth);
              },
            ),
          ),

          const SizedBox(height: 34),

          // Recent Stations (bento grid)
          const Text(
            'Recent Stations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final gap = 16.0;
              final half = (w - gap) / 2;
              return Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: half,
                        height: half,
                        child: _StationTile.large(
                          title: 'Techno Core',
                          subtitle: 'Live from Berlin',
                          leading: Icons.settings_input_antenna_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: half,
                        height: half,
                        child: Column(
                          children: const [
                            Expanded(
                              child: _StationTile.small(
                                title: 'Electronica',
                                leading: Icons.bolt_rounded,
                              ),
                            ),
                            SizedBox(height: 16),
                            Expanded(
                              child: _StationTile.small(
                                title: 'Ambient',
                                leading: Icons.waves_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _StationTile.wide(
                    title: 'Radio Flux',
                    subtitle: '42.5k listeners',
                    leading: Icons.graphic_eq_rounded,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 34),

          // Top Playlists (list)
          const Text(
            'Top Playlists',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _PlaylistList(songs: playlist),
        ],
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({required this.song, required this.width});
  final Song? song;
  final double width;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final title = song?.trackName ?? 'Neon Echoes';
    final subtitle = song?.artistName ?? 'Sonic Architect';
    final art = song?.artworkUrl;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF353438),
                    border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: art == null
                      ? Container(
                          alignment: Alignment.center,
                          child: Icon(Icons.album_rounded,
                              color: Colors.white.withValues(alpha: 0.4),
                              size: 56),
                        )
                      : Image.network(
                          art,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            alignment: Alignment.center,
                            child: Icon(Icons.album_rounded,
                                color: Colors.white.withValues(alpha: 0.4),
                                size: 56),
                          ),
                        ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(Icons.play_arrow_rounded, color: cs.onPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _StationTile extends StatelessWidget {
  const _StationTile._({
    required this.title,
    this.subtitle,
    required this.leading,
    required this.variant,
  });

  final String title;
  final String? subtitle;
  final IconData leading;
  final _StationVariant variant;

  const _StationTile.large({
    required String title,
    required String subtitle,
    required IconData leading,
  }) : this._(
          title: title,
          subtitle: subtitle,
          leading: leading,
          variant: _StationVariant.large,
        );

  const _StationTile.small({
    required String title,
    required IconData leading,
  }) : this._(
          title: title,
          subtitle: null,
          leading: leading,
          variant: _StationVariant.small,
        );

  const _StationTile.wide({
    required String title,
    required String subtitle,
    required IconData leading,
  }) : this._(
          title: title,
          subtitle: subtitle,
          leading: leading,
          variant: _StationVariant.wide,
        );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = BoxDecoration(
      color: const Color(0xFF1F1F22),
      border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
      borderRadius: BorderRadius.circular(0),
    );

    Widget content;
    switch (variant) {
      case _StationVariant.large:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(leading, color: cs.primary),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle ?? '',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    letterSpacing: 2,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            )
          ],
        );
        break;
      case _StationVariant.small:
        content = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF353438),
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
                ),
                child: Icon(leading, color: Colors.white.withValues(alpha: 0.55)),
              ),
              const SizedBox(height: 10),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
        break;
      case _StationVariant.wide:
        content = Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF0E0E11),
                border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
              ),
              child: Icon(leading, color: cs.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle ?? '',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.45)),
          ],
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: base,
      child: content,
    );
  }
}

enum _StationVariant { large, small, wide }

class _PlaylistList extends StatelessWidget {
  const _PlaylistList({required this.songs});
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = songs.take(6).toList(growable: false);
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F22),
          border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
        ),
        child: Text(
          'Sua playlist ainda está vazia. Faça uma busca e adicione músicas.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          _PlaylistRow(index: i + 1, song: items[i]),
      ],
    );
  }
}

class _PlaylistRow extends StatelessWidget {
  const _PlaylistRow({required this.index, required this.song});
  final int index;
  final Song song;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/playlist'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: cs.outline.withValues(alpha: 0.25)),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF0E0E11),
                border: Border.all(
                  color: cs.outline.withValues(alpha: 0.35),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: song.artworkUrl == null
                  ? Icon(Icons.music_note_rounded,
                      color: Colors.white.withValues(alpha: 0.45))
                  : Image.network(
                      song.artworkUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.music_note_rounded,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.trackName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${song.artistName} • ${song.albumName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.more_vert_rounded,
                color: Colors.white.withValues(alpha: 0.55)),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: cs.primary.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
            ),
          ],
        ),
      ),
    );
  }
}

