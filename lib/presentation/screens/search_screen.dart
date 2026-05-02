import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/itunes_service.dart';
import '../../domain/entities/song.dart';
import '../providers/search_provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/now_playing_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/mini_player_bar.dart';
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
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!mounted) return;
    context.read<SearchProvider>().setSearchActive(_controller.text.isNotEmpty);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && arg.trim().isNotEmpty && _controller.text.isEmpty) {
      _controller.text = arg.trim();
      // Auto-search on first open with argument.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<SearchProvider>().search(_controller.text);
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(SearchProvider provider) {
    FocusScope.of(context).unfocus();
    provider.search(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(builder: (context, provider, _) {
      final cs = Theme.of(context).colorScheme;
      final w = MediaQuery.sizeOf(context).width;
      final isCompact = w < 420;
      final side = isCompact ? 14.0 : 18.0;
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 8,
              title: const Text(
                'UniTune',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.5,
                ),
              ),
              leading: IconButton(
                tooltip: 'Menu',
                icon: Icon(Icons.menu_rounded,
                    color: cs.onSurface.withValues(alpha: 0.7)),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu (placeholder)')),
                ),
              ),
              actions: [
                Consumer<ThemeProvider>(
                  builder: (_, themeProvider, __) => IconButton(
                    tooltip:
                        themeProvider.isDark ? 'Light mode' : 'Dark mode',
                    icon: Icon(
                      themeProvider.isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                    onPressed: themeProvider.toggle,
                  ),
                ),
                IconButton(
                  tooltip: 'Account',
                  icon: Icon(Icons.account_circle_rounded,
                      color: cs.onSurface.withValues(alpha: 0.7)),
                  onPressed: () {},
                ),
                const SizedBox(width: 4),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(side, 18, side, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search field
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded,
                              color: cs.onSurface.withValues(alpha: 0.5)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _onSearch(provider),
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Search artists, tracks, or radios...',
                                hintStyle: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.3),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Filter bar (type radios + explicit)
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: cs.outline.withValues(alpha: 0.25),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                'Explicit Content',
                                style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: provider.allowExplicit,
                                onChanged: provider.setAllowExplicit,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    Text(
                      provider.isSearchActive
                          ? 'RESULTS'
                          : 'RECENT DISCOVERIES',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.4),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _ResultsSliver(provider: provider),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(side, 22, side, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BROWSE GENRES',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.4),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _GenresGrid(),
                    const SizedBox(height: 18),
                    _BottomSpacerHint(primary: cs.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _onSearch(provider),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          child: const Icon(Icons.search_rounded),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayerBar(),
            AppBottomNav(
              currentIndex: 1,
              onTap: (i) {
                if (i == 1) return;
                if (i == 0) {
                  Navigator.popUntil(context, (r) => r.isFirst);
                  return;
                }
                if (i == 2) {
                  Navigator.pushNamed(context, '/playlist');
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Radio (placeholder)')),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class _ResultsSliver extends StatelessWidget {
  const _ResultsSliver({required this.provider});
  final SearchProvider provider;

  @override
  Widget build(BuildContext context) {
    // ── History mode (search field empty) ───────────────────────────────────
    if (!provider.isSearchActive) {
      if (provider.recentHistory.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Faça uma busca para ver resultados aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        sliver: SliverList.separated(
          itemCount: provider.recentHistory.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) =>
              _SongRow(song: provider.recentHistory[index]),
        ),
      );
    }

    // ── Search mode (search field has text) ─────────────────────────────────
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

    if (provider.results.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Pressione buscar para ver resultados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverList.separated(
        itemCount: provider.results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) =>
            _SongRow(song: provider.results[index]),
      ),
    );
  }
}

// ── Song tile ──────────────────────────────────────────────────────────────

class _SongRow extends StatelessWidget {
  const _SongRow({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.read<PlaylistProvider>();
    final nowPlaying = context.read<NowPlayingProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final inPlaylist = playlistProvider.contains(song.trackId);
    // Duration isn't present in the current Song entity; keep layout minimal.
    final String? durationText = null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          context.read<SearchProvider>().addToHistory(song);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailsScreen(song: song)),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  context.read<SearchProvider>().addToHistory(song);
                  nowPlaying.playPreview(song);
                },
                borderRadius: BorderRadius.circular(10),
                child: _ArtWithPlay(url: song.artworkUrl),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (durationText != null)
                Text(
                  durationText,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: inPlaylist ? 'In playlist' : 'Add to playlist',
                icon: Icon(
                  inPlaylist
                      ? Icons.playlist_add_check_rounded
                      : Icons.playlist_add_rounded,
                  color: inPlaylist
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.35),
                ),
                onPressed: inPlaylist
                    ? null
                    : () {
                        playlistProvider.addSong(song);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '"${song.trackName}" adicionada na playlist'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
              ),
              Icon(Icons.more_vert_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtWithPlay extends StatelessWidget {
  const _ArtWithPlay({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(
            width: 64,
            height: 64,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: url == null
                ? Icon(Icons.album_rounded,
                    color: cs.onSurface.withValues(alpha: 0.35), size: 28)
                : Image.network(
                    url!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.album_rounded,
                        color: cs.onSurface.withValues(alpha: 0.35), size: 28),
                  ),
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: 0.0,
              child: Container(color: Colors.black.withValues(alpha: 0.35)),
            ),
          ),
          Positioned(
            right: 6,
            bottom: 6,
            child: Icon(Icons.play_circle_fill_rounded,
                color: cs.primary, size: 22),
          ),
        ],
      ),
    );
  }
}

class _GenresGrid extends StatelessWidget {
  const _GenresGrid();

  static const _genres = [
    'Electronic',
    'Ambient',
    'Synthwave',
    'Rock',
    'Hip-Hop',
    'Jazz',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 92,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _genres.length,
      itemBuilder: (context, i) {
        final g = _genres[i];
        return InkWell(
          onTap: () => Navigator.pushNamed(context, '/search', arguments: g),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary.withValues(alpha: 0.10),
                  Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.55),
                ],
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                g,
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomSpacerHint extends StatelessWidget {
  const _BottomSpacerHint({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.18)),
      ),
      child: Text(
        'Dica: toque em um resultado para ver detalhes e ouvir o preview de 30s.',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}


