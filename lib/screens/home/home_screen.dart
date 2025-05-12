import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:software_development/widgets/task_window.dart';
import 'package:software_development/widgets/profile_icon_settings.dart';
import 'package:software_development/screens/tools/reusable_tools/task_viewer.dart';

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
  Map<String, int> _toolTaskCounts = {};
  bool isLoading = true;
  String? error;
  Map<String, bool> _expandedTasks = {};

  // Map Firestore tool IDs to display names
  final Map<String, String> _toolDisplayNames = {
    'todo': 'To-do',
    'gym': 'Gym',
    'waterreminder': 'Water Reminder',
    'workout': 'Workout',
    'dietplan': 'Diet',
    'customplan': 'Custom Plan',
  };

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
      final toolCounts = await _fetchToolTaskCounts();
      await prefs.setString('cached_tasks', jsonEncode(tasks));
      if (mounted) {
        setState(() {
          _cachedTasks = tasks;
          _toolTaskCounts = toolCounts;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Error loading tasks: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllTasks() async {
    if (userId == null) return [];

    final List<Map<String, dynamic>> allTasks = [];

    final userDocRef = FirebaseFirestore.instance.collection('userData').doc(userId);
    final userDocSnapshot = await userDocRef.get();
    if (!userDocSnapshot.exists) return [];

    final toolsSnapshot = await userDocRef.collection('tools').get();
    if (toolsSnapshot.docs.isEmpty) return [];

    for (final toolDoc in toolsSnapshot.docs) {
      final toolId = toolDoc.id;
      final displayName = _toolDisplayNames[toolId.toLowerCase()] ?? toolId;
      final tasksSnapshot = await userDocRef
          .collection('tools')
          .doc(toolId)
          .collection('tasks')
          .get();

      for (final taskDoc in tasksSnapshot.docs) {
        final data = taskDoc.data();
        final isCompleted = data['completed'] != null ? data['completed'] as bool : false;
        allTasks.add({
          'taskId': taskDoc.id,
          'taskType': displayName, // Use display name for consistency
          'title': data['title'] ?? '',
          'priority': data['priority'] ?? 'Low',
          'completed': isCompleted,
        });
      }
    }

    return allTasks;
  }

  Future<Map<String, int>> _fetchToolTaskCounts() async {
    if (userId == null) return {};

    final Map<String, int> toolCounts = {};
    final userDocRef = FirebaseFirestore.instance.collection('userData').doc(userId);
    final userDocSnapshot = await userDocRef.get();
    if (!userDocSnapshot.exists) return {};

    final toolsSnapshot = await userDocRef.collection('tools').get();
    if (toolsSnapshot.docs.isEmpty) return {};

    // Initialize counts for all defined tools
    final tools = ['To-do', 'Workout', 'Water Reminder', 'Diet', 'Custom Plan'];
    for (var tool in tools) {
      toolCounts[tool] = 0;
    }

    // Fetch tasks for each tool and map to display names
    for (var toolDoc in toolsSnapshot.docs) {
      final toolId = toolDoc.id.toLowerCase();
      final displayName = _toolDisplayNames[toolId] ?? toolId;
      if (!tools.contains(displayName)) continue; // Skip unmapped tools

      final tasksSnapshot = await userDocRef
          .collection('tools')
          .doc(toolId)
          .collection('tasks')
          .get();

      toolCounts[displayName] = tasksSnapshot.docs.length;
    }

    return toolCounts;
  }

  Future<void> _deleteTask(String taskId, String taskType) async {
    if (userId == null) return;

    // Map display name back to Firestore toolId
    final toolId = _toolDisplayNames.entries
        .firstWhere((entry) => entry.value == taskType, orElse: () => MapEntry(taskType.toLowerCase(), taskType))
        .key;

    await FirebaseFirestore.instance
        .collection('userData')
        .doc(userId)
        .collection('tools')
        .doc(toolId)
        .collection('tasks')
        .doc(taskId)
        .delete();

    setState(() {
      _cachedTasks.removeWhere((task) => task['taskId'] == taskId);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_tasks', jsonEncode(_cachedTasks));
    _fetchToolTaskCounts().then((counts) {
      setState(() {
        _toolTaskCounts = counts;
      });
    });
  }

  Future<void> _markAsDone(String taskId) async {
    if (userId == null) return;

    final task = _cachedTasks.firstWhere((task) => task['taskId'] == taskId);
    final taskType = task['taskType'];
    final toolId = _toolDisplayNames.entries
        .firstWhere((entry) => entry.value == taskType, orElse: () => MapEntry(taskType.toLowerCase(), taskType))
        .key;

    final taskRef = FirebaseFirestore.instance
        .collection('userData')
        .doc(userId)
        .collection('tools')
        .doc(toolId)
        .collection('tasks')
        .doc(taskId);

    await taskRef.update({'completed': true});

    setState(() {
      _cachedTasks.removeWhere((task) => task['taskId'] == taskId);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_tasks', jsonEncode(_cachedTasks));
    _fetchToolTaskCounts().then((counts) {
      setState(() {
        _toolTaskCounts = counts;
      });
    });
  }

  Widget _buildSearchBar(bool isEnabled) {
    return Container(
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _searchController,
        enabled: isEnabled,
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

  Color _getCategoryColor(String tool) {
    switch (tool.toLowerCase()) {
      case 'to-do':
        return Color(0xFFbbcfff);
      case 'workout':
        return Color(0xFFb9c0ff);
      case 'water reminder':
        return Color(0xFFc8b6ff);
      case 'diet':
        return Color(0xFFe7c6ff);
      case 'custom plan':
        return Color(0xFFffd6ff);
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.black87;
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

    final tools = ['To-do', 'Workout', 'Water Reminder', 'Diet', 'Custom Plan'];

    final filteredTasks = _cachedTasks
        .where((task) =>
    !(task['completed'] as bool) &&
        task['title'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    filteredTasks.sort((a, b) =>
        _priorityToInt(b['priority']).compareTo(_priorityToInt(a['priority'])));

    final visibleTasks = filteredTasks.take(visibleTaskCount).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFf2faff),
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
                      fontSize: screenWidth * 0.1,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_none, size: screenWidth * 0.06, color: Colors.black87),
                        onPressed: () {
                          // Handle notification click
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          // Open profile/logout window
                        },
                        child: ProfileIconSettings(
                          profileImage: _profileImage,
                          userName: userName,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.030),
                  Text(
                    "Welcome to Bracelyte, here's your task summary",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              Text(
                "CATEGORY",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                height: screenHeight * 0.16,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tools.length,
                  itemBuilder: (context, index) {
                    final tool = tools[index];
                    final color = _getCategoryColor(tool);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskViewer(category: tool),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: screenWidth * 0.03),
                        child: Container(
                          width: screenWidth * 0.35,
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tool,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                "${_toolTaskCounts[tool] ?? 0} tasks",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              Text(
                "TODAY'S TASKS",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              _buildSearchBar(filteredTasks.isNotEmpty),
              SizedBox(height: screenHeight * 0.02),

              if (filteredTasks.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                    child: Text(
                      "No specific task today",
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
                          final taskId = task['taskId'];
                          final title = task['title'];
                          final taskType = task['taskType'];
                          final priority = task['priority'];
                          final isExpanded = _expandedTasks[taskId] ?? false;
                          final color = _getCategoryColor(taskType);

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                            child: GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  _expandedTasks[taskId] = !(_expandedTasks[taskId] ?? false);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [color.withOpacity(1.0), Colors.white],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (!isExpanded)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              taskType,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            width: screenWidth * 0.55,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              textDirection: TextDirection.rtl,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.cancel, color: Colors.black87, size: screenWidth * 0.06),
                                                  onPressed: () {
                                                    setState(() {
                                                      _expandedTasks[taskId] = false;
                                                    });
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.check, color: Colors.black87, size: screenWidth * 0.06),
                                                  onPressed: () {
                                                    _markAsDone(taskId);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete, color: Colors.black87, size: screenWidth * 0.06),
                                                  onPressed: () {
                                                    _deleteTask(taskId, taskType);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.edit, color: Colors.black87, size: screenWidth * 0.06),
                                                  onPressed: () {
                                                    // Handle edit
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (!isExpanded)
                                      Text(
                                        priority,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: _getPriorityColor(priority),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
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
                          style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.blue),
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
            builder: (_) => const TaskWindow(),
          );

          if (result == true) {
            setState(() {
              isLoading = true;
              _cachedTasks = [];
            });
            _fetchTasks();
          }
        },
        backgroundColor: const Color(0xFF00BFFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}