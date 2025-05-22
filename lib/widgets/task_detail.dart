import 'package:flutter/material.dart';

class TaskDetailsPage extends StatelessWidget {
  final String taskTitle;
  final String taskType;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final String taskPriority;
  final String status;
  final String description;
  final Map<String, dynamic> uniqueAttributes;

  const TaskDetailsPage({
    super.key,
    required this.taskTitle,
    required this.taskType,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.taskPriority,
    required this.status,
    required this.description,
    required this.uniqueAttributes,
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
        return Colors.grey;
    }
  }

  String _getTitleLabel(String taskType) {
    switch (taskType.toLowerCase()) {
      case 'custom':
        return 'Custom Task';
      case 'study':
        return 'Study Task';
      case 'work':
        return 'Work Task';
      case 'project':
        return 'Project Task';
      case 'to-do':
        return 'To-do Task';
      case 'workout':
        return 'Workout Task';
      default:
        return 'Task Details';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = screenWidth < 360 ? 0.9 : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        title: Text(_getTitleLabel(taskType)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(screenWidth * 0.03, 0, screenWidth * 0.01, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task Details',
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

              _label(context, "Task Title"),
              _boxText(context, taskTitle),

              _label(context, "Task Type"),
              _boxText(context, taskType),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label(context, "Priority"),
                        _statusBox(context, taskPriority, _getPriorityColor()),
                      ],
                    ),
                  ),
                  SizedBox(width: 10 * scaleFactor),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label(context, "Status"),
                        _statusBox(context, status, Colors.black),
                      ],
                    ),
                  ),
                ],
              ),

              _label(context, "Start Date"),
              _boxText(context, startDate != null ? startDate!.toLocal().toString().split(' ')[0] : 'Not set'),

              _label(context, "End Date"),
              _boxText(context, endDate != null ? endDate!.toLocal().toString().split(' ')[0] : 'Not set'),

              _label(context, "Description"),
              _multilineBox(context, description.isNotEmpty ? description : 'No description'),

              if (taskType.toLowerCase() == 'to-do') ...[
                _label(context, "Details"),
                if (uniqueAttributes['steps'] != null && (uniqueAttributes['steps'] as List).isNotEmpty)
                  Column(
                    children: (uniqueAttributes['steps'] as List).asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final step = entry.value;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0 * scaleFactor),
                        child: _boxText(context, "Step $index: $step"),
                      );
                    }).toList(),
                  )
                else
                  _boxText(context, "No details specified"),
              ],

              if (taskType.toLowerCase() == 'workout') ...[
                _label(context, "Steps"),
                if (uniqueAttributes['prebuiltSteps'] != null && (uniqueAttributes['prebuiltSteps'] as List).isNotEmpty)
                  Column(
                    children: (uniqueAttributes['prebuiltSteps'] as List).asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final exercise = entry.value;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0 * scaleFactor),
                        child: _boxText(context, "$index. $exercise"),
                      );
                    }).toList(),
                  )
                else
                  _boxText(context, "No steps provided"),
              ],
              SizedBox(height: screenHeight * 0.04 * scaleFactor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.9 : 1.0;
    return Padding(
      padding: EdgeInsets.only(top: 18.0 * scaleFactor, bottom: 6 * scaleFactor),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15 * scaleFactor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _boxText(BuildContext context, String text) {
    final scaleFactor = MediaQuery.of(context).size.width < 360 ? 0.9 : 1.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 14 * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14 * scaleFactor,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _multilineBox(BuildContext context, String text) {
    final scaleFactor = MediaQuery.of(context).size.width < 360 ? 0.9 : 1.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14 * scaleFactor,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _statusBox(BuildContext context, String text, Color borderColor) {
    final scaleFactor = MediaQuery.of(context).size.width < 360 ? 0.9 : 1.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10 * scaleFactor, horizontal: 12 * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: borderColor,
          fontWeight: FontWeight.w500,
          fontSize: 14 * scaleFactor,
        ),
      ),
    );
  }
}