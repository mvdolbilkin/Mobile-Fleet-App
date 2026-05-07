import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/reports/domain/car_summary.dart';
import 'package:mobile/features/reports/domain/park_summary.dart';
import 'package:mobile/features/reports/domain/driver_summary.dart';
import 'package:mobile/shared/api/dio_provider.dart';

final summaryReportServiceProvider = Provider<SummaryReportService>((ref) {
  return SummaryReportService(ref.watch(dioProvider));
});

class SummaryReportService {
  final Dio _dio;
  SummaryReportService(this._dio);

  Future<DriverSummaryResponse> getDriversSummary({
    required String dateFrom,
    required String dateTo,
    String sortField = 'driver_id',
    String sortDirection = 'asc',
  }) async {
    final response = await _dio.post(
      'api/reports/summary/drivers/list',
      data: {
        'limit': 25,
        'date_from': dateFrom,
        'date_to': dateTo,
        'sort': {'field': sortField, 'direction': sortDirection},
      },
    );
    return DriverSummaryResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<CarSummaryResponse> getCarsSummary({
    required String dateFrom,
    required String dateTo,
    String sortField = 'car_id',
    String sortDirection = 'asc',
  }) async {
    final response = await _dio.post(
      'api/reports/summary/cars/list',
      data: {
        'page': 1,
        'limit': 25,
        'date_from': dateFrom,
        'date_to': dateTo,
        'sort': {'field': sortField, 'direction': sortDirection},
      },
    );
    return CarSummaryResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<ParkSummaryResponse> getParksSummary() async {
    final response = await _dio.post(
      'api/reports/summary/parks/list',
      data: {},
    );
    return ParkSummaryResponse.fromJson(
        response.data as Map<String, dynamic>);
  }
}
