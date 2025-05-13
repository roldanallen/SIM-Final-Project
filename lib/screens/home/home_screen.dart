import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:software_development/widgets/task_window.dart';
import 'package:software_development/widgets/profile_icon_settings.dart';
import 'package:software_development/screens/tools/reusable_tools/task_viewer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

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

  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _enableFirestoreOffline();
    _loadProfileImage();
    _loadCachedUserName();
    _loadCachedTasksAndCounts();
    _initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
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

  Future<void> _loadCachedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedName = prefs.getString('userName');
    if (cachedName != null && mounted) {
      setState(() => userName = cachedName);
    }
  }

  Future<void> _loadCachedTasksAndCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTasksJson = prefs.getString('cached_tasks');
    if (cachedTasksJson != null && mounted) {
      final tasks = List<Map<String, dynamic>>.from(jsonDecode(cachedTasksJson));
      setState(() {
        _cachedTasks = tasks;
        _toolTaskCounts = _calculateToolTaskCounts(tasks);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false); // Show UI with empty data if no cache
    }
  }

  Map<String, int> _calculateToolTaskCounts(List<Map<String, dynamic>> tasks) {
    final Map<String, int> counts = {};
    final tools = ['To-do', 'Workout', 'Water Reminder', 'Diet', 'Custom Plan'];
    for (var tool in tools) {
      counts[tool] = tasks.where((task) => task['taskType'] == tool).length;
    }
    return counts;
  }

  Future<void> _fetchUserName() async {
    if (userId == null) return;
    try {
      final userSnap = await FirebaseFirestore.instance
          .collection('userData')
          .doc(userId)
          .get();
      if (userSnap.exists && mounted) {
        final data = userSnap.data();
        final firstName = data?['firstName'] ?? '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', firstName);
        setState(() => userName = firstName);
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = 'Error fetching username: $e');
      }
    }
  }

  Future<void> _fetchTasks() async {
    if (userId == null) {
      setState(() {
        error = 'Please sign in';
        isLoading = false;
      });
      return;
    }

    try {
      final tasks = await _fetchAllTasks();
      final toolCounts = _calculateToolTaskCounts(tasks); // Use cached tasks for consistency
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_tasks', jsonEncode(tasks));
      if (mounted) {
        setState(() {
          _cachedTasks = tasks;
          _toolTaskCounts = toolCounts;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Error loading tasks: $e';
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
          'taskType': displayName,
          'title': data['title'] ?? '',
          'priority': data['priority'] ?? 'Low',
          'completed': isCompleted,
        });
      }
    }

    return allTasks;
  }

  Future<void> _deleteTask(String taskId, String taskType) async {
    if (userId == null) return;

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
      _toolTaskCounts = _calculateToolTaskCounts(_cachedTasks);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_tasks', jsonEncode(_cachedTasks));
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
      _toolTaskCounts = _calculateToolTaskCounts(_cachedTasks);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_tasks', jsonEncode(_cachedTasks));
  }

  Widget _buildSearchBar(bool isEnabled) {
    return Container(
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
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
        return const Color(0xFFB7B1F2);
      case 'workout':
        return const Color(0xFFFDB7EA);
      case 'water reminder':
        return const Color(0xFFFFDCCC);
      case 'diet':
        return const Color(0xFFFBF3B9);
      case 'custom plan':
        return const Color(0xFFffd6ff);
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

  Future<void> _initConnectivity() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOnline = connectivityResults.any((result) =>
        result == ConnectivityResult.wifi || result == ConnectivityResult.mobile);
      });
    }

    if (_isOnline) {
      _fetchUserName();
      _fetchTasks();
    }

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (mounted) {
        setState(() {
          _isOnline = results.any((result) =>
          result == ConnectivityResult.wifi || result == ConnectivityResult.mobile);
        });
        if (_isOnline) {
          _fetchUserName();
          _fetchTasks();
        }
      }
    });
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

    if (isLoading && _cachedTasks.isEmpty && userName.isEmpty) {
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
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                "${_toolTaskCounts[tool] ?? 0} tasks",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.black45,
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

              _buildSearchBar(_cachedTasks.isNotEmpty),
              SizedBox(height: screenHeight * 0.02),

              if (visibleTasks.isEmpty && _cachedTasks.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                  child: Center(
                    child: Text(
                      'No tasks found',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                )
              else if (_cachedTasks.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                    child: Text(
                      'No specific task today',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey.shade600,
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
                                      color: Colors.black26,
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