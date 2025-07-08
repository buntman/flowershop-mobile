import 'package:shared_preferences/shared_preferences.dart';

class Token {
    static Future<void> storeToken(String token) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
    }

    static Future<String?> getToken() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        return prefs.getString('jwt_token');
    }

    static Future<void> removeToken() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('jwt_token');
    }
}
