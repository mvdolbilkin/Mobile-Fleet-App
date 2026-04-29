import 'package:dio/dio.dart';
import 'package:mobile/features/summary/models/profile_model.dart';
import 'package:mobile/features/summary/models/active_drivers_model.dart';
import 'package:intl/intl.dart';

class SummaryService {
  final Dio _client;

  SummaryService(this._client);

  Future<ProfileResponse> getProfile() async {
    final response = await _client.get('/api/summary/profile');
    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(response.data);
    } else {
      throw Exception('Не удалось загрузить данные профиля: ${response.statusMessage}');
    }
  }

  Future<ActiveDriversResponse> getActiveDrivers() async {
    final now = DateTime.now();
    // Monday of current week
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    // Sunday of current week
    final currentWeekEnd = currentWeekStart.add(Duration(days: 6));
    
    final dateFormat = DateFormat('yyyy-MM-dd');
    final dateFrom = dateFormat.format(currentWeekStart);
    final dateTo = dateFormat.format(currentWeekEnd);

    try {
      final response = await _client.post(
        '/api/summary/active-drivers',
        data: {
          'date_from': dateFrom,
          'date_to': dateTo,
        },
      );

      if (response.statusCode == 200) {
        return ActiveDriversResponse.fromJson(response.data);
      }
      throw Exception('Не удалось загрузить данные: ${response.statusMessage}');
    } on DioException catch (e) {
      throw Exception('Не удалось загрузить данные активных водителей: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Непредвиденная ошибка: $e');
    }
  }
}
