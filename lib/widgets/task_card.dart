import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  Color _difficultyColor() {
    switch (task.difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF00B86B);
      case 'medium':
        return const Color(0xFFE0B800);
      case 'hard':
        return const Color(0xFFFF3333);
      default:
        return const Color(0xFF333333);
    }
  }

  String _formatDate() {
    final day = task.date.day.toString().padLeft(2, '0');
    final month = task.date.month.toString().padLeft(2, '0');
    final year = task.date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
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
              right: 80,
              child: Text(
                task.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF111111),
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
                style: TextStyle(
                  color: _difficultyColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Text(
                _formatDate(),
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}