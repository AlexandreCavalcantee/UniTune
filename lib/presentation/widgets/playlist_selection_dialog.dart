import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/song.dart';
import '../providers/playlist_provider.dart';

/// Shows a dialog for selecting or creating a playlist to add a song.
Future<void> showPlaylistSelectionDialog({
  required BuildContext context,
  required Song song,
}) async {
  final provider = context.read<PlaylistProvider>();
  final playlists = provider.playlists;

  if (!context.mounted) return;

  return showDialog(
    context: context,
    builder: (context) {
      String? newPlaylistName;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Adicionar à playlist',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (newPlaylistName == null)
                    SizedBox(
                      height: 200,
                      width: double.maxFinite,
                      child: ListView.builder(
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = playlists[index];
                          final isAlreadyAdded = playlist.songs
                              .any((s) => s.trackId == song.trackId);

                          return ListTile(
                            title: Text(
                              playlist.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${playlist.songs.length} músicas',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 12,
                              ),
                            ),
                            trailing: isAlreadyAdded
                                ? const Icon(Icons.check_rounded, color: Colors.green)
                                : null,
                            enabled: !isAlreadyAdded,
                            onTap: isAlreadyAdded
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    provider.addSongToPlaylist(
                                        playlist.id, song);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '"${song.trackName}" adicionada à playlist ${playlist.name}',
                                        ),
                                        duration:
                                            const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                          );
                        },
                      ),
                    )
                  else
                    Column(
                      children: [
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Nome da playlist',
                            hintStyle:
                                TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                            filled: true,
                            fillColor: const Color(0xFF0F0F12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => newPlaylistName = value);
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              if (newPlaylistName == null)
                TextButton(
                  onPressed: () {
                    setState(() => newPlaylistName = '');
                  },
                  child: const Text(
                    'Criar nova',
                    style: TextStyle(color: Colors.blue),
                  ),
                )
              else ...[
                TextButton(
                  onPressed: () {
                    setState(() => newPlaylistName = null);
                  },
                  child: const Text(
                    'Voltar',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              if (newPlaylistName != null)
                TextButton(
                  onPressed: () async {
                    final name = newPlaylistName!.trim();
                    if (name.isNotEmpty) {
                      await provider.createPlaylist(name);
                      if (provider.activePlaylist != null) {
                        await provider.addSongToPlaylist(
                          provider.activePlaylist!.id,
                          song,
                        );
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Playlist "$name" criada com "${ song.trackName}"',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Criar',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}
