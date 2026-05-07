import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/reports/data/summary_report_service.dart';
import 'package:mobile/features/reports/domain/park_summary.dart';

class ParkSummaryState {
  final bool isLoading;
  final String? error;
  final ParkSummaryResponse? data;

  const ParkSummaryState({
    this.isLoading = false,
    this.error,
    this.data,
  });

  ParkSummaryState copyWith({
    bool? isLoading,
    String? error,
    ParkSummaryResponse? data,
    bool clearError = false,
  }) {
    return ParkSummaryState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      data: data ?? this.data,
    );
  }
}

class ParkSummaryNotifier extends Notifier<ParkSummaryState> {
  @override
  ParkSummaryState build() {
    Future.microtask(_load);
    return const ParkSummaryState(isLoading: true);
  }

  SummaryReportService get _service => ref.read(summaryReportServiceProvider);

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.getParksSummary();
      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _load();
}

final parkSummaryProvider =
    NotifierProvider<ParkSummaryNotifier, ParkSummaryState>(
  () => ParkSummaryNotifier(),
);
