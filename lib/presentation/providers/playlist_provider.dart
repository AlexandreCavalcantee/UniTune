import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/services/preferences_service.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/playlist.dart';

/// State for managing multiple playlists.
class PlaylistProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  PlaylistProvider({PreferencesService? prefs})
      : _prefs = prefs ?? PreferencesService() {
    loadPlaylists();
  }

  // ── State ────────────────────────────────────────────────────────────────

  List<Playlist> _playlists = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _activePlaylistId;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Playlist? get activePlaylist => _activePlaylistId != null
      ? _playlists.firstWhereOrNull((p) => p.id == _activePlaylistId)
      : null;

  /// For backward compatibility: returns songs from active/first playlist
  List<Song> get songs {
    if (_playlists.isEmpty) return [];
    final playlist = activePlaylist ?? _playlists.first;
    return playlist.songs;
  }

  // ── Public Methods ───────────────────────────────────────────────────────

  /// Loads all playlists from local storage.
  Future<void> loadPlaylists() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _playlists = await _prefs.loadPlaylists();
      if (_playlists.isEmpty) {
        _playlists = [
          Playlist(
            id: const Uuid().v4(),
            name: 'Favoritas',
            songs: [],
          ),
        ];
        await _prefs.savePlaylists(_playlists);
      }
      _activePlaylistId = _playlists.first.id;
    } catch (e) {
      _errorMessage = 'Não foi possível carregar as playlists.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// For backward compatibility with old system
  Future<void> loadPlaylist() async => loadPlaylists();

  /// Creates a new playlist with the given name.
  Future<void> createPlaylist(String name) async {
    final newPlaylist = Playlist(
      id: const Uuid().v4(),
      name: name.trim().isEmpty ? 'Nova Playlist' : name.trim(),
      songs: [],
    );
    _playlists.add(newPlaylist);
    _activePlaylistId = newPlaylist.id;
    notifyListeners();
    try {
      await _prefs.savePlaylists(_playlists);
    } catch (_) {}
  }

  /// Renames a playlist.
  Future<void> renamePlaylist(String playlistId, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;
    _playlists[index] = _playlists[index].copyWith(name: newName);
    notifyListeners();
    try {
      await _prefs.savePlaylists(_playlists);
    } catch (_) {}
  }

  /// Deletes a playlist by ID.
  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    if (_activePlaylistId == playlistId) {
      _activePlaylistId = _playlists.isNotEmpty ? _playlists.first.id : null;
    }
    notifyListeners();
    try {
      await _prefs.savePlaylists(_playlists);
    } catch (_) {}
  }

  /// Sets the active playlist.
  void setActivePlaylist(String playlistId) {
    if (_playlists.any((p) => p.id == playlistId)) {
      _activePlaylistId = playlistId;
      notifyListeners();
    }
  }

  /// Adds a song to a specific playlist if not already present.
  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _playlists[index];
    if (playlist.songs.any((s) => s.trackId == song.trackId)) return;

    final id = DateTime.now().millisecondsSinceEpoch;
    final songWithId = song.copyWith(id: id);
    final newSongs = [songWithId, ...playlist.songs];
    _playlists[index] = playlist.copyWith(songs: newSongs);
    notifyListeners();

    try {
      await _prefs.savePlaylists(_playlists);
    } catch (_) {}
  }

  /// Adds [song] to the active playlist if not already present.
  Future<void> addSong(Song song) async {
    if (_activePlaylistId == null) return;
    await addSongToPlaylist(_activePlaylistId!, song);
  }

  /// Returns true if a song with [trackId] is in any playlist.
  bool contains(String trackId) {
    return _playlists.any((p) => p.songs.any((s) => s.trackId == trackId));
  }

  /// Returns true if a song is in a specific playlist.
  bool isInPlaylist(String playlistId, String trackId) {
    final playlist = _playlists.firstWhereOrNull((p) => p.id == playlistId);
    return playlist?.songs.any((s) => s.trackId == trackId) ?? false;
  }

  /// Removes a song by ID from a specific playlist.
  Future<void> removeSongFromPlaylist(String playlistId, int songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _playlists[index];
    final newSongs = playlist.songs.where((s) => s.id != songId).toList();
    _playlists[index] = playlist.copyWith(songs: newSongs);
    notifyListeners();

    try {
      await _prefs.savePlaylists(_playlists);
    } catch (_) {}
  }

  /// Removes the song identified by [id] from active playlist.
  Future<void> removeSong(int id) async {
    if (_activePlaylistId == null) return;
    await removeSongFromPlaylist(_activePlaylistId!, id);
  }

  /// Toggles the "suggest to radio" flag for a song in a specific playlist.
  Future<void> toggleSuggestToRadioInPlaylist(
      String playlistId, Song song) async {
    if (song.id == null) return;

    final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
    if (playlistIndex == -1) return;

    final playlist = _playlists[playlistIndex];
    final songIndex = playlist.songs.indexWhere((s) => s.id == song.id);
    if (songIndex == -1) return;

    final newSongs = [...playlist.songs];
    newSongs[songIndex] =
        song.copyWith(suggestToRadio: !song.suggestToRadio);
    _playlists[playlistIndex] = playlist.copyWith(songs: newSongs);
    notifyListeners();

    try {
      await _prefs.savePlaylists(_playlists);
    } catch (_) {}
  }

  /// Toggles the "suggest to radio" flag for a song in active playlist.
  Future<void> toggleSuggestToRadio(Song song) async {
    if (_activePlaylistId == null) return;
    await toggleSuggestToRadioInPlaylist(_activePlaylistId!, song);
  }
}

extension FirstWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
