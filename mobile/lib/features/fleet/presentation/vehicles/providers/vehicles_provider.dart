import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/fleet/domain/vehicle.dart';
import 'package:mobile/features/fleet/domain/vehicle_details.dart';
import '../../../data/vehicles_service.dart';

import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

final vehiclesServiceProvider = Provider<VehiclesService>((ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return VehiclesService(dio, secureStorage);
});

class VehiclesFilterNotifier extends StateNotifier<VehicleFilter> {
  VehiclesFilterNotifier() : super(const VehicleFilter());

  void updateFilter(VehicleFilter newFilter) {
    state = newFilter;
  }
  
  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final vehiclesFilterProvider = StateNotifierProvider<VehiclesFilterNotifier, VehicleFilter>((ref) {
  return VehiclesFilterNotifier();
});

final vehiclesProvider = FutureProvider.autoDispose<List<Vehicle>>((ref) async {
  final filter = ref.watch(vehiclesFilterProvider);
  final service = ref.watch(vehiclesServiceProvider);
  
  return service.getVehicles(filter);
});

final vehicleDetailsProvider = FutureProvider.autoDispose.family<VehicleDetails, String>((ref, id) async {
  final service = ref.watch(vehiclesServiceProvider);
  return service.getVehicleDetails(id);
});

final vehicleCategoriesProvider = FutureProvider.autoDispose.family<List<String>, String>((ref, vehicleId) async {
  final service = ref.watch(vehiclesServiceProvider);
  return service.getCategories(vehicleId);
});

final carCategoriesProvider = FutureProvider<Map<String, String>>((ref) async {
  final service = ref.watch(vehiclesServiceProvider);
  return service.getCarCategories();
});
