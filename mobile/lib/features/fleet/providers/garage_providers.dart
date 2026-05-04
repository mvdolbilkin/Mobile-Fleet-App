import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/data/garage_repository.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

final garageOfficesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final parkId = await ref.read(secureStorageServiceProvider).getParkId();
  if (parkId == null) return <Map<String, dynamic>>[];
  return ref.read(garageRepositoryProvider).getOfficeAddressList(parkId: parkId);
});

final garageCarsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final parkId = await ref.read(secureStorageServiceProvider).getParkId();
  if (parkId == null) return <Map<String, dynamic>>[];
  return ref.read(garageRepositoryProvider).getCarsSuggest(parkId: parkId);
});
