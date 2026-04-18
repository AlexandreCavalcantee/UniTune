import 'package:flutter/foundation.dart';
import '../../data/services/itunes_service.dart';
import '../../data/services/preferences_service.dart';
import '../../domain/entities/song.dart';

/// State for the Search screen.
class SearchProvider extends ChangeNotifier {
  final ItunesService _itunesService;
  final PreferencesService _prefsService;

  SearchProvider({
    ItunesService? itunesService,
    PreferencesService? prefsService,
  })  : _itunesService = itunesService ?? ItunesService(),
        _prefsService = prefsService ?? PreferencesService() {
    _loadPreferences();
  }

  // ── State ────────────────────────────────────────────────────────────────

  List<Song> _results = [];
  bool _isLoading = false;
  String? _errorMessage;
  SearchType _searchType = SearchType.song;
  bool _allowExplicit = true;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<Song> get results => _results;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SearchType get searchType => _searchType;
  bool get allowExplicit => _allowExplicit;

  // ── Public Methods ───────────────────────────────────────────────────────

  /// Perform a search with the current settings.
  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

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

  /// Clears the current results.
  void clearResults() {
    _results = [];
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private ──────────────────────────────────────────────────────────────

  Future<void> _loadPreferences() async {
    _searchType = await _prefsService.loadSearchType();
    _allowExplicit = await _prefsService.loadAllowExplicit();
    notifyListeners();
  }

  @override
  void dispose() {
    _itunesService.dispose();
    super.dispose();
  }
}
