import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';
import 'package:mobile/features/summary/models/profile_model.dart';
import 'package:mobile/features/summary/models/active_drivers_model.dart';
import 'package:mobile/features/summary/services/summary_service.dart';

final summaryServiceProvider = Provider<SummaryService>((ref) {
  final dio = ref.watch(dioProvider);
  return SummaryService(dio);
});

class SummaryDateRangeNotifier extends Notifier<DateRange> {
  @override
  DateRange build() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    return DateRange(start: start, end: now);
  }

  void update(DateRange range) => state = range;
}

final summaryDateRangeProvider =
    NotifierProvider<SummaryDateRangeNotifier, DateRange>(
        () => SummaryDateRangeNotifier());

final parkProfileProvider = FutureProvider<ProfileResponse>((ref) async {
  final service = ref.watch(summaryServiceProvider);
  return service.getProfile();
});

final activeDriversProvider = FutureProvider<ActiveDriversResponse>((ref) async {
  final dr = ref.watch(summaryDateRangeProvider);
  final service = ref.watch(summaryServiceProvider);
  return service.getActiveDrivers(dr.start, dr.end);
});

final ordersByTariffProvider = FutureProvider<ActiveDriversResponse>((ref) async {
  final dr = ref.watch(summaryDateRangeProvider);
  final service = ref.watch(summaryServiceProvider);
  return service.getOrders(dr.start, dr.end, 'tariff');
});

final ordersByStatusProvider = FutureProvider<ActiveDriversResponse>((ref) async {
  final dr = ref.watch(summaryDateRangeProvider);
  final service = ref.watch(summaryServiceProvider);
  return service.getOrders(dr.start, dr.end, 'status');
});

final ordersByPaymentProvider = FutureProvider<ActiveDriversResponse>((ref) async {
  final dr = ref.watch(summaryDateRangeProvider);
  final service = ref.watch(summaryServiceProvider);
  return service.getOrders(dr.start, dr.end, 'payment_type');
});

final supplyHoursProvider = FutureProvider<ActiveDriversResponse>((ref) async {
  final dr = ref.watch(summaryDateRangeProvider);
  final service = ref.watch(summaryServiceProvider);
  return service.getSupplyHours(dr.start, dr.end);
});

final profitProvider = FutureProvider<ActiveDriversResponse>((ref) async {
  final dr = ref.watch(summaryDateRangeProvider);
  final service = ref.watch(summaryServiceProvider);
  return service.getProfit(dr.start, dr.end);
});

final ordersSumProvider = FutureProvider<ActiveDriversResponse>((ref) async {
  final dr = ref.watch(summaryDateRangeProvider);
  final service = ref.watch(summaryServiceProvider);
  return service.getOrdersSum(dr.start, dr.end);
});

final certificationProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(summaryServiceProvider);
  return service.getCertification();
});