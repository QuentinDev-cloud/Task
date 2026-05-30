import 'package:flutter/material.dart';
import '../../database/task_database.dart';
import '../../models/task.dart';
import '../../widgets/create_task_popup.dart';
import '../../widgets/edit_task_popup.dart';
import '../../widgets/task_card.dart';

class ActualTab extends StatefulWidget {
  final Future<void> Function() onDataChanged;

  const ActualTab({
    super.key,
    required this.onDataChanged,
  });

  @override
  State<ActualTab> createState() => _ActualTabState();
}

class _ActualTabState extends State<ActualTab> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskDatabase.instance.getActualTasks();

    if (!mounted) return;

    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _refreshAll() async {
    await _loadTasks();
    await widget.onDataChanged();
  }

  Future<bool> _confirmDeleteTask() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete task?'),
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

  Future<void> _openCreatePopup() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => const CreateTaskPopup(),
    );

    if (saved == true) {
      await _refreshAll();
    }
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
          await TaskDatabase.instance.markTaskDone(task);
          await _refreshAll();
          return false;
        }

        final confirmed = await _confirmDeleteTask();

        if (confirmed) {
          await TaskDatabase.instance.deleteTask(task.id!);
          await _refreshAll();
        }

        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF00B86B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'DONE',
          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ),
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
          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
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
          'No actual task',
          style: TextStyle(
            color: Color(0xFF777777),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _addButton() {
    return Center(
      child: GestureDetector(
        onTap: _openCreatePopup,
        child: Container(
          width: 46,
          height: 28,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF111111),
              width: 1.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            '+',
            style: TextStyle(
              color: Color(0xFF111111),
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
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
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            children: [
              if (_tasks.isEmpty) _emptyMessage(),
              for (final task in _tasks) _taskSwipe(task),
              _addButton(),
            ],
          ),
        ),
      ),
    );
  }
}