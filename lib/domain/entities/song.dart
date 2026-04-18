/// Domain entity representing a track returned by the iTunes Search API.
class Song {
  final int? id;
  final String trackId;
  final String trackName;
  final String artistName;
  final String albumName;
  final String? artworkUrl;
  final String? previewUrl;
  final String? genre;
  final bool isExplicit;
  final bool suggestToRadio;

  const Song({
    this.id,
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.albumName,
    this.artworkUrl,
    this.previewUrl,
    this.genre,
    this.isExplicit = false,
    this.suggestToRadio = false,
  });

  /// Creates a [Song] from a raw iTunes API result map.
  factory Song.fromItunesJson(Map<String, dynamic> json) {
    return Song(
      trackId: json['trackId']?.toString() ?? '',
      trackName: json['trackName'] as String? ?? 'Unknown Track',
      artistName: json['artistName'] as String? ?? 'Unknown Artist',
      albumName: json['collectionName'] as String? ?? 'Unknown Album',
      artworkUrl: (json['artworkUrl100'] as String?)?.replaceFirst(
        '100x100',
        '300x300',
      ),
      previewUrl: json['previewUrl'] as String?,
      genre: json['primaryGenreName'] as String?,
      isExplicit: json['trackExplicitness'] == 'explicit',
    );
  }

  /// Creates a [Song] from a local SQLite database row.
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as int?,
      trackId: map['track_id'] as String,
      trackName: map['track_name'] as String,
      artistName: map['artist_name'] as String,
      albumName: map['album_name'] as String,
      artworkUrl: map['artwork_url'] as String?,
      previewUrl: map['preview_url'] as String?,
      genre: map['genre'] as String?,
      isExplicit: (map['is_explicit'] as int? ?? 0) == 1,
      suggestToRadio: (map['suggest_to_radio'] as int? ?? 0) == 1,
    );
  }

  /// Converts this entity to a map for SQLite insertion.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'track_id': trackId,
      'track_name': trackName,
      'artist_name': artistName,
      'album_name': albumName,
      'artwork_url': artworkUrl,
      'preview_url': previewUrl,
      'genre': genre,
      'is_explicit': isExplicit ? 1 : 0,
      'suggest_to_radio': suggestToRadio ? 1 : 0,
    };
  }

  Song copyWith({
    int? id,
    String? trackId,
    String? trackName,
    String? artistName,
    String? albumName,
    String? artworkUrl,
    String? previewUrl,
    String? genre,
    bool? isExplicit,
    bool? suggestToRadio,
  }) {
    return Song(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      trackName: trackName ?? this.trackName,
      artistName: artistName ?? this.artistName,
      albumName: albumName ?? this.albumName,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      genre: genre ?? this.genre,
      isExplicit: isExplicit ?? this.isExplicit,
      suggestToRadio: suggestToRadio ?? this.suggestToRadio,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song &&
          runtimeType == other.runtimeType &&
          trackId == other.trackId;

  @override
  int get hashCode => trackId.hashCode;

  @override
  String toString() =>
      'Song(trackId: $trackId, trackName: $trackName, artist: $artistName)';
}
