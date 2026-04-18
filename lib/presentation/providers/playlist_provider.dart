import 'package:flutter/foundation.dart';
import '../../data/services/database_service.dart';
import '../../domain/entities/song.dart';

/// State for the Playlist screen.
class PlaylistProvider extends ChangeNotifier {
  final DatabaseService _db;

  PlaylistProvider({DatabaseService? db})
      : _db = db ?? DatabaseService() {
    loadPlaylist();
  }

  // ── State ────────────────────────────────────────────────────────────────

  List<Song> _songs = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Public Methods ───────────────────────────────────────────────────────

  /// Loads all saved songs from the local database.
  Future<void> loadPlaylist() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _songs = await _db.getAllSongs();
    } catch (e) {
      _errorMessage = 'Could not load playlist.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds [song] to the local playlist.
  Future<void> addSong(Song song) async {
    final id = await _db.insertSong(song);
    _songs.insert(0, song.copyWith(id: id));
    notifyListeners();
  }

  /// Returns true if a song with [trackId] is already saved in the playlist.
  bool contains(String trackId) =>
      _songs.any((s) => s.trackId == trackId);

  /// Removes the song identified by [id] from the playlist.
  Future<void> removeSong(int id) async {
    await _db.deleteSong(id);
    _songs.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// Toggles the "suggest to radio" flag for a song.
  Future<void> toggleSuggestToRadio(Song song) async {
    if (song.id == null) return;

    final newValue = !song.suggestToRadio;
    await _db.updateSuggestToRadio(song.id!, suggest: newValue);

    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      _songs[index] = song.copyWith(suggestToRadio: newValue);
      notifyListeners();
    }
  }
}
