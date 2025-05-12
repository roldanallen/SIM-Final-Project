import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class TaskViewer extends StatefulWidget {
  final String category;

  const TaskViewer({super.key, required this.category});

  @override
  State<TaskViewer> createState() => _TaskViewerState();
}

class _TaskViewerState extends State<TaskViewer> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> filteredTasks = [];
  bool isLoading = true;
  String? error;
  String currentFilter = 'Total Task'; // Default filter
  String sortType = 'Sort by Date'; // Default sort type
  bool isAscending = true; // For sorting direction

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    if (userId == null) {
      setState(() {
        error = 'Please sign in';
        isLoading = false;
      });
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance.collection('userData').doc(userId);
      final userDocSnapshot = await userDocRef.get();
      if (!userDocSnapshot.exists) {
        setState(() {
          error = 'User data not found';
          isLoading = false;
        });
        return;
      }

      final toolId = _mapCategoryToToolId(widget.category.toLowerCase());
      final tasksSnapshot = await userDocRef
          .collection('tools')
          .doc(toolId)
          .collection('tasks')
          .get();

      final taskList = tasksSnapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now();
        return {
          'taskId': doc.id,
          'title': data['title'] ?? '',
          'priority': data['priority'] ?? 'Low',
          'completed': data['completed'] != null ? data['completed'] as bool : false,
          'createdAt': createdAt,
        };
      }).toList();

      setState(() {
        tasks = taskList;
        filteredTasks = taskList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading tasks: $e';
        isLoading = false;
      });
    }
  }

  String _mapCategoryToToolId(String category) {
    const toolMap = {
      'to-do': 'todo',
      'workout': 'workout',
      'water reminder': 'waterreminder',
      'diet': 'dietplan',
      'custom plan': 'customplan',
    };
    return toolMap[category] ?? category.replaceAll(' ', '');
  }

  void _filterTasks(String filter) {
    setState(() {
      currentFilter = filter;
      if (filter == 'Total Task') {
        filteredTasks = tasks;
      } else if (filter == 'Task Completed') {
        filteredTasks = tasks.where((task) => task['completed'] as bool).toList();
      } else if (filter == 'On going') {
        filteredTasks = tasks.where((task) => !(task['completed'] as bool)).toList();
      }
    });
  }

  void _sortTasks() {
    setState(() {
      filteredTasks.sort((a, b) {
        if (sortType == 'Sort by Date') {
          final dateA = a['createdAt'] as DateTime;
          final dateB = b['createdAt'] as DateTime;
          return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        } else {
          final titleA = (a['title'] as String).toLowerCase();
          final titleB = (b['title'] as String).toLowerCase();
          return isAscending
              ? titleA.compareTo(titleB)
              : titleB.compareTo(titleA);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Scale factors for smaller devices
    final double fontScale = screenWidth < 360 ? 0.9 : 1.0;
    final double paddingScale = screenWidth < 360 ? 0.8 : 1.0;
    final double barChartHeight = screenHeight < 600 ? 180 : 200;

    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final created = tasks.length;
    final completed = tasks.where((task) => task['completed'] as bool).length;
    final ongoing = tasks.where((task) => !(task['completed'] as bool)).length;

    final taskStats = <String, int>{
      'Total': created,
      'Completed': completed,
      'Ongoing': ongoing,
    };

    final maxVal = [created, completed, ongoing].reduce((a, b) => a > b ? a : b);
    final int interval;
    final double axisMax;
    if (maxVal <= 8) {
      interval = 1;
      axisMax = 8.0;
    } else {
      interval = 2;
      axisMax = ((maxVal / interval).ceil() * interval).toDouble();
    }

    // Mini description based on category
    String mainDescription, subDescription;
    switch (widget.category.toLowerCase()) {
      case 'to-do':
        mainDescription = 'Master your daily tasks!';
        subDescription = 'Stay organized with a clear overview of your to-do list and priorities.';
        break;
      case 'workout':
        mainDescription = 'Boost your fitness journey!';
        subDescription = 'Track your workout routines and achieve your fitness goals effortlessly.';
        break;
      case 'water reminder':
        mainDescription = 'Stay hydrated with ease!';
        subDescription = 'Monitor your water intake and maintain a healthy lifestyle.';
        break;
      case 'diet':
        mainDescription = 'Fuel your body right!';
        subDescription = 'Manage your diet plans and stay on top of your nutrition goals.';
        break;
      case 'custom plan':
        mainDescription = 'Tailor your success!';
        subDescription = 'Customize and track your unique plans with full control.';
        break;
      default:
        mainDescription = 'Manage your tasks!';
        subDescription = 'Track and organize your activities effectively.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05 * paddingScale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Return Arrow and Category Name
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24 * fontScale),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    widget.category,
                    style: TextStyle(fontSize: 24 * fontScale, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16 * paddingScale),
              // Mini Description
              Text(
                mainDescription,
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8 * paddingScale),
              Text(
                subDescription,
                style: TextStyle(fontSize: 14 * fontScale, color: Colors.grey.shade600),
              ),
              SizedBox(height: 24 * paddingScale),
              // Bar Chart with Statistics Label
              Text(
                'Statistics',
                style: TextStyle(fontSize: 20 * fontScale, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16 * paddingScale),
              Container(
                width: double.infinity,
                height: barChartHeight,
                padding: EdgeInsets.all(12 * paddingScale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20 * paddingScale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 12 * paddingScale,
                      offset: Offset(0, 6 * paddingScale),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(8 * paddingScale),
                  child: AspectRatio(
                    aspectRatio: 1.4,
                    child: BarChart(
                      BarChartData(
                        maxY: axisMax,
                        barGroups: _buildBarData(taskStats),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: interval.toDouble(),
                              reservedSize: 32 * paddingScale,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: EdgeInsets.only(right: 8.0 * paddingScale),
                                  child: Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      fontSize: 10 * fontScale,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final labels = ['Total', 'Completed', 'Ongoing'];
                                final idx = value.toInt();
                                return Text(
                                  idx < labels.length ? labels[idx] : '',
                                  style: TextStyle(fontSize: 12 * fontScale),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          drawHorizontalLine: true,
                          getDrawingHorizontalLine: (value) =>
                              FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
              ),
              // Details Section with Sorting
              SizedBox(height: 24 * paddingScale),
              Text(
                'Details',
                style: TextStyle(fontSize: 20 * fontScale, fontWeight: FontWeight.bold),
              ),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16 * paddingScale,
                mainAxisSpacing: 16 * paddingScale,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.3,
                children: {
                  'Total Task': created.toString(),
                  'Task Completed': completed.toString(),
                  'On going': ongoing.toString(),
                }.entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _filterTasks(entry.key),
                    child: Container(
                      padding: EdgeInsets.all(16 * paddingScale),
                      decoration: BoxDecoration(
                        color: currentFilter == entry.key ? Colors.grey.shade200 : Colors.white,
                        borderRadius: BorderRadius.circular(16 * paddingScale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8 * paddingScale,
                            offset: Offset(0, 4 * paddingScale),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(fontSize: 14 * fontScale, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8 * paddingScale),
                          Text(
                            entry.value,
                            style: TextStyle(fontSize: 18 * fontScale, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Task List Section with Filter for To-do
              SizedBox(height: 24 * paddingScale),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.category,
                    style: TextStyle(fontSize: 20 * fontScale, fontWeight: FontWeight.bold),
                  ),
                  if (widget.category.toLowerCase() == 'to-do')
                    PopupMenuButton<String>(
                      icon: Icon(Icons.filter_list, color: Colors.black87, size: 24 * fontScale),
                      onSelected: (String value) {
                        setState(() {
                          sortType = value;
                          if (sortType == 'Sort by Date') {
                            isAscending = true; // Default for date sorting
                          } else {
                            isAscending = sortType == 'Ascending';
                          }
                          _sortTasks();
                        });
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Sort by Date',
                          child: Text('Sort by Date'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Ascending',
                          child: Text('Ascending'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Descending',
                          child: Text('Descending'),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 16 * paddingScale),
              if (filteredTasks.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                  child: Center(
                    child: Text(
                      'No tasks specified',
                      style: TextStyle(fontSize: 16 * fontScale, color: Colors.grey.shade600),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final title = task['title'];
                    final createdAt = (task['createdAt'] as DateTime).toString().split(' ')[0]; // Format date
                    final isCompleted = task['completed'] as bool;
                    final status = isCompleted ? 'Completed' : (createdAt.isEmpty ? 'Not yet started' : 'In progress');

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.04 * paddingScale),
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.green.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(10 * paddingScale),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4 * paddingScale,
                              offset: Offset(0, 2 * paddingScale),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04 * fontScale,
                                          color: Colors.black87,
                                          decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                        ),
                                      ),
                                      Text(
                                        'Created: $createdAt',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03 * fontScale,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isCompleted)
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04 * fontScale,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (isCompleted)
                                  Checkbox(
                                    value: true,
                                    onChanged: null,
                                    activeColor: Colors.green,
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                            if (isCompleted)
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05 * fontScale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarData(Map<String, int> stats) => [
    for (var i = 0; i < stats.length; i++)
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: stats.values.elementAt(i).toDouble(),
            width: 22,
            color: [Colors.blue, Colors.green, Colors.orange][i],
            borderRadius: BorderRadius.zero,
          )
        ],
      ),
  ];
}