import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/fleet/domain/car_efficiency_model.dart';

class CarEfficiencyService {
  final Dio _dio;

  CarEfficiencyService(this._dio);

  Future<CarEfficiencyResponse> getCarsEfficiency({
    required DateTime from,
    required DateTime to,
    bool fleetCarsOnly = false,
    List<String> carTypes = const [],
    List<String> carIds = const [],
    int limit = 30,
    int offset = 0,
  }) async {
    final fmt = DateFormat('yyyy-MM-dd');
    final filters = <String, dynamic>{'fleet_cars_only': fleetCarsOnly};
    if (carTypes.isNotEmpty) filters['car_types'] = carTypes;
    if (carIds.isNotEmpty) filters['car_ids'] = carIds;
    final response = await _dio.post(
      'api/fleet/fleet-reports/v1/summary/cars/efficiency/list',
      data: {
        'filters': filters,
        'date_period': {
          'from': fmt.format(from),
          'to': fmt.format(to),
        },
        'limit': limit,
        'offset': offset,
      },
    );
    return CarEfficiencyResponse.fromJson(
        response.data as Map<String, dynamic>);
  }
}
