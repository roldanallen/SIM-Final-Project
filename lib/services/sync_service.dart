import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  static Future<void> initialize() async {
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        await _syncPendingTasks();
      }
    });
  }

  static Future<void> _syncPendingTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    List<String> pendingTasks = prefs.getStringList('pending_tasks') ?? [];
    if (pendingTasks.isEmpty) return;

    List<String> updatedPendingTasks = [];
    for (String taskJson in pendingTasks) {
      final task = jsonDecode(taskJson);
      if (task['synced'] == false) {
        try {
          // Save to Firestore
          await FirebaseFirestore.instance
              .collection('userData')
              .doc(userId)
              .collection('tools')
              .doc('todo')
              .collection('tasks')
              .add({
            ...task,
            'createdAt': Timestamp.fromDate(DateTime.parse(task['createdAt'])),
            'synced': true,
          });
          task['synced'] = true;
        } catch (e) {
          print('Error syncing task: $e');
        }
      }
      updatedPendingTasks.add(jsonEncode(task));
    }

    // Update pending_tasks
    await prefs.setStringList('pending_tasks', updatedPendingTasks);

    // Refresh cached_tasks for HomeScreen
    List<Map<String, dynamic>> cachedTasks = [];
    final cachedTasksJson = prefs.getString('cached_tasks');
    if (cachedTasksJson != null) {
      cachedTasks = List<Map<String, dynamic>>.from(jsonDecode(cachedTasksJson));
    }
    for (var taskJson in updatedPendingTasks) {
      final task = jsonDecode(taskJson);
      if (!cachedTasks.any((t) =>
      t['title'] == task['title'] && t['taskType'] == task['taskType'])) {
        cachedTasks.add({
          'taskType': task['taskType'],
          'title': task['title'],
          'priority': task['priority'],
        });
      }
    }
    await prefs.setString('cached_tasks', jsonEncode(cachedTasks));
  }
}