import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static PreferencesService? _instance;
  static SharedPreferences? _preferences;
  static bool _initialized = false;
  static final Future<PreferencesService> _initFuture = _initInstance();

  static const String _keyFirstTime = 'isFirstTime';

  PreferencesService._();
  static PreferencesService get I {
    if (!_initialized) {
      throw StateError(
          'PreferencesService has not been initialized. Use await PreferencesService.instance before using PreferencesService.I');
    }
    return _instance!;
  }

  static Future<PreferencesService> get instance => _initFuture;

  static Future<PreferencesService> _initInstance() async {
    if (!_initialized) {
      _instance = PreferencesService._();
      _preferences = await SharedPreferences.getInstance();
      _initialized = true;
    }
    return _instance!;
  }

  bool get isFirstTime {
    return _preferences?.getBool(_keyFirstTime) ?? true;
  }

  Future<void> setFirstTime(bool value) async {
    await _preferences?.setBool(_keyFirstTime, value);
  }
}
