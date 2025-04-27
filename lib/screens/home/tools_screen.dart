import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:software_development/screens/tools/todo_tool.dart';
import 'package:software_development/screens/tools/workout_tool.dart';
import 'package:software_development/screens/tools/diet_tool.dart';
import 'package:software_development/screens/tools/gym_tool.dart';
import 'package:software_development/screens/tools/water_tool.dart';
import 'package:software_development/screens/tools/custom_tool.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final extraTimes = <DateTime>[]; // replace with real task times

    return Scaffold(
      backgroundColor: const Color(0xF0F6F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Creative Tools',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Tool Buttons with navigation
              _buildToolButton(
                context,
                'To-do List',
                const Color(0xFFFF8CDE),
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TodoToolPage()),
                ),
              ),
              _buildToolButton(
                context,
                'Workout Plan',
                const Color(0xFFD88BFF),
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkoutToolPage()),
                ),
              ),
              _buildToolButton(
                context,
                'Diet Plan',
                const Color(0xFF8BACFF),
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DietToolPage()),
                ),
              ),
              _buildToolButton(
                context,
                'Gym',
                const Color(0xFF8BC9FF),
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GymToolPage()),
                ),
              ),
              _buildToolButton(
                context,
                'Water Reminder',
                const Color(0xFF8BDAFF),
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WaterToolPage()),
                ),
              ),
              _buildToolButton(
                context,
                'Custom Plan',
                const Color(0xFF8BFFC7),
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomToolPage()),
                ),
              ),

              const SizedBox(height: 32),

              // Schedule Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Schedule',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Icon(Icons.calendar_today),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMMM d').format(today),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Gantt Timeline (30-min slots, first 6 rows)
              _buildGanttTimeline(
                reference: today,
                startHour: 6,
                defaultCount: 6,
                extraTimes: extraTimes,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton(
      BuildContext context,
      String label,
      Color color,
      VoidCallback onTap,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 24),
                const Icon(Icons.circle, size: 12, color: Colors.white),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DateTime> _getTimelineTicks(
      DateTime reference, {
        int startHour = 6,
        int defaultCount = 6,
        List<DateTime> extraTimes = const [],
      }) {
    final ticks = <DateTime>[];
    for (var i = 0; i < defaultCount; i++) {
      ticks.add(
        DateTime(reference.year, reference.month, reference.day)
            .add(Duration(hours: startHour, minutes: i * 30)),
      );
    }
    for (var et in extraTimes) {
      final totalMin = et.hour * 60 + et.minute;
      final slotMin = (totalMin ~/ 30) * 30;
      final slotTime = DateTime(reference.year, reference.month, reference.day)
          .add(Duration(minutes: slotMin));
      if (!ticks.contains(slotTime)) ticks.add(slotTime);
    }
    ticks.sort();
    return ticks;
  }

  Widget _buildGanttTimeline({
    required DateTime reference,
    int startHour = 6,
    int defaultCount = 6,
    List<DateTime> extraTimes = const [],
  }) {
    final ticks = _getTimelineTicks(
      reference,
      startHour: startHour,
      defaultCount: defaultCount,
      extraTimes: extraTimes,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ticks.map((dt) {
        final label = DateFormat('h:mm a').format(dt);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(label, style: const TextStyle(fontSize: 12)),
              ),
              Expanded(child: Divider(thickness: 1.2)),
            ],
          ),
        );
      }).toList(),
    );
  }
}