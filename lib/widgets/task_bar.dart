import 'package:flutter/material.dart';
import 'package:software_development/widgets/task_detail.dart';

class TaskButtonBar extends StatelessWidget {
  final String taskTitle;
  final String taskType;
  final String taskPriority;
  final bool isExpanded;
  final VoidCallback onMarkAsDone;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onToggleExpand;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String description;
  final Map<String, dynamic> uniqueAttributes;

  const TaskButtonBar({
    super.key,
    required this.taskTitle,
    required this.taskType,
    required this.taskPriority,
    required this.isExpanded,
    required this.onMarkAsDone,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleExpand,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsPage(
              taskTitle: taskTitle,
              taskType: taskType,
              createdAt: createdAt,
              startDate: startDate,
              endDate: endDate,
              taskPriority: taskPriority,
              status: status,
              description: description,
              uniqueAttributes: uniqueAttributes,
            ),
          ),
        );
      },
      onLongPress: () => onToggleExpand(),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isExpanded)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskTitle,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      taskType,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                  ],
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: screenWidth * 0.55,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      textDirection: TextDirection.rtl,
                      children: [
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.black87, size: screenWidth * 0.06),
                          onPressed: onToggleExpand,
                        ),
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.black87, size: screenWidth * 0.06),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Action'),
                                content: const Text('Are you sure you want to mark this task as done?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      onMarkAsDone();
                                    },
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.black87, size: screenWidth * 0.06),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Action'),
                                content: const Text('Are you sure you want to delete this task?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      onDelete();
                                    },
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.black87, size: screenWidth * 0.06),
                          onPressed: onEdit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            if (!isExpanded)
              Text(
                taskPriority,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: _getPriorityColor(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}