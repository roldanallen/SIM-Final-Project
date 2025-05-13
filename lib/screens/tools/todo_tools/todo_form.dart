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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.9 : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        title: Text(_getTitleLabel(taskType)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04 * scaleFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create To-do List',
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