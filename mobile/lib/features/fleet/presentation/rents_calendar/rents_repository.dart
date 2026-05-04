import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/features/fleet/presentation/rents_calendar/rents_calendar_models.dart';

final rentsRepositoryProvider = Provider<RentsRepository>((ref) {
  return RentsRepository(dio: ref.watch(dioProvider));
});

class RentsRepository {
  final Dio dio;

  RentsRepository({required this.dio});

  Future<RentsCalendarResponse> getVehiclesByDays({
    required String parkId,
    required DateTime dateFrom,
    required int days,
    int limit = 25,
    int offset = 0,
    bool isRental = true,
    String? searchText,
    List<String>? categories,
    List<String>? statuses,
  }) async {
    // Форматируем дату согласно примеру (добавляем смещение, если нужно, или просто ISO)
    // Простой хак для получения нужного формата с зоной +03:00
    // Если нужно конкретно +03:00, лучше юзать DateFormat из intl, но для примера достаточно:
    final isoDate = "${dateFrom.toIso8601String().split('.').first}+03:00";

    final filterData = <String, dynamic>{
      'is_rental': isRental,
      if (searchText != null && searchText.isNotEmpty) 'search_text': searchText,
      if (categories != null && categories.isNotEmpty) 'categories': categories,
      if (statuses != null && statuses.isNotEmpty) 'statuses': statuses,
    };

    final requestBody = {
      'from': isoDate,
      'days': days,
      'limit': limit,
      'offset': offset,
      'filter': filterData,
    };

    print('📅 getVehiclesByDays request: $requestBody');

    final response = await dio.post(
      '/api/vehicles/by-days',
      data: requestBody,
      options: Options(headers: {'X-Park-ID': parkId}),
    );

    print('📅 getVehiclesByDays response status: ${response.statusCode}, total: ${(response.data as Map<String, dynamic>)['total']}');

    return RentsCalendarResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DriverBalanceHistoryResponse> getDriverBalanceHistory({
    required String driverId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final response = await dio.post(
      '/api/expenses/driver/balance-history',
      data: {
        'driver_id': driverId,
        'date_from': _formatIsoDate(dateFrom),
        'date_to': _formatIsoDate(dateTo),
      },
    );

    return DriverBalanceHistoryResponse.fromJson(response.data as Map<String, dynamic>);
  }

  String _formatIsoDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    if (dt.millisecond > 0) {
      final ms = dt.millisecond.toString().padLeft(3, '0');
      return '$y-$mo-${d}T$h:$mi:$s.$ms+03:00';
    }
    return '$y-$mo-${d}T$h:$mi:$s+03:00';
  }
}
