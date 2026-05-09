import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/domain/car_efficiency_model.dart';
import 'package:mobile/features/fleet/domain/vehicle_type_model.dart';
import 'package:mobile/features/fleet/presentation/car_efficiency/providers/car_efficiency_provider.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/providers/vehicle_type_provider.dart';
import 'package:mobile/shared/widgets/filter_chip.dart';
import 'package:mobile/features/fleet/data/vehicles_service.dart';
import 'package:mobile/features/fleet/domain/vehicle.dart' hide VehicleType;
import 'package:mobile/features/fleet/presentation/vehicles/providers/vehicles_provider.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class CarEfficiencyScreen extends ConsumerStatefulWidget {
  const CarEfficiencyScreen({super.key});

  @override
  ConsumerState<CarEfficiencyScreen> createState() =>
      _CarEfficiencyScreenState();
}

class _CarEfficiencyScreenState extends ConsumerState<CarEfficiencyScreen> {
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();

  static const double _colCar = 180;
  static const double _colDriver = 200;
  static const double _colStatus = 170;
  static const double _colTrips = 80;
  static const double _colHours = 130;
  static const double _colAcceptance = 145;
  static const double _colCancellation = 175;
  static const double _colCompletion = 175;

  static const double _rowHeight = 64;
  static const double _headerHeight = 44;

  @override
  void initState() {
    super.initState();
    _verticalScroll.addListener(_onVerticalScroll);
  }

