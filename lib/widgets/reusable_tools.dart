import 'package:flutter/material.dart';

// ================= Universal Input Widgets =================

/// Task title input with fixed height box
class TaskTitleInput extends StatelessWidget {
  final TextEditingController controller;
  const TaskTitleInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _LabeledBox(
      label: 'Task Title',
      height: 70,
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Enter your task title here',
          border: InputBorder.none,
        ),
      ),
    );
  }
}

/// Single date picker field with calendar icon, fixed height box
class DateInputField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const DateInputField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledBox(
      label: label,
      height: 70,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDate != null
                    ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                    : 'Select date',
                style: TextStyle(
                  fontSize: 16,
                  color: selectedDate != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
            const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// Side-by-side start/end date inputs
class DateInputRow extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;

  const DateInputRow({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartTap,
    required this.onEndTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DateInputField(
            label: 'Start Date',
            selectedDate: startDate,
            onTap: onStartTap,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DateInputField(
            label: 'End Date',
            selectedDate: endDate,
            onTap: onEndTap,
          ),
        ),
      ],
    );
  }
}

/// Side-by-side priority/status dropdowns, fixed height boxes
class DropdownInputRow extends StatelessWidget {
  final String? priority;
  final String? status;
  final Function(String?) onPriorityChanged;
  final Function(String?) onStatusChanged;

  const DropdownInputRow({
    super.key,
    required this.priority,
    required this.status,
    required this.onPriorityChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LabeledBox(
            label: 'Priority',
            height: 70,
            child: DropdownButtonFormField<String>(
              value: priority,
              decoration: const InputDecoration(
                hintText: 'Select priority',
                border: InputBorder.none,
              ),
              items: ['Low', 'Medium', 'High']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: onPriorityChanged,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _LabeledBox(
            label: 'Status',
            height: 70,
            child: DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(
                hintText: 'Select status',
                border: InputBorder.none,
              ),
              items: ['Not Started', 'In Progress', 'Completed']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: onStatusChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Description field (flexible height)
class DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const DescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _LabeledBox(
      label: 'Description',
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Write additional details here…',
          border: InputBorder.none,
        ),
      ),
    );
  }
}

/// Full-width green save button with rounded corners
class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SaveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text(
          'Save',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}

// ================ Internal: Wrapper with Label & Styling ================

class _LabeledBox extends StatelessWidget {
  final String label;
  final Widget child;
  final double? height; // if null, box is auto-height (e.g. Description)

  const _LabeledBox({
    required this.label,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field label
          Text(label,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          // White box with optional fixed height
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Usage Screen ====================

/// A screen that demonstrates the form with steps and a bottom-pinned Save button.
class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key});
  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _startDate, _endDate;
  String? _priority, _status;
  final List<String> _steps = [];

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  void _addStep() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Step'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Enter a step')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) Navigator.pop(context, ctrl.text.trim());
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null) setState(() => _steps.add(result));
  }

  void _save() {
    // your save logic
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Scrollable form
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TaskTitleInput(controller: _titleController),
                    DateInputRow(
                      startDate: _startDate,
                      endDate: _endDate,
                      onStartTap: () => _pickDate(true),
                      onEndTap: () => _pickDate(false),
                    ),
                    DropdownInputRow(
                      priority: _priority,
                      status: _status,
                      onPriorityChanged: (v) => setState(() => _priority = v),
                      onStatusChanged: (v) => setState(() => _status = v),
                    ),

                    // Description + Add Step on same row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Description',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        TextButton(onPressed: _addStep, child: const Text('+ Add Step')),
                      ],
                    ),
                    // Description box
                    DescriptionField(controller: _descController),
                    // Steps list or placeholder
                    if (_steps.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 4, left: 4),
                        child: Text('No steps specified.', style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ..._steps.map((s) => Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text('• $s'),
                      )),
                  ],
                ),
              ),
            ),

            // Bottom-pinned Save button
            SaveButton(onPressed: _save),
          ],
        ),
      ),
    );
  }
}
