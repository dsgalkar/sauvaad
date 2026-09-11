import 'package:shared_preferences/shared_preferences.dart';

/// ZegoConfig manages ZEGOCLOUD AppID and AppSign.
/// Users can obtain their AppID and AppSign for free from:
/// https://console.zegocloud.com/
class ZegoConfig {
  static const String _keyAppId = 'zego_app_id';
  static const String _keyAppSign = 'zego_app_sign';

  // Live ZEGOCLOUD Credentials
  static const int defaultAppID = 933357530;
  static const String defaultAppSign =
      '60ccc1c282f712c1317bfac8176c61c8f8834202cc96d7e022ed06c3431454e0';

  static int _cachedAppId = defaultAppID;
  static String _cachedAppSign = defaultAppSign;
  static bool _isLoaded = false;

  /// Loads saved AppID & AppSign from local storage.
  static Future<void> init() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    _cachedAppId = prefs.getInt(_keyAppId) ?? defaultAppID;
    _cachedAppSign = prefs.getString(_keyAppSign) ?? defaultAppSign;
    _isLoaded = true;
  }

  static int get appId => _cachedAppId;
  static String get appSign => _cachedAppSign;

  /// Whether custom credentials are live
  static bool get isCustomConfigured => true;

  /// Save new AppID and AppSign
  static Future<void> saveCredentials(int newAppId, String newAppSign) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAppId, newAppId);
    await prefs.setString(_keyAppSign, newAppSign.trim());
    _cachedAppId = newAppId;
    _cachedAppSign = newAppSign.trim();
  }

  /// Reset to default placeholders
  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAppId);
    await prefs.remove(_keyAppSign);
    _cachedAppId = defaultAppID;
    _cachedAppSign = defaultAppSign;
  }
}
