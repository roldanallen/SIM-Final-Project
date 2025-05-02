import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String selectedTool = 'All';

  final Map<String, int> taskCounts = {
    'To-do List': 4,
    'Gym': 2,
    'Water Reminder': 1,
  };

  final Map<String, Map<String, String>> summaryStats = {
    'To-do List': {
      'Total Task': '4',
      'Tasks This Month': '2',
      'Completed': '2',
      'On‑going': '2',
    },
    'Gym': {
      'Total Sessions': '2',
      'This Month': '1',
      'Calories Burned': '350 kcal',
      'Missed': '1',
    },
    'Water Reminder': {
      'Total Logs': '1',
      'Daily Avg': '5 glasses',
      'Best Day': 'Apr 30 (8)',
      'Streak': '1 day',
    },
  };

  Color _colorForTool(String tool, {bool faded = false}) {
    Color color;
    switch (tool) {
      case 'To-do List':
        color = const Color(0xFFFF8CDE);
        break;
      case 'Gym':
        color = const Color(0xFF8BC9FF);
        break;
      case 'Water Reminder':
        color = const Color(0xFF8BDAFF);
        break;
      default:
        color = Colors.grey;
    }
    return faded ? color.withOpacity(0.3) : color;
  }

  List<PieChartSectionData> _buildPieSections() {
    final total = taskCounts.values.fold(0, (a, b) => a + b);

    return taskCounts.entries.map((e) {
      final percent = ((e.value / total) * 100).toStringAsFixed(1);
      final isSelected = selectedTool == 'All' || e.key == selectedTool;
      final showLabel = e.value > 0;

      return PieChartSectionData(
        color: _colorForTool(e.key, faded: !isSelected),
        value: e.value.toDouble(),
        title: showLabel ? '$percent%' : '',
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 70,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentStats = summaryStats[selectedTool == 'All' ? 'To-do List' : selectedTool]!;
    final totalTasks = taskCounts.values.fold(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: const Color(0xF0F6F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Activity',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 2),

              const Text(
                'Task Completion',
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 30),

              // ——— Chart Section ———
              Center(
                child: Container(
                  width: 500,
                  height: 300,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: _buildPieSections(),
                          centerSpaceRadius: 55,
                          sectionsSpace: 4,
                        ),
                        swapAnimationDuration: const Duration(milliseconds: 500),
                        swapAnimationCurve: Curves.easeInOut,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            '$totalTasks',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ——— Legend ———
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 10,
                  children: taskCounts.keys.map((tool) {
                    final isSelected = selectedTool == 'All' || selectedTool == tool;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: _colorForTool(tool, faded: !isSelected),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(tool, style: const TextStyle(fontSize: 14)),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 30),
              const Divider(thickness: 1.2),
              const SizedBox(height: 16),

              // ——— My Summary ———
              const Text(
                'My Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // ——— Dropdown with color box ———
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: selectedTool == 'All'
                          ? Colors.grey
                          : _colorForTool(selectedTool),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedTool,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: [
                        const DropdownMenuItem(
                          value: 'All',
                          child: Text('All'),
                        ),
                        ...taskCounts.keys.map((tool) {
                          return DropdownMenuItem(
                            value: tool,
                            child: Text(tool),
                          );
                        }),
                      ],
                      onChanged: (tool) {
                        if (tool != null) setState(() => selectedTool = tool);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ——— Summary Grid ———
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.3,
                children: currentStats.entries.map((entry) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              // Statistics
              const SizedBox(height: 50),
              const Divider(thickness: 2),
              const SizedBox(height: 24),

              const Text(
                'Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
