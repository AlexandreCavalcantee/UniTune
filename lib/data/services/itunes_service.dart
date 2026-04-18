import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/song.dart';
import '../../domain/entities/artist.dart';

/// Search type used when querying the iTunes Search API.
enum SearchType { artist, album, song }

/// Service responsible for querying the iTunes Search API.
class ItunesService {
  static const String _baseUrl = 'https://itunes.apple.com/search';

  final http.Client _client;

  ItunesService({http.Client? client}) : _client = client ?? http.Client();

  /// Searches the iTunes catalogue.
  ///
  /// [query]       – the search term entered by the user.
  /// [type]        – restricts results to artists, albums, or songs.
  /// [allowExplicit] – when `false`, explicit tracks are excluded from results.
  Future<List<Song>> searchSongs({
    required String query,
    SearchType type = SearchType.song,
    bool allowExplicit = true,
  }) async {
    final entity = _entityParam(type);
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'term': query,
      'entity': entity,
      'limit': '50',
      if (!allowExplicit) 'explicit': 'No',
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ItunesServiceException(
        'iTunes API returned status ${response.statusCode}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>? ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .where((r) => r['wrapperType'] == 'track')
        .map(Song.fromItunesJson)
        .where((s) => allowExplicit || !s.isExplicit)
        .toList();
  }

  /// Searches and returns a list of artists.
  Future<List<Artist>> searchArtists(String query) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'term': query,
      'entity': 'musicArtist',
      'limit': '20',
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ItunesServiceException(
        'iTunes API returned status ${response.statusCode}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>? ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .where((r) => r['wrapperType'] == 'artist')
        .map(Artist.fromItunesJson)
        .toList();
  }

  String _entityParam(SearchType type) {
    switch (type) {
      case SearchType.artist:
        return 'musicArtist';
      case SearchType.album:
        return 'album';
      case SearchType.song:
        return 'musicTrack';
    }
  }

  void dispose() => _client.close();
}

/// Thrown when the iTunes API request fails.
class ItunesServiceException implements Exception {
  final String message;
  const ItunesServiceException(this.message);

  @override
  String toString() => 'ItunesServiceException: $message';
}
