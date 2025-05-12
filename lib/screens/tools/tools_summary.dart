import 'package:flutter/material.dart';
import 'dart:math' as math;

class MySummary extends StatelessWidget {
  final String selectedTool;
  final Map<String, Map<String, String>> summaryStats;
  final List<String> toolOptions;
  final ValueChanged<String> onToolChanged;

  const MySummary({
    super.key,
    required this.selectedTool,
    required this.summaryStats,
    required this.toolOptions,
    required this.onToolChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = math.min(14.0, screenHeight * 0.022);
    final padding = math.min(12.0, screenWidth * 0.03);

    print('MySummary - selectedTool: $selectedTool, toolOptions: $toolOptions'); // Debug log

    // Fallback if selectedTool is not in toolOptions
    final validSelectedTool = toolOptions.contains(selectedTool) ? selectedTool : toolOptions[0];

    // Compute aggregate values if 'All' is selected
    final Map<String, String> displayStats = validSelectedTool == 'All'
        ? _computeTotalStats(summaryStats)
        : summaryStats[validSelectedTool] ?? summaryStats['All']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: padding),
        // Dropdown with outline, half width
        Container(
          width: screenWidth * 0.5, // Half screen width
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: validSelectedTool,
            underline: const SizedBox.shrink(),
            onChanged: (value) {
              if (value != null) onToolChanged(value);
            },
            items: toolOptions.map((tool) {
              return DropdownMenuItem(
                value: tool,
                child: Text(
                  tool,
                  style: TextStyle(
                    fontSize: fontSize,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              );
            }).toList(),
            isExpanded: true,
          ),
        ),
        SizedBox(height: padding),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: padding,
          mainAxisSpacing: padding,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.8, // Adjusted for taller, narrower cards
          children: _universalLabels.map((label) {
            final value = displayStats[label] ?? '0';
            return _StatCard(
              label: label,
              value: value,
              fontSize: fontSize,
              padding: padding,
            );
          }).toList(),
        ),
      ],
    );
  }

  static const _universalLabels = [
    'Total Task',
    'Task this month',
    'Task Completed',
    'On going',
  ];

  Map<String, String> _computeTotalStats(Map<String, Map<String, String>> stats) {
    final totals = <String, int>{
      for (var label in _universalLabels) label: 0,
    };

    // Exclude 'All' to avoid double-counting
    for (var entry in stats.entries.where((entry) => entry.key != 'All')) {
      for (var label in _universalLabels) {
        final value = int.tryParse(entry.value[label] ?? '0') ?? 0;
        totals[label] = (totals[label] ?? 0) + value;
      }
    }

    return {
      for (var entry in totals.entries) entry.key: entry.value.toString(),
    };
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final double fontSize;
  final double padding;

  const _StatCard({
    required this.label,
    required this.value,
    required this.fontSize,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
          SizedBox(height: padding / 2),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize + 2,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}