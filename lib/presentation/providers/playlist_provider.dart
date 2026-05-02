import 'package:flutter/foundation.dart';
import '../../data/services/preferences_service.dart';
import '../../domain/entities/song.dart';

/// State for the Playlist/Library screen.
class PlaylistProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  PlaylistProvider({PreferencesService? prefs})
      : _prefs = prefs ?? PreferencesService() {
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

  /// Loads all saved songs from local storage.
  Future<void> loadPlaylist() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _songs = await _prefs.loadPlaylist();
    } catch (e) {
      _errorMessage = 'Could not load playlist.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds [song] to the playlist if not already present.
  Future<void> addSong(Song song) async {
    if (contains(song.trackId)) return;
    final id = DateTime.now().millisecondsSinceEpoch;
    final songWithId = song.copyWith(id: id);
    _songs.insert(0, songWithId);
    notifyListeners();
    try {
      await _prefs.savePlaylist(_songs);
    } catch (_) {}
  }

  /// Returns true if a song with [trackId] is already in the playlist.
  bool contains(String trackId) => _songs.any((s) => s.trackId == trackId);

  /// Removes the song identified by [id] from the playlist.
  Future<void> removeSong(int id) async {
    _songs.removeWhere((s) => s.id == id);
    notifyListeners();
    try {
      await _prefs.savePlaylist(_songs);
    } catch (_) {}
  }

  /// Toggles the "suggest to radio" flag for a song.
  Future<void> toggleSuggestToRadio(Song song) async {
    if (song.id == null) return;
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index == -1) return;
    _songs[index] = song.copyWith(suggestToRadio: !song.suggestToRadio);
    notifyListeners();
    try {
      await _prefs.savePlaylist(_songs);
    } catch (_) {}
  }
}
