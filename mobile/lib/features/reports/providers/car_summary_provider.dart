import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/reports/data/summary_report_service.dart';
import 'package:mobile/features/reports/domain/car_summary.dart';

class CarSummaryState {
  final bool isLoading;
  final String? error;
  final CarSummaryResponse? data;
  final CarSummaryFilter filter;

  const CarSummaryState({
    this.isLoading = false,
    this.error,
    this.data,
    required this.filter,
  });

  CarSummaryState copyWith({
    bool? isLoading,
    String? error,
    CarSummaryResponse? data,
    CarSummaryFilter? filter,
    bool clearError = false,
  }) {
    return CarSummaryState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      data: data ?? this.data,
      filter: filter ?? this.filter,
    );
  }
}

class CarSummaryNotifier extends Notifier<CarSummaryState> {
  @override
  CarSummaryState build() {
    Future.microtask(_load);
    return CarSummaryState(filter: CarSummaryFilter.defaultFilter);
  }

  SummaryReportService get _service => ref.read(summaryReportServiceProvider);

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.getCarsSummary(
        dateFrom: state.filter.dateFromFormatted,
        dateTo: state.filter.dateToFormatted,
        sortField: state.filter.sortField,
        sortDirection: state.filter.sortDirection,
      );
      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void applyFilter(CarSummaryFilter filter) {
    state = state.copyWith(filter: filter);
    _load();
  }

  Future<void> refresh() => _load();
}

final carSummaryProvider =
    NotifierProvider<CarSummaryNotifier, CarSummaryState>(
  () => CarSummaryNotifier(),
);
