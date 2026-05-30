import 'package:flutter/material.dart';
import '../../database/task_database.dart';
import '../../models/task.dart';
import '../../widgets/edit_task_popup.dart';
import '../../widgets/task_card.dart';

class IncomingTab extends StatefulWidget {
  final Future<void> Function() onDataChanged;

  const IncomingTab({
    super.key,
    required this.onDataChanged,
  });

  @override
  State<IncomingTab> createState() => _IncomingTabState();
}

class _IncomingTabState extends State<IncomingTab> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskDatabase.instance.getIncomingTasks();

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

  Future<void> _openEditPopup(Task task) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => EditTaskPopup(task: task),
    );

    if (saved == true) {
      await _refreshAll();
    }
  }

  Widget _emptyMessage() {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: Text(
          'No incoming task',
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
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            children: [
              if (_tasks.isEmpty) _emptyMessage(),
              for (final task in _tasks)
                TaskCard(
                  task: task,
                  onTap: () => _openEditPopup(task),
                ),
            ],
          ),
        ),
      ),
    );
  }
}