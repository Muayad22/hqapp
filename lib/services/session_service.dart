import 'package:shared_preferences/shared_preferences.dart';


class SessionService {
  SessionService._();

  static const _keyUserId = 'hq_session_user_id';

  static Future<void> saveSession(String userId) async {
    if (userId.isEmpty || userId == 'guest') return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }

  static Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyUserId);
    if (id == null || id.isEmpty || id == 'guest') return null;
    return id;
  }
}
