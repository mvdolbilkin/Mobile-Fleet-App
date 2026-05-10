import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/data/car_efficiency_service.dart';
import 'package:mobile/features/fleet/domain/car_efficiency_model.dart';
import 'package:mobile/shared/api/dio_provider.dart';

final carEfficiencyServiceProvider = Provider<CarEfficiencyService>((ref) {
  return CarEfficiencyService(ref.watch(dioProvider));
});

class CarEfficiencyState {
  final List<CarEfficiencyItem> items;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final DateTime dateFrom;
  final DateTime dateTo;
  final bool fleetCarsOnly;
  final Set<String> selectedCarTypes;
  final Set<String> selectedCarIds;
  final Set<String> selectedCarCategories;
  final Set<String> selectedCarStatuses;

  const CarEfficiencyState({
    this.items = const [],
    this.total = 0,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
    required this.dateFrom,
    required this.dateTo,
    this.fleetCarsOnly = false,
    this.selectedCarTypes = const {},
    this.selectedCarIds = const {},
    this.selectedCarCategories = const {},
    this.selectedCarStatuses = const {},
  });

  bool get hasMore => items.length < total;

  CarEfficiencyState copyWith({
    List<CarEfficiencyItem>? items,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? fleetCarsOnly,
    Set<String>? selectedCarTypes,
    Set<String>? selectedCarIds,
    Set<String>? selectedCarCategories,
    Set<String>? selectedCarStatuses,
  }) {
    return CarEfficiencyState(
      items: items ?? this.items,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      fleetCarsOnly: fleetCarsOnly ?? this.fleetCarsOnly,
      selectedCarTypes: selectedCarTypes ?? this.selectedCarTypes,
      selectedCarIds: selectedCarIds ?? this.selectedCarIds,
      selectedCarCategories: selectedCarCategories ?? this.selectedCarCategories,
      selectedCarStatuses: selectedCarStatuses ?? this.selectedCarStatuses,
    );
  }
}

class CarEfficiencyNotifier extends Notifier<CarEfficiencyState> {
  static const int _pageSize = 30;

  @override
  CarEfficiencyState build() {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month - 1, now.day);
    Future.microtask(_load);
    return CarEfficiencyState(dateFrom: from, dateTo: now);
  }

  Future<void> _load({bool append = false}) async {
    if (!append) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      final service = ref.read(carEfficiencyServiceProvider);
      final result = await service.getCarsEfficiency(
        from: state.dateFrom,
        to: state.dateTo,
        fleetCarsOnly: state.fleetCarsOnly,
        carTypes: state.selectedCarTypes.toList(),
        carIds: state.selectedCarIds.toList(),
        carCategories: state.selectedCarCategories.toList(),
        carStatuses: state.selectedCarStatuses.toList(),
        limit: _pageSize,
        offset: append ? state.items.length : 0,
      );

      final allItems =
          append ? [...state.items, ...result.items] : result.items;

      state = state.copyWith(
        items: allItems,
        total: result.pagination.total,
        isLoading: false,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void loadMore() {
    if (state.hasMore && !state.isLoadingMore && !state.isLoading) {
      _load(append: true);
    }
  }

  void setDateRange(DateTime from, DateTime to) {
    state = state.copyWith(dateFrom: from, dateTo: to);
    _load();
  }

  void setFleetCarsOnly(bool value) {
    state = state.copyWith(fleetCarsOnly: value);
    _load();
  }

  void setCarTypes(Set<String> types) {
    state = state.copyWith(selectedCarTypes: types);
    _load();
  }

  void setCarIds(Set<String> ids) {
    state = state.copyWith(selectedCarIds: ids);
    _load();
  }

  void setCarCategories(Set<String> categories) {
    state = state.copyWith(selectedCarCategories: categories);
    _load();
  }

  void setCarStatuses(Set<String> statuses) {
    state = state.copyWith(selectedCarStatuses: statuses);
    _load();
  }

  void applyFilters({
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool fleetCarsOnly,
    required Set<String> carTypes,
    required Set<String> carIds,
    required Set<String> carCategories,
    required Set<String> carStatuses,
  }) {
    state = state.copyWith(
      dateFrom: dateFrom,
      dateTo: dateTo,
      fleetCarsOnly: fleetCarsOnly,
      selectedCarTypes: carTypes,
      selectedCarIds: carIds,
      selectedCarCategories: carCategories,
      selectedCarStatuses: carStatuses,
    );
    _load();
  }

  void resetFilters() {
    state = state.copyWith(
      fleetCarsOnly: false,
      selectedCarTypes: {},
      selectedCarIds: {},
      selectedCarCategories: {},
      selectedCarStatuses: {},
    );
    _load();
  }

  void refresh() => _load();
}

final carEfficiencyProvider =
    NotifierProvider<CarEfficiencyNotifier, CarEfficiencyState>(
  () => CarEfficiencyNotifier(),
);
