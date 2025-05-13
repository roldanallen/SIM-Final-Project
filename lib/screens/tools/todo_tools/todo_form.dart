import 'package:flutter/material.dart';
import 'package:software_development/screens/tools/reusable_tools/tools_form.dart';

class ToDoToolPage extends StatelessWidget {
  final String taskType;

  const ToDoToolPage({super.key, required this.taskType});

  String _getTitleLabel(String taskType) {
    switch (taskType.toLowerCase()) {
      case 'custom':
        return 'Custom To-do';
      case 'study':
        return 'Study To-do';
      case 'work':
        return 'Work To-do';
      case 'project':
        return 'Project To-do';
      default:
        return 'To-do List';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolsForm(
      toolType: taskType, // Store task type (e.g., 'custom') in document
      titleLabel: _getTitleLabel(taskType),
      priorityOptions: ['Low', 'Medium', 'High'],
      statusOptions: ['Not Started', 'In Progress'],
      collectionPath: 'todo', // Save all ToDo tasks under 'todo'
      requireSteps: true,
      parentType: 'todo', // Navigate back to ToDoTypeSelectionScreen
    );
  }
}