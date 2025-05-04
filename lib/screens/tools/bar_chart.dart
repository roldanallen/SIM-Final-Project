import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartSection extends StatelessWidget {
  final String selectedTool;

  const BarChartSection({Key? key, required this.selectedTool}) : super(key: key);

  List<BarChartGroupData> _getBarGroups() {
    switch (selectedTool) {
      case 'Gym':
        return [
          _barGroup(0, 3), // Sessions
          _barGroup(1, 1), // Missed
          _barGroup(2, 350), // Calories
        ];
      case 'Water Reminder':
        return [
          _barGroup(0, 5), // Daily Avg
          _barGroup(1, 8), // Best Day
          _barGroup(2, 1), // Streak
        ];
      case 'To-do List':
        return [
          _barGroup(0, 4), // Created
          _barGroup(1, 2), // Completed
          _barGroup(2, 2), // Ongoing
        ];
      case 'All':
      default:
        return [
          _barGroup(0, 7), // Total Created
          _barGroup(1, 4), // Completed
          _barGroup(2, 3), // Missed or Ongoing
        ];
    }
  }

  List<String> _getTitles() {
    switch (selectedTool) {
      case 'Gym':
        return ['Sessions', 'Missed', 'Calories'];
      case 'Water Reminder':
        return ['Avg', 'Best', 'Streak'];
      case 'To-do List':
        return ['Created', 'Done', 'Ongoing'];
      case 'All':
      default:
        return ['Created', 'Done', 'Missed'];
    }
  }

  BarChartGroupData _barGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blueAccent,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = _getTitles();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          height: 250,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              barGroups: _getBarGroups(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, interval: 1),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          index >= 0 && index < titles.length ? titles[index] : '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              barTouchData: BarTouchData(enabled: false),
              maxY: selectedTool == 'Gym' ? 400 : 10,
            ),
          ),
        ),
      ],
    );
  }
}
