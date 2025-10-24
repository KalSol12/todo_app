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
        scaffoldBackgroundColor: Colors.grey[200],
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
    _loadTasks(); // Load saved tasks when app starts
  }

  // ✅ Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('tasks');
    if (savedData != null) {
      setState(() {
        _tasks.clear();
        _tasks.addAll(List<Map<String, dynamic>>.from(json.decode(savedData)));
      });
    }
  }

  // ✅ Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', json.encode(_tasks));
  }

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _tasks.add({'title': text, 'done': false});
      });
      _controller.clear();
      _saveTasks(); // Save changes
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['done'] = !_tasks[index]['done'];
    });
    _saveTasks(); // Save changes
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks(); // Save changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List 📝'),
        centerTitle: true,
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.add),
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
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Checkbox(
                            value: task['done'],
                            onChanged: (_) => _toggleTask(index),
                          ),
                          title: Text(
                            task['title'],
                            style: TextStyle(
                              decoration: task['done']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color:
                                  task['done'] ? Colors.grey : Colors.black87,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(index),
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
