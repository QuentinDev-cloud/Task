import 'package:flutter/material.dart';
import '../../database/task_database.dart';
import '../../models/task.dart';
import '../../widgets/edit_task_popup.dart';
import '../../widgets/task_card.dart';

class DoneTab extends StatefulWidget {
  final Future<void> Function() onDataChanged;

  const DoneTab({
    super.key,
    required this.onDataChanged,
  });

  @override
  State<DoneTab> createState() => _DoneTabState();
}

class _DoneTabState extends State<DoneTab> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _prepareAndLoad();
  }

  Future<void> _prepareAndLoad() async {
    await TaskDatabase.instance.cleanupOldDoneTasks();
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskDatabase.instance.getDoneTasks();

    if (!mounted) return;

    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _refreshAll() async {
    await _prepareAndLoad();
    await widget.onDataChanged();
  }

  Future<void> _openEditPopup(Task task) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => EditTaskPopup(task: task),
    );

    if (saved == true) {
      await _refreshAll();
    }
  }

  Widget _taskSwipe(Task task) {
    return Dismissible(
      key: ValueKey(task.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await TaskDatabase.instance.updateTask(
            task.copyWith(status: 'actual'),
          );

          await _refreshAll();
          return false;
        }

        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'RESTORE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      child: TaskCard(
        task: task,
        onTap: () => _openEditPopup(task),
      ),
    );
  }

  Widget _emptyMessage() {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: Text(
          'No done task',
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
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(2),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              if (_tasks.isEmpty) _emptyMessage(),
              for (final task in _tasks) _taskSwipe(task),
            ],
          ),
        ),
      ),
    );
  }
}