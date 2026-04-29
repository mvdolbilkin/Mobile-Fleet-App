import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/data/expenses_repository.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

final costTypesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final parkId = await ref.read(secureStorageServiceProvider).getParkId();
  if (parkId == null) return <Map<String, dynamic>>[];
  return ref.read(expensesRepositoryProvider).getAvailableCostTypes(parkId: parkId);
});

final suggestCarsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final parkId = await ref.read(secureStorageServiceProvider).getParkId();
  if (parkId == null) return <Map<String, dynamic>>[];
  return ref.read(expensesRepositoryProvider).getSuggestCars(parkId: parkId);
});
