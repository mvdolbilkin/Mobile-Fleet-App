import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/map/domain/map_driver.dart';
import 'package:mobile/shared/api/dio_provider.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MapRepository(dio: dio);
});

final driverItemProvider =
    FutureProvider.family<MapDriverItemResponse, String>((ref, driverId) async {
  final repo = ref.watch(mapRepositoryProvider);
  return repo.fetchDriverItem(driverId);
});

final driverStatusHistoryProvider =
    FutureProvider.family<MapDriverStatusHistoryResponse, String>(
        (ref, driverId) async {
  final repo = ref.watch(mapRepositoryProvider);
  return repo.fetchDriverStatusHistory(driverId);
});

final mapDataProvider = FutureProvider<MapCombinedData>((ref) async {
  final repo = ref.watch(mapRepositoryProvider);
  final points = await repo.fetchDriverPoints();
  final driverIds = points.items.map((e) => e.driverId).toList();
  if (driverIds.isEmpty) {
    return MapCombinedData(
      points: points,
      details: const MapDriversListResponse(items: []),
    );
  }
  final details = await repo.fetchDriverList(driverIds);
  return MapCombinedData(points: points, details: details);
});

class MapRepository {
  final Dio _dio;

  MapRepository({required Dio dio}) : _dio = dio;

  Future<MapDriversPointsResponse> fetchDriverPoints() async {
    final response = await _dio.post('api/map/drivers/points');
    return MapDriversPointsResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<MapDriversListResponse> fetchDriverList(List<String> driverIds) async {
    final response = await _dio.post(
      'api/map/drivers/list',
      data: {'driver_ids': driverIds},
    );
    return MapDriversListResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<MapDriverItemResponse> fetchDriverItem(String driverId) async {
    final response = await _dio.get(
      'api/map/driver/item',
      queryParameters: {'driver_id': driverId, 'show_blocked': 'false'},
    );
    return MapDriverItemResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<MapDriverStatusHistoryResponse> fetchDriverStatusHistory(
      String driverId) async {
    final response = await _dio.get(
      'api/map/driver/status-history',
      queryParameters: {'driver_id': driverId},
    );
    return MapDriverStatusHistoryResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
