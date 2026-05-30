class Task {
  final int? id;
  final String name;
  final String description;
  final String difficulty;
  final DateTime date;
  final String status;

  const Task({
    this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.date,
    required this.status,
  });

  Task copyWith({
    int? id,
    String? name,
    String? description,
    String? difficulty,
    DateTime? date,
    String? status,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'date': _formatDbDate(date),
      'status': status,
    };
  }

  static Task fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as int,
      name: map['name'].toString(),
      description: map['description'].toString(),
      difficulty: map['difficulty'].toString(),
      date: DateTime.parse(map['date'].toString()),
      status: map['status'].toString(),
    );
  }

  String _formatDbDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year-$month-$day';
  }
}