import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ToolsStatistics extends StatelessWidget {
  final String selectedTool;
  final Map<String, Map<String, String>> summaryStats;

  const ToolsStatistics({
    super.key,
    required this.selectedTool,
    required this.summaryStats,
  });

  @override
  Widget build(BuildContext context) {
    final isAll = selectedTool == 'All';
    final displayStats = isAll
        ? _computeTotalStats(summaryStats)
        : summaryStats[selectedTool]!;

    // Extract the three values we want to chart
    final created = int.tryParse(displayStats['Total Task'] ?? '0') ?? 0;
    final completed = int.tryParse(displayStats['Task Completed'] ?? '0') ?? 0;
    final ongoing = int.tryParse(displayStats['On going'] ?? '0') ?? 0;

    final taskStats = <String, int>{
      'Total': created,
      'Completed': completed,
      'Ongoing': ongoing,
    };

    // Determine the highest bar
    final maxVal = [created, completed, ongoing].reduce((a, b) => a > b ? a : b);

    // Decide on interval and axis max
    final int interval;
    final double axisMax;
    if (maxVal <= 8) {
      interval = 1;
      axisMax = 8.0;
    } else {
      interval = 2;
      axisMax = ((maxVal / interval).ceil() * interval).toDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text('Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        // Bar Chart
        Container(
          width: double.infinity,
          height: 260,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 12,
                  offset: Offset(0, 6))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AspectRatio(
              aspectRatio: 1.4,
              child: BarChart(
                BarChartData(
                  maxY: axisMax,
                  barGroups: _buildBarData(taskStats),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval.toDouble(),
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final labels = ['Total', 'Completed', 'Ongoing'];
                          final idx = value.toInt();
                          return Text(
                            idx < labels.length ? labels[idx] : '',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),
        ),
        // Details
        const SizedBox(height: 24),
        const Text('Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          children: displayStats.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarData(Map<String, int> stats) => [
    for (var i = 0; i < stats.length; i++)
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: stats.values.elementAt(i).toDouble(),
            width: 22,
            color: [Colors.blue, Colors.green, Colors.orange][i],
            borderRadius: BorderRadius.zero,
          )
        ],
      ),
  ];

  Map<String, String> _computeTotalStats(Map<String, Map<String, String>> stats) {
    final totals = <String, int>{};
    // Exclude 'All' to avoid double-counting
    for (var entry in stats.entries.where((entry) => entry.key != 'All')) {
      for (var stat in entry.value.entries) {
        totals[stat.key] = (totals[stat.key] ?? 0) + (int.tryParse(stat.value) ?? 0);
      }
    }
    return totals.map((k, v) => MapEntry(k, v.toString()));
  }
}