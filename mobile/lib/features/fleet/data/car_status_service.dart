import 'package:dio/dio.dart';
import 'package:mobile/features/fleet/domain/car_status_model.dart';

class CarStatusService {
  final Dio _dio;

  CarStatusService(this._dio);

  Future<List<CarStatus>> getCarStatuses() async {
    final response = await _dio.get('api/fleet/references/car-statuses');
    final data = response.data as Map<String, dynamic>;
    final list = data['car_statuses'] as List? ?? [];
    return list
        .map((e) => CarStatus.fromJson(e as Map<String, dynamic>))
        .where((s) => s.name.isNotEmpty)
        .toList();
  }
}
