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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        title: const Text('Select To-do Type'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskTypeCard(
              label: 'Custom',
              subtext: 'Create a custom task type.',
              hexColor1: '#80B8E8',
              hexColor2: '#E3F2FF',
              imagePath: 'assets/images/custom.png',
              onTap: () => navigateToTool(context, 'custom'),
            ),
            TaskTypeCard(
              label: 'Study',
              subtext: 'Tasks related to studying or schoolwork.',
              hexColor1: '#A480E8',
              hexColor2: '#EEE4FF',
              imagePath: 'assets/images/study.png',
              onTap: () => navigateToTool(context, 'custom'),
            ),
            TaskTypeCard(
              label: 'Work',
              subtext: 'Office or professional work tasks.',
              hexColor1: '#E880D3',
              hexColor2: '#FFECFB',
              imagePath: 'assets/images/work.png',
              onTap: () => navigateToTool(context, 'Work'),
            ),
            TaskTypeCard(
              label: 'Project',
              subtext: 'Plan and track your projects.',
              hexColor1: '#E88081',
              hexColor2: '#FEFFF9',
              imagePath: 'assets/images/project.png',
              onTap: () => navigateToTool(context, 'Project'),
            ),
          ],
        ),
      ),
    );
  }
}
