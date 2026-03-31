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
}
