import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:software_development/widgets/task_window.dart';
import 'package:software_development/widgets/task_schedule.dart';
import 'package:software_development/widgets/profile_icon_settings.dart';
import 'package:software_development/widgets/task_bar.dart'; // Import TaskButtonBar

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
  TextEditingController _searchController = TextEditingController(); // Controller for the search bar
  String searchQuery = ''; // Search query string

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _fetchUserName();
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
    if (userSnap.exists) {
      setState(() => userName = userSnap.data()?['username'] ?? '');
    }
  }

  // Method to fetch all tasks dynamically from Firestore
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

  // Updated Search bar to filter tasks
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Search Tasks',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (query) {
        setState(() {
          searchQuery = query; // Update search query as user types
        });
      },
    );
  }

  // Method to convert priority text to an integer for sorting
  int _priorityToInt(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return 0;
      case 'medium':
        return 1;
      case 'high':
        return 2;
      default:
        return 0; // Default to 'low'
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF0F6F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hi $userName",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ProfileIconSettings(
                    profileImage: _profileImage,
                    userName: userName,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: TaskSchedule(),
              ),
              const SizedBox(height: 10),
              const Text(
                "My Tasks",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildSearchBar(),

              const SizedBox(height: 10),

              // Fetching and displaying tasks
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchAllTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final tasks = snapshot.data ?? [];
                  final filteredTasks = tasks
                      .where((task) =>
                      task['title'].toLowerCase().contains(searchQuery.toLowerCase()))
                      .toList();

                  // Sort tasks by priority
                  filteredTasks.sort((a, b) {
                    return _priorityToInt(b['priority']).compareTo(_priorityToInt(a['priority']));
                  });

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          "No tasks found.",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ),
                    );
                  }

                  // Display a limited number of tasks
                  final visibleTasks = filteredTasks.take(visibleTaskCount).toList();

                  return Column(
                    children: [
                      // Wrapping the task list in a Scrollable Container
                      Container(
                        height: 400, // Set a fixed height for the scrollable area
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: visibleTasks.length,
                          itemBuilder: (context, index) {
                            final task = visibleTasks[index];
                            final title = task['title'];
                            final taskType = task['taskType'];
                            final priority = task['priority'];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
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

                      // Optional: Load more button to show more tasks
                      if (visibleTasks.length < filteredTasks.length)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              visibleTaskCount += 10; // Load more tasks
                            });
                          },
                          child: const Text('Load More'),
                        ),
                    ],
                  );
                },
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
            setState(() {}); // Refresh after adding task
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}