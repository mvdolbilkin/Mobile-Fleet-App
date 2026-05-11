import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'regular_charges_models.dart';

final regularChargesRepositoryProvider = Provider<RegularChargesRepository>((ref) {
  return RegularChargesRepository(ref.read(dioProvider));
});

class RegularChargesRepository {
  final Dio dio;

  RegularChargesRepository(this.dio);

  Future<RegularChargesResponse> getRegularCharges({
    required String parkId,
    int page = 1,
    int limit = 50,
    String dateType = 'date_from',
    List<String>? states,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final fromStr = dateFrom != null
        ? '${dateFrom.toIso8601String().split('T')[0]}T00:00:00+03:00'
        : '${DateTime.now().toIso8601String().split('T')[0]}T00:00:00+03:00';
    final toStr = dateTo != null
        ? '${dateTo.toIso8601String().split('T')[0]}T00:00:00+03:00'
        : '${DateTime.now().add(const Duration(days: 5)).toIso8601String().split('T')[0]}T00:00:00+03:00';

    final requestBody = <String, dynamic>{
      'date_type': dateType,
      'page': page,
      'limit': limit,
      'date_period': {
        'from': fromStr,
        'to': toStr,
      },
    };

    if (states != null && states.isNotEmpty) {
      requestBody['states'] = states;
    }

    print('📋 getRegularCharges request: $requestBody');

    final response = await dio.post(
      '/api/vehicles/regular-charges',
      data: requestBody,
      options: Options(headers: {'X-Park-ID': parkId}),
    );

    print('📋 getRegularCharges response status: ${response.statusCode}');

    return RegularChargesResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> initiateReportGeneration({
    required String parkId,
    required String operationId,
    required String dateType,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final fromStr = '${dateFrom.toIso8601String().split('T')[0]}T00:00:00+03:00';
    final toStr = '${dateTo.toIso8601String().split('T')[0]}T00:00:00+03:00';

    await dio.post(
      '/api/expenses/reports/regular-charges/initiate',
      data: {
        'operation_id': operationId,
        'date_type': dateType,
        'date_period': {
          'from': fromStr,
          'to': toStr,
        },
      },
      options: Options(headers: {'X-Park-ID': parkId}),
    );
  }
}
