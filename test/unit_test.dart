import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unitune/domain/entities/song.dart';
import 'package:unitune/data/services/itunes_service.dart';

void main() {
  group('Song entity', () {
    test('fromItunesJson parses a track correctly', () {
      final json = {
        'trackId': 123456,
        'trackName': 'Bohemian Rhapsody',
        'artistName': 'Queen',
        'collectionName': 'A Night at the Opera',
        'artworkUrl100':
            'https://example.com/artwork/100x100bb.jpg',
        'previewUrl': 'https://example.com/preview.m4a',
        'primaryGenreName': 'Rock',
        'trackExplicitness': 'notExplicit',
        'wrapperType': 'track',
      };

      final song = Song.fromItunesJson(json);

      expect(song.trackId, '123456');
      expect(song.trackName, 'Bohemian Rhapsody');
      expect(song.artistName, 'Queen');
      expect(song.albumName, 'A Night at the Opera');
      expect(song.isExplicit, isFalse);
      expect(song.genre, 'Rock');
      // Artwork URL should be upgraded to 300x300
      expect(song.artworkUrl, contains('300x300'));
    });

    test('fromItunesJson marks explicit tracks', () {
      final json = {
        'trackId': 999,
        'trackName': 'Explicit Track',
        'artistName': 'Some Artist',
        'collectionName': 'Some Album',
        'trackExplicitness': 'explicit',
      };

      final song = Song.fromItunesJson(json);
      expect(song.isExplicit, isTrue);
    });

    test('toMap / fromMap round-trip preserves all fields', () {
      const original = Song(
        id: 1,
        trackId: 'abc',
        trackName: 'Test Song',
        artistName: 'Test Artist',
        albumName: 'Test Album',
        artworkUrl: 'https://example.com/art.jpg',
        previewUrl: 'https://example.com/preview.m4a',
        genre: 'Pop',
        isExplicit: true,
        suggestToRadio: true,
      );

      final map = original.toMap();
      final restored = Song.fromMap(map);

      expect(restored.trackId, original.trackId);
      expect(restored.trackName, original.trackName);
      expect(restored.artistName, original.artistName);
      expect(restored.albumName, original.albumName);
      expect(restored.artworkUrl, original.artworkUrl);
      expect(restored.previewUrl, original.previewUrl);
      expect(restored.genre, original.genre);
      expect(restored.isExplicit, original.isExplicit);
      expect(restored.suggestToRadio, original.suggestToRadio);
    });

    test('copyWith updates only specified fields', () {
      const song = Song(
        trackId: 'x1',
        trackName: 'Original',
        artistName: 'Artist',
        albumName: 'Album',
      );

      final updated = song.copyWith(
        trackName: 'Updated',
        suggestToRadio: true,
      );

      expect(updated.trackName, 'Updated');
      expect(updated.suggestToRadio, isTrue);
      expect(updated.trackId, song.trackId);
      expect(updated.artistName, song.artistName);
    });

    test('equality is based on trackId', () {
      const a = Song(
          trackId: 'same',
          trackName: 'A',
          artistName: 'X',
          albumName: 'Y');
      const b = Song(
          trackId: 'same',
          trackName: 'B',
          artistName: 'Z',
          albumName: 'W');
      const c = Song(
          trackId: 'different',
          trackName: 'A',
          artistName: 'X',
          albumName: 'Y');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('ItunesService entity parameter', () {
    /// Builds a minimal iTunes API response containing one track result.
    String _fakeResponse() => jsonEncode({
          'resultCount': 1,
          'results': [
            {
              'wrapperType': 'track',
              'trackId': 1,
              'trackName': 'Track',
              'artistName': 'Artist',
              'collectionName': 'Album',
              'trackExplicitness': 'notExplicit',
            }
          ]
        });

    test('uses "musicTrack" entity for SearchType.song', () async {
      Uri? capturedUri;
      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(_fakeResponse(), 200);
      });

      final service = ItunesService(client: mockClient);
      await service.searchSongs(query: 'test', type: SearchType.song);

      expect(capturedUri?.queryParameters['entity'], 'musicTrack');
    });

    test('uses "musicArtist" entity for SearchType.artist', () async {
      Uri? capturedUri;
      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(_fakeResponse(), 200);
      });

      final service = ItunesService(client: mockClient);
      await service.searchSongs(query: 'test', type: SearchType.artist);

      expect(capturedUri?.queryParameters['entity'], 'musicArtist');
    });

    test('uses "album" entity for SearchType.album', () async {
      Uri? capturedUri;
      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(_fakeResponse(), 200);
      });

      final service = ItunesService(client: mockClient);
      await service.searchSongs(query: 'test', type: SearchType.album);

      expect(capturedUri?.queryParameters['entity'], 'album');
    });

    test('passes explicit=No when allowExplicit is false', () async {
      Uri? capturedUri;
      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(_fakeResponse(), 200);
      });

      final service = ItunesService(client: mockClient);
      await service.searchSongs(
          query: 'test', type: SearchType.song, allowExplicit: false);

      expect(capturedUri?.queryParameters['explicit'], 'No');
    });

    test('throws ItunesServiceException on non-200 status', () async {
      final mockClient = MockClient(
          (_) async => http.Response('Server Error', 500));

      final service = ItunesService(client: mockClient);

      expect(
        () => service.searchSongs(query: 'test'),
        throwsA(isA<ItunesServiceException>()),
      );
    });
  });
}
