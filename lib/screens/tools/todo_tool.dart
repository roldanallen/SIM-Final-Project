import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoToolPage extends StatefulWidget {
  const TodoToolPage({super.key});

  @override
  State<TodoToolPage> createState() => _TodoToolPageState();
}

class _TodoToolPageState extends State<TodoToolPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _priority = 'Medium';
  String _status = 'Not yet started';
  DateTime? _startDate;
  DateTime? _endDate;
  String _description = '';

  Duration? _timeLeft;

  Future<void> _pickDateTime(bool isStart) async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (time != null) {
        final DateTime fullDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isStart) {
            _startDate = fullDateTime;
          } else {
            _endDate = fullDateTime;
          }
          if (_startDate != null && _endDate != null) {
            _timeLeft = _endDate!.difference(_startDate!);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create To-do Task'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title Task
              TextFormField(
                decoration: const InputDecoration(labelText: 'Task Title'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Title is required'
                    : null,
                onChanged: (value) => _title = value,
              ),
              const SizedBox(height: 20),

              // Priority
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['Low', 'Medium', 'High']
                    .map((level) => DropdownMenuItem(
                  value: level,
                  child: Text(level),
                ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _priority = value!;
                }),
              ),
              const SizedBox(height: 20),

              // Status
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Not yet started', 'In Progress', 'Completed']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _status = value!;
                }),
              ),
              const SizedBox(height: 20),

              // Start Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start Date & Time'),
                subtitle: Text(_startDate != null
                    ? DateFormat('yyyy-MM-dd – HH:mm').format(_startDate!)
                    : 'Not set'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDateTime(true),
              ),

              // End Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End Date & Time'),
                subtitle: Text(_endDate != null
                    ? DateFormat('yyyy-MM-dd – HH:mm').format(_endDate!)
                    : 'Not set'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDateTime(false),
              ),

              // Time Left
              if (_timeLeft != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Text(
                    'Time left: ${_timeLeft!.inHours} hrs ${_timeLeft!.inMinutes.remainder(60)} mins',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),

              // Description
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLines: 3,
                onChanged: (value) => _description = value,
              ),
              const SizedBox(height: 30),

              // Save / Cancel Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Save data to backend or state
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Task saved')),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
