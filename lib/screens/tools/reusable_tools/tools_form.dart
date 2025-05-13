import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:software_development/widgets/reusable_tools.dart';
import 'package:software_development/utils/error_handler.dart';
import 'package:software_development/screens/tools/todo_tools/todo_selection.dart';
import 'package:software_development/screens/tools/workout_tools/workout_selection.dart';

class ToolsForm extends StatefulWidget {
  final String toolType;
  final String titleLabel;
  final List<String> priorityOptions;
  final List<String> statusOptions;
  final String collectionPath;
  final Map<String, dynamic> additionalData;
  final bool requireSteps;
  final String parentType;
  final List<Map<String, String>>? prebuiltSteps;
  final bool includeSaveButton;
  final VoidCallback? onFormChanged;

  const ToolsForm({
    super.key,
    required this.toolType,
    required this.titleLabel,
    required this.priorityOptions,
    required this.statusOptions,
    required this.collectionPath,
    this.additionalData = const {},
    this.requireSteps = true,
    required this.parentType,
    this.prebuiltSteps,
    this.includeSaveButton = true,
    this.onFormChanged,
  });

  @override
  State<ToolsForm> createState() => ToolsFormState();
}

class ToolsFormState extends State<ToolsForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final GlobalKey<ToolsFormState> _formKey = GlobalKey<ToolsFormState>();

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

  @override
  void initState() {
    super.initState();
    // Add listeners to text controllers to trigger onFormChanged
    _titleController.addListener(_handleFormChanged);
    _descController.addListener(_handleFormChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_handleFormChanged);
    _descController.removeListener(_handleFormChanged);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleFormChanged() {
    widget.onFormChanged?.call();
  }

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
        _handleFormChanged();
      });
    }
  }

  void _addStep(String step) {
    setState(() {
      steps.add(step);
      _handleFormChanged();
    });
  }

  void _deleteStep(int index) {
    setState(() {
      steps.removeAt(index);
      _handleFormChanged();
    });
  }

  void _editStep(int index, String newText) {
    setState(() {
      steps[index] = newText;
      _handleFormChanged();
    });
  }

  void _reorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex--;
      final step = steps.removeAt(oldIndex);
      steps.insert(newIndex, step);
      _handleFormChanged();
    });
  }

  bool _isSaveEnabled() {
    return _titleController.text.isNotEmpty &&
        _startDate != null &&
        _endDate != null &&
        _priority != null &&
        _status != null &&
        _descController.text.isNotEmpty &&
        (!widget.requireSteps || steps.isNotEmpty);
  }

  void _handleSave() {
    if (!_isSaveEnabled()) return;
    _saveTask();
  }

  // Public methods for external access
  void save() => _handleSave();
  bool isSaveEnabled() => _isSaveEnabled();

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
      print('Validation failed: titleError=$_titleError, startDateError=$_startDateError, '
          'endDateError=$_endDateError, priorityError=$_priorityError, '
          'statusError=$_statusError, descError=$_descError');
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print('No user logged in');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final toolData = {
      'toolType': widget.toolType,
      'title': title,
      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
      'priority': _priority,
      'status': _status,
      'description': desc,
      'steps': widget.requireSteps ? steps : [],
      'createdAt': FieldValue.serverTimestamp(),
      if (widget.collectionPath == 'workout' && widget.prebuiltSteps != null)
        'prebuiltSteps': widget.prebuiltSteps,
      ...widget.additionalData,
    };

    print('Attempting to save task for user: $uid, toolType: ${widget.toolType}, '
        'collectionPath: ${widget.collectionPath}, data: $toolData');

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('userData')
          .doc(uid)
          .collection('tools')
          .doc(widget.collectionPath)
          .collection('tasks')
          .add(toolData);

      print('Task saved successfully with ID: ${docRef.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.titleLabel} saved to database!')),
      );

      // Reset form
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
        _handleFormChanged();
      });

      // Navigate to parent selection screen after save
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.pop(context);
        if (widget.parentType == 'todo') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ToDoTypeSelectionScreen()),
          );
        } else if (widget.parentType == 'workout') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WorkoutSelectionScreen()),
          );
        }
      }
    } catch (e) {
      print('Error saving task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskTitleInput(controller: _titleController),
                ErrorHandler.displayError(_titleError),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateInputRow(
                  startDate: _startDate,
                  endDate: _endDate,
                  onStartTap: () => _selectDate(true),
                  onEndTap: () => _selectDate(false),
                ),
                if (_startDateError != null || _endDateError != null)
                  Row(
                    children: [
                      Expanded(child: ErrorHandler.displayError(_startDateError)),
                      const SizedBox(width: 16),
                      Expanded(child: ErrorHandler.displayError(_endDateError)),
                    ],
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownInputRow(
                  priority: _priority,
                  status: _status,
                  onPriorityChanged: (v) => setState(() {
                    _priority = v;
                    _handleFormChanged();
                  }),
                  onStatusChanged: (v) => setState(() {
                    _status = v;
                    _handleFormChanged();
                  }),
                  priorityOptions: widget.priorityOptions,
                  statusOptions: widget.statusOptions,
                ),
                if (_priorityError != null || _statusError != null)
                  Row(
                    children: [
                      Expanded(child: ErrorHandler.displayError(_priorityError)),
                      const SizedBox(width: 16),
                      Expanded(child: ErrorHandler.displayError(_statusError)),
                    ],
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DescriptionField(controller: _descController),
                ErrorHandler.displayError(_descError),
              ],
            ),
            if (widget.requireSteps)
              StepList(
                steps: steps,
                onAddStep: _addStep,
                onDeleteStep: _deleteStep,
                onEditStep: _editStep,
                onReorderSteps: _reorderSteps,
              ),
            if (widget.includeSaveButton) ...[
              const SizedBox(height: 20),
              SaveButton(
                onPressed: _handleSave,
                isEnabled: _isSaveEnabled(),
              ),
            ],
          ],
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
                      overflow: TextOverflow.ellipsis,
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