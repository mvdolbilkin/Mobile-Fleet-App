import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/features/fleet/data/fleet_summary_service.dart';
import 'package:mobile/features/fleet/domain/cars_mileage_model.dart';
import 'package:mobile/features/fleet/domain/cars_statuses_model.dart';

final fleetSummaryServiceProvider = Provider<FleetSummaryService>((ref) {
  final dio = ref.watch(dioProvider);
  return FleetSummaryService(dio);
});

final carsStatusesProvider = FutureProvider<CarsStatusesResponse>((ref) async {
  final service = ref.watch(fleetSummaryServiceProvider);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month - 1, now.day);
  return service.getCarsStatuses(from: from, to: now);
});

final carsMileageProvider = FutureProvider<CarsMileageResponse>((ref) async {
  final service = ref.watch(fleetSummaryServiceProvider);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month - 1, now.day);
  return service.getCarsMileage(from: from, to: now);
});

final carsHoursOnlineProvider = FutureProvider<CarsMileageResponse>((ref) async {
  final service = ref.watch(fleetSummaryServiceProvider);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month - 1, now.day);
  return service.getCarsHoursOnline(from: from, to: now);
});

final carsAcceptanceRateProvider = FutureProvider<CarsMileageResponse>((ref) async {
  final service = ref.watch(fleetSummaryServiceProvider);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month - 1, now.day);
  return service.getCarsAcceptanceRate(from: from, to: now);
});

final carsTripsProvider = FutureProvider<CarsMileageResponse>((ref) async {
  final service = ref.watch(fleetSummaryServiceProvider);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month - 1, now.day);
  return service.getCarsTrips(from: from, to: now);
});
