import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/itunes_service.dart';
import '../../domain/entities/song.dart';
import '../providers/search_provider.dart';
import '../providers/playlist_provider.dart';
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
          appBar: AppBar(
            title: const Text('UniTune'),
            actions: [
              IconButton(
                icon: const Icon(Icons.playlist_play),
                tooltip: 'My Playlist',
                onPressed: () => Navigator.pushNamed(context, '/playlist'),
              ),
            ],
          ),
          body: Column(
            children: [
              _SearchBar(
                controller: _controller,
                onSearch: () => _onSearch(provider),
              ),
              _FilterRow(provider: provider),
              const Divider(height: 1),
              Expanded(child: _ResultsList(provider: provider)),
            ],
          ),
        );
      },
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onSearch,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search artists, albums, songs…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onSearch,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(14),
            ),
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}

// ── Filter row ─────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.provider});

  final SearchProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // Radio buttons for search type
          _TypeRadio(
            label: 'Song',
            value: SearchType.song,
            groupValue: provider.searchType,
            onChanged: provider.setSearchType,
          ),
          _TypeRadio(
            label: 'Artist',
            value: SearchType.artist,
            groupValue: provider.searchType,
            onChanged: provider.setSearchType,
          ),
          _TypeRadio(
            label: 'Album',
            value: SearchType.album,
            groupValue: provider.searchType,
            onChanged: provider.setSearchType,
          ),
          const Spacer(),
          // Explicit content switch
          const Text('Explicit'),
          Switch(
            value: provider.allowExplicit,
            onChanged: provider.setAllowExplicit,
          ),
        ],
      ),
    );
  }
}

class _TypeRadio extends StatelessWidget {
  const _TypeRadio({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final SearchType value;
  final SearchType groupValue;
  final ValueChanged<SearchType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<SearchType>(
          value: value,
          groupValue: groupValue,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
        Text(label),
      ],
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
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            provider.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (provider.results.isEmpty) {
      return const Center(
        child: Text(
          'Search for your favorite music above.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: _AlbumArtThumbnail(url: song.artworkUrl),
        title: Text(
          song.trackName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${song.artistName} • ${song.albumName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (song.isExplicit)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: _ExplicitBadge(),
              ),
            IconButton(
              icon: Icon(
                playlistProvider.contains(song.trackId)
                    ? Icons.playlist_add_check
                    : Icons.playlist_add,
              ),
              tooltip: playlistProvider.contains(song.trackId)
                  ? 'In playlist'
                  : 'Add to playlist',
              onPressed: playlistProvider.contains(song.trackId)
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen(song: song),
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
    if (url == null) {
      return const _PlaceholderArt(size: 48);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        url!,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _PlaceholderArt(size: 48),
      ),
    );
  }
}

class _PlaceholderArt extends StatelessWidget {
  const _PlaceholderArt({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: Icon(Icons.music_note, size: size * 0.5, color: Colors.grey[600]),
    );
  }
}

class _ExplicitBadge extends StatelessWidget {
  const _ExplicitBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(2),
      ),
      child: const Text(
        'E',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
