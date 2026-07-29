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

  // Récupérer toutes les tâches
  Future<List<Task>> fetchTasks() async {
    try {
      final response = await _dio.get('/tasks');

      final data = response.data;

      if (data is! List) {
        throw TaskApiException('Format de réponse invalide.');
      }

      return data
          .map((json) => Task.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on DioException catch (e) {
      throw TaskApiException(_getErrorMessage(e));
    } catch (e) {
      if (e is TaskApiException) {
        rethrow;
      }

      throw TaskApiException('Une erreur inattendue est survenue.');
    }
  }

  // Ajouter une nouvelle tâche
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

      return Task.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw TaskApiException(_getErrorMessage(e));
    } catch (e) {
      throw TaskApiException('Impossible de créer la tâche.');
    }
  }

  // Modifier une tâche
  Future<Task> updateTask(Task task) async {
    try {
      final response = await _dio.patch(
        '/tasks/${task.id}',
        data: task.toJson(),
      );

      return Task.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw TaskApiException(_getErrorMessage(e));
    } catch (e) {
      throw TaskApiException('Impossible de modifier la tâche.');
    }
  }

  // Supprimer une tâche
  Future<void> deleteTask(int id) async {
    try {
      await _dio.delete('/tasks/$id');
    } on DioException catch (e) {
      throw TaskApiException(_getErrorMessage(e));
    } catch (e) {
      throw TaskApiException('Impossible de supprimer la tâche.');
    }
  }

  String _getErrorMessage(DioException error) {
    if (error.response != null) {
      return 'Erreur serveur : ${error.response?.statusCode}';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Le serveur met trop de temps à répondre.';

      case DioExceptionType.connectionError:
        return 'Impossible de se connecter au serveur.';

      default:
        return 'Une erreur réseau est survenue.';
    }
  }
}
