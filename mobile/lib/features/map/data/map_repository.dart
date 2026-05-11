import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/map/domain/map_driver.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/shared/providers/logger_provider.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(loggerProvider);
  return MapRepository(dio: dio, logger: logger);
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

final mapFilterProvider =
    StateNotifierProvider<MapFilterNotifier, MapFilterState>((ref) {
  return MapFilterNotifier();
});

final workRulesProvider = FutureProvider<List<WorkRule>>((ref) async {
  final repo = ref.watch(mapRepositoryProvider);
  return repo.fetchWorkRules();
});

List<MapCombinedDriver> _applySortToDrivers(
    List<MapCombinedDriver> drivers, MapFilterState filter) {
  final list = [...drivers];
  switch (filter.sortField) {
    case 'full_name':
      list.sort((a, b) => filter.sortDirection == 'asc'
          ? a.fullName.compareTo(b.fullName)
          : b.fullName.compareTo(a.fullName));
      break;
    case 'balance':
      list.sort((a, b) => filter.sortDirection == 'asc'
          ? a.balance.compareTo(b.balance)
          : b.balance.compareTo(a.balance));
      break;
    default:
      list.sort(
          (a, b) => b.statusDurationSeconds.compareTo(a.statusDurationSeconds));
  }
  return list;
}

final filteredDriverListProvider =
    FutureProvider<List<MapCombinedDriver>>((ref) async {
  final filter = ref.watch(mapFilterProvider);
  final data = await ref.watch(mapDataProvider.future);
  return _applySortToDrivers(data.combinedDrivers, filter);
});

final mapDataProvider = FutureProvider<MapCombinedData>((ref) async {
  final repo = ref.watch(mapRepositoryProvider);
  final filter = ref.watch(mapFilterProvider);
  final points = await repo.fetchDriverPoints(
    filter: filter.hasServerFilters ? filter : null,
  );
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
  final dynamic _logger;

  MapRepository({required Dio dio, dynamic logger})
      : _dio = dio,
        _logger = logger;

  Future<MapDriversPointsResponse> fetchDriverPoints(
      {MapFilterState? filter}) async {
    final payload = filter != null ? filter.toServerBody() : <String, dynamic>{};
    _logger?.i('fetchDriverPoints payload: ${jsonEncode(payload)}');
    final response = await _dio.post(
      'api/map/drivers/points',
      data: filter != null ? filter.toServerBody() : null,
    );
    _logger?.i('fetchDriverPoints response: ${response.statusCode}, items: ${(response.data as Map<String, dynamic>)['items']?.length ?? 0}');
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

  Future<List<WorkRule>> fetchWorkRules() async {
    final response = await _dio.post(
      'api/map/work-rules',
      data: {'is_archived': false},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['light_work_rules'] as List<dynamic>? ?? [];
    return items
        .map((e) => WorkRule.fromJson(e as Map<String, dynamic>))
        .toList();
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

  Future<SurgeResponse> fetchSurge(double lat, double lon) async {
    final response = await _dio.post(
      'api/map/surge',
      data: {'lat': lat, 'lon': lon, 'options': ['surge_raw']},
    );
    return SurgeResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
