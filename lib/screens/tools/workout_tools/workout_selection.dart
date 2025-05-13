import 'package:flutter/material.dart';
import 'package:software_development/widgets/task_card.dart';
import 'package:software_development/screens/tools/workout_tools/workout_form.dart';

class WorkoutSelectionScreen extends StatelessWidget {
  const WorkoutSelectionScreen({Key? key}) : super(key: key);

  void navigateToTool(BuildContext context, String workoutType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutToolPage(taskType: workoutType),
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
        title: const Text('Workout'),
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
              'Workout Plan',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Get stronger, healthier, and more confident—choose your ideal workout plan today!',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            // Wide image below the description
            Image.asset(
              'assets/images/workout_banner.png', // Update with your image asset
              width: double.infinity, // Full width within padding
              height: screenHeight * 0.25, // Adjustable height, scalable for small screens
              fit: BoxFit.cover,
            ),
            SizedBox(height: screenHeight * 0.04),

            // Workout Plan Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start Training',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle "See all" action
                  },
                  child: Text(
                    'See all',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            TaskTypeCard(
              label: 'Lose Weight',
              subtext: 'Day 1 Full Body',
              hexColor1: '#fc90f8',
              hexColor2: '#FFFFFF',
              imagePath: 'assets/images/workout1.png',
              duration: '29 min',
              calories: '450 kcal',
              onTap: () => navigateToTool(context, 'lose_weight_day1'),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Workout Packages Section
            Text(
              'Beginner Workout',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            TaskTypeCard(
              label: 'Lose Weight',
              subtext: 'Dumbbell Lose Weight',
              hexColor1: '#ffc78f',
              hexColor2: '#FFFFFF',
              imagePath: 'assets/images/workout2.png',
              duration: '25 min',
              calories: '440 kcal',
              onTap: () => navigateToTool(context, 'dumbbell_lose_weight'),
            ),
            SizedBox(height: screenHeight * 0.02),
            TaskTypeCard(
              label: 'Lose Weight',
              subtext: 'Squat Lose Weight',
              hexColor1: '#fcf090',
              hexColor2: '#FFFFFF',
              imagePath: 'assets/images/workout3.png',
              duration: '25 min',
              calories: '440 kcal',
              onTap: () => navigateToTool(context, 'squat_lose_weight'),
            ),
          ],
        ),
      ),
    );
  }
}
