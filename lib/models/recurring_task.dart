class RecurringTask {
  final int? id;
  final String name;
  final String description;
  final String difficulty;
  final String recurrenceType;
  final int recurrenceValue;
  final String? lastGeneratedDate;

  const RecurringTask({
    this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.recurrenceType,
    required this.recurrenceValue,
    this.lastGeneratedDate,
  });

  RecurringTask copyWith({
    int? id,
    String? name,
    String? description,
    String? difficulty,
    String? recurrenceType,
    int? recurrenceValue,
    String? lastGeneratedDate,
  }) {
    return RecurringTask(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceValue: recurrenceValue ?? this.recurrenceValue,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'recurrenceType': recurrenceType,
      'recurrenceValue': recurrenceValue,
      'lastGeneratedDate': lastGeneratedDate,
    };
  }

  static RecurringTask fromMap(Map<String, Object?> map) {
    return RecurringTask(
      id: map['id'] as int,
      name: map['name'].toString(),
      description: map['description'].toString(),
      difficulty: map['difficulty'].toString(),
      recurrenceType: map['recurrenceType'].toString(),
      recurrenceValue: map['recurrenceValue'] as int,
      lastGeneratedDate: map['lastGeneratedDate']?.toString(),
    );
  }
}