part of 'api_manager.dart';

extension TaskApi on ApiManager {
  Map<String, String> _authHeaders() {
    final box = Hive.box('userData');
    final tok = box.get('token') as String? ?? '';
    return {
      'Content-Type': 'application/json',
      if (tok.isNotEmpty) 'Authorization': 'Bearer $tok',
    };
  }

  Future<List<TaskModel>> getMyTasks() async {
    final response = await get('tasks', headers: _authHeaders());
    final list = (response['tasks'] as List? ?? []);
    return list
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    String status = 'pending',
    DateTime? dueDate,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'status': status,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (dueDate != null) 'due_date': dueDate.toIso8601String(),
    };

    final response = await post('tasks', body, headers: _authHeaders());

    return TaskModel.fromJson(response['task']);
  }

  Future<TaskModel> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
  }) async {
    final body = <String, dynamic>{
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (dueDate != null) 'due_date': dueDate.toIso8601String(),
    };

    final response = await put('tasks/$taskId', body, headers: _authHeaders());

    return TaskModel.fromJson(response['task']);
  }

  Future<void> deleteTask(String taskId) async {
    await delete('tasks/$taskId', headers: _authHeaders());
  }
}
