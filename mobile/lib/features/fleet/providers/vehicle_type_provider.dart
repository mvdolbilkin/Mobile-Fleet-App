import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/data/vehicle_type_service.dart';
import 'package:mobile/features/fleet/domain/vehicle_type_model.dart';
import 'package:mobile/shared/api/dio_provider.dart';

final vehicleTypeServiceProvider = Provider<VehicleTypeService>((ref) {
  return VehicleTypeService(ref.watch(dioProvider));
});

final vehicleTypesProvider = FutureProvider<List<VehicleType>>((ref) {
  return ref.read(vehicleTypeServiceProvider).getVehicleTypes();
});
