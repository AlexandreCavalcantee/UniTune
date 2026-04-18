import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/song.dart';
import '../providers/playlist_provider.dart';
import 'details_screen.dart';

/// Screen showing all locally-saved songs with "suggest to radio" toggles.
class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Playlist'),
            actions: [
              if (provider.songs.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.radio),
                  tooltip: 'Suggested to radio',
                  onPressed: () {
                    final count =
                        provider.songs.where((s) => s.suggestToRadio).length;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '$count track(s) suggested to the radio.'),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: _PlaylistBody(provider: provider),
        );
      },
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────

class _PlaylistBody extends StatelessWidget {
  const _PlaylistBody({required this.provider});

  final PlaylistProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Text(
          provider.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (provider.songs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Your playlist is empty.\nSearch for a song and tap ➕ to add it here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.songs.length,
      itemBuilder: (context, index) {
        final song = provider.songs[index];
        return _PlaylistTile(song: song, provider: provider);
      },
    );
  }
}

// ── Playlist tile ──────────────────────────────────────────────────────────

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({required this.song, required this.provider});

  final Song song;
  final PlaylistProvider provider;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: _AlbumThumb(url: song.artworkUrl),
        title: Text(
          song.trackName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              song.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Checkbox(
                  value: song.suggestToRadio,
                  onChanged: (_) => provider.toggleSuggestToRadio(song),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Text(
                  'Suggest to radio',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'Remove',
          onPressed: () async {
            if (song.id != null) {
              await provider.removeSong(song.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('"${song.trackName}" removed from playlist'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
        ),
        isThreeLine: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailsScreen(song: song)),
        ),
      ),
    );
  }
}

// ── Album thumbnail ────────────────────────────────────────────────────────

class _AlbumThumb extends StatelessWidget {
  const _AlbumThumb({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(
        width: 48,
        height: 48,
        color: Colors.grey[300],
        child: Icon(Icons.music_note, color: Colors.grey[600]),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        url!,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 48,
          height: 48,
          color: Colors.grey[300],
          child: Icon(Icons.music_note, color: Colors.grey[600]),
        ),
      ),
    );
  }
}
