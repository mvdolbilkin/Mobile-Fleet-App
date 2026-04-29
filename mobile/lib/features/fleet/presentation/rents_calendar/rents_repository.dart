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

    final response = await dio.post(
      '/api/vehicles/by-days', // Note: mapped to /api/vehicles/by-days based on our go routes
      data: {
        'from': isoDate,
        'days': days,
        'limit': limit,
        'offset': offset,
        'filter': filterData,
      },
      options: Options(headers: {'X-Park-ID': parkId}),
    );

    return RentsCalendarResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
