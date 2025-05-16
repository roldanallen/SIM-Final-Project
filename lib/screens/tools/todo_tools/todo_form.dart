import 'package:flutter/material.dart';
import 'package:software_development/screens/tools/reusable_tools/tools_form.dart';

class ToDoToolPage extends StatelessWidget {
  final String taskType;
  final String? taskId; // Added for editing
  final String? initialTitle; // Added for editing
  final String? initialPriority; // Added for editing

  const ToDoToolPage({
    super.key,
    required this.taskType,
    this.taskId,
    this.initialTitle,
    this.initialPriority,
  });

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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.9 : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        title: Text(taskId != null ? 'Edit ${_getTitleLabel(taskType)}' : _getTitleLabel(taskType)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(screenWidth * 0.03, 0, screenWidth * 0.01, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              taskId != null ? 'Edit To-do List' : 'Create To-do List',
              style: TextStyle(
                fontSize: screenWidth * 0.05 * scaleFactor,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.01 * scaleFactor),
            Text(
              'Organize your tasks and boost your productivity!',
              style: TextStyle(
                fontSize: screenWidth * 0.04 * scaleFactor,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: screenHeight * 0.02 * scaleFactor),
            ToolsForm(
              taskId: taskId,
              initialTitle: initialTitle,
              initialPriority: initialPriority,
              toolType: taskType,
              titleLabel: _getTitleLabel(taskType),
              priorityOptions: ['Low', 'Medium', 'High'],
              statusOptions: ['Not Started', 'In Progress'],
              collectionPath: 'todo',
              requireSteps: true,
              parentType: 'todo',
              includeSaveButton: true,
              onFormChanged: () {}, // No-op, as internal SaveButton handles updates
            ),
            SizedBox(height: screenHeight * 0.04 * scaleFactor),
          ],
        ),
      ),
    );
  }
}