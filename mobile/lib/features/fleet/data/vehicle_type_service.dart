import 'package:dio/dio.dart';
import 'package:mobile/features/fleet/domain/vehicle_type_model.dart';

class VehicleTypeService {
  final Dio _dio;

  VehicleTypeService(this._dio);

  Future<List<VehicleType>> getVehicleTypes() async {
    final response = await _dio.get(
      'api/fleet/cars-catalog/v1/vehicle-types/by-park/list',
    );
    return VehicleTypesResponse.fromJson(
            response.data as Map<String, dynamic>)
        .vehicleTypes;
  }
}
