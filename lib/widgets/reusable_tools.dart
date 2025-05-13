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
  final List<String> priorityOptions;
  final List<String> statusOptions;

  const DropdownInputRow({
    super.key,
    required this.priority,
    required this.status,
    required this.onPriorityChanged,
    required this.onStatusChanged,
    required this.priorityOptions,
    required this.statusOptions,
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
              items: priorityOptions
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
              items: statusOptions
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

/// Full-width save button with rounded corners, grey when disabled, green when enabled
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