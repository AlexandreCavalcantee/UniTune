import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/song.dart';
import '../providers/playlist_provider.dart';
import '../providers/recommendation_provider.dart';
import '../screens/album_details_screen.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/mini_player_bar.dart';

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
            const _TopBar(),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _HomeBody(
                    searchController: _searchController,
                    onSearch: _openSearch,
                  ),
                  const _PlaceholderTab(
                    title: 'Pesquisa',
                    subtitle: 'Pesquise usando a barra acima ou o botão abaixo.',
                    icon: Icons.search_rounded,
                  ),
                  const _PlaceholderTab(
                    title: 'Biblioteca',
                    subtitle: 'Acesse suas playlists salvas.',
                    icon: Icons.library_music_rounded,
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
  const _TopBar();

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
          Expanded(
            child: Text(
              'UniTune',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: cs.onSurface,
              ),
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
    final recommendation = context.watch<RecommendationProvider>();
    final recommendedAlbums = recommendation.albums;
    final isLoadingAlbums = recommendation.isLoading;
    final recommendedError = recommendation.errorMessage;
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
                    color: cs.onSurface.withValues(alpha: 0.55)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(color: cs.onSurface),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                    decoration: InputDecoration(
                      hintText: 'Pesquise artistas ou faixas...',
                      hintStyle: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.35),
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

          // Recommended Albums
          Text(
            'Recommended for Today',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 290,
            child: isLoadingAlbums
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(cs.primary),
                    ),
                  )
                : recommendedAlbums.isEmpty
                    ? Center(
                        child: Text(
                          recommendedError ??
                              'Adicione músicas para ver álbuns recomendados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recommendedAlbums.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, i) {
                          return _AlbumCard(
                            album: recommendedAlbums[i],
                            width: clampedCardWidth,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AlbumDetailsScreen(
                                    album: recommendedAlbums[i],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),

          const SizedBox(height: 34),

          const SizedBox(height: 34),

          // Top Playlists (list)
          Text(
            'Top Playlists',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _PlaylistList(songs: playlist),
        ],
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    required this.album,
    required this.width,
    this.onTap,
  });
  final Album? album;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final title = album?.collectionName ?? 'Discover albums';
    final subtitle = album?.artistName ?? 'Save songs to see recommendations';
    final genre = album?.primaryGenreName;
    final art = album?.artworkUrl;

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
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
                  child: art == null || art.isEmpty
                      ? Container(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.album_rounded,
                            color: cs.onSurface.withValues(alpha: 0.4),
                            size: 56,
                          ),
                        )
                      : Image.network(
                          art,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.album_rounded,
                              color: cs.onSurface.withValues(alpha: 0.4),
                              size: 56,
                            ),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
          if (genre != null) ...[
            const SizedBox(height: 4),
            Text(
              genre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ],
      ),
    )
        );
  }
}

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
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
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
                  color: cs.onSurface.withValues(alpha: 0.55),
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
                      color: cs.onSurface.withValues(alpha: 0.45))
                  : Image.network(
                      song.artworkUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.music_note_rounded,
                        color: cs.onSurface.withValues(alpha: 0.45),
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
                    style: TextStyle(
                      color: cs.onSurface,
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
                      color: cs.onSurface.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.more_vert_rounded,
                color: cs.onSurface.withValues(alpha: 0.55)),
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
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.55)),
            ),
          ],
        ),
      ),
    );
  }
}

