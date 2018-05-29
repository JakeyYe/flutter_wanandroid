import '../common/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getCookie() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('set-cookie');
}

setCookie(String cookie) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('set-cookie', cookie);
}