  @override
  void dispose() {
    _verticalScroll.dispose();
    _horizontalScroll.dispose();
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
                    : _TableView(
                        state: state,
                        verticalScroll: _verticalScroll,
                        horizontalScroll: _horizontalScroll,
                        rowHeight: _rowHeight,
                        headerHeight: _headerHeight,
                        colWidths: _ColWidths(
                          car: _colCar,
                          driver: _colDriver,
                          status: _colStatus,
                          trips: _colTrips,
                          hours: _colHours,
                          acceptance: _colAcceptance,
                          cancellation: _colCancellation,
                          completion: _colCompletion,
                        ),
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
  final VoidCallback onResetAll;
  final String Function(DateTime, DateTime) formatDateRange;

  const _FiltersBar({
    required this.state,
    required this.onDateTap,
    required this.onFiltersTap,
    required this.onRemoveFleetCarsOnly,
    required this.onRemoveCarTypes,
    required this.onRemoveCarIds,
    required this.onResetAll,
    required this.formatDateRange,
  });

  bool get _hasFilters =>
      state.selectedCarTypes.isNotEmpty ||
      state.selectedCarIds.isNotEmpty ||
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

// ─── Table ────────────────────────────────────────────────────────────────────

class _ColWidths {
  final double car;
  final double driver;
  final double status;
  final double trips;
  final double hours;
  final double acceptance;
  final double cancellation;
  final double completion;

  const _ColWidths({
    required this.car,
    required this.driver,
    required this.status,
    required this.trips,
    required this.hours,
    required this.acceptance,
    required this.cancellation,
    required this.completion,
  });

  double get total =>
      car + driver + status + trips + hours + acceptance + cancellation + completion;
}

class _TableView extends StatelessWidget {
  final CarEfficiencyState state;
  final ScrollController verticalScroll;
  final ScrollController horizontalScroll;
  final double rowHeight;
  final double headerHeight;
  final _ColWidths colWidths;
  final String Function(int) formatSupplyTime;
  final String Function(double?) formatPercent;
  final Color Function(String) statusColor;

  const _TableView({
    required this.state,
    required this.verticalScroll,
    required this.horizontalScroll,
    required this.rowHeight,
    required this.headerHeight,
    required this.colWidths,
    required this.formatSupplyTime,
    required this.formatPercent,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: verticalScroll,
      child: SingleChildScrollView(
        controller: horizontalScroll,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — живёт в том же горизонтальном контейнере
            _HeaderRow(colWidths: colWidths, height: headerHeight),
            const Divider(height: 1, color: Color(0xFFE5E5EA)),
            // Data rows
            ...state.items.asMap().entries.map((entry) {
              final isLast = entry.key == state.items.length - 1;
              return Column(
                children: [
                  _DataRow(
                    item: entry.value,
                    colWidths: colWidths,
                    rowHeight: rowHeight,
                    formatSupplyTime: formatSupplyTime,
                    formatPercent: formatPercent,
                    statusColor: statusColor,
                  ),
                  if (!isLast || state.isLoadingMore)
                    const Divider(height: 1, color: Color(0xFFE5E5EA)),
                ],
              );
            }),
            if (state.isLoadingMore)
              SizedBox(
                width: colWidths.total,
                height: 48,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            if (!state.isLoadingMore && !state.hasMore && state.items.isNotEmpty)
              SizedBox(
                width: colWidths.total,
                height: 40,
                child: Center(
                  child: Text(
                    'Всего: ${state.total}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Header row ───────────────────────────────────────────────────────────────

class _HeaderRow extends StatelessWidget {
  final _ColWidths colWidths;
  final double height;

  const _HeaderRow({required this.colWidths, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Colors.white,
      child: Row(
        children: [
          _HeaderCell('ТС', colWidths.car, align: TextAlign.left),
          _HeaderCell('Водитель', colWidths.driver, align: TextAlign.left),
          _HeaderCell('Дней в статусе', colWidths.status),
          _HeaderCell('Поездки', colWidths.trips),
          _HeaderCell('Часы на линии', colWidths.hours),
          _HeaderCell('Доля принятых\nзаказов', colWidths.acceptance),
          _HeaderCell('Доля заказов,\nотменённых водителем', colWidths.cancellation),
          _HeaderCell('Доля успешно\nвыполненных заказов', colWidths.completion),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;
  final TextAlign align;

  const _HeaderCell(this.label, this.width,
      {this.align = TextAlign.right});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8E8E93),
            fontFamily: 'Yandex Sans Text',
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

// ─── Data row ─────────────────────────────────────────────────────────────────

class _DataRow extends StatelessWidget {
  final CarEfficiencyItem item;
  final _ColWidths colWidths;
  final double rowHeight;
  final String Function(int) formatSupplyTime;
  final String Function(double?) formatPercent;
  final Color Function(String) statusColor;

  const _DataRow({
    required this.item,
    required this.colWidths,
    required this.rowHeight,
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
    final extraDrivers = item.drivers.length - (visibleDriver != null ? 1 : 0);

    return Container(
      height: rowHeight,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ТС
          SizedBox(
            width: colWidths.car,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${item.car.carBrand} ${item.car.carModel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Yandex Sans Text',
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.car.carNumber,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8E8E93),
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Водитель
          SizedBox(
            width: colWidths.driver,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: item.drivers.isEmpty
                  ? const Text(
                      '—',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                        fontFamily: 'Yandex Sans Text',
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          visibleDriver!.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Yandex Sans Text',
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        if (extraDrivers > 0)
                          GestureDetector(
                            onTap: () => _showDriversSheet(context),
                            child: Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E5EA),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Ещё $extraDrivers',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF3C3C43),
                                  fontFamily: 'Yandex Sans Text',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),

          // Дней в статусе
          SizedBox(
            width: colWidths.status,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: primaryStatus == null
                  ? const Text('—',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8E8E93),
                          fontFamily: 'Yandex Sans Text'))
                  : Row(
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
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${primaryStatus.status.name} ${primaryStatus.days} д.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Yandex Sans Text',
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Поездки
          SizedBox(
            width: colWidths.trips,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${item.successOrdersCount}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Yandex Sans Text',
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ),
          ),

          // Часы на линии
          SizedBox(
            width: colWidths.hours,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                formatSupplyTime(item.supplyTimeSeconds),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Yandex Sans Text',
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ),
          ),

          // Доля принятых заказов
          SizedBox(
            width: colWidths.acceptance,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                formatPercent(item.acceptanceRate),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Yandex Sans Text',
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ),
          ),

          // Доля заказов, отменённых водителями
          SizedBox(
            width: colWidths.cancellation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                formatPercent(item.driverCancellationRate),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Yandex Sans Text',
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ),
          ),

          // Доля успешно выполненных заказов
          SizedBox(
            width: colWidths.completion,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                formatPercent(item.completionRate),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Yandex Sans Text',
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ),
          ),
        ],
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

  @override
  void initState() {
    super.initState();
    final s = widget.initialState;
    _dateFrom = s.dateFrom;
    _dateTo = s.dateTo;
    _fleetCarsOnly = s.fleetCarsOnly;
    _selectedCarTypes = Set.from(s.selectedCarTypes);
    _selectedCarIds = Set.from(s.selectedCarIds);
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  void _reset() {
    setState(() {
      _fleetCarsOnly = false;
      _selectedCarTypes.clear();
      _selectedCarIds.clear();
    });
  }

  void _apply() {
    ref.read(carEfficiencyProvider.notifier).applyFilters(
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      fleetCarsOnly: _fleetCarsOnly,
      carTypes: Set.from(_selectedCarTypes),
      carIds: Set.from(_selectedCarIds),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vehicleTypes =
        ref.watch(vehicleTypesProvider).asData?.value ?? [];
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
                      _sectionLabel('Настройки'),
                      Container(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 4, 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Только парковые машины',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: AppTheme.textPrimary),
                              ),
                            ),
                            Switch.adaptive(
                              value: _fleetCarsOnly,
                              onChanged: (v) =>
                                  setState(() => _fleetCarsOnly = v),
                              activeColor: const Color(0xFF34C759),
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
