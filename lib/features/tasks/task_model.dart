class Task {
  final String id;
  String title;
  String note;
  String priority; // 'Low', 'Medium', 'High'
  DateTime? dueDate;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.note = '',
    this.priority = 'Medium',
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'note': note,
    'priority': priority,
    'dueDate': dueDate?.toIso8601String(),
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id: j['id'],
    title: j['title'],
    note: j['note'] ?? '',
    priority: j['priority'] ?? 'Medium',
    dueDate: j['dueDate'] != null ? DateTime.parse(j['dueDate']) : null,
    isCompleted: j['isCompleted'] ?? false,
    createdAt: DateTime.parse(j['createdAt']),
  );
}
