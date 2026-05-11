import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/reports/data/payment_dashboard_service.dart';
import 'package:mobile/features/reports/domain/payment_dashboard.dart';

class PaymentDashboardData {
  final DashboardWidgetResponse transactionsSummary;
  final DashboardWidgetResponse feesSummary;
  final TransactionDriversResponse transactionsDrivers;
  final DashboardWidgetResponse transactionsCount;
  final TransactionStatusesResponse transactionsStatuses;

  const PaymentDashboardData({
    required this.transactionsSummary,
    required this.feesSummary,
    required this.transactionsDrivers,
    required this.transactionsCount,
    required this.transactionsStatuses,
  });
}

class PaymentDashboardState {
  final bool isLoading;
  final String? error;
  final PaymentDashboardData? data;
  final DateTime dateFrom;
  final DateTime dateTo;
  final bool isTopup;

  const PaymentDashboardState({
    this.isLoading = false,
    this.error,
    this.data,
    required this.dateFrom,
    required this.dateTo,
    this.isTopup = false,
  });

  String get fromFormatted =>
      '${dateFrom.year}-${dateFrom.month.toString().padLeft(2, '0')}-${dateFrom.day.toString().padLeft(2, '0')}';

  String get toFormatted =>
      '${dateTo.year}-${dateTo.month.toString().padLeft(2, '0')}-${dateTo.day.toString().padLeft(2, '0')}';

  PaymentDashboardState copyWith({
    bool? isLoading,
    String? error,
    PaymentDashboardData? data,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? isTopup,
    bool clearError = false,
  }) {
    return PaymentDashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      data: data ?? this.data,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      isTopup: isTopup ?? this.isTopup,
    );
  }
}

class PaymentDashboardNotifier extends Notifier<PaymentDashboardState> {
  @override
  PaymentDashboardState build() {
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 6));
    Future.microtask(_load);
    return PaymentDashboardState(
      isLoading: true,
      dateFrom: DateTime(from.year, from.month, from.day),
      dateTo: DateTime(now.year, now.month, now.day),
    );
  }

  PaymentDashboardService get _service =>
      ref.read(paymentDashboardServiceProvider);

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _service.getTransactionsSummary(
            from: state.fromFormatted,
            to: state.toFormatted,
            isTopup: state.isTopup),
        _service.getFeesSummary(
            from: state.fromFormatted,
            to: state.toFormatted,
            isTopup: state.isTopup),
        _service.getTransactionsDrivers(
            from: state.fromFormatted,
            to: state.toFormatted,
            isTopup: state.isTopup),
        _service.getTransactionsCount(
            from: state.fromFormatted,
            to: state.toFormatted,
            isTopup: state.isTopup),
        _service.getTransactionsStatuses(
            from: state.fromFormatted,
            to: state.toFormatted,
            isTopup: state.isTopup),
      ]);
      state = state.copyWith(
        isLoading: false,
        data: PaymentDashboardData(
          transactionsSummary: results[0] as DashboardWidgetResponse,
          feesSummary: results[1] as DashboardWidgetResponse,
          transactionsDrivers: results[2] as TransactionDriversResponse,
          transactionsCount: results[3] as DashboardWidgetResponse,
          transactionsStatuses: results[4] as TransactionStatusesResponse,
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setDateRange(DateTime from, DateTime to) {
    state = state.copyWith(dateFrom: from, dateTo: to);
    _load();
  }

  void setTab(bool isTopup) {
    state = state.copyWith(isTopup: isTopup);
    _load();
  }

  Future<void> refresh() => _load();
}

final paymentDashboardProvider =
    NotifierProvider<PaymentDashboardNotifier, PaymentDashboardState>(
  () => PaymentDashboardNotifier(),
);
