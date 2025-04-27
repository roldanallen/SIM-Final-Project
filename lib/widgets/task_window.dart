import 'package:flutter/material.dart';

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
                _taskButton(context, 'To-do', Icons.check_circle, Colors.blue),
                _taskButton(context, 'Workout', Icons.fitness_center, Colors.green),
                _taskButton(context, 'Diet', Icons.restaurant, Colors.red),
                _taskButton(context, 'Gym', Icons.sports_gymnastics, Colors.orange),
                _taskButton(context, 'Water', Icons.water_drop, Colors.teal),
                _taskButton(context, 'Custom', Icons.edit, Colors.purple),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _taskButton(BuildContext context, String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {
        onAddTask(label);  // Trigger the callback
        Navigator.pop(context);  // Close the bottom sheet
      },
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
