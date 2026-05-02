import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/song.dart';
import '../providers/playlist_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/mini_player_bar.dart';
import 'details_screen.dart';

/// Screen showing all locally-saved songs with "suggest to radio" toggles.
class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, _) {
        final cs = Theme.of(context).colorScheme;
        final w = MediaQuery.sizeOf(context).width;
        final isCompact = w < 420;
        final side = isCompact ? 14.0 : 18.0;
        return Scaffold(
          backgroundColor: Colors.black,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.black.withValues(alpha: 0.95),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  tooltip: 'Menu',
                  icon: Icon(Icons.menu_rounded, color: cs.primary),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menu (placeholder)')),
                  ),
                ),
                title: const Text(
                  'UniTune',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Search',
                    onPressed: () => Navigator.pushNamed(context, '/search'),
                    icon: Icon(Icons.search_rounded,
                        color: Colors.white.withValues(alpha: 0.65)),
                  ),
                  IconButton(
                    tooltip: 'Add',
                    onPressed: () => Navigator.pushNamed(context, '/search'),
                    icon: Icon(Icons.add_rounded,
                        color: Colors.white.withValues(alpha: 0.65)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1F22),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: cs.outline.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(Icons.person_rounded,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(side, 14, side, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sua Biblioteca',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _RecentsHeader(onToggleView: () {}),
                      const SizedBox(height: 12),
                      _RecentsGrid(provider: provider),
                      const SizedBox(height: 22),
                      Text(
                        'MÚSICAS SALVAS',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          letterSpacing: 2,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              _SongsSliverList(provider: provider),
              SliverToBoxAdapter(
                child: SizedBox(height: provider.songs.isEmpty ? 140 : 24),
              ),
            ],
          ),
          bottomNavigationBar: _BottomWithMiniPlayer(
            provider: provider,
            child: AppBottomNav(
              currentIndex: 2,
              onTap: (i) {
                if (i == 2) return;
                if (i == 0) {
                  Navigator.popUntil(context, (r) => r.isFirst);
                  return;
                }
                if (i == 1) {
                  Navigator.pushNamed(context, '/search');
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Radio (placeholder)')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _RecentsHeader extends StatelessWidget {
  const _RecentsHeader({required this.onToggleView});
  final VoidCallback onToggleView;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.swap_vert_rounded, color: cs.primary),
        const SizedBox(width: 6),
        Text(
          'Recentes'.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 2,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'View',
          onPressed: onToggleView,
          icon: Icon(Icons.grid_view_rounded,
              color: Colors.white.withValues(alpha: 0.45)),
        ),
      ],
    );
  }
}

class _RecentsGrid extends StatelessWidget {
  const _RecentsGrid({required this.provider});

  final PlaylistProvider provider;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final songs = provider.songs;
    final w = MediaQuery.sizeOf(context).width;
    final isCompact = w < 420;
    final artists = <String>{
      for (final s in songs) s.artistName,
    }.toList()
      ..sort();

    final cards = <Widget>[];

    for (final s in songs.take(3)) {
      cards.add(_SquareMediaCard(
        title: s.albumName,
        subtitle: 'Playlist • 1 música',
        imageUrl: s.artworkUrl,
        primary: cs.primary,
        onTap: () {},
      ));
    }

    for (final a in artists.take(2)) {
      final s = songs.firstWhere((x) => x.artistName == a);
      cards.add(_ArtistCard(
        name: a,
        imageUrl: s.artworkUrl,
        primary: cs.primary,
        onTap: () {},
      ));
    }

    return GridView.count(
      crossAxisCount: isCompact ? 2 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isCompact ? 0.92 : 0.86,
      children: cards.take(6).toList(),
    );
  }
}


class _SquareMediaCard extends StatelessWidget {
  const _SquareMediaCard({
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.onTap,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: const Color(0xFF1F1F22),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              clipBehavior: Clip.hardEdge,
              child: imageUrl == null
                  ? Icon(Icons.album_rounded,
                      color: primary.withValues(alpha: 0.55), size: 44)
                  : Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.album_rounded,
                          color: primary.withValues(alpha: 0.55), size: 44),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  const _ArtistCard({
    required this.name,
    required this.primary,
    required this.onTap,
    this.imageUrl,
  });

  final String name;
  final String? imageUrl;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1F1F22),
                  border: Border.all(color: const Color(0xFF27272A)),
                ),
                clipBehavior: Clip.hardEdge,
                child: imageUrl == null
                    ? Icon(Icons.person_rounded,
                        color: primary.withValues(alpha: 0.55), size: 44)
                    : Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person_rounded,
                          color: primary.withValues(alpha: 0.55),
                          size: 44,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Artista',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SongsSliverList extends StatelessWidget {
  const _SongsSliverList({required this.provider});
  final PlaylistProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (provider.errorMessage != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      );
    }

    if (provider.songs.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F22),
              border: Border.all(color: const Color(0xFF27272A)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Sua playlist está vazia. Vá em Search e adicione músicas.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      sliver: SliverList.separated(
        itemCount: provider.songs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, i) => _LibrarySongRow(
          song: provider.songs[i],
          provider: provider,
        ),
      ),
    );
  }
}

// ── Playlist tile ──────────────────────────────────────────────────────────

class _LibrarySongRow extends StatelessWidget {
  const _LibrarySongRow({required this.song, required this.provider});

  final Song song;
  final PlaylistProvider provider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailsScreen(song: song)),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF131316),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AlbumThumb(url: song.artworkUrl),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SuggestRow(
                      value: song.suggestToRadio,
                      onTap: () => provider.toggleSuggestToRadio(song),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: colorScheme.error.withValues(alpha: 0.75)),
                tooltip: 'Remover',
                onPressed: () async {
                  if (song.id != null) {
                    await provider.removeSong(song.id!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '"${song.trackName}" removida da playlist'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlbumThumb extends StatelessWidget {
  const _AlbumThumb({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    if (url == null) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F22),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF27272A)),
        ),
        child: Icon(Icons.music_note_rounded,
            color: color.withValues(alpha: 0.5)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url!,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F22),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: Icon(Icons.music_note_rounded,
              color: color.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

class _SuggestRow extends StatelessWidget {
  const _SuggestRow({required this.value, required this.onTap});
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 34,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: value ? cs.primary : cs.outline,
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Sugerir para a rádio',
            style: TextStyle(
              color: value
                  ? cs.primary
                  : Colors.white.withValues(alpha: 0.55),
              fontWeight: value ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomWithMiniPlayer extends StatelessWidget {
  const _BottomWithMiniPlayer({required this.provider, required this.child});

  final PlaylistProvider provider;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MiniPlayerBar(),
        child,
      ],
    );
  }
}

