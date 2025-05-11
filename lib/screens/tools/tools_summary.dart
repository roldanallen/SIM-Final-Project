import 'package:flutter/material.dart';

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
        const Text(
          'My Summary',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Dropdown with outline, half width
        Container(
          width: MediaQuery.of(context).size.width * 0.5, // Half screen width
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
                child: Text(tool),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: _universalLabels.map((label) {
            final value = displayStats[label] ?? '0';
            return _StatCard(label: label, value: value);
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

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}