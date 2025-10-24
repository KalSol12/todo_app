import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _sortTasks() {
  _tasks.sort((a, b) {
    // Incomplete tasks first
    final doneA = a['done'] ?? false;
    final doneB = b['done'] ?? false;
    if (doneA != doneB) return doneA ? 1 : -1;

    // Higher priority first
    final priorityA = a['priority'] ?? 1;
    final priorityB = b['priority'] ?? 1;
    if (priorityA != priorityB) return priorityB - priorityA;

    // Older tasks first
    final dateA = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.now();
    final dateB = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime.now();
    return dateA.compareTo(dateB);
  });
}


 Future<void> _loadTasks() async {
  final prefs = await SharedPreferences.getInstance();
  final savedData = prefs.getString('tasks');
  if (savedData != null) {
    final loadedTasks = List<Map<String, dynamic>>.from(json.decode(savedData));
    setState(() {
      _tasks.clear();
      _tasks.addAll(
        loadedTasks.map((task) => {
          'title': task['title'] ?? '',
          'done': task['done'] ?? false,
          'priority': task['priority'] ?? 1,
          'timestamp': task['timestamp'] ?? DateTime.now().toString(),
        }),
      );
      _sortTasks(); // <-- sort after loading
    });
  }
}

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', json.encode(_tasks));
  }

  void _addTask({int priority = 1}) {
  final text = _controller.text.trim();
  if (text.isNotEmpty) {
    setState(() {
      _tasks.add({
        'title': text,
        'done': false,
        'priority': priority,
        'timestamp': DateTime.now().toString(),
      });
      _sortTasks(); // <-- sort after adding
    });
    _controller.clear();
    _saveTasks();
  }
}

  void _toggleTask(int index) {
  setState(() {
    _tasks[index]['done'] = !(_tasks[index]['done'] ?? false);
    _sortTasks(); // <-- sort after toggling
  });
  _saveTasks();
}

  void _deleteTask(int index) {
  setState(() {
    _tasks.removeAt(index);
    _sortTasks(); // <-- sort after deleting
  });
  _saveTasks();
}

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List 📝'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Enter a new task',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<int>(
                  icon: const Icon(Icons.add_circle, size: 36, color: Colors.purple),
                  onSelected: (priority) => _addTask(priority: priority),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 1, child: Text('Low Priority')),
                    PopupMenuItem(value: 2, child: Text('Medium Priority')),
                    PopupMenuItem(value: 3, child: Text('High Priority')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks yet — add one!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      final done = task['done'] ?? false;
                      final priority = task['priority'] ?? 1;
                      final title = task['title'] ?? '';
                      final timestamp = task['timestamp'] ?? DateTime.now().toString();

                      return Dismissible(
                        key: Key(title + index.toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteTask(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: done
                                ? LinearGradient(
                                    colors: [Colors.grey.shade300, Colors.grey.shade100],
                                  )
                                : LinearGradient(
                                    colors: [priorityColor(priority), Colors.white],
                                  ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Checkbox(
                                key: ValueKey(done),
                                value: done,
                                onChanged: (_) => _toggleTask(index),
                                activeColor: Colors.purple,
                              ),
                            ),
                            title: Text(
                              title,
                              style: TextStyle(
                                decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
                                color: done ? Colors.grey : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Added: ${timestamp.substring(0, 16)}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
