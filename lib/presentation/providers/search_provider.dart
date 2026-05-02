import 'package:flutter/foundation.dart';
import '../../data/services/database_service.dart';
import '../../data/services/itunes_service.dart';
import '../../data/services/preferences_service.dart';
import '../../domain/entities/song.dart';

/// State for the Search screen.
class SearchProvider extends ChangeNotifier {
  final ItunesService _itunesService;
  final PreferencesService _prefsService;
  final DatabaseService _db;

  SearchProvider({
    ItunesService? itunesService,
    PreferencesService? prefsService,
    DatabaseService? db,
  })  : _itunesService = itunesService ?? ItunesService(),
        _prefsService = prefsService ?? PreferencesService(),
        _db = db ?? DatabaseService() {
    _init();
  }

  // ── State ────────────────────────────────────────────────────────────────

  List<Song> _results = [];
  List<Song> _recentHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  SearchType _searchType = SearchType.song;
  bool _allowExplicit = true;
  bool _isSearchActive = false;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<Song> get results => _results;
  List<Song> get recentHistory => _recentHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SearchType get searchType => _searchType;
  bool get allowExplicit => _allowExplicit;

  /// True when the search field has text (showing results instead of history).
  bool get isSearchActive => _isSearchActive;

  // ── Public Methods ───────────────────────────────────────────────────────

  /// Perform a search with the current settings.
  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    _isSearchActive = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _results = await _itunesService.searchSongs(
        query: query.trim(),
        type: _searchType,
        allowExplicit: _allowExplicit,
      );
    } catch (e) {
      _errorMessage = 'Search failed. Please check your connection.';
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called when the search field gains or loses text content.
  /// Shows history when [active] is false; shows results panel when true.
  void setSearchActive(bool active) {
    if (_isSearchActive == active) return;
    _isSearchActive = active;
    if (!active) {
      _results = [];
      _errorMessage = null;
    }
    notifyListeners();
  }

  /// Saves [song] to history and moves it to the top of the list.
  /// Called when the user taps on a song (opens details or plays preview).
  Future<void> addToHistory(Song song) async {
    // Update in-memory list immediately — never fails.
    _recentHistory.removeWhere((s) => s.trackId == song.trackId);
    _recentHistory.insert(0, song);
    if (_recentHistory.length > 30) {
      _recentHistory = _recentHistory.sublist(0, 30);
    }
    notifyListeners();

    // Persist via shared_preferences (works on all platforms including web).
    try {
      await _prefsService.saveRecentHistory(_recentHistory);
    } catch (_) {}

    // Also persist to SQLite for native platforms (best effort).
    try {
      await _db.upsertRecentSong(song);
    } catch (_) {}
  }

  /// Updates the search type and persists it.
  Future<void> setSearchType(SearchType type) async {
    if (_searchType == type) return;
    _searchType = type;
    await _prefsService.saveSearchType(type);
    notifyListeners();
  }

  /// Toggles explicit content filter and persists it.
  Future<void> setAllowExplicit(bool allow) async {
    _allowExplicit = allow;
    await _prefsService.saveAllowExplicit(allow);
    notifyListeners();
  }

  /// Clears active search and returns to history view.
  void clearResults() {
    _results = [];
    _errorMessage = null;
    _isSearchActive = false;
    notifyListeners();
  }

  // ── Private ──────────────────────────────────────────────────────────────

  Future<void> _init() async {
    _searchType = await _prefsService.loadSearchType();
    _allowExplicit = await _prefsService.loadAllowExplicit();
    // Load from shared_preferences (works everywhere, including web).
    try {
      _recentHistory = await _prefsService.loadRecentHistory();
    } catch (_) {}
    notifyListeners();
  }

  @override
  void dispose() {
    _itunesService.dispose();
    super.dispose();
  }
}
