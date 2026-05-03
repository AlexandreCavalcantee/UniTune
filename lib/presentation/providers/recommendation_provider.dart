import 'package:flutter/foundation.dart';
import '../../data/services/itunes_service.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/song.dart';
import '../../presentation/providers/playlist_provider.dart';

class RecommendationProvider extends ChangeNotifier {
  final ItunesService _itunesService;
  PlaylistProvider? _playlistProvider;

  List<Album> _albums = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _activeGenre;

  RecommendationProvider({ItunesService? itunesService})
      : _itunesService = itunesService ?? ItunesService();

  List<Album> get albums => _albums;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void attachPlaylist(PlaylistProvider playlistProvider) {
    if (identical(_playlistProvider, playlistProvider)) return;
    _playlistProvider?.removeListener(_onPlaylistChanged);
    _playlistProvider = playlistProvider;
    _playlistProvider?.addListener(_onPlaylistChanged);
    _refreshRecommendations();
  }

  void _onPlaylistChanged() {
    _refreshRecommendations();
  }

  Future<void> _refreshRecommendations() async {
    final playlist = _playlistProvider?.songs ?? [];
    final genres = _extractTopGenres(playlist);
    final genre = genres.isEmpty ? null : genres.first;

    if (genre == null) {
      _albums = [];
      _activeGenre = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (genre == _activeGenre && _albums.isNotEmpty) return;

    _activeGenre = genre;
    _isLoading = true;
    _errorMessage = null;
    _albums = [];
    notifyListeners();

    try {
      _albums = await _itunesService.searchAlbums(
        query: genre,
        limit: 8,
      );
    } catch (_) {
      _errorMessage = 'Não foi possível carregar recomendações de álbum.';
      _albums = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> _extractTopGenres(List<Song> playlist) {
    final counts = <String, int>{};
    for (final song in playlist) {
      final genre = song.genre?.trim();
      if (genre == null || genre.isEmpty) continue;
      counts[genre] = (counts[genre] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.key).toList(growable: false);
  }

  @override
  void dispose() {
    _playlistProvider?.removeListener(_onPlaylistChanged);
    _itunesService.dispose();
    super.dispose();
  }
}
