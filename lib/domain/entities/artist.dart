/// Domain entity representing an artist returned by the iTunes Search API.
class Artist {
  final String artistId;
  final String artistName;
  final String? primaryGenre;
  final String? artistLinkUrl;

  const Artist({
    required this.artistId,
    required this.artistName,
    this.primaryGenre,
    this.artistLinkUrl,
  });

  /// Creates an [Artist] from a raw iTunes API result map.
  factory Artist.fromItunesJson(Map<String, dynamic> json) {
    return Artist(
      artistId: json['artistId']?.toString() ?? '',
      artistName: json['artistName'] as String? ?? 'Unknown Artist',
      primaryGenre: json['primaryGenreName'] as String?,
      artistLinkUrl: json['artistLinkUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Artist &&
          runtimeType == other.runtimeType &&
          artistId == other.artistId;

  @override
  int get hashCode => artistId.hashCode;

  @override
  String toString() =>
      'Artist(artistId: $artistId, artistName: $artistName)';
}
