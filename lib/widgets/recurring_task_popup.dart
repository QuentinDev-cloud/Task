import 'package:flutter/material.dart';
import '../database/task_database.dart';
import '../models/recurring_task.dart';

class RecurringTaskPopup extends StatefulWidget {
  final RecurringTask? task;

  const RecurringTaskPopup({
    super.key,
    this.task,
  });

  @override
  State<RecurringTaskPopup> createState() => _RecurringTaskPopupState();
}

class _RecurringTaskPopupState extends State<RecurringTaskPopup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _difficulty = 'easy';
  String _recurrenceType = 'weekly';
  int _recurrenceValue = 1;

  final List<String> _difficulties = ['easy', 'medium', 'hard'];

  final Map<int, String> _weekDays = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _nameController.text = widget.task!.name;
      _descriptionController.text = widget.task!.description;
      _difficulty = widget.task!.difficulty;
      _recurrenceType = widget.task!.recurrenceType;
      _recurrenceValue = widget.task!.recurrenceValue;
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;

    final recurringTask = RecurringTask(
      id: widget.task?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      difficulty: _difficulty,
      recurrenceType: _recurrenceType,
      recurrenceValue: _recurrenceValue,
      lastGeneratedDate: widget.task?.lastGeneratedDate,
    );

    if (widget.task == null) {
      await TaskDatabase.instance.insertRecurringTask(recurringTask);
    } else {
      await TaskDatabase.instance.updateRecurringTask(recurringTask);
    }

    await TaskDatabase.instance.generateRecurringTasksIfNeeded();

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
            border: Border.all(
              color: const Color(0xFF111111),
              width: 1.4,
            ),
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

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _recurrenceTypeButton(String value, String label) {
    final selected = _recurrenceType == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _recurrenceType = value;
            _recurrenceValue = value == 'weekly' ? 1 : 1;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 29,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2B2B2B) : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFF111111),
              width: 1.4,
            ),
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

  Widget _recurrenceValueSelector() {
    if (_recurrenceType == 'daily') {
      return Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: const Color(0xFF111111),
            width: 1.4,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: const Text(
          'Every day',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    if (_recurrenceType == 'weekly') {
      return Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: const Color(0xFF111111),
            width: 1.4,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _recurrenceValue,
            isExpanded: true,
            iconSize: 18,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            items: _weekDays.entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text('Every ${entry.value}'),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _recurrenceValue = value);
            },
          ),
        ),
      );
    }

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFF111111),
          width: 1.4,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _recurrenceValue,
          isExpanded: true,
          iconSize: 18,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          items: List.generate(31, (index) => index + 1).map((day) {
            return DropdownMenuItem<int>(
              value: day,
              child: Text('Every $day of month'),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _recurrenceValue = value);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.task == null ? 'Create Recurring Task' : 'Edit Recurring Task';

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFF111111),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 9),
              Scrollbar(
                child: TextField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _sectionTitle('Difficulty'),
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
              const SizedBox(height: 13),
              _sectionTitle('Recurrence'),
              const SizedBox(height: 7),
              Row(
                children: [
                  _recurrenceTypeButton('daily', 'Daily'),
                  const SizedBox(width: 7),
                  _recurrenceTypeButton('weekly', 'Weekly'),
                  const SizedBox(width: 7),
                  _recurrenceTypeButton('monthly', 'Monthly'),
                ],
              ),
              const SizedBox(height: 9),
              _recurrenceValueSelector(),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
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