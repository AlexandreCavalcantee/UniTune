import '../../domain/entities/song.dart';

/// Represents a user-created playlist with a name and list of songs.
class Playlist {
  final String id;
  final String name;
  final List<Song> songs;

  const Playlist({
    required this.id,
    required this.name,
    required this.songs,
  });

  factory Playlist.fromMap(Map<String, dynamic> map) {
    final songsList = (map['songs'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            .map((s) => Song.fromMap(s))
            .toList() ??
        [];
    return Playlist(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Untitled',
      songs: songsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'songs': songs.map((s) => s.toMap()).toList(),
    };
  }

  Playlist copyWith({
    String? id,
    String? name,
    List<Song>? songs,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
    );
  }
}
