import 'package:shared_preferences/shared_preferences.dart';
import 'itunes_service.dart';

/// Keys used in [SharedPreferences].
class _Keys {
  static const String searchType = 'search_type';
  static const String allowExplicit = 'allow_explicit';
}

/// Service that persists and retrieves user search preferences.
class PreferencesService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Saves the selected [SearchType].
  Future<void> saveSearchType(SearchType type) async {
    final prefs = await _preferences;
    await prefs.setInt(_Keys.searchType, type.index);
  }

  /// Loads the saved [SearchType]. Defaults to [SearchType.song].
  Future<SearchType> loadSearchType() async {
    final prefs = await _preferences;
    final index = prefs.getInt(_Keys.searchType) ?? SearchType.song.index;
    return SearchType.values[index];
  }

  /// Saves whether explicit content is allowed.
  Future<void> saveAllowExplicit(bool allow) async {
    final prefs = await _preferences;
    await prefs.setBool(_Keys.allowExplicit, allow);
  }

  /// Loads the explicit-content preference. Defaults to `true`.
  Future<bool> loadAllowExplicit() async {
    final prefs = await _preferences;
    return prefs.getBool(_Keys.allowExplicit) ?? true;
  }
}
