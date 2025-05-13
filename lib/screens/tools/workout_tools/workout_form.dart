import 'package:flutter/material.dart';
import 'package:software_development/screens/tools/reusable_tools/tools_form.dart';

class WorkoutToolPage extends StatelessWidget {
  final String taskType;

  const WorkoutToolPage({super.key, required this.taskType});

  String _getTitleLabel(String taskType) {
    switch (taskType.toLowerCase()) {
      case 'cardio':
        return 'Cardio Workout';
      case 'strength':
        return 'Strength Workout';
      case 'yoga':
        return 'Yoga Workout';
      default:
        return 'Workout Plan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolsForm(
      toolType: taskType, // Store task type (e.g., 'cardio') in document
      titleLabel: _getTitleLabel(taskType),
      priorityOptions: ['Low', 'Medium', 'High'],
      statusOptions: ['Not Started', 'In Progress'],
      collectionPath: 'workout', // Save all workout tasks under 'workout'
      requireSteps: true,
      parentType: 'workout', // Navigate back to WorkoutSelectionScreen
    );
  }
}