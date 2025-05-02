import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xF0F6F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Creative Tools',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              _buildToolButton(
                context,
                title: 'To-do List',
                description: 'Create and manage your daily tasks.',
                color: const Color(0xFFFF8CDE),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TodoToolPage()),
                ),
              ),
              _buildToolButton(
                context,
                title: 'Workout Plan',
                description: 'Plan and track your workouts.',
                color: const Color(0xFFD88BFF),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkoutToolPage()),
                ),
              ),
              _buildToolButton(
                context,
                title: 'Diet Plan',
                description: 'Log meals and maintain a healthy diet.',
                color: const Color(0xFF8BACFF),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DietToolPage()),
                ),
              ),
              _buildToolButton(
                context,
                title: 'Gym',
                description: 'Track gym sessions and progress.',
                color: const Color(0xFF8BC9FF),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GymToolPage()),
                ),
              ),
              _buildToolButton(
                context,
                title: 'Water Reminder',
                description: 'Stay hydrated with reminders.',
                color: const Color(0xFF8BDAFF),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WaterToolPage()),
                ),
              ),
              _buildToolButton(
                context,
                title: 'Custom Plan',
                description: 'Design your own personal plans.',
                color: const Color(0xFF8BFFC7),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomToolPage()),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton(
      BuildContext context, {
        required String title,
        required String description,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
