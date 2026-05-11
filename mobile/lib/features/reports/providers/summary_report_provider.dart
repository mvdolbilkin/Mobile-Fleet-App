import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/reports/data/summary_report_service.dart';
import 'package:mobile/features/reports/domain/driver_summary.dart';

class SummaryReportState {
  final bool isLoading;
  final String? error;
  final DriverSummaryResponse? data;
  final SummaryReportFilter filter;

  const SummaryReportState({
    this.isLoading = false,
    this.error,
    this.data,
    required this.filter,
  });

  SummaryReportState copyWith({
    bool? isLoading,
    String? error,
    DriverSummaryResponse? data,
    SummaryReportFilter? filter,
    bool clearError = false,
    bool clearData = false,
  }) {
    return SummaryReportState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      data: clearData ? null : (data ?? this.data),
      filter: filter ?? this.filter,
    );
  }

  List<DriverSummaryItem> get filteredItems {
    if (data == null) return [];
    var items = data!.items;
    if (filter.driverId != null) {
      items = items.where((i) => i.driver.id == filter.driverId).toList();
    }
    if (filter.workRuleId != null) {
      items = items.where((i) => i.driver.workRuleId == filter.workRuleId).toList();
    }
    return items;
  }
}

class SummaryReportNotifier extends Notifier<SummaryReportState> {
  @override
  SummaryReportState build() {
    Future.microtask(_load);
    return SummaryReportState(filter: SummaryReportFilter.defaultFilter);
  }

  SummaryReportService get _service => ref.read(summaryReportServiceProvider);

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.getDriversSummary(
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

  void applyFilter(SummaryReportFilter filter) {
    state = state.copyWith(filter: filter);
    _load();
  }

  Future<void> refresh() => _load();
}

final summaryReportProvider =
    NotifierProvider<SummaryReportNotifier, SummaryReportState>(
  () => SummaryReportNotifier(),
);
