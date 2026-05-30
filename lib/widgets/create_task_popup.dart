import 'package:flutter/material.dart';
import '../database/task_database.dart';
import '../models/task.dart';

class CreateTaskPopup extends StatefulWidget {
  const CreateTaskPopup({super.key});

  @override
  State<CreateTaskPopup> createState() => _CreateTaskPopupState();
}

class _CreateTaskPopupState extends State<CreateTaskPopup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _difficulty = 'easy';
  DateTime _selectedDate = DateTime.now();

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
    if (_nameController.text.trim().isEmpty) return;

    await TaskDatabase.instance.insertTask(
      Task(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        difficulty: _difficulty,
        date: _selectedDate,
        status: 'actual',
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF111111), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Create Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
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