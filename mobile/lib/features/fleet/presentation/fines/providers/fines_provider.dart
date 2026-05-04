import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/data/fines_service.dart';
import 'package:mobile/features/fleet/domain/traffic_fine.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/shared/providers/logger_provider.dart';

final finesServiceProvider = Provider<FinesService>((ref) {
  final dio = ref.read(dioProvider);
  return FinesService(dio);
});

final finesTotalProvider = FutureProvider<TrafficFinesTotal>((ref) async {
  final service = ref.read(finesServiceProvider);
  return service.getTotal();
});

class FinesFilter {
  final FineStatusFilter statusFilter;
  final String searchQuery;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? carId;

  const FinesFilter({
    this.statusFilter = FineStatusFilter.all,
    this.searchQuery = '',
    this.dateFrom,
    this.dateTo,
    this.carId,
  });

  FinesFilter copyWith({
    FineStatusFilter? statusFilter,
    String? searchQuery,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? carId,
    bool clearDates = false,
    bool clearCarId = false,
  }) {
    return FinesFilter(
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      dateFrom: clearDates ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDates ? null : (dateTo ?? this.dateTo),
      carId: clearCarId ? null : (carId ?? this.carId),
    );
  }
}

class FinesNotifier extends Notifier<FinesState> {
  @override
  FinesState build() {
    Future.microtask(_loadFines);
    return const FinesState();
  }

  FinesFilter _filter = const FinesFilter();
  FinesFilter get filter => _filter;

  Future<void> _loadFines({bool append = false, String? cursor}) async {
    if (!append) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final service = ref.read(finesServiceProvider);
      final logger = ref.read(loggerProvider);
      final result = await service.retrieveFines(
        dateFrom: _filter.dateFrom,
        dateTo: _filter.dateTo,
        carId: _filter.carId,
        fineUin: _filter.searchQuery.isNotEmpty ? _filter.searchQuery : null,
        cursor: cursor,
        logger: logger,
      );

      final allFines = append
          ? [...state.fines, ...result.fines]
          : result.fines;

      // Apply client-side status filter
      final filtered = _applyStatusFilter(allFines);

      state = state.copyWith(
        fines: allFines,
        filteredFines: filtered,
        cursor: result.cursor,
        isLoading: false,
        isLoadingMore: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  List<TrafficFine> _applyStatusFilter(List<TrafficFine> fines) {
    switch (_filter.statusFilter) {
      case FineStatusFilter.all:
        return fines;
      case FineStatusFilter.unpaid:
        return fines.where((f) => f.fine.status == 'issued').toList();
      case FineStatusFilter.paymentSent:
        return fines.where((f) =>
            f.contractor.payment.status == 'paid' &&
            f.fine.status != 'paid').toList();
      case FineStatusFilter.paid:
        return fines.where((f) => f.fine.status == 'paid').toList();
      case FineStatusFilter.overdue:
        return fines.where((f) => f.fine.status == 'overdue').toList();
    }
  }

  void updateFilter(FinesFilter newFilter) {
    _filter = newFilter;
    // If only status filter changed, just re-filter locally
    if (_filter.dateFrom == newFilter.dateFrom &&
        _filter.dateTo == newFilter.dateTo &&
        _filter.carId == newFilter.carId &&
        _filter.searchQuery == newFilter.searchQuery) {
      state = state.copyWith(
        filteredFines: _applyStatusFilter(state.fines),
      );
    } else {
      _filter = newFilter;
      _loadFines();
    }
  }

  void setStatusFilter(FineStatusFilter statusFilter) {
    _filter = _filter.copyWith(statusFilter: statusFilter);
    state = state.copyWith(
      filteredFines: _applyStatusFilter(state.fines),
    );
  }

  void setSearchQuery(String query) {
    _filter = _filter.copyWith(searchQuery: query);
    _loadFines();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _filter = _filter.copyWith(dateFrom: from, dateTo: to, clearDates: from == null);
    _loadFines();
  }

  void loadMore() {
    if (state.cursor != null && !state.isLoadingMore) {
      _loadFines(append: true, cursor: state.cursor);
    }
  }

  void refresh() {
    _loadFines();
    ref.invalidate(finesTotalProvider);
  }
}

class FinesState {
  final List<TrafficFine> fines;
  final List<TrafficFine> filteredFines;
  final String? cursor;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const FinesState({
    this.fines = const [],
    this.filteredFines = const [],
    this.cursor,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
  });

  FinesState copyWith({
    List<TrafficFine>? fines,
    List<TrafficFine>? filteredFines,
    String? cursor,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return FinesState(
      fines: fines ?? this.fines,
      filteredFines: filteredFines ?? this.filteredFines,
      cursor: cursor ?? this.cursor,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

final finesProvider = NotifierProvider<FinesNotifier, FinesState>(
  () => FinesNotifier(),
);
