import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String taskID;
  final String title;
  final Timestamp startDate;
  final Timestamp endDate;
  final String priority;
  final String status;
  final String description;

  // Tool-specific attributes (nullable, depending on the tool type)
  final List<String>? steps;          // For To-Do
  final int? duration;                // For Workout
  final String? category;             // For Workout
  final int? reps;                    // For Workout
  final int? sets;                    // For Workout
  final String? workoutType;          // For Workout
  final int? calories;                // For Diet
  final int? carbohydrates;           // For Diet
  final int? fats;                    // For Diet
  final List<String>? mealList;       // For Diet
  final int? protein;                 // For Diet

  TaskModel({
    required this.taskID,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.priority,
    required this.status,
    required this.description,
    this.steps,
    this.duration,
    this.category,
    this.reps,
    this.sets,
    this.workoutType,
    this.calories,
    this.carbohydrates,
    this.fats,
    this.mealList,
    this.protein,
  });

  // Convert task data to a Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'priority': priority,
      'status': status,
      'description': description,
      'steps': steps,
      'duration': duration,
      'category': category,
      'reps': reps,
      'sets': sets,
      'workoutType': workoutType,
      'calories': calories,
      'carbohydrates': carbohydrates,
      'fats': fats,
      'mealList': mealList,
      'protein': protein,
    };
  }

  // Create a TaskModel from Firestore data
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      taskID: doc.id,
      title: data['title'],
      startDate: data['startDate'],
      endDate: data['endDate'],
      priority: data['priority'],
      status: data['status'],
      description: data['description'],
      steps: List<String>.from(data['steps'] ?? []),
      duration: data['duration'],
      category: data['category'],
      reps: data['reps'],
      sets: data['sets'],
      workoutType: data['workoutType'],
      calories: data['calories'],
      carbohydrates: data['carbohydrates'],
      fats: data['fats'],
      mealList: List<String>.from(data['mealList'] ?? []),
      protein: data['protein'],
    );
  }
}
