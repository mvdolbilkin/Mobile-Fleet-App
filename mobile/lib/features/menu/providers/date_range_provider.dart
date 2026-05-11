import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateRangeState {
  final DateTime startDate;
  final DateTime endDate;

  DateRangeState({
    required this.startDate,
    required this.endDate,
  });

  DateRangeState copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DateRangeState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class DateRangeNotifier extends Notifier<DateRangeState> {
  @override
  DateRangeState build() {
    return DateRangeState(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
    );
  }

  void updateDateRange(DateTime startDate, DateTime endDate) {
    state = DateRangeState(startDate: startDate, endDate: endDate);
  }

  void resetToDefault() {
    state = DateRangeState(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
    );
  }
}

// Provider for date range state
final dateRangeProvider = NotifierProvider<DateRangeNotifier, DateRangeState>(() {
  return DateRangeNotifier();
});
