import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';

class TaskStorage {
  static const String key = 'tasks';

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(key);
    if (savedData != null) {
      final List decoded = json.decode(savedData);
      return decoded.map((e) => Task.fromMap(e)).toList();
    }
    return [];
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(tasks.map((e) => e.toMap()).toList());
    await prefs.setString(key, encoded);
  }
}
