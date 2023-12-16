import 'package:shared_preferences/shared_preferences.dart';

class SharedServices {
  final token = 'token';

  Future<String?> getToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(token);
  }

  Future<bool> saveToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(token, token);
  }

  Future<bool> deleteToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.remove(token);
  }
}
