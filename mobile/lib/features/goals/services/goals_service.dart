import 'package:dio/dio.dart';
import 'package:mobile/features/goals/models/goals_model.dart';

class GoalsService {
  final Dio _client;

  GoalsService(this._client);

  Future<GoalsResponse> getCurrentGoals({
    required String dateFrom,
    required String dateTo,
  }) async {
    try {
      final response = await _client.post(
        '/api/goals/current',
        data: {
          'date_from': dateFrom,
          'date_to': dateTo,
        },
      );

      return GoalsResponse.fromJson(response.data);
    } catch (e) {
      print('Error fetching current goals: $e');
      rethrow;
    }
  }

  Future<GoalsResponse> getPreviousGoals({
    required String dateFrom,
    required String dateTo,
  }) async {
    try {
      final response = await _client.post(
        '/api/goals/previous',
        data: {
          'date_from': dateFrom,
          'date_to': dateTo,
        },
      );

      return GoalsResponse.fromJson(response.data);
    } catch (e) {
      print('Error fetching previous goals: $e');
      rethrow;
    }
  }
}
