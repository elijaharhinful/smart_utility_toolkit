import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_model.dart';

class TasksProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get pending => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completed => _tasks.where((t) => t.isCompleted).toList();

  TasksProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks_v1');
    if (data != null) {
      _tasks = (jsonDecode(data) as List).map((e) => Task.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'tasks_v1',
      jsonEncode(_tasks.map((t) => t.toJson()).toList()),
    );
  }

  void addTask(String title, String note, String priority, DateTime? dueDate) {
    _tasks.insert(
      0,
      Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        note: note,
        priority: priority,
        dueDate: dueDate,
        createdAt: DateTime.now(),
      ),
    );
    _save();
    notifyListeners();
  }

  void updateTask(
    String id,
    String title,
    String note,
    String priority,
    DateTime? dueDate,
  ) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i != -1) {
      _tasks[i].title = title;
      _tasks[i].note = note;
      _tasks[i].priority = priority;
      _tasks[i].dueDate = dueDate;
      _save();
      notifyListeners();
    }
  }

  void toggleComplete(String id) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i != -1) {
      _tasks[i].isCompleted = !_tasks[i].isCompleted;
      _save();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }
}
