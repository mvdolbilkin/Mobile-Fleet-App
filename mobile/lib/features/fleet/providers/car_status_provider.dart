import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/data/car_status_service.dart';
import 'package:mobile/features/fleet/domain/car_status_model.dart';
import 'package:mobile/shared/api/dio_provider.dart';

final carStatusServiceProvider = Provider<CarStatusService>((ref) {
  return CarStatusService(ref.watch(dioProvider));
});

final efficiencyCarStatusesProvider = FutureProvider<List<CarStatus>>((ref) {
  return ref.read(carStatusServiceProvider).getCarStatuses();
});
