import 'package:flutter/material.dart';
import 'package:software_development/widgets/task_card.dart';
import 'todo_tool.dart';

class ToDoTypeSelectionScreen extends StatelessWidget {
  final void Function(String)? onTypeSelected;

  const ToDoTypeSelectionScreen({Key? key, this.onTypeSelected}) : super(key: key);

  void navigateToTool(BuildContext context, String selectedType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ToDoToolPage(taskType: selectedType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        title: const Text('To-do'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To-do Plan',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            // Mini Description
            Text(
              'Organize your day with ease—pick the perfect to-do plan!',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            // Wide image below the description
            Image.asset(
              'assets/images/todo_banner.png', // Update with your image asset
              width: double.infinity, // Full width within padding
              height: screenHeight * 0.25, // Adjustable height, scalable for small screens
              fit: BoxFit.cover,
            ),
            SizedBox(height: screenHeight * 0.04),

            // To-do Types Section
            Text(
              'Create your own task',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            TaskTypeCard(
              label: 'Custom',
              subtext: 'Create a custom task type.',
              hexColor1: '#80B8E8',
              hexColor2: '#FFFFFF',
              imagePath: 'assets/images/custom.png',
              onTap: () => navigateToTool(context, 'custom'),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Study & Works',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            TaskTypeCard(
              label: 'Study',
              subtext: 'Tasks related to studying or schoolwork.',
              hexColor1: '#A480E8',
              hexColor2: '#FFFFFF',
              imagePath: 'assets/images/study.png',
              onTap: () => navigateToTool(context, 'study'), // Fixed to match label
            ),
            SizedBox(height: screenHeight * 0.02),
            TaskTypeCard(
              label: 'Work',
              subtext: 'Office or professional work tasks.',
              hexColor1: '#E880D3',
              hexColor2: '#FFFFFF',
              imagePath: 'assets/images/work.png',
              onTap: () => navigateToTool(context, 'work'), // Fixed to match label
            ),
            SizedBox(height: screenHeight * 0.02),
            TaskTypeCard(
              label: 'Project',
              subtext: 'Plan and track your projects.',
              hexColor1: '#f5b5bd',
              hexColor2: '#FFFFFF',
              imagePath: 'assets/images/project.png',
              onTap: () => navigateToTool(context, 'project'), // Fixed to match label
            ),
          ],
        ),
      ),
    );
  }
}