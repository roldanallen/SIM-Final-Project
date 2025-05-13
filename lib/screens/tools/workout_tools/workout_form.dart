import 'package:flutter/material.dart';
import 'package:software_development/screens/tools/reusable_tools/tools_form.dart';
import 'package:software_development/widgets/reusable_tools.dart';

class WorkoutToolPage extends StatefulWidget {
  final String taskType;

  const WorkoutToolPage({super.key, required this.taskType});

  @override
  _WorkoutToolPageState createState() => _WorkoutToolPageState();
}

class _WorkoutToolPageState extends State<WorkoutToolPage> {
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

  // GlobalKey to access ToolsForm state
  final GlobalKey<ToolsFormState> _formKey = GlobalKey<ToolsFormState>();

  // Expanded state for each step
  final List<bool> _expandedStates = List<bool>.filled(5, false);

  // Pre-built steps data (5 steps)
  final List<Map<String, String>> _preBuiltSteps = [
    {
      'title': 'Push-ups',
      'details': '3 sets, 15 reps, 30s rest between sets.',
    },
    {
      'title': 'Squats',
      'details': '3 sets, 12 reps, 45s rest between sets.',
    },
    {
      'title': 'Plank',
      'details': '3 sets, 30s hold, 30s rest between sets.',
    },
    {
      'title': 'Lunges',
      'details': '3 sets, 10 reps per leg, 45s rest between sets.',
    },
    {
      'title': 'Burpees',
      'details': '3 sets, 10 reps, 60s rest between sets.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.9 : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        title: Text(_getTitleLabel(widget.taskType)),
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
              'Create Workout Plan',
              style: TextStyle(
                fontSize: screenWidth * 0.05 * scaleFactor,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.01 * scaleFactor),
            Text(
              'Design your personalized workout plan to achieve your fitness goals!',
              style: TextStyle(
                fontSize: screenWidth * 0.04 * scaleFactor,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: screenHeight * 0.02 * scaleFactor),
            Image.asset(
              'assets/images/workout_banner.png',
              width: double.infinity,
              height: screenHeight * 0.25 * scaleFactor,
              fit: BoxFit.cover,
            ),
            SizedBox(height: screenHeight * 0.06 * scaleFactor),
            // Reusable ToolsForm content without SaveButton
            ToolsForm(
              key: _formKey,
              toolType: widget.taskType,
              titleLabel: _getTitleLabel(widget.taskType),
              priorityOptions: ['Low', 'Medium', 'High'],
              statusOptions: ['Not Started', 'In Progress'],
              collectionPath: 'workout',
              requireSteps: false,
              parentType: 'workout',
              prebuiltSteps: _preBuiltSteps,
              includeSaveButton: false,
              onFormChanged: () {
                setState(() {}); // Rebuild to update SaveButton
              },
            ),
            SizedBox(height: screenHeight * 0.06 * scaleFactor),
            // Steps section
            Text(
              'Steps',
              style: TextStyle(
                fontSize: screenWidth * 0.05 * scaleFactor,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.02 * scaleFactor),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _preBuiltSteps.length,
              itemBuilder: (context, index) {
                final step = _preBuiltSteps[index];
                final isExpanded = _expandedStates[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedStates[index] = !isExpanded;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12 * scaleFactor),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10 * scaleFactor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4 * scaleFactor,
                              offset: Offset(0, 2 * scaleFactor),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              size: 16 * scaleFactor,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 8 * scaleFactor),
                            Expanded(
                              child: Text(
                                step['title']!,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04 * scaleFactor,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                              firstChild: Icon(
                                Icons.chevron_right,
                                size: 20 * scaleFactor,
                                color: Colors.black54,
                              ),
                              secondChild: Icon(
                                Icons.expand_more,
                                size: 20 * scaleFactor,
                                color: Colors.black54,
                              ),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 200),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: EdgeInsets.only(
                          top: 8 * scaleFactor,
                          left: 12 * scaleFactor,
                          right: 12 * scaleFactor,
                          bottom: 12 * scaleFactor,
                        ),
                        child: Text(
                          step['details']!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035 * scaleFactor,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    if (index < _preBuiltSteps.length - 1)
                      SizedBox(height: 12 * scaleFactor),
                  ],
                );
              },
            ),
            SizedBox(height: screenHeight * 0.04 * scaleFactor),
            // SaveButton
            SaveButton(
              onPressed: () {
                _formKey.currentState?.save();
              },
              isEnabled: _formKey.currentState?.isSaveEnabled() ?? false,
            ),
            SizedBox(height: screenHeight * 0.04 * scaleFactor),
          ],
        ),
      ),
    );
  }
}