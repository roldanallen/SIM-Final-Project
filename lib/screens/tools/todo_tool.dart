import 'package:flutter/material.dart';
import 'package:software_development/widgets/reusable_tools.dart';

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
  List<bool> stepCompleted = [];

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
      stepCompleted.add(false);
    });
  }

  void _deleteStep(int index) {
    setState(() {
      steps.removeAt(index);
      stepCompleted.removeAt(index);
    });
  }

  void _toggleStep(int index) {
    setState(() {
      stepCompleted[index] = !stepCompleted[index];
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
      final complete = stepCompleted.removeAt(oldIndex);
      steps.insert(newIndex, step);
      stepCompleted.insert(newIndex, complete);
    });
  }

  void _saveTask() {
    print('--- To‑do Task Saved ---');
    print('Title      : ${_titleController.text}');
    print('Start Date : $_startDate');
    print('End Date   : $_endDate');
    print('Priority   : $_priority');
    print('Status     : $_status');
    print('Description: ${_descController.text}');
    print('Steps      : $steps');
    print('Completed  : $stepCompleted');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('To‑do task saved!')),
    );
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

            // Updated StepList
            StepList(
              steps: steps,
              completed: stepCompleted,
              onAddStep: _addStep,
              onDeleteStep: _deleteStep,
              onToggleStep: _toggleStep,
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
/// To‑do‑specific widget: shows current steps (or "No steps specified") +
/// an "Add Step" button that pops up an input dialog.
/// ------------------------------------------------------------------------
class StepList extends StatelessWidget {
  final List<String> steps;
  final List<bool> completed;
  final void Function(String) onAddStep;
  final void Function(int) onDeleteStep;
  final void Function(int) onToggleStep;
  final void Function(int, String) onEditStep;
  final void Function(int, int) onReorderSteps;

  const StepList({
    super.key,
    required this.steps,
    required this.completed,
    required this.onAddStep,
    required this.onDeleteStep,
    required this.onToggleStep,
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
          ListTile(
            leading: Icon(completed[index] ? Icons.undo : Icons.check),
            title: Text(completed[index] ? 'Mark as Undone' : 'Mark as Done'),
            onTap: () {
              Navigator.pop(context);
              onToggleStep(index);
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
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 14),
                    decoration: BoxDecoration(
                      color: completed[index] ? Colors.green[100] : Colors.white,
                      borderRadius: BorderRadius.circular(20), // more rounded
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // makes it shrink-wrap around contents
                      children: [
                        IconButton(
                          icon: Icon(
                            completed[index]
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                          onPressed: () => onToggleStep(index),
                        ),
                        Flexible(
                          child: Text(
                            steps[index],
                            style: TextStyle(
                              fontSize: 15,
                              decoration:
                              completed[index] ? TextDecoration.lineThrough : null,
                              color: completed[index] ? Colors.black54 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
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
