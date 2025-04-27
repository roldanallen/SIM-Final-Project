import 'package:flutter/material.dart';
import 'package:software_development/screens/models/task_model.dart';

class TaskBar extends StatelessWidget {
  final Task task;
  const TaskBar({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: () {
          // Will open task detail later
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple.shade50,
          foregroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.task_alt, color: Colors.deepPurple),
            const SizedBox(width: 10),
            Text(task.type, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
