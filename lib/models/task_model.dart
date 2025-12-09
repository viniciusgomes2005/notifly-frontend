class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String status;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.status = 'pending',
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> j) {
    final rawId = j['task_id'] ?? j['id'];
    return TaskModel(
      id: rawId?.toString() ?? '',
      userId: (j['user_id'] ?? '').toString(),
      title: j['title'] ?? '',
      description: j['description'],
      status: j['status'] ?? 'pending',
      dueDate: j['due_date'] != null
          ? DateTime.tryParse(j['due_date'].toString())
          : null,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'].toString())
          : null,
      updatedAt: j['updated_at'] != null
          ? DateTime.tryParse(j['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'task_id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'status': status,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  TaskModel copyWeird({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
