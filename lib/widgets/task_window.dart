import 'package:flutter/material.dart';
import 'package:software_development/screens/home/tools_screen.dart';
import 'package:software_development/screens/tools/todo_tool.dart';
import 'package:software_development/screens/tools/workout_tool.dart';
import 'package:software_development/screens/tools/diet_tool.dart';

class TaskWindow extends StatelessWidget {
  final Function(String) onAddTask;

  const TaskWindow({super.key, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Title
            const Text(
              'What type of task do you want?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Task type buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                _taskButton(
                    context, 'To-do', Icons.check_circle, Colors.blue, true,
                    'to_do'),
                _taskButton(
                    context, 'Workout', Icons.fitness_center, Colors.green,
                    true, 'workout'),
                _taskButton(context, 'Diet', Icons.restaurant, Colors.red, true,
                    'diet'),
                _taskButton(
                    context, 'Gym', Icons.sports_gymnastics, Colors.orange,
                    false, 'gym'),
                _taskButton(
                    context, 'Water', Icons.water_drop, Colors.teal, false,
                    'water'),
                _taskButton(context, 'Custom', Icons.edit, Colors.purple, false,
                    'custom'),
              ],
            ),
            const SizedBox(height: 24),

            // Close button
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              label: const Text("Cancel"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskButton(BuildContext context, String label, IconData icon,
      Color color, bool enabled, String taskType) {
    return ElevatedButton.icon(
      onPressed: enabled
          ? () async {
        onAddTask(label); // Trigger the callback

        // Determine the target page
        Widget targetPage;
        switch (taskType) {
          case 'To-do':
            targetPage = const ToDoToolPage();
            break;
          case 'Workout':
            targetPage = const WorkoutToolPage();
            break;
          case 'Diet':
            targetPage = const DietToolPage();
            break;
          default:
            targetPage = const ToDoToolPage();
            break;
        }

        // Wait for the bottom sheet to close
        Navigator.pop(context); // Close the sheet
        await Future.delayed(const Duration(milliseconds: 200));

        // Ensure context is still valid by using a global navigator key or rebuild-safe context
        Navigator.of(context, rootNavigator: true).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => targetPage,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      }
          : null,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
