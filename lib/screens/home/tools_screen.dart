import 'package:flutter/material.dart';
import 'package:software_development/screens/tools/todo_tool.dart';
import 'package:software_development/screens/tools/workout_tool.dart';
import 'package:software_development/screens/tools/diet_tool.dart';
import 'package:software_development/screens/tools/gym_tool.dart';
import 'package:software_development/screens/tools/water_tool.dart';
import 'package:software_development/screens/tools/custom_tool.dart';

class ToolsScreen extends StatefulWidget {
  final String? initialToolType;              // Keep this
  final VoidCallback? onToolHandled;          // Add this

  const ToolsScreen({
    super.key,
    this.initialToolType,
    this.onToolHandled,                       // Include it in the constructor
  });

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  @override
  void initState() {
    super.initState();

    // Automatically navigate to the specified tool page after the first frame
    if (widget.initialToolType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToToolPage(context, widget.initialToolType!);
      });
    }
  }

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
                onTap: () => _navigateToToolPage(context, 'to_do'),
                enabled: true,
              ),
              _buildToolButton(
                context,
                title: 'Workout Plan',
                description: 'Plan and track your workouts.',
                color: const Color(0xFFD88BFF),
                onTap: () => _navigateToToolPage(context, 'workout'),
                enabled: true,
              ),
              _buildToolButton(
                context,
                title: 'Diet Plan',
                description: 'Log meals and maintain a healthy diet.',
                color: const Color(0xFF8BACFF),
                onTap: () => _navigateToToolPage(context, 'diet'),
                enabled: true,
              ),
              _buildToolButton(
                context,
                title: 'Gym',
                description: 'Track gym sessions and progress.',
                color: const Color(0xFF8BC9FF),
                onTap: null, // Disabled
                enabled: false,
              ),
              _buildToolButton(
                context,
                title: 'Water Reminder',
                description: 'Stay hydrated with reminders.',
                color: const Color(0xFF8BDAFF),
                onTap: null, // Disabled
                enabled: false,
              ),
              _buildToolButton(
                context,
                title: 'Custom Plan',
                description: 'Design your own personal plans.',
                color: const Color(0xFF8BFFC7),
                onTap: null, // Disabled
                enabled: false,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToToolPage(BuildContext context, String toolType) {
    switch (toolType) {
      case 'to_do':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ToDoToolPage()),
        );
        break;
      case 'workout':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WorkoutToolPage()),
        );
        break;
      case 'diet':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DietToolPage()),
        );
        break;
    // Extend with more tools here
      default:
        break;
    }
  }

  Widget _buildToolButton(
      BuildContext context, {
        required String title,
        required String description,
        required Color color,
        required VoidCallback? onTap,
        required bool enabled,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: enabled ? color : Colors.grey,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: enabled ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: enabled ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: enabled ? Colors.black87 : Colors.black38,
                      ),
                    ),
                  ),
                  if (!enabled)
                    const Icon(
                      Icons.lock,
                      color: Colors.black38,
                      size: 30,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: enabled ? Colors.black54 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
