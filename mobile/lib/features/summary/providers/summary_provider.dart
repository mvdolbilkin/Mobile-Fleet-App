import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/features/summary/models/profile_model.dart';
import 'package:mobile/features/summary/models/active_drivers_model.dart';
import 'package:mobile/features/summary/services/summary_service.dart';

final summaryServiceProvider = Provider<SummaryService>((ref) {
  final dio = ref.watch(dioProvider);
  return SummaryService(dio);
});

final parkProfileProvider = FutureProvider<ProfileResponse>((ref) async {
  final service = ref.watch(summaryServiceProvider);
  return service.getProfile();
});

final activeDriversProvider = FutureProvider<ActiveDriversResponse>((ref) async {
  final service = ref.watch(summaryServiceProvider);
  return service.getActiveDrivers();
});