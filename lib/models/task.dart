class Task {
  String title;
  bool done;
  int priority;
  String timestamp;

  Task({
    required this.title,
    this.done = false,
    this.priority = 1,
    String? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toString();

  // Convert Task to Map
  Map<String, dynamic> toMap() => {
        'title': title,
        'done': done,
        'priority': priority,
        'timestamp': timestamp,
      };

  // Create Task from Map
  factory Task.fromMap(Map<String, dynamic> map) => Task(
        title: map['title'],
        done: map['done'],
        priority: map['priority'],
        timestamp: map['timestamp'],
      );
}
