import 'package:flutter/material.dart';
import 'package:software_development/widgets/reusable_tools.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ToDoToolPage extends StatefulWidget {
  const ToDoToolPage({super.key});

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

  void _saveTask() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final todoData = {
      'taskType': 'todo', // Hardcoded task type
      'title': _titleController.text.trim(),
      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
      'priority': _priority,
      'status': _status ?? 'Not started',
      'description': _descController.text.trim(),
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
        const SnackBar(content: Text('To‑do task saved to database!')),
      );

      setState(() {
        _titleController.clear();
        _descController.clear();
        _startDate = null;
        _endDate = null;
        _priority = null;
        _status = null;
        steps.clear();
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
      appBar: AppBar(title: const Text('Create To‑do List')),
      backgroundColor: const Color(0xFFF0F6F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TaskTitleInput(controller: _titleController),
            DateInputRow(
              startDate: _startDate,
              endDate: _endDate,
              onStartTap: () => _selectDate(true),
              onEndTap: () => _selectDate(false),
            ),
            DropdownInputRow(
              priority: _priority,
              status: _status,
              onPriorityChanged: (v) => setState(() => _priority = v),
              onStatusChanged: (v) => setState(() => _status = v),
            ),
            DescriptionField(controller: _descController),

            StepList(
              steps: steps,
              onAddStep: _addStep,
              onDeleteStep: _deleteStep,
              onEditStep: _editStep,
              onReorderSteps: _reorderSteps,
            ),

            const SizedBox(height: 20),
            SaveButton(onPressed: _saveTask),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------------------
/// Minimal note-like StepList (no toggles, just text-based steps)
/// ------------------------------------------------------------------------
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
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
          // Label + Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Steps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton.icon(
                onPressed: () => _handleAddStep(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Step'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (steps.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No steps specified.', style: TextStyle(color: Colors.grey[600])),
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
