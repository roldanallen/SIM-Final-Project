import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TaskSchedule extends StatefulWidget {
  const TaskSchedule({super.key});

  @override
  State<TaskSchedule> createState() => _TaskScheduleState();
}

class _TaskScheduleState extends State<TaskSchedule> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final List<Map<String, dynamic>> _taskList = [
    {
      'start': DateTime.utc(2025, 5, 1),
      'end': DateTime.utc(2025, 5, 1),
      'color': Colors.red,
      'label': 'W1',
    },
    {
      'start': DateTime.utc(2025, 5, 1),
      'end': DateTime.utc(2025, 5, 1),
      'color': Colors.green,
      'label': 'GYM',
    },
    {
      'start': DateTime.utc(2025, 5, 3),
      'end': DateTime.utc(2025, 5, 4),
      'color': Colors.blue,
      'label': 'TD',
    },
  ];

  List<Map<String, dynamic>> _getTasksForDay(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return _taskList.where((task) {
      final start = DateTime.utc(task['start'].year, task['start'].month, task['start'].day);
      final end = DateTime.utc(task['end'].year, task['end'].month, task['end'].day);
      return isSameDay(start, key) || isSameDay(end, key);
    }).toList();
  }

  bool _isStartDate(DateTime taskDate, DateTime day) =>
      isSameDay(DateTime.utc(taskDate.year, taskDate.month, taskDate.day),
          DateTime.utc(day.year, day.month, day.day));

  bool _isEndDate(DateTime taskEnd, DateTime day) =>
      isSameDay(DateTime.utc(taskEnd.year, taskEnd.month, taskEnd.day),
          DateTime.utc(day.year, day.month, day.day));

  Color _dimColor(Color color) {
    HSLColor hsl = HSLColor.fromColor(color);
    return hsl.withSaturation(hsl.saturation * 0.4).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10),
          child: Text(
            'Task Schedule',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, _) {
              final tasks = _getTasksForDay(day);
              if (tasks.isEmpty) {
                return Center(child: Text('${day.day}'));
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    children: tasks.map((task) {
                      final isStart = _isStartDate(task['start'], day);
                      final isEnd = _isEndDate(task['end'], day);
                      if (!isStart && !isEnd) return const SizedBox.shrink();

                      final Color baseColor = task['color'];
                      final Color color = isEnd && !isStart ? _dimColor(baseColor) : baseColor;

                      return Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          task['label'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ),
        const Divider(thickness: 1),
      ]),
    );
  }
}
