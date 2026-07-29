import 'package:dio/dio.dart';
import '../models/task.dart';

class TaskApiException implements Exception {
  final String message;
  TaskApiException(this.message);

  @override
  String toString() => message;
}

class TaskApiService {
  final Dio _dio;

  TaskApiService(this._dio);

  Future<List<Task>> fetchTasks() async {
    try {
      final response = await _dio.get('/tasks');
      final data = response.data as List;
      return data
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw TaskApiException(_messageFrom(e));
    }
  }

  Future<Task> createTask({required String title, String? description}) async {
    try {
      final response = await _dio.post(
        '/tasks',
        data: {
          'title': title,
          'description': description,
          'isDone': false,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      return Task.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw TaskApiException(_messageFrom(e));
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      final response = await _dio.put('/tasks/${task.id}', data: task.toJson());
      return Task.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw TaskApiException(_messageFrom(e));
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _dio.delete('/tasks/$id');
    } on DioException catch (e) {
      throw TaskApiException(_messageFrom(e));
    }
  }

  String _messageFrom(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Impossible de contacter le serveur.';
    }
    final status = e.response?.statusCode;
    return status != null
        ? 'Erreur serveur ($status).'
        : 'Erreur réseau inconnue.';
  }
}
