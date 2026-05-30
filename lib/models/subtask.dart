class Subtask {
  final int? id;
  final int parentTaskId;
  final String name;
  final bool isValid;

  const Subtask({
    this.id,
    required this.parentTaskId,
    required this.name,
    required this.isValid,
  });

  Subtask copyWith({
    int? id,
    int? parentTaskId,
    String? name,
    bool? isValid,
  }) {
    return Subtask(
      id: id ?? this.id,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      name: name ?? this.name,
      isValid: isValid ?? this.isValid,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'parentTaskId': parentTaskId,
      'name': name,
      'isValid': isValid ? 1 : 0,
    };
  }

  static Subtask fromMap(Map<String, Object?> map) {
    return Subtask(
      id: map['id'] as int,
      parentTaskId: map['parentTaskId'] as int,
      name: map['name'].toString(),
      isValid: map['isValid'] == 1,
    );
  }
}