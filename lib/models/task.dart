enum TaskStatus { todo, inProgress, done }

enum TaskPriority { low, medium, high }

const taskCategories = [
  'UI Design',
  'Development',
  'Testing',
  'Documentation',
  'Planning',
];

class Task {
  final String id; // a number as text, for example 109
  String title;
  String description;
  String category;
  String assigneeId;
  DateTime dueDate;
  TaskPriority priority;
  TaskStatus status;
  String notes;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'Development',
    required this.assigneeId,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.notes = '',
  });

  // The code shown on cards, for example TM-109.
  String get code => 'TM-$id';

  // Turn a Task into a map so it can be saved as JSON text.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'assigneeId': assigneeId,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority.name,
        'status': status.name,
        'notes': notes,
      };

  // Rebuild a Task from the saved map.
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'Development',
        assigneeId: json['assigneeId'] as String,
        dueDate: DateTime.parse(json['dueDate'] as String),
        priority: TaskPriority.values.byName(json['priority'] as String),
        status: TaskStatus.values.byName(json['status'] as String),
        notes: json['notes'] as String? ?? '',
      );
}

// The next free task number: one more than the highest so far.
String nextTaskId(List<Task> tasks) {
  var highest = 100;
  for (final task in tasks) {
    final number = int.tryParse(task.id) ?? 0;
    if (number > highest) highest = number;
  }
  return '${highest + 1}';
}
