import 'package:flutter/material.dart';
import '../database/task_database.dart';
import '../models/subtask.dart';
import '../models/task.dart';

class EditTaskPopup extends StatefulWidget {
  final Task task;

  const EditTaskPopup({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskPopup> createState() => _EditTaskPopupState();
}

class _EditTaskPopupState extends State<EditTaskPopup> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _difficulty;
  late DateTime _selectedDate;

  List<Subtask> _subtasks = [];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController = TextEditingController(text: widget.task.description);
    _difficulty = widget.task.difficulty;
    _selectedDate = widget.task.date;

    _loadSubtasks();
  }

  Future<void> _loadSubtasks() async {
    final result = await TaskDatabase.instance.getSubtasks(widget.task.id!);
    if (!mounted) return;
    setState(() => _subtasks = result);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;
    setState(() => _selectedDate = pickedDate);
  }

  Future<void> _save() async {
    await TaskDatabase.instance.updateTask(
      widget.task.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        difficulty: _difficulty,
        date: _selectedDate,
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _addSubtask() async {
    await TaskDatabase.instance.insertSubtask(
      Subtask(
        parentTaskId: widget.task.id!,
        name: 'New subtask',
        isValid: false,
      ),
    );

    await _loadSubtasks();
  }

  Future<bool> _confirmDeleteSubtask() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete subtask?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    return result == true;
  }

  Widget _difficultyButton(String value, String label) {
    final selected = _difficulty == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _difficulty = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 27,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2B2B2B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF111111), width: 1.4),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF111111),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _subtaskLine(Subtask subtask) {
    return Dismissible(
      key: ValueKey(subtask.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await TaskDatabase.instance.updateSubtask(subtask.copyWith(isValid: true));
          await _loadSubtasks();
          return false;
        }

        if (subtask.isValid) {
          await TaskDatabase.instance.updateSubtask(subtask.copyWith(isValid: false));
          await _loadSubtasks();
          return false;
        }

        final confirmed = await _confirmDeleteSubtask();

        if (confirmed) {
          await TaskDatabase.instance.deleteSubtask(subtask.id!);
          await _loadSubtasks();
        }

        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 12),
        color: const Color(0xFF00B86B),
        child: const Text('VALID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 12),
        color: const Color(0xFFFF3333),
        child: const Text('DELETE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
      ),
      child: Container(
        height: 34,
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: subtask.isValid ? const Color(0xFFE8FFF2) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: subtask.isValid ? const Color(0xFF00B86B) : const Color(0xFF111111),
            width: 1.4,
          ),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          initialValue: subtask.name,
          onFieldSubmitted: (value) async {
            await TaskDatabase.instance.updateSubtask(subtask.copyWith(name: value.trim()));
            await _loadSubtasks();
          },
          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF111111), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Edit Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                decoration: const InputDecoration(labelText: 'Name', isDense: true, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 9),
              Scrollbar(
                child: TextField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(labelText: 'Description', isDense: true, border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Difficulty', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  _difficultyButton('easy', 'Easy'),
                  const SizedBox(width: 7),
                  _difficultyButton('medium', 'Medium'),
                  const SizedBox(width: 7),
                  _difficultyButton('hard', 'Hard'),
                ],
              ),
              const SizedBox(height: 11),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  height: 33,
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: const Color(0xFF111111), width: 1.4),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text('Date : ${_formatDate(_selectedDate)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 13),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Subtasks', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 7),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 175),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final subtask in _subtasks) _subtaskLine(subtask),
                    Center(
                      child: GestureDetector(
                        onTap: _addSubtask,
                        child: Container(
                          width: 42,
                          height: 26,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF111111), width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: const Text('+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, height: 1)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel'))),
                  const SizedBox(width: 9),
                  Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Save'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}