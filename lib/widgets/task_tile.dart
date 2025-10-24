import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  Color priorityColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.redAccent;
      case 2:
        return Colors.orangeAccent;
      default:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.title + task.timestamp),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: task.done
              ? LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade100])
              : LinearGradient(colors: [priorityColor(task.priority), Colors.white]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Checkbox(
              key: ValueKey(task.done),
              value: task.done,
              onChanged: (_) => onToggle(),
              activeColor: Colors.purple,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : TextDecoration.none,
              color: task.done ? Colors.grey : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Added: ${task.timestamp.substring(0, 16)}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
