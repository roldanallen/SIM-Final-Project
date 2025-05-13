import 'package:flutter/material.dart';
import 'package:software_development/screens/tools/todo_tools/todo_selection.dart';
import 'package:software_development/screens/tools/workout_tools/workout_selection.dart';
import 'package:software_development/screens/tools/diet_tools/diet_tool.dart';
import 'package:software_development/widgets/task_card.dart';

class ToolsScreen extends StatefulWidget {
  final String? initialToolType;
  final VoidCallback? onToolHandled;

  const ToolsScreen({
    super.key,
    this.initialToolType,
    this.onToolHandled,
  });

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialToolType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToToolPage(context, widget.initialToolType!);
      });
    }
  }

  void _navigateToToolPage(BuildContext context, String toolType) {
    switch (toolType) {
      case 'to_do':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ToDoTypeSelectionScreen(
              onTypeSelected: (selectedType) {
                print('Selected Type: $selectedType');
              },
            ),
          ),
        );
        break;
      case 'workout':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WorkoutSelectionScreen(),
          ),
        );
        break;
      case 'diet':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DietToolPage(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = screenWidth < 360 ? 0.9 : 1.0; // Scaling for small screens

    return Scaffold(
      backgroundColor: const Color(0xF0F6F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20 * scaleFactor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Your Tools',
                style: TextStyle(
                  fontSize: 28 * scaleFactor,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12 * scaleFactor),
              Text(
                'Choose from a variety of tools to organize your tasks and goals.',
                style: TextStyle(
                  fontSize: 16 * scaleFactor,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 24 * scaleFactor),
              // Group 1: Task Management
              Text(
                'Task Management',
                style: TextStyle(
                  fontSize: 20 * scaleFactor,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 12 * scaleFactor),
              TaskTypeCard(
                label: 'To-do List',
                subtext: 'Create and manage your daily tasks.',
                hexColor1: '#bbcfff',
                hexColor2: '#bbcfff',
                imagePath: 'assets/images/todo.png',
                imageSize: 40,
                onTap: () => _navigateToToolPage(context, 'to_do'),
              ),
              TaskTypeCard(
                label: 'Custom Plan',
                subtext: 'Design your own personal plans.',
                hexColor1: '#8BFFC7',
                hexColor2: '#8BFFC7',
                imagePath: 'assets/images/custom.png',
                imageSize: 40,
                onTap: null,
                enabled: true,
              ),
              SizedBox(height: 20 * scaleFactor),
              // Group 2: Fitness Goals
              Text(
                'Fitness Goals',
                style: TextStyle(
                  fontSize: 20 * scaleFactor,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 12 * scaleFactor),
              TaskTypeCard(
                label: 'Workout Plan',
                subtext: 'Plan and track your workouts.',
                hexColor1: '#ff7a8a',
                hexColor2: '#ff7a8a',
                imagePath: 'assets/images/workout.png',
                imageSize: 40,
                onTap: () => _navigateToToolPage(context, 'workout'),
              ),
              SizedBox(height: 20 * scaleFactor),
              // Group 3: Health & Wellness
              Text(
                'Health & Wellness',
                style: TextStyle(
                  fontSize: 20 * scaleFactor,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 12 * scaleFactor),
              TaskTypeCard(
                label: 'Diet Plan',
                subtext: 'Log meals and maintain healthy diet.',
                hexColor1: '#E880D3',
                hexColor2: '#E880D3',
                imagePath: 'assets/images/diet.png',
                imageSize: 40,
                onTap: null,
                enabled: true,
              ),
              TaskTypeCard(
                label: 'Water Reminder',
                subtext: 'Stay hydrated with reminders.',
                hexColor1: '#8BDAFF',
                hexColor2: '#8BDAFF',
                imagePath: 'assets/images/water.png',
                imageSize: 40,
                onTap: null,
                enabled: true,
              ),
              SizedBox(height: 32 * scaleFactor),
            ],
          ),
        ),
      ),
    );
  }
}