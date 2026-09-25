import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getData(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<void> saveData(String key, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value.toString());
}

Future<void> clearData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}