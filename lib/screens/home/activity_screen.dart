import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:software_development/screens/tools/tools_summary.dart';
import 'package:software_development/screens/tools/tools_metric.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String selectedTool = 'All';
  List<String> toolTypes = [];
  List<QuerySnapshot> taskSnapshots = [];
  bool isLoading = true;
  String? error;

  // Dynamic colors for tools
  final List<Color> _toolColors = [
    const Color(0xFFFF8CDE),
    const Color(0xFF8BC9FF),
    const Color(0xFF8BDAFF),
    const Color(0xFFFFA500),
    const Color(0xFF800080),
    const Color(0xFF00FF00),
    const Color(0xFFFF0000),
    const Color(0xFF00CED1),
  ];

  Color _colorForTool(String tool, int index) {
    return _toolColors[index % _toolColors.length];
  }

  // Bar chart data builder
  List<BarChartGroupData> _buildBarData(Map<String, Map<String, int>> taskStats) {
    final stats = taskStats[selectedTool] ?? taskStats['All']!;
    return [
      _bar(0, stats['created']?.toDouble() ?? 0),
      _bar(1, stats['completed']?.toDouble() ?? 0),
      _bar(2, stats['ongoing']?.toDouble() ?? 0),
    ];
  }

  BarChartGroupData _bar(int x, double y) => BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
          toY: y, width: 20, borderRadius: BorderRadius.circular(4)),
    ],
  );

  List<String> _barLabels() {
    return ['Total', 'Done', 'Ongoing'];
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    if (userID == null) {
      setState(() {
        error = 'Please sign in';
        isLoading = false;
      });
      return;
    }

    try {
      // Fetch tool types
      final toolsSnapshot = await FirebaseFirestore.instance
          .collection('userData')
          .doc(userID)
          .collection('tools')
          .get();
      toolTypes = toolsSnapshot.docs.map((doc) => doc.id).toList();

      // Fetch tasks for each tool
      taskSnapshots = await Future.wait(
        toolTypes.map((toolType) => FirebaseFirestore.instance
            .collection('userData')
            .doc(userID)
            .collection('tools')
            .doc(toolType)
            .collection('tasks')
            .get()),
      );

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading data';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final userID = FirebaseAuth.instance.currentUser?.uid;

    if (userID == null || error != null) {
      return Scaffold(
        body: Center(child: Text(error ?? 'Please sign in')),
      );
    }

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Process tasks
    final taskCounts = <String, int>{};
    final summaryStats = <String, Map<String, int>>{};
    final displayToolTypes = <String>[];

    // Map toolType to display name
    final toolDisplayNames = {
      'todo': 'To-do List',
      'gym': 'Gym',
      'waterReminder': 'Water Reminder',
      'workout': 'Workout',
      'dietPlan': 'Diet Plan',
    };

    // Initialize 'All' stats
    summaryStats['All'] = {
      'created': 0,
      'completed': 0,
      'ongoing': 0,
      'thisMonth': 0,
    };

    // Process each tool's tasks
    for (var i = 0; i < toolTypes.length; i++) {
      final toolType = toolTypes[i];
      final tasks = taskSnapshots[i].docs;
      final displayName = toolDisplayNames[toolType] ?? toolType.capitalize();

      if (displayToolTypes.contains(displayName)) {
        print('Duplicate display name: $displayName for toolType: $toolType');
        continue;
      }

      taskCounts[displayName] = tasks.length;
      displayToolTypes.add(displayName);

      summaryStats[displayName] = {
        'created': 0,
        'completed': 0,
        'ongoing': 0,
        'thisMonth': 0,
      };

      for (var doc in tasks) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String? ?? 'created';
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

        summaryStats[displayName]!['created'] = summaryStats[displayName]!['created']! + 1;
        summaryStats['All']!['created'] = summaryStats['All']!['created']! + 1;

        if (status == 'completed') {
          summaryStats[displayName]!['completed'] = summaryStats[displayName]!['completed']! + 1;
          summaryStats['All']!['completed'] = summaryStats['All']!['completed']! + 1;
        } else if (status == 'ongoing') {
          summaryStats[displayName]!['ongoing'] = summaryStats[displayName]!['ongoing']! + 1;
          summaryStats['All']!['ongoing'] = summaryStats['All']!['ongoing']! + 1;
        }

        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        if (createdAt.isAfter(startOfMonth)) {
          summaryStats[displayName]!['thisMonth'] = summaryStats[displayName]!['thisMonth']! + 1;
          summaryStats['All']!['thisMonth'] = summaryStats['All']!['thisMonth']! + 1;
        }
      }
    }

    // Pie chart sections
    List<PieChartSectionData> _buildPieSections() {
      if (taskCounts.isEmpty) {
        return [
          PieChartSectionData(
            color: Colors.grey,
            value: 1,
            title: 'No Tasks (0.0%)',
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            radius: 70,
          )
        ];
      }

      final total = taskCounts.values.fold(0, (a, b) => a + b).toDouble();
      return taskCounts.entries.toList().asMap().entries.map((entry) {
        final index = entry.key;
        final e = entry.value;
        final isActive = selectedTool == 'All' || e.key == selectedTool;
        final color = _colorForTool(e.key, index).withOpacity(isActive ? 1 : 0.3);
        final percent = (e.value / (total == 0 ? 1 : total) * 100).toStringAsFixed(1);
        return PieChartSectionData(
          color: color,
          value: e.value.toDouble(),
          title: e.value > 0 ? '$percent%' : '',
          titleStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          radius: 70,
        );
      }).toList();
    }

    final totalTasks = taskCounts.values.fold(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: const Color(0xF0F6F9FF),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 52, 24, math.min(24, screenHeight * 0.03)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              child: Text(
                'My Activity',
                style: TextStyle(
                    fontSize: math.min(24, screenHeight * 0.04),
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: math.min(24, screenHeight * 0.03)),
            Container(
              width: screenWidth - 48,
              height: math.min(screenHeight * 0.35, 280),
              padding: EdgeInsets.all(math.min(12, screenWidth * 0.03)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6))
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                        sections: _buildPieSections(),
                        centerSpaceRadius: math.min(55, screenWidth * 0.12),
                        sectionsSpace: 4),
                    swapAnimationDuration: const Duration(milliseconds: 500),
                    swapAnimationCurve: Curves.easeInOut,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Tasks',
                          style: TextStyle(color: Colors.grey)),
                      Text('$totalTasks',
                          style: TextStyle(
                              fontSize: math.min(20, screenHeight * 0.03),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: math.min(24, screenHeight * 0.03)),
            Center(
              child: Wrap(
                spacing: math.min(16, screenWidth * 0.04),
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: taskCounts.isEmpty
                    ? [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                      const Text('No Tasks',
                          style: TextStyle(fontSize: 14)),
                    ],
                  )
                ]
                    : taskCounts.keys.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final tool = entry.value;
                  final isActive =
                      selectedTool == 'All' || selectedTool == tool;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                            color: _colorForTool(tool, index)
                                .withOpacity(isActive ? 1 : 0.3),
                            borderRadius: BorderRadius.circular(2)),
                      ),
                      Text(tool, style: const TextStyle(fontSize: 14)),
                    ],
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: math.min(56, screenHeight * 0.07)),
            MySummary(
              selectedTool: selectedTool,
              summaryStats: summaryStats.map((key, value) => MapEntry(key, {
                'Total Task': value['created'].toString(),
                'Task this month': value['thisMonth'].toString(),
                'Task Completed': value['completed'].toString(),
                'On going': value['ongoing'].toString(),
              })),
              toolOptions: ['All', ...displayToolTypes],
              onToolChanged: (tool) => setState(() => selectedTool = tool),
            ),
            SizedBox(height: math.min(40, screenHeight * 0.05)),
            const Divider(thickness: 2),
            ToolsStatistics(
              selectedTool: selectedTool,
              summaryStats: summaryStats.map((key, value) => MapEntry(key, {
                'Total Task': value['created'].toString(),
                'Task this month': value['thisMonth'].toString(),
                'Task Completed': value['completed'].toString(),
                'On going': value['ongoing'].toString(),
              })),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to capitalize tool names
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}