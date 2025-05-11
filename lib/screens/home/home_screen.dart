import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import 'package:software_development/widgets/task_window.dart';
import 'package:software_development/widgets/task_schedule.dart';
import 'package:software_development/widgets/profile_icon_settings.dart';
import 'package:software_development/widgets/task_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int visibleTaskCount = 10;
  File? _profileImage;
  String userName = "";
  final userId = FirebaseAuth.instance.currentUser?.uid;
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  List<Map<String, dynamic>> _cachedTasks = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _fetchUserName();
    _enableFirestoreOffline();
    _fetchTasks();
  }

  Future<void> _enableFirestoreOffline() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image');
    if (path != null && mounted) {
      setState(() => _profileImage = File(path));
    }
  }

  Future<void> _fetchUserName() async {
    if (userId == null) return;
    final userSnap = await FirebaseFirestore.instance
        .collection('userData')
        .doc(userId)
        .get();
    if (userSnap.exists && mounted) {
      final data = userSnap.data();
      final firstName = data?['firstName'] ?? '';
      setState(() => userName = firstName);
    }
  }

  Future<void> _fetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTasksJson = prefs.getString('cached_tasks');
    if (cachedTasksJson != null && mounted) {
      final tasks = List<Map<String, dynamic>>.from(jsonDecode(cachedTasksJson));
      setState(() {
        _cachedTasks = tasks;
        isLoading = false;
      });
    }

    if (userId == null) {
      setState(() {
        error = 'Please sign in';
        isLoading = false;
      });
      return;
    }

    try {
      final tasks = await _fetchAllTasks();
      await prefs.setString('cached_tasks', jsonEncode(tasks));
      if (mounted) {
        setState(() {
          _cachedTasks = tasks;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Error loading tasks';
          isLoading = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllTasks() async {
    if (userId == null) return [];

    final List<Map<String, dynamic>> allTasks = [];

    final userDocRef = FirebaseFirestore.instance
        .collection('userData')
        .doc(userId);

    final userDocSnapshot = await userDocRef.get();
    if (!userDocSnapshot.exists) return [];

    final toolsSnapshot = await userDocRef.collection('tools').get();
    if (toolsSnapshot.docs.isEmpty) return [];

    for (final toolDoc in toolsSnapshot.docs) {
      final toolId = toolDoc.id;

      final tasksSnapshot = await userDocRef
          .collection('tools')
          .doc(toolId)
          .collection('tasks')
          .get();

      for (final taskDoc in tasksSnapshot.docs) {
        final data = taskDoc.data();
        allTasks.add({
          'taskType': toolId,
          'title': data['title'] ?? '',
          'priority': data['priority'] ?? 'Low',
        });
      }
    }

    return allTasks;
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search Tasks',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        onChanged: (query) {
          setState(() {
            searchQuery = query;
          });
        },
      ),
    );
  }

  int _priorityToInt(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return 0;
      case 'medium':
        return 1;
      case 'high':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    if (isLoading && _cachedTasks.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredTasks = _cachedTasks
        .where((task) =>
        task['title'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    filteredTasks.sort((a, b) =>
        _priorityToInt(b['priority']).compareTo(_priorityToInt(a['priority'])));

    final visibleTasks = filteredTasks.take(visibleTaskCount).toList();

    return Scaffold(
      backgroundColor: const Color(0xF0F6F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hi $userName",
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ProfileIconSettings(
                    profileImage: _profileImage,
                    userName: userName,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                height: screenHeight * 0.45,
                child: TaskSchedule(),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "My Tasks",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildSearchBar(),
              SizedBox(height: screenHeight * 0.02),
              if (filteredTasks.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                    child: Text(
                      "No tasks found.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    Container(
                      height: screenHeight * 0.4,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: visibleTasks.length,
                        itemBuilder: (context, index) {
                          final task = visibleTasks[index];
                          final title = task['title'];
                          final taskType = task['taskType'];
                          final priority = task['priority'];

                          return Padding(
                            padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                            child: TaskButtonBar(
                              taskTitle: title,
                              taskType: taskType,
                              taskPriority: priority,
                              onPressed: () {
                                // Placeholder for opening task details screen
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    if (visibleTasks.length < filteredTasks.length)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            visibleTaskCount += 10;
                          });
                        },
                        child: Text(
                          'Load More',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => TaskWindow(),
          );

          if (result == true) {
            setState(() {
              isLoading = true;
              _cachedTasks = []; // Clear cache to force refetch
            });
            _fetchTasks(); // Refetch tasks after adding a new one
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}