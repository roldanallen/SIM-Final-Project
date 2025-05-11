import 'package:flutter/material.dart';
import 'package:software_development/screens/tools/todo_tools/todo_selection.dart';
import 'package:software_development/screens/tools/workout_tools/workout_tool.dart';
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
              TaskTypeCard(
                label: 'To-do List',
                subtext: 'Create and manage your daily tasks.',
                hexColor1: '#80B8E8',
                hexColor2: '#E3F2FF',
                imagePath: 'assets/images/todo.png',
                // test
                onTap: () => _navigateToToolPage(context, 'to_do'),
              ),
              TaskTypeCard(
                label: 'Workout Plan',
                subtext: 'Plan and track your workouts.',
                hexColor1: '#A480E8',
                hexColor2: '#EEE4FF',
                imagePath: 'assets/images/workout.png',
                onTap: () => _navigateToToolPage(context, 'workout'),
              ),
              TaskTypeCard(
                label: 'Diet Plan',
                subtext: 'Log meals and maintain healthy diet.',
                hexColor1: '#E880D3',
                hexColor2: '#FFECFB',
                imagePath: 'assets/images/diet.png',
                onTap: null,
                enabled: false,
              ),
              TaskTypeCard(
                label: 'Water Reminder',
                subtext: 'Stay hydrated with reminders.',
                hexColor1: '#8BDAFF',
                hexColor2: '#B6EBFF',
                imagePath: 'assets/images/water.png',
                onTap: null,
                enabled: false,
              ),
              TaskTypeCard(
                label: 'Custom Plan',
                subtext: 'Design your own personal plans.',
                hexColor1: '#8BFFC7',
                hexColor2: '#B6FFE2',
                imagePath: 'assets/images/custom.png',
                onTap: null,
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
          MaterialPageRoute(
            builder: (_) =>
                ToDoTypeSelectionScreen(
                  onTypeSelected: (selectedType) {
                    // Handle the selected type (e.g., navigate to the appropriate page or do something with it)
                    print(
                        'Selected Type: $selectedType'); // You can replace this with your own logic
                  },
                ),
          ),
        );
        break;
      case 'workout':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WorkoutToolPage(),
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
    // Add more tools here as needed
    }
  }
}
