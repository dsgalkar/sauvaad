import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String id;
  final String name;
  final int avatarIndex;

  const UserModel({
    required this.id,
    required this.name,
    this.avatarIndex = 0,
  });

  static const String _keyUserId = 'user_profile_id';
  static const String _keyUserName = 'user_profile_name';
  static const String _keyUserAvatar = 'user_profile_avatar';

  static Future<UserModel?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyUserId);
    final name = prefs.getString(_keyUserName);
    final avatar = prefs.getInt(_keyUserAvatar) ?? 0;

    if (id != null && name != null && id.isNotEmpty && name.isNotEmpty) {
      return UserModel(id: id, name: name, avatarIndex: avatar);
    }
    return null;
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, id);
    await prefs.setString(_keyUserName, name);
    await prefs.setInt(_keyUserAvatar, avatarIndex);
  }

  static String generateRandomUserId() {
    final random = Random();
    final number = 1000 + random.nextInt(9000);
    return 'user_$number';
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserAvatar);
  }
}
