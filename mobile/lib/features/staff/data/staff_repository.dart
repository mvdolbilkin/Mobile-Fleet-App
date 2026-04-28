import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/staff/domain/staff.dart';
import 'package:mobile/shared/api/dio_provider.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return StaffRepository(dio: dio);
});

final staffListProvider = FutureProvider<List<Staff>>((ref) async {
  final repository = ref.watch(staffRepositoryProvider);
  return await repository.fetchStaff();
});

final staffProfileProvider = FutureProvider.family<Staff, String>((ref, profileId) async {
  final repository = ref.watch(staffRepositoryProvider);
  return await repository.fetchStaffProfile(profileId);
});

final driverOrdersProvider = FutureProvider.family<List<dynamic>, String>((ref, profileId) async {
  final repository = ref.watch(staffRepositoryProvider);
  
  // Рассчитываем даты внутри провайдера, чтобы избежать бесконечного цикла обновлений UI.
  // API Яндекса требует таймзону.
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  
  // Форматируем с нулями и добавляем таймзону
  String formatYandexDate(DateTime dt) {
    return '${dt.toIso8601String().split('.')[0]}+03:00'; // Упрощенный формат для примера
  }

  final fromStr = formatYandexDate(thirtyDaysAgo);
  final toStr = formatYandexDate(now);

  final data = await repository.fetchDriverOrders(profileId, fromStr, toStr);
  return data['orders'] as List<dynamic>? ?? [];
});

final carInfoProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, carId) async {
  if (carId.isEmpty) return null;
  final repository = ref.watch(staffRepositoryProvider);
  final data = await repository.fetchCarInfo(carId);
  final cars = data['cars'] as List<dynamic>? ?? [];
  if (cars.isNotEmpty) {
    return cars.first as Map<String, dynamic>;
  }
  return null;
});

class StaffRepository {
  final Dio _dio;

  StaffRepository({required Dio dio}) : _dio = dio;

  Future<List<Staff>> fetchStaff({int limit = 500, int offset = 0, int retries = 2}) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        final response = await _dio.get(
          '/api/staff/list',
          queryParameters: {
            'limit': limit,
            'offset': offset,
          },
        );

        final data = response.data;
        if (data != null && data['driver_profiles'] != null) {
          final List<dynamic> profiles = data['driver_profiles'];
          return profiles.map((json) => Staff.fromJson(json)).toList();
        }
        return [];
      } catch (e) {
        if (attempt == retries) {
          throw Exception('Failed to load staff: $e');
        }
      }
    }
    return [];
  }

  Future<Staff> fetchStaffProfile(String profileId) async {
    try {
      final response = await _dio.get(
        '/api/staff/profile',
        queryParameters: {
          'contractor_profile_id': profileId,
        },
      );

      final data = response.data;
      if (data != null) {
        return Staff.fromV2ProfileJson(profileId, data);
      }
      throw Exception('Пустой ответ от сервера');
    } catch (e) {
      throw Exception('Failed to load staff profile: $e');
    }
  }

  Future<Map<String, dynamic>> fetchDriverOrders(String profileId, String from, String to) async {
    try {
      final response = await _dio.get(
        '/api/staff/orders',
        queryParameters: {
          'contractor_profile_id': profileId,
          'from': from,
          'to': to,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception('Failed to load driver orders: $e');
    }
  }

  Future<Map<String, dynamic>> fetchCarInfo(String carId) async {
    try {
      final response = await _dio.get(
        '/api/staff/car',
        queryParameters: {
          'car_id': carId,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception('Failed to load car info: $e');
    }
  }
}
