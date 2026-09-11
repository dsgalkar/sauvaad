/// ZegoConfig securely stores ZEGOCLOUD AppID and AppSign.
/// These credentials are used automatically and never shown to end users.
class ZegoConfig {
  // Live ZEGOCLOUD Credentials
  static const int defaultAppID = 933357530;
  static const String defaultAppSign =
      '60ccc1c282f712c1317bfac8176c61c8f8834202cc96d7e022ed06c3431454e0';

  static int get appId => defaultAppID;
  static String get appSign => defaultAppSign;

  static Future<void> init() async {
    // No-op: Credentials are securely built into the app
  }
}
