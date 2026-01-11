import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyIsLogin = 'is_login';
  static const String _keyUsername = 'username';
  static const String _keyLastLogin = 'last_login';

  static Future<void> saveSession(String username) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(_keyIsLogin, true);
    await pref.setString(_keyUsername, username);
    await pref.setString(_keyLastLogin, DateTime.now().toString());
    print('✅ Session Saved: $username login at ${DateTime.now()}');
  }

  static Future<bool> isLoggedIn() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(_keyIsLogin) ?? false;
  }

  static Future<String?> getUsername() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_keyUsername);
  }

  static Future<void> clearSession() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(_keyIsLogin);
    await pref.remove(_keyUsername); 
    print('🚀 Session Cleared: User Logged Out');
  }
}