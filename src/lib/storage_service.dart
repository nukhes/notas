import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String notesKey = "notes";

  Future<void> saveNotes(List<Map<String, String>> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(notesKey, jsonEncode(notes));
  }

  Future<List<Map<String, String>>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(notesKey);
    if (data != null && data.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => Map<String, String>.from(e)).toList();
    }
    return [];
  }
}
