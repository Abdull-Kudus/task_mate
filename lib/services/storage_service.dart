import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../models/team_member.dart';

class StorageService {
  static const _tasksKey = 'tasks';
  static const _membersKey = 'members';
  static const _userKey = 'currentUserId';
  static const _emailKey = 'currentEmail';

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_tasksKey), Task.fromJson);
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_tasksKey, raw);
  }

  static Future<List<TeamMember>> loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_membersKey), TeamMember.fromJson);
  }

  static Future<void> saveMembers(List<TeamMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(members.map((m) => m.toJson()).toList());
    await prefs.setString(_membersKey, raw);
  }

  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey) ?? '';
  }

  static Future<void> signIn(String memberId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, memberId);
    await prefs.setString(_emailKey, email);
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_emailKey);
  }

  // Turns saved JSON text back into a list of objects.
  static List<T> _decodeList<T>(
    String? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Saved data is unreadable: start empty instead of crashing.
      return [];
    }
  }

  // First launch only: add the sample members and tasks.
  static Future<void> seedIfEmpty() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_membersKey)) return;

    await saveMembers([
      TeamMember(id: 'm1', name: 'Abdul Karim', role: 'Project Manager'),
      TeamMember(id: 'm2', name: 'Chris Otieno', role: 'UI/UX Designer'),
      TeamMember(id: 'm3', name: 'Methode Habimana', role: 'Mobile Developer'),
      TeamMember(id: 'm4', name: 'Ama Owusu', role: 'QA Tester'),
      TeamMember(id: 'm5', name: 'Jessica Moyo', role: 'Documentation'),
    ]);

    final today = DateTime.now();
    const low = TaskPriority.low;
    const medium = TaskPriority.medium;
    const high = TaskPriority.high;
    const todo = TaskStatus.todo;
    const doing = TaskStatus.inProgress;
    const done = TaskStatus.done;

    // days: due date counted from today (negative means in the past).
    Task make(String id, String title, String category, String assigneeId,
            TaskPriority priority, TaskStatus status, int days) =>
        Task(
          id: id,
          title: title,
          category: category,
          assigneeId: assigneeId,
          priority: priority,
          status: status,
          dueDate: today.add(Duration(days: days)),
        );

    await saveTasks([
      make('101', 'Design login screen', 'UI Design', 'm2', medium, done, -4),
      make('102', 'Create task model', 'Development', 'm3', high, done, -3),
      make('103', 'Set up project repository', 'Development', 'm1', medium,
          done, -5),
      make('104', 'Define SLA rules', 'Planning', 'm1', high, done, -5),
      make('105', 'Design dashboard', 'UI Design', 'm2', medium, done, -2),
      make('106', 'Build task list screen', 'Development', 'm3', medium, done,
          -1),
      make('107', 'Create test plan', 'Testing', 'm4', low, done, -4),
      make('108', 'Write user guide outline', 'Documentation', 'm5', low, done,
          -1),
      make('109', 'Implement local storage', 'Development', 'm3', high, doing,
          2),
      make('110', 'Test application', 'Testing', 'm4', medium, todo, 1),
      make('111', 'Write technical report', 'Documentation', 'm5', medium,
          doing, -1),
      make('112', 'Prepare demo', 'Planning', 'm1', medium, todo, 8),
    ]);
  }
}
