import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/domain/car_efficiency_model.dart';
import 'package:mobile/features/fleet/domain/vehicle_type_model.dart';
import 'package:mobile/features/fleet/presentation/car_efficiency/providers/car_efficiency_provider.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/domain/car_category_model.dart';
import 'package:mobile/features/fleet/domain/car_status_model.dart';
import 'package:mobile/features/fleet/providers/car_category_provider.dart';
import 'package:mobile/features/fleet/providers/car_status_provider.dart';
import 'package:mobile/features/fleet/providers/vehicle_type_provider.dart';
import 'package:mobile/shared/widgets/filter_chip.dart';
import 'package:mobile/features/fleet/data/vehicles_service.dart';
import 'package:mobile/features/fleet/domain/vehicle.dart' hide VehicleType;
import 'package:mobile/features/fleet/presentation/vehicles/providers/vehicles_provider.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';
import 'package:mobile/shared/widgets/custom_switch.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class CarEfficiencyScreen extends ConsumerStatefulWidget {
  const CarEfficiencyScreen({super.key});

  @override
  ConsumerState<CarEfficiencyScreen> createState() =>
      _CarEfficiencyScreenState();
}

class _CarEfficiencyScreenState extends ConsumerState<CarEfficiencyScreen> {
  final ScrollController _verticalScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _verticalScroll.addListener(_onVerticalScroll);
  }

  @override
  void dispose() {
    _verticalScroll.dispose();
    super.dispose();
  }

  void _onVerticalScroll() {
    final pos = _verticalScroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      ref.read(carEfficiencyProvider.notifier).loadMore();
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'янв.', 'февр.', 'мар.', 'апр.', 'мая', 'июня',
      'июля', 'авг.', 'сент.', 'окт.', 'нояб.', 'дек.',
    ];
    return '${d.day} ${months[d.month]}';
  }

  String _formatDateRange(DateTime from, DateTime to) {
    return '${_formatDate(from)} – ${_formatDate(to)}';
  }

  String _formatSupplyTime(int seconds) {
    if (seconds <= 0) return '—';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h == 0) return '$m мин';
    if (m == 0) return '$h ч';
    return '$h ч $m мин';
  }

  String _formatPercent(double? value) {
    if (value == null) return '—';
    return '${(value * 100).round()} %';
  }

  Color _statusColor(String statusId) {
    switch (statusId) {
      case 'working':
        return const Color(0xFF34C759);
      case 'pending':
        return const Color(0xFFFF9500);
      case 'repairing':
        return const Color(0xFF007AFF);
      case 'no_driver':
        return const Color(0xFFFF3B30);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  void _showFilterSheet(CarEfficiencyState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(initialState: state),
    );
  }

  void _pickDateRange(CarEfficiencyState state) async {
    final result = await CustomDateRangePickerBottomSheet.show(
      context: context,
      title: 'Период',
      startDate: state.dateFrom,
      endDate: state.dateTo,
    );
    if (result != null) {
      ref
          .read(carEfficiencyProvider.notifier)
          .setDateRange(result.start, result.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(carEfficiencyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Отчёт по ТС'),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _FiltersBar(
            state: state,
            onDateTap: () => _pickDateRange(state),
            onFiltersTap: () => _showFilterSheet(state),
            onRemoveFleetCarsOnly: () => ref
                .read(carEfficiencyProvider.notifier)
                .setFleetCarsOnly(false),
            onRemoveCarTypes: () => ref
                .read(carEfficiencyProvider.notifier)
                .setCarTypes({}),
            onRemoveCarIds: () => ref
                .read(carEfficiencyProvider.notifier)
                .setCarIds({}),
            onRemoveCarCategories: () => ref
                .read(carEfficiencyProvider.notifier)
                .setCarCategories({}),
            onRemoveCarStatuses: () => ref
                .read(carEfficiencyProvider.notifier)
                .setCarStatuses({}),
            onResetAll: () => ref
                .read(carEfficiencyProvider.notifier)
                .resetFilters(),
            formatDateRange: _formatDateRange,
          ),
          const Divider(height: 1, color: Color(0xFFE5E5EA)),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.items.isEmpty
                    ? _ErrorView(
                        error: state.error!,
                        onRetry: () =>
                            ref.read(carEfficiencyProvider.notifier).refresh(),
                      )
                    : _CardListView(
                        state: state,
                        scrollController: _verticalScroll,
                        formatSupplyTime: _formatSupplyTime,
                        formatPercent: _formatPercent,
                        statusColor: _statusColor,
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Filters bar ─────────────────────────────────────────────────────────────

class _FiltersBar extends StatelessWidget {
  final CarEfficiencyState state;
  final VoidCallback onDateTap;
  final VoidCallback onFiltersTap;
  final VoidCallback onRemoveFleetCarsOnly;
  final VoidCallback onRemoveCarTypes;
  final VoidCallback onRemoveCarIds;
  final VoidCallback onRemoveCarCategories;
  final VoidCallback onRemoveCarStatuses;
  final VoidCallback onResetAll;
  final String Function(DateTime, DateTime) formatDateRange;

  const _FiltersBar({
    required this.state,
    required this.onDateTap,
    required this.onFiltersTap,
    required this.onRemoveFleetCarsOnly,
    required this.onRemoveCarTypes,
    required this.onRemoveCarIds,
    required this.onRemoveCarCategories,
    required this.onRemoveCarStatuses,
    required this.onResetAll,
    required this.formatDateRange,
  });

  bool get _hasFilters =>
      state.selectedCarTypes.isNotEmpty ||
      state.selectedCarIds.isNotEmpty ||
      state.selectedCarCategories.isNotEmpty ||
      state.selectedCarStatuses.isNotEmpty ||
      state.fleetCarsOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: onDateTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: AppTheme.textPrimary),
                      const SizedBox(width: 6),
                      Text(
                        formatDateRange(state.dateFrom, state.dateTo),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 16, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onFiltersTap,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _hasFilters
                        ? AppTheme.buttonColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tune,
                    size: 22,
                    color: _hasFilters
                        ? Colors.black
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_hasFilters) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Row(
              children: [
                if (state.selectedCarTypes.isNotEmpty) ...[
                  _pill('Тип ТС · ${state.selectedCarTypes.length}',
                      onRemoveCarTypes),
                  const SizedBox(width: 8),
                ],
                if (state.selectedCarIds.isNotEmpty) ...[
                  _pill('Автомобиль · ${state.selectedCarIds.length}',
                      onRemoveCarIds),
                  const SizedBox(width: 8),
                ],
                if (state.selectedCarCategories.isNotEmpty) ...[
                  _pill('Класс авто · ${state.selectedCarCategories.length}',
                      onRemoveCarCategories),
                  const SizedBox(width: 8),
                ],
                if (state.selectedCarStatuses.isNotEmpty) ...[
                  _pill('Статус · ${state.selectedCarStatuses.length}',
                      onRemoveCarStatuses),
                  const SizedBox(width: 8),
                ],
                if (state.fleetCarsOnly)
                  _pill('Только парковые', onRemoveFleetCarsOnly),
              ],
            ),
          ),
          GestureDetector(
            onTap: onResetAll,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 4),
              child: Text(
                'Сбросить все фильтры',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _pill(String label, VoidCallback onClear) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textPrimary)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close,
                size: 16, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Card list view ────────────────────────────────────────────────────────────

class _CardListView extends StatelessWidget {
  final CarEfficiencyState state;
  final ScrollController scrollController;
  final String Function(int) formatSupplyTime;
  final String Function(double?) formatPercent;
  final Color Function(String) statusColor;

  const _CardListView({
    required this.state,
    required this.scrollController,
    required this.formatSupplyTime,
    required this.formatPercent,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    if (state.items.isEmpty) {
      return const Center(
        child: Text(
          'Нет данных',
          style: TextStyle(color: Color(0xFF8E8E93)),
        ),
      );
    }

    final extraCount = (state.isLoadingMore ? 1 : 0) +
        (!state.isLoadingMore && !state.hasMore ? 1 : 0);

    return ListView.separated(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: state.items.length + extraCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        if (i >= state.items.length) {
          if (state.isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'Всего: ${state.total}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ),
          );
        }
        return _CarEfficiencyCard(
          item: state.items[i],
          formatSupplyTime: formatSupplyTime,
          formatPercent: formatPercent,
          statusColor: statusColor,
        );
      },
    );
  }
}

class _CarEfficiencyCard extends StatelessWidget {
  final CarEfficiencyItem item;
  final String Function(int) formatSupplyTime;
  final String Function(double?) formatPercent;
  final Color Function(String) statusColor;

  const _CarEfficiencyCard({
    required this.item,
    required this.formatSupplyTime,
    required this.formatPercent,
    required this.statusColor,
  });

  void _showDriversSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DriversBottomSheet(
        car: item.car,
        drivers: item.drivers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryStatus =
        item.dailyStatuses.isNotEmpty ? item.dailyStatuses.first : null;
    final visibleDriver = item.drivers.isNotEmpty ? item.drivers.first : null;
    final extraDrivers =
        item.drivers.length - (visibleDriver != null ? 1 : 0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Авто + статус ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.car.carBrand} ${item.car.carModel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.car.carNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              if (primaryStatus != null) ...[
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor(primaryStatus.status.id),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${primaryStatus.status.name} · ${primaryStatus.days} д.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3C3C43),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          // ── Водитель ───────────────────────────────────────────────
          if (visibleDriver != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE5E5EA)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    size: 16, color: Color(0xFF8E8E93)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    visibleDriver.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ),
                if (extraDrivers > 0)
                  GestureDetector(
                    onTap: () => _showDriversSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5EA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ещё $extraDrivers',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3C3C43),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          // ── Метрики ────────────────────────────────────────────────
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE5E5EA)),
          const SizedBox(height: 10),
          Row(
            children: [
              _MetricTile(
                label: 'Поездки',
                value: '${item.successOrdersCount}',
              ),
              const SizedBox(width: 8),
              _MetricTile(
                label: 'Часы на линии',
                value: formatSupplyTime(item.supplyTimeSeconds),
              ),
              const SizedBox(width: 8),
              _MetricTile(
                label: 'Принято',
                value: formatPercent(item.acceptanceRate),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MetricTile(
                label: 'Отм. водителем',
                value: formatPercent(item.driverCancellationRate),
              ),
              const SizedBox(width: 8),
              _MetricTile(
                label: 'Выполнено',
                value: formatPercent(item.completionRate),
              ),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter sheet ────────────────────────────────────────────────────────────────

class _FilterSheet extends ConsumerStatefulWidget {
  final CarEfficiencyState initialState;

  const _FilterSheet({required this.initialState});

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late DateTime _dateFrom;
  late DateTime _dateTo;
  late bool _fleetCarsOnly;
  late Set<String> _selectedCarTypes;
  late Set<String> _selectedCarIds;
  late Set<String> _selectedCarCategories;
  late Set<String> _selectedCarStatuses;

  @override
  void initState() {
    super.initState();
    final s = widget.initialState;
    _dateFrom = s.dateFrom;
    _dateTo = s.dateTo;
    _fleetCarsOnly = s.fleetCarsOnly;
    _selectedCarTypes = Set.from(s.selectedCarTypes);
    _selectedCarIds = Set.from(s.selectedCarIds);
    _selectedCarCategories = Set.from(s.selectedCarCategories);
    _selectedCarStatuses = Set.from(s.selectedCarStatuses);
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  void _reset() {
    setState(() {
      _fleetCarsOnly = false;
      _selectedCarTypes.clear();
      _selectedCarIds.clear();
      _selectedCarCategories.clear();
      _selectedCarStatuses.clear();
    });
  }

  void _apply() {
    ref.read(carEfficiencyProvider.notifier).applyFilters(
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      fleetCarsOnly: _fleetCarsOnly,
      carTypes: Set.from(_selectedCarTypes),
      carIds: Set.from(_selectedCarIds),
      carCategories: Set.from(_selectedCarCategories),
      carStatuses: Set.from(_selectedCarStatuses),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vehicleTypes =
        ref.watch(vehicleTypesProvider).asData?.value ?? [];
    final carCategories =
        ref.watch(efficiencyCarCategoriesProvider).asData?.value ?? [];
    final carStatuses =
        ref.watch(efficiencyCarStatusesProvider).asData?.value ?? [];
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Фильтры', style: AppTheme.listTitle),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _reset,
                          child: const Text('Сбросить',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary)),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close,
                              color: AppTheme.textSecondary, size: 24),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Период'),
                      GestureDetector(
                        onTap: () async {
                          final result =
                              await CustomDateRangePickerBottomSheet.show(
                            context: context,
                            title: 'Период',
                            startDate: _dateFrom,
                            endDate: _dateTo,
                          );
                          if (result != null) {
                            setState(() {
                              _dateFrom = result.start;
                              _dateTo = result.end;
                            });
                          }
                        },
                        child: _rowControl(
                          icon: Icons.calendar_today_outlined,
                          label: '${_fmt(_dateFrom)} — ${_fmt(_dateTo)}',
                          hasValue: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sectionLabel('Тип ТС'),
                      if (vehicleTypes.isEmpty)
                        const _LoadingRow()
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: vehicleTypes
                              .map(
                                (t) => CustomFilterChip(
                                  label: t.label,
                                  isSelected:
                                      _selectedCarTypes.contains(t.value),
                                  onTap: () {
                                    setState(() {
                                      if (_selectedCarTypes
                                          .contains(t.value)) {
                                        _selectedCarTypes.remove(t.value);
                                      } else {
                                        _selectedCarTypes.add(t.value);
                                      }
                                    });
                                  },
                                  borderRadius: 20,
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: 20),
                      _sectionLabel('Класс авто'),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => _CarCategorySheet(
                              categories: carCategories,
                              selected: _selectedCarCategories,
                              onApply: (ids) {
                                setState(() =>
                                    _selectedCarCategories = Set.from(ids));
                              },
                            ),
                          );
                        },
                        child: _rowControl(
                          icon: Icons.category_outlined,
                          label: _selectedCarCategories.isEmpty
                              ? 'Все классы'
                              : '${_selectedCarCategories.length} класс(ов) выбрано',
                          hasValue: _selectedCarCategories.isNotEmpty,
                          onClear: _selectedCarCategories.isNotEmpty
                              ? () => setState(
                                  () => _selectedCarCategories.clear())
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sectionLabel('Статус'),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => _CarStatusSheet(
                              statuses: carStatuses,
                              selected: _selectedCarStatuses,
                              onApply: (ids) {
                                setState(() =>
                                    _selectedCarStatuses = Set.from(ids));
                              },
                            ),
                          );
                        },
                        child: _rowControl(
                          icon: Icons.info_outline_rounded,
                          label: _selectedCarStatuses.isEmpty
                              ? 'Все статусы'
                              : '${_selectedCarStatuses.length} статус(ов) выбрано',
                          hasValue: _selectedCarStatuses.isNotEmpty,
                          onClear: _selectedCarStatuses.isNotEmpty
                              ? () => setState(
                                  () => _selectedCarStatuses.clear())
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sectionLabel('Автомобиль'),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => _CarListSheet(
                              selected: _selectedCarIds,
                              onApply: (ids) {
                                setState(
                                    () => _selectedCarIds = Set.from(ids));
                              },
                            ),
                          );
                        },
                        child: _rowControl(
                          icon: Icons.directions_car_outlined,
                          label: _selectedCarIds.isEmpty
                              ? 'Все автомобили'
                              : '${_selectedCarIds.length} авто выбрано',
                          hasValue: _selectedCarIds.isNotEmpty,
                          onClear: _selectedCarIds.isNotEmpty
                              ? () =>
                                  setState(() => _selectedCarIds.clear())
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.garage_outlined,
                                size: 20, color: AppTheme.textPrimary),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Только парковые машины',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: AppTheme.textPrimary),
                              ),
                            ),
                            CustomSwitch(
                              value: _fleetCarsOnly,
                              onChanged: (v) =>
                                  setState(() => _fleetCarsOnly = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 16),
                child: FadingButton(
                  onTap: _apply,
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.buttonColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Применить',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      );

  Widget _rowControl({
    required IconData icon,
    required String label,
    required bool hasValue,
    VoidCallback? onClear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: hasValue
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
              ),
            ),
          ),
          if (hasValue && onClear != null)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close,
                  size: 18, color: AppTheme.textSecondary),
            )
          else
            const Icon(Icons.keyboard_arrow_right,
                color: AppTheme.textSecondary),
        ],
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 12),
          Text('Загрузка...',
              style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

// ─── Vehicle type chip (unused — Тип ТС is now in filter sheet) ───────────────

class _VehicleTypeChip extends StatelessWidget {
  // kept for compilation — not rendered
  final Set<String> selected;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _VehicleTypeChip({
    required this.selected,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selected.isNotEmpty;
    return FadingButton(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
            left: 10, right: isActive ? 4 : 10, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8F0FE) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? const Color(0xFF4285F4)
                : const Color(0xFFE5E5EA),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Тип ТС',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Yandex Sans Text',
                color: isActive
                    ? const Color(0xFF4285F4)
                    : const Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(width: 4),
            if (!isActive)
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 16, color: Color(0xFF8E8E93))
            else ...[              Text(
                ' · ${selected.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4285F4),
                  fontFamily: 'Yandex Sans Text',
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close_rounded,
                    size: 15, color: Color(0xFF4285F4)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Vehicle type sheet ────────────────────────────────────────────────────────

class _VehicleTypeSheet extends StatefulWidget {
  final List<VehicleType> vehicleTypes;
  final Set<String> selected;
  final ValueChanged<Set<String>> onApply;

  const _VehicleTypeSheet({
    required this.vehicleTypes,
    required this.selected,
    required this.onApply,
  });

  @override
  State<_VehicleTypeSheet> createState() => _VehicleTypeSheetState();
}

class _VehicleTypeSheetState extends State<_VehicleTypeSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
            child: Row(
              children: [
                const Text(
                  'Тип ТС',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Yandex Sans Text',
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const Spacer(),
                if (_selected.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() => _selected.clear());
                      widget.onApply({});
                    },
                    child: const Text(
                      'Сбросить',
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFFF3B30),
                          fontFamily: 'Yandex Sans Text'),
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      size: 20, color: Color(0xFF8E8E93)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E5EA)),
          if (widget.vehicleTypes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            ...widget.vehicleTypes.asMap().entries.map((entry) {
              final isLast = entry.key == widget.vehicleTypes.length - 1;
              final type = entry.value;
              final isChecked = _selected.contains(type.value);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isChecked) {
                          _selected.remove(type.value);
                        } else {
                          _selected.add(type.value);
                        }
                      });
                      widget.onApply(Set.from(_selected));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Row(
                        children: [
                          Text(
                            type.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Yandex Sans Text',
                              fontWeight: isChecked
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isChecked
                                  ? const Color(0xFF4285F4)
                                  : const Color(0xFF1C1C1E),
                            ),
                          ),
                          const Spacer(),
                          if (isChecked)
                            const Icon(Icons.check_rounded,
                                size: 20, color: Color(0xFF4285F4)),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                        height: 1,
                        indent: 20,
                        color: Color(0xFFE5E5EA)),
                ],
              );
            }),
          SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ─── (old filter sheet replaced — see new _FilterSheet above) ─────────────────

// ─── Car category sheet ───────────────────────────────────────────────────────

class _CarCategorySheet extends StatefulWidget {
  final List<CarCategory> categories;
  final Set<String> selected;
  final ValueChanged<Set<String>> onApply;

  const _CarCategorySheet({
    required this.categories,
    required this.selected,
    required this.onApply,
  });

  @override
  State<_CarCategorySheet> createState() => _CarCategorySheetState();
}

class _CarCategorySheetState extends State<_CarCategorySheet> {
  final TextEditingController _search = TextEditingController();
  late Set<String> _selected;
  late List<CarCategory> _filtered;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selected);
    _filtered = widget.categories;
    _search.addListener(_filter);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _filter() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.categories
          : widget.categories
              .where((c) => c.name.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
            child: Row(
              children: [
                const Text(
                  'Класс авто',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const Spacer(),
                if (_selected.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() => _selected.clear());
                      widget.onApply({});
                    },
                    child: const Text(
                      'Сбросить',
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFFFF3B30)),
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      size: 20, color: Color(0xFF8E8E93)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Поиск',
                hintStyle: const TextStyle(color: Color(0xFFAEAEB2)),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFFAEAEB2), size: 20),
                suffixIcon: _search.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _search.clear();
                          setState(() => _filtered = widget.categories);
                        },
                        child: const Icon(Icons.close_rounded,
                            color: Color(0xFFAEAEB2), size: 18),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF2F2F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E5EA)),
          Expanded(
            child: widget.categories.isEmpty
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _filtered.isEmpty
                    ? const Center(
                        child: Text('Ничего не найдено',
                            style: TextStyle(color: Color(0xFF8E8E93))))
                    : ListView.builder(
                        itemCount: _filtered.length,
                        padding:
                            EdgeInsets.only(bottom: bottomPad + 16),
                        itemBuilder: (ctx, i) {
                          final cat = _filtered[i];
                          final isChecked = _selected.contains(cat.id);
                          final isLast = i == _filtered.length - 1;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isChecked) {
                                      _selected.remove(cat.id);
                                    } else {
                                      _selected.add(cat.id);
                                    }
                                  });
                                  widget.onApply(Set.from(_selected));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  child: Row(
                                    children: [
                                      Text(
                                        cat.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isChecked
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isChecked
                                              ? const Color(0xFF4285F4)
                                              : const Color(0xFF1C1C1E),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (isChecked)
                                        const Icon(Icons.check_rounded,
                                            size: 20,
                                            color: Color(0xFF4285F4)),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isLast)
                                const Divider(
                                    height: 1,
                                    indent: 20,
                                    color: Color(0xFFE5E5EA)),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Car status sheet ────────────────────────────────────────────────────────

class _CarStatusSheet extends StatefulWidget {
  final List<CarStatus> statuses;
  final Set<String> selected;
  final ValueChanged<Set<String>> onApply;

  const _CarStatusSheet({
    required this.statuses,
    required this.selected,
    required this.onApply,
  });

  @override
  State<_CarStatusSheet> createState() => _CarStatusSheetState();
}

class _CarStatusSheetState extends State<_CarStatusSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
            child: Row(
              children: [
                const Text(
                  'Статус',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const Spacer(),
                if (_selected.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() => _selected.clear());
                      widget.onApply({});
                    },
                    child: const Text(
                      'Сбросить',
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFFFF3B30)),
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      size: 20, color: Color(0xFF8E8E93)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E5EA)),
          Flexible(
            child: widget.statuses.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.statuses.length,
                    padding: EdgeInsets.only(bottom: bottomPad + 16),
                    itemBuilder: (ctx, i) {
                      final status = widget.statuses[i];
                      final isChecked = _selected.contains(status.id);
                      final isLast = i == widget.statuses.length - 1;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isChecked) {
                                  _selected.remove(status.id);
                                } else {
                                  _selected.add(status.id);
                                }
                              });
                              widget.onApply(Set.from(_selected));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Row(
                                children: [
                                  Text(
                                    status.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isChecked
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isChecked
                                          ? const Color(0xFF4285F4)
                                          : const Color(0xFF1C1C1E),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isChecked)
                                    const Icon(Icons.check_rounded,
                                        size: 20,
                                        color: Color(0xFF4285F4)),
                                ],
                              ),
                            ),
                          ),
                          if (!isLast)
                            const Divider(
                                height: 1,
                                indent: 20,
                                color: Color(0xFFE5E5EA)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Car list sheet ──────────────────────────────────────────────────────────

class _CarListSheet extends ConsumerStatefulWidget {
  final Set<String> selected;
  final ValueChanged<Set<String>> onApply;

  const _CarListSheet({
    required this.selected,
    required this.onApply,
  });

  @override
  ConsumerState<_CarListSheet> createState() => _CarListSheetState();
}

class _CarListSheetState extends ConsumerState<_CarListSheet> {
  final TextEditingController _search = TextEditingController();
  List<Vehicle> _all = [];
  List<Vehicle> _filtered = [];
  late Set<String> _selected;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selected);
    _search.addListener(_filter);
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final service = ref.read(vehiclesServiceProvider);
      final cars = await service.getVehicles(const VehicleFilter());
      if (!mounted) return;
      setState(() {
        _all = cars;
        _filtered = cars;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _filter() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all.where((v) {
              final b = (v.brand ?? '').toLowerCase();
              final m = v.model.toLowerCase();
              final n = v.plateNumber.toLowerCase();
              return b.contains(q) || m.contains(q) || n.contains(q);
            }).toList();
    });
  }

  String _label(Vehicle v) {
    return '${v.brand ?? ''} ${v.model} ${v.plateNumber}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
            child: Row(
              children: [
                const Text(
                  'Автомобиль',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Yandex Sans Text',
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const Spacer(),
                if (_selected.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() => _selected.clear());
                      widget.onApply({});
                    },
                    child: const Text('Сбросить',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFF3B30),
                            fontFamily: 'Yandex Sans Text')),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      size: 20, color: Color(0xFF8E8E93)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Поиск',
                hintStyle: const TextStyle(
                    color: Color(0xFFAEAEB2),
                    fontFamily: 'Yandex Sans Text'),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFFAEAEB2), size: 20),
                suffixIcon: _search.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () => _search.clear(),
                        child: const Icon(Icons.close_rounded,
                            size: 18, color: Color(0xFFAEAEB2)),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF2F2F7),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E5EA)),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: Color(0xFFFF3B30),
                                fontFamily: 'Yandex Sans Text')))
                    : _filtered.isEmpty
                        ? const Center(
                            child: Text('Не найдено',
                                style: TextStyle(
                                    color: Color(0xFF8E8E93),
                                    fontFamily: 'Yandex Sans Text')))
                        : ListView.separated(
                            padding: EdgeInsets.only(bottom: bottomPad + 16),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                indent: 20,
                                color: Color(0xFFE5E5EA)),
                            itemBuilder: (_, i) {
                              final car = _filtered[i];
                              final id = car.id;
                              final checked = _selected.contains(id);
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (checked) {
                                      _selected.remove(id);
                                    } else {
                                      _selected.add(id);
                                    }
                                  });
                                  widget.onApply(Set.from(_selected));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _label(car),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'Yandex Sans Text',
                                            fontWeight: checked
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: checked
                                                ? const Color(0xFF4285F4)
                                                : const Color(0xFF1C1C1E),
                                          ),
                                        ),
                                      ),
                                      if (checked)
                                        const Icon(Icons.check_rounded,
                                            size: 20,
                                            color: Color(0xFF4285F4)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

// ─── Drivers bottom sheet ────────────────────────────────────────────────────

class _DriversBottomSheet extends StatelessWidget {
  final CarInfo car;
  final List<DriverInfo> drivers;

  const _DriversBottomSheet({
    required this.car,
    required this.drivers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${car.carBrand} ${car.carModel}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Yandex Sans Text',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        car.carNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                          fontFamily: 'Yandex Sans Text',
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${drivers.length} водит.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                    fontFamily: 'Yandex Sans Text',
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E5EA)),

          // Driver list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: drivers.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 20, color: Color(0xFFE5E5EA)),
              itemBuilder: (context, index) {
                final d = drivers[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            d.lastName.isNotEmpty
                                ? d.lastName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Yandex Sans Text',
                              color: Color(0xFF3C3C43),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.fullName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Yandex Sans Text',
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            if (d.middleName != null &&
                                d.middleName!.isNotEmpty)
                              Text(
                                d.middleName!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8E8E93),
                                  fontFamily: 'Yandex Sans Text',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Color(0xFFFF3B30)),
            const SizedBox(height: 12),
            Text(
              'Не удалось загрузить данные',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Yandex Sans Text',
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8E8E93),
                fontFamily: 'Yandex Sans Text',
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
