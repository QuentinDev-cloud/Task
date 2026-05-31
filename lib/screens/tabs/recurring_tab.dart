import 'package:flutter/material.dart';
import '../../database/task_database.dart';
import '../../models/recurring_task.dart';
import '../../widgets/recurring_task_popup.dart';

class RecurringTab extends StatefulWidget {
  final Future<void> Function() onDataChanged;

  const RecurringTab({
    super.key,
    required this.onDataChanged,
  });

  @override
  State<RecurringTab> createState() => _RecurringTabState();
}

class _RecurringTabState extends State<RecurringTab> {
  List<RecurringTask> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskDatabase.instance.getRecurringTasks();

    if (!mounted) return;

    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _refreshAll() async {
    await TaskDatabase.instance.generateRecurringTasksIfNeeded();
    await _loadTasks();
    await widget.onDataChanged();
  }

  Future<void> _openPopup({RecurringTask? task}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => RecurringTaskPopup(task: task),
    );

    if (saved == true) {
      await _refreshAll();
    }
  }

  Future<bool> _confirmDeleteTask() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete recurring task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return result == true;
  }

  String _recurrenceText(RecurringTask task) {
    if (task.recurrenceType == 'daily') {
      return 'Every day';
    }

    if (task.recurrenceType == 'weekly') {
      const days = {
        1: 'Monday',
        2: 'Tuesday',
        3: 'Wednesday',
        4: 'Thursday',
        5: 'Friday',
        6: 'Saturday',
        7: 'Sunday',
      };

      return 'Every ${days[task.recurrenceValue]}';
    }

    return 'Every ${task.recurrenceValue} of month';
  }

  Widget _card(RecurringTask task) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await _confirmDeleteTask();

        if (confirmed) {
          await TaskDatabase.instance.deleteRecurringTask(task.id!);
          await _refreshAll();
        }

        return false;
      },
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFF3333),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'DELETE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      background: const SizedBox(),
      child: GestureDetector(
        onTap: () => _openPopup(task: task),
        child: Container(
          height: 58,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF111111),
              width: 1.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                right: 90,
                child: Text(
                  task.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Text(
                  task.difficulty.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: Text(
                  _recurrenceText(task),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addButton() {
    return Center(
      child: GestureDetector(
        onTap: () => _openPopup(),
        child: Container(
          width: 46,
          height: 28,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF111111),
              width: 1.8,
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            '+',
            style: TextStyle(
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyMessage() {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: Text(
          'No recurring task',
          style: TextStyle(
            color: Color(0xFF777777),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: const Color(0xFF262626),
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        color: Colors.white,
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              if (_tasks.isEmpty) _emptyMessage(),
              for (final task in _tasks) _card(task),
              _addButton(),
            ],
          ),
        ),
      ),
    );
  }
}