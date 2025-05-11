import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:software_development/widgets/reusable_tools.dart';
import 'package:software_development/utils/error_handler.dart';

class ToDoToolPage extends StatefulWidget {
  final String taskType;
  const ToDoToolPage({super.key, this.taskType = 'todo'});

  @override
  State<ToDoToolPage> createState() => _ToDoToolPageState();
}

class _ToDoToolPageState extends State<ToDoToolPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _priority;
  String? _status;
  String? _titleError;
  String? _startDateError;
  String? _endDateError;
  String? _priorityError;
  String? _statusError;
  String? _descError;

  List<String> steps = [];

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        isStart ? _startDate = picked : _endDate = picked;
      });
    }
  }

  void _addStep(String step) {
    setState(() {
      steps.add(step);
    });
  }

  void _deleteStep(int index) {
    setState(() {
      steps.removeAt(index);
    });
  }

  void _editStep(int index, String newText) {
    setState(() {
      steps[index] = newText;
    });
  }

  void _reorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex--;
      final step = steps.removeAt(oldIndex);
      steps.insert(newIndex, step);
    });
  }

  bool _isSaveEnabled() {
    return _titleController.text.isNotEmpty &&
        _startDate != null &&
        _endDate != null &&
        _priority != null &&
        _status != null &&
        _descController.text.isNotEmpty;
  }

  void _handleSave() {
    if (!_isSaveEnabled()) return;
    _saveTask();
  }

  void _saveTask() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    setState(() {
      _titleError = ErrorHandler.handleFieldError(
        value: title,
        fieldType: 'title',
        regExp: RegExp(r'.+'),
        emptyError: 'Title is required',
        invalidError: 'Invalid title',
      );
      _startDateError = _startDate == null ? 'Start date is required' : null;
      _endDateError = _endDate == null ? 'End date is required' : null;
      _priorityError = _priority == null ? 'Priority is required' : null;
      _statusError = _status == null ? 'Status is required' : null;
      _descError = ErrorHandler.handleFieldError(
        value: desc,
        fieldType: 'description',
        regExp: RegExp(r'.+'),
        emptyError: 'Description is required',
        invalidError: 'Invalid description',
      );
    });

    if (_titleError != null ||
        _startDateError != null ||
        _endDateError != null ||
        _priorityError != null ||
        _statusError != null ||
        _descError != null) {
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final todoData = {
      'taskType': widget.taskType,
      'title': title,
      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
      'priority': _priority,
      'status': _status,
      'description': desc,
      'steps': steps,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('userData')
          .doc(uid)
          .collection('tools')
          .doc('todo')
          .collection('tasks')
          .add(todoData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('To-do task saved to database!')),
      );

      setState(() {
        _titleController.clear();
        _descController.clear();
        _startDate = null;
        _endDate = null;
        _priority = null;
        _status = null;
        steps.clear();
        _titleError = null;
        _startDateError = null;
        _endDateError = null;
        _priorityError = null;
        _statusError = null;
        _descError = null;
      });
    } catch (e) {
      print('Error saving task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save task')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create To-do List')),
      backgroundColor: const Color(0xFFF0F6F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskTitleInput(
                  controller: _titleController,
                  errorText: _titleError,
                ),
                ErrorHandler.displayError(_titleError),
              ],
            ),
            DateInputRow(
              startDate: _startDate,
              endDate: _endDate,
              onStartTap: () => _selectDate(true),
              onEndTap: () => _selectDate(false),
              startDateError: _startDateError,
              endDateError: _endDateError,
            ),
            DropdownInputRow(
              priority: _priority,
              status: _status,
              onPriorityChanged: (v) => setState(() => _priority = v),
              onStatusChanged: (v) => setState(() => _status = v),
              priorityError: _priorityError,
              statusError: _statusError,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DescriptionField(
                  controller: _descController,
                  errorText: _descError,
                ),
                ErrorHandler.displayError(_descError),
              ],
            ),
            StepList(
              steps: steps,
              onAddStep: _addStep,
              onDeleteStep: _deleteStep,
              onEditStep: _editStep,
              onReorderSteps: _reorderSteps,
            ),
            const SizedBox(height: 20),
            SaveButton(
              onPressed: _handleSave,
              isEnabled: _isSaveEnabled(),
            ),
          ],
        ),
      ),
    );
  }
}

// Modified widgets from reusable_tools.dart to support error handling
class TaskTitleInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const TaskTitleInput({super.key, required this.controller, this.errorText});

  @override
  Widget build(BuildContext context) {
    return _LabeledBox(
      label: 'Task Title',
      height: 70,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Enter your task title here',
          border: InputBorder.none,
          errorText: errorText,
          errorStyle: const TextStyle(height: 0),
        ),
      ),
    );
  }
}

class DateInputField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String? errorText;

  const DateInputField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledBox(
      label: label,
      height: 70,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: errorText != null && errorText!.isNotEmpty
                ? Border.all(color: Colors.red, width: 1.2)
                : null,
          ),
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
      ),
    );
  }
}

class DateInputRow extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;
  final String? startDateError;
  final String? endDateError;

  const DateInputRow({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartTap,
    required this.onEndTap,
    this.startDateError,
    this.endDateError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DateInputField(
                label: 'Start Date',
                selectedDate: startDate,
                onTap: onStartTap,
                errorText: startDateError,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DateInputField(
                label: 'End Date',
                selectedDate: endDate,
                onTap: onEndTap,
                errorText: endDateError,
              ),
            ),
          ],
        ),
        if (startDateError != null || endDateError != null)
          Row(
            children: [
              Expanded(child: ErrorHandler.displayError(startDateError)),
              const SizedBox(width: 16),
              Expanded(child: ErrorHandler.displayError(endDateError)),
            ],
          ),
      ],
    );
  }
}

class DropdownInputRow extends StatelessWidget {
  final String? priority;
  final String? status;
  final Function(String?) onPriorityChanged;
  final Function(String?) onStatusChanged;
  final String? priorityError;
  final String? statusError;

  const DropdownInputRow({
    super.key,
    required this.priority,
    required this.status,
    required this.onPriorityChanged,
    required this.onStatusChanged,
    this.priorityError,
    this.statusError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _LabeledBox(
                label: 'Priority',
                height: 70,
                child: Container(
                  decoration: BoxDecoration(
                    border: priorityError != null && priorityError!.isNotEmpty
                        ? Border.all(color: Colors.red, width: 1.2)
                        : null,
                  ),
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
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _LabeledBox(
                label: 'Status',
                height: 70,
                child: Container(
                  decoration: BoxDecoration(
                    border: statusError != null && statusError!.isNotEmpty
                        ? Border.all(color: Colors.red, width: 1.2)
                        : null,
                  ),
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
            ),
          ],
        ),
        if (priorityError != null || statusError != null)
          Row(
            children: [
              Expanded(child: ErrorHandler.displayError(priorityError)),
              const SizedBox(width: 16),
              Expanded(child: ErrorHandler.displayError(statusError)),
            ],
          ),
      ],
    );
  }
}

class DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const DescriptionField({super.key, required this.controller, this.errorText});

  @override
  Widget build(BuildContext context) {
    return _LabeledBox(
      label: 'Description',
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Write additional details here…',
          border: InputBorder.none,
          errorText: errorText,
          errorStyle: const TextStyle(height: 0),
        ),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;

  const SaveButton({super.key, required this.onPressed, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.green : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text(
          'Save',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}

class StepList extends StatelessWidget {
  final List<String> steps;
  final void Function(String) onAddStep;
  final void Function(int) onDeleteStep;
  final void Function(int, String) onEditStep;
  final void Function(int, int) onReorderSteps;

  const StepList({
    super.key,
    required this.steps,
    required this.onAddStep,
    required this.onDeleteStep,
    required this.onEditStep,
    required this.onReorderSteps,
  });

  void _showStepOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () async {
              Navigator.pop(context);
              final controller = TextEditingController(text: steps[index]);
              final result = await showDialog<String>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Edit Step'),
                  content: TextField(controller: controller),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) Navigator.pop(context, text);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
              if (result != null) {
                onEditStep(index, result);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              onDeleteStep(index);
            },
          ),
        ],
      ),
    );
  }

  void _handleAddStep(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Step'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.pop(context, text);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null) onAddStep(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton.icon(
                onPressed: () => _handleAddStep(context),
                icon: const Icon(Icons.add),
                label: const Text('Add detail'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (steps.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No detail specified.', style: TextStyle(color: Colors.grey[600])),
              ),
            )
          else
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: onReorderSteps,
              children: List.generate(steps.length, (index) {
                return GestureDetector(
                  key: Key('$index'),
                  onLongPress: () => _showStepOptions(context, index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      steps[index],
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

class _LabeledBox extends StatelessWidget {
  final String label;
  final Widget child;
  final double? height;

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
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
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
                ),
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