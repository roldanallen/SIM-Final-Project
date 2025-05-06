import 'package:flutter/material.dart';

class TaskButtonBar extends StatelessWidget {
  final String taskTitle;
  final String taskType;
  final String taskPriority;
  final VoidCallback onPressed;

  const TaskButtonBar({
    super.key,
    required this.taskTitle,
    required this.taskType,
    required this.taskPriority,
    required this.onPressed,
  });

  Color _getPriorityColor() {
    switch (taskPriority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey; // Default color
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          taskTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              taskType,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Priority: $taskPriority',
              style: TextStyle(
                fontSize: 14,
                color: _getPriorityColor(),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
