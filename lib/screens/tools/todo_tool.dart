import 'package:flutter/material.dart';
import 'package:software_development/widgets/reusable_tools.dart';

class ToDoToolPage extends StatefulWidget {
  const ToDoToolPage({super.key});

  @override
  State<ToDoToolPage> createState() => _ToDoToolPageState();
}

class _ToDoToolPageState extends State<ToDoToolPage> {
  // Controllers & state
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController  = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _priority;
  String? _status;

  List<String> steps = [];

  // Pick start or end date
  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Add a step to the list
  void _addStep(String step) {
    setState(() {
      steps.add(step);
    });
  }

  // Save button handler
  void _saveTask() {
    // TODO: replace with your actual save logic
    print('--- To‑do Task Saved ---');
    print('Title      : ${_titleController.text}');
    print('Start Date : $_startDate');
    print('End Date   : $_endDate');
    print('Priority   : $_priority');
    print('Status     : $_status');
    print('Description: ${_descController.text}');
    print('Steps      : $steps');

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
            // Universal fields
            TaskTitleInput(controller: _titleController),
            DateInputRow(
              startDate: _startDate,
              endDate: _endDate,
              onStartTap: () => _selectDate(true),
              onEndTap:   () => _selectDate(false),
            ),
            DropdownInputRow(
              priority:         _priority,
              status:           _status,
              onPriorityChanged: (v) => setState(() => _priority = v),
              onStatusChanged:   (v) => setState(() => _status   = v),
            ),
            DescriptionField(controller: _descController),

            // To‑do‑specific Steps
            StepList(
              steps:     steps,
              onAddStep: _addStep,
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
class StepList extends StatefulWidget {
  final List<String> steps;
  final void Function(String) onAddStep;
  const StepList({super.key, required this.steps, required this.onAddStep});

  @override
  _StepListState createState() => _StepListState();
}

class _StepListState extends State<StepList> {
  late List<bool> _stepCompleted;

  @override
  void initState() {
    super.initState();
    _stepCompleted = List<bool>.filled(widget.steps.length, false);
  }

  // Ensure the stepCompleted list matches the number of steps
  @override
  void didUpdateWidget(covariant StepList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_stepCompleted.length != widget.steps.length) {
      setState(() {
        _stepCompleted = List<bool>.filled(widget.steps.length, false);
      });
    }
  }

  void _toggleCompletion(int index) {
    setState(() {
      _stepCompleted[index] = !_stepCompleted[index];
    });
  }

  void _editStep(int index) async {
    final controller = TextEditingController(text: widget.steps[index]);
    final result = await showDialog<String>(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Edit Step'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Edit step'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context, text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    });

    if (result != null) {
      setState(() {
        widget.steps[index] = result;
      });
    }
  }

  void _deleteStep(int index) {
    setState(() {
      widget.steps.removeAt(index);
      _stepCompleted.removeAt(index); // Ensure the completion state is also removed
    });
  }

  void _showStepOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editStep(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteStep(index);
              },
            ),
            ListTile(
              leading: Icon(
                _stepCompleted[index] ? Icons.undo : Icons.check,
              ),
              title: Text(
                _stepCompleted[index] ? 'Mark as Undone' : 'Mark as Done',
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleCompletion(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddStep() async {
    final dialogCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Step'),
        content: TextField(
          controller: dialogCtrl,
          decoration: const InputDecoration(hintText: 'Enter a step'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = dialogCtrl.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context, text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() {
        widget.onAddStep(result);
        _stepCompleted.add(false); // New step starts as unchecked
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Steps',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton.icon(
                onPressed: _handleAddStep,
                icon: const Icon(Icons.add),
                label: const Text('Add Step'),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Step Items
          if (widget.steps.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No steps specified.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ReorderableListView(
              shrinkWrap: true,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final step = widget.steps.removeAt(oldIndex);
                  final completion = _stepCompleted.removeAt(oldIndex);
                  widget.steps.insert(newIndex, step);
                  _stepCompleted.insert(newIndex, completion);
                });
              },
              children: List.generate(widget.steps.length, (index) {
                return GestureDetector(
                  key: Key('$index'), // Needed for reorder
                  onLongPress: () => _showStepOptions(index),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _stepCompleted[index]
                          ? Colors.green[100]
                          : Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _stepCompleted[index]
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                          onPressed: () => _toggleCompletion(index),
                        ),
                        Expanded(
                          child: Text(
                            widget.steps[index],
                            style: TextStyle(
                              fontSize: 16,
                              decoration: _stepCompleted[index]
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: _stepCompleted[index]
                                  ? Colors.black54
                                  : Colors.black87,
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
