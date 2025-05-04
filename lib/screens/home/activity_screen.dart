import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:software_development/screens/tools/tools_summary.dart';
import 'package:software_development/screens/tools/tools_metric.dart';// Import MySummary

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String selectedTool = 'All';

  // Data for pie chart and summary
  final Map<String, int> taskCounts = {
    'To-do List': 4,
    'Gym': 2,
    'Water Reminder': 1,
  };

  final Map<String, Map<String, String>> summaryStats = {
    'To-do List': {
      'Total Task': '5',
      'Task this month': '8',
      'Task Completed': '4',
      'On going': '1',
    },
    'Gym': {
      'Total Task': '2',
      'Task this month': '2',
      'Task Completed': '1',
      'On going': '1',
    },
    'Water Reminder': {
      'Total Task': '4',
      'Task this month': '2',
      'Task Completed': '3',
      'On going': '1',
    },
  };


  // Bar chart data builder
  List<BarChartGroupData> _buildBarData() {
    switch (selectedTool) {
      case 'To-do List':
        return [
          _bar(0, 4), // Created
          _bar(1, 2), // Completed
          _bar(2, 2), // Ongoing
        ];
      case 'Gym':
        return [
          _bar(0, 2),   // Sessions
          _bar(1, 1),   // Missed
          _bar(2, 350), // Calories
        ];
      case 'Water Reminder':
        return [
          _bar(0, 1), // Logs
          _bar(1, 5), // Avg Intake
          _bar(2, 8), // Best Day
        ];
      default: // All
        return [
          _bar(0, 10), // Created (sum of all)
          _bar(1, 5), // Completed (sum of To‑do + Gym)
          _bar(2, 3), // Missed/Ongoing
        ];
    }
  }

  BarChartGroupData _bar(int x, double y) => BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(toY: y, width: 20, borderRadius: BorderRadius.circular(4)),
    ],
  );

  List<String> _barLabels() {
    switch (selectedTool) {
      case 'To-do List':
        return ['Created', 'Done', 'Ongoing'];
      case 'Gym':
        return ['Sessions', 'Missed', 'Calories'];
      case 'Water Reminder':
        return ['Logs', 'Avg', 'Best'];
      default:
        return ['Created', 'Done', 'Missed'];
    }
  }

  // Pie chart sections
  List<PieChartSectionData> _buildPieSections() {
    final total = taskCounts.values.fold(0, (a, b) => a + b).toDouble();
    return taskCounts.entries.map((e) {
      final isActive = selectedTool == 'All' || e.key == selectedTool;
      final color = _colorForTool(e.key).withOpacity(isActive ? 1 : 0.3);
      final percent = (e.value / (total == 0 ? 1 : total) * 100).toStringAsFixed(1);
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: e.value > 0 ? '$percent%' : '',
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        radius: 70,
      );
    }).toList();
  }

  // Base color per tool
  Color _colorForTool(String tool) {
    switch (tool) {
      case 'To-do List':
        return const Color(0xFFFF8CDE);
      case 'Gym':
        return const Color(0xFF8BC9FF);
      case 'Water Reminder':
        return const Color(0xFF8BDAFF);
      default:
        return Colors.grey;
    }
  }

  // Callback to update selectedTool
  void _updateSelectedTool(String tool) {
    setState(() {
      selectedTool = tool;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = taskCounts.values.fold(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: const Color(0xF0F6F9FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 52, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pie Chart
            const Text('My Activity', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 280,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 12, offset: Offset(0, 6))],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(sections: _buildPieSections(), centerSpaceRadius: 55, sectionsSpace: 4),
                    swapAnimationDuration: const Duration(milliseconds: 500),
                    swapAnimationCurve: Curves.easeInOut,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Tasks', style: TextStyle(color: Colors.grey)),
                      Text('$totalTasks', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: taskCounts.keys.map((tool) {
                  final isActive = selectedTool == 'All' || selectedTool == tool;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 12, height: 12, margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(color: _colorForTool(tool).withOpacity(isActive?1:0.3), borderRadius: BorderRadius.circular(2)),
                      ),
                      Text(tool, style: const TextStyle(fontSize: 14)),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 56),
            // My Summary (integrating MySummary widget)
            MySummary(
              selectedTool: selectedTool,
              summaryStats: summaryStats,
              onToolChanged: (tool) => setState(() => selectedTool = tool),
            ),

            const SizedBox(height: 40),
            const Divider(thickness: 2),

            ToolsStatistics(
              selectedTool: selectedTool,
              summaryStats: summaryStats,
            ),
          ],
        ),
      ),
    );
  }
}
