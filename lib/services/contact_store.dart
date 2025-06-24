import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ContactStore {
  static const String _key = 'emergency_contacts';

  static Future<void> saveContacts(List<Map<String, String>> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(contacts);
    await prefs.setString(_key, jsonString);
  }

  static Future<List<Map<String, String>>> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, String>.from(e)).toList();
  }
}
