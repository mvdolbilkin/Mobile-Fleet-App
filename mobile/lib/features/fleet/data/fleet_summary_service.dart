import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/fleet/domain/cars_mileage_model.dart';
import 'package:mobile/features/fleet/domain/cars_statuses_model.dart';

class FleetSummaryService {
  final Dio _dio;

  FleetSummaryService(this._dio);

  Future<CarsStatusesResponse> getCarsStatuses({
    required DateTime from,
    required DateTime to,
    bool fleetCarsOnly = true,
  }) async {
    final fmt = DateFormat('yyyy-MM-dd');
    final response = await _dio.post(
      'api/fleet/fleet-reports/v1/dashboard/widget/cars/statuses',
      data: {
        'date_period': {
          'from': fmt.format(from),
          'to': fmt.format(to),
        },
        'filters': {
          'fleet_cars_only': fleetCarsOnly,
        },
      },
    );
    return CarsStatusesResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CarsMileageResponse> getCarsMileage({
    required DateTime from,
    required DateTime to,
    bool fleetCarsOnly = true,
  }) async {
    final fmt = DateFormat('yyyy-MM-dd');
    final response = await _dio.post(
      'api/fleet/fleet-reports/v1/dashboard/widget/cars/mileage',
      data: {
        'date_period': {
          'from': fmt.format(from),
          'to': fmt.format(to),
        },
        'filters': {
          'fleet_cars_only': fleetCarsOnly,
        },
      },
    );
    return CarsMileageResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CarsMileageResponse> getCarsHoursOnline({
    required DateTime from,
    required DateTime to,
    bool fleetCarsOnly = true,
  }) async {
    final fmt = DateFormat('yyyy-MM-dd');
    final response = await _dio.post(
      'api/fleet/fleet-reports/v1/dashboard/widget/cars/hours-online',
      data: {
        'date_period': {
          'from': fmt.format(from),
          'to': fmt.format(to),
        },
        'filters': {
          'fleet_cars_only': fleetCarsOnly,
        },
      },
    );
    return CarsMileageResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CarsMileageResponse> getCarsAcceptanceRate({
    required DateTime from,
    required DateTime to,
    bool fleetCarsOnly = true,
  }) async {
    final fmt = DateFormat('yyyy-MM-dd');
    final response = await _dio.post(
      'api/fleet/fleet-reports/v1/dashboard/widget/cars/acceptance-rate',
      data: {
        'date_period': {
          'from': fmt.format(from),
          'to': fmt.format(to),
        },
        'filters': {
          'fleet_cars_only': fleetCarsOnly,
        },
      },
    );
    return CarsMileageResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CarsMileageResponse> getCarsTrips({
    required DateTime from,
    required DateTime to,
    bool fleetCarsOnly = true,
  }) async {
    final fmt = DateFormat('yyyy-MM-dd');
    final response = await _dio.post(
      'api/fleet/fleet-reports/v1/dashboard/widget/cars/trips',
      data: {
        'date_period': {
          'from': fmt.format(from),
          'to': fmt.format(to),
        },
        'filters': {
          'fleet_cars_only': fleetCarsOnly,
        },
      },
    );
    return CarsMileageResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
