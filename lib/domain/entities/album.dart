/// Domain entity representing an album returned by the iTunes Search API.
class Album {
  final String collectionId;
  final String artistName;
  final String collectionName;
  final String primaryGenreName;
  final String artworkUrl;
  final String collectionViewUrl;
  final DateTime? releaseDate;
  final int trackCount;
  final double? collectionPrice;

  const Album({
    required this.collectionId,
    required this.artistName,
    required this.collectionName,
    required this.primaryGenreName,
    required this.artworkUrl,
    required this.collectionViewUrl,
    this.releaseDate,
    required this.trackCount,
    this.collectionPrice,
  });

  factory Album.fromItunesJson(Map<String, dynamic> json) {
    return Album(
      collectionId: json['collectionId']?.toString() ?? '',
      artistName: json['artistName'] as String? ?? 'Unknown Artist',
      collectionName: json['collectionName'] as String? ?? 'Unknown Album',
      primaryGenreName: json['primaryGenreName'] as String? ?? 'Unknown Genre',
      artworkUrl: (json['artworkUrl100'] as String?)?.replaceFirst(
            '100x100',
            '300x300',
          ) ?? '',
      collectionViewUrl: json['collectionViewUrl'] as String? ?? '',
      releaseDate: json['releaseDate'] != null
          ? DateTime.tryParse(json['releaseDate'] as String)
          : null,
      trackCount: json['trackCount'] as int? ?? 0,
      collectionPrice: (json['collectionPrice'] as num?)?.toDouble(),
    );
  }
}
