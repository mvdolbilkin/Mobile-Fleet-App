import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile/features/reports/domain/car_summary.dart';
import 'package:mobile/features/reports/domain/driver_summary.dart';
import 'package:mobile/features/reports/domain/park_summary.dart';
import 'package:mobile/features/reports/providers/car_summary_provider.dart';
import 'package:mobile/features/reports/providers/park_summary_provider.dart';
import 'package:mobile/features/reports/providers/summary_report_provider.dart';
import 'package:mobile/features/reports/widgets/summary_report_filter_sheet.dart';
import 'package:mobile/shared/widgets/animated_icon_button.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';
import 'package:mobile/shared/widgets/filter_chip.dart';

class SummaryReportScreen extends ConsumerStatefulWidget {
  const SummaryReportScreen({super.key});

  @override
  ConsumerState<SummaryReportScreen> createState() =>
      _SummaryReportScreenState();
}

class _SummaryReportScreenState extends ConsumerState<SummaryReportScreen> {
  int _selectedTab = 0;

  static const _tabs = [
    'По исполнителям',
    'По автомобилям',
    'По датам',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Сводный отчёт', style: AppTheme.appBarTitle),
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedIconButton(
            onTap: () => Navigator.of(context).pop(),
            icon: const Padding(
              padding: EdgeInsets.only(left: 6.0),
              child: Icon(Icons.arrow_back_ios,
                  size: 20, color: AppTheme.textPrimary),
            ),
            color: Colors.transparent,
            size: 40,
            borderRadius: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab selector
          Container(
            color: AppTheme.backgroundColor,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: List.generate(_tabs.length, (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Center(
                        child: CustomFilterChip(
                          label: _tabs[i],
                          isSelected: _selectedTab == i,
                          onTap: () => setState(() => _selectedTab = i),
                          selectedColor: Colors.black,
                          selectedBorderColor: Colors.black,
                          selectedTextColor: Colors.white,
                          unselectedColor: Colors.white,
                          unselectedBorderColor: const Color(0xFFDDDDDD),
                          unselectedTextColor: AppTheme.textPrimary,
                          borderRadius: 20,
                        ),
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: _selectedTab == 0
                ? _ByDriversTab()
                : _selectedTab == 1
                    ? _ByCarsTab()
                    : _ByDatesTab(),
          ),
        ],
      ),
    );
  }
}

// Tab: by drivers

class _ByDriversTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(summaryReportProvider);
    final notifier = ref.read(summaryReportProvider.notifier);
    final filter = state.filter;

    return Column(
      children: [
        // Filter toolbar
        _FilterToolbar(
          filter: filter,
          availableItems: state.data?.items ?? [],
          onFilterChanged: notifier.applyFilter,
        ),

        // Content
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? _ErrorView(
                      error: state.error!,
                      onRetry: notifier.refresh,
                    )
                  : state.data == null
                      ? const Center(
                          child: Text('Нет данных',
                              style: AppTheme.captionSecondary))
                      : _DriversContent(
                          items: state.filteredItems,
                          total: state.data!.total,
                          onRefresh: notifier.refresh,
                        ),
        ),
      ],
    );
  }
}

// Filter toolbar

class _FilterToolbar extends StatelessWidget {
  final SummaryReportFilter filter;
  final List<DriverSummaryItem> availableItems;
  final ValueChanged<SummaryReportFilter> onFilterChanged;

  const _FilterToolbar({
    required this.filter,
    required this.availableItems,
    required this.onFilterChanged,
  });

  bool get _hasActiveFilters =>
      filter.driverId != null ||
      filter.workRuleId != null ||
      filter.sortField != 'driver_id' ||
      filter.sortDirection != 'asc';

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Filter button
            GestureDetector(
              onTap: () async {
                final result = await SummaryReportFilterSheet.show(
                  context: context,
                  initialFilter: filter,
                  availableItems: availableItems,
                );
                if (result != null) onFilterChanged(result);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _hasActiveFilters
                      ? AppTheme.buttonColor
                      : AppTheme.controlsColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune, size: 18,
                    color: AppTheme.textPrimary),
              ),
            ),
            const SizedBox(width: 8),

            // Date range chip
            _FilterChip(
              label: '${_fmt(filter.dateFrom)} – ${_fmt(filter.dateTo)}',
              icon: Icons.calendar_today_outlined,
              active: false,
              onTap: () async {
                final range = await CustomDateRangePickerBottomSheet.show(
                  context: context,
                  title: 'Выберите период',
                  startDate: filter.dateFrom,
                  endDate: filter.dateTo,
                );
                if (range != null) {
                  onFilterChanged(filter.copyWith(
                    dateFrom: range.start,
                    dateTo: range.end,
                  ));
                }
              },
            ),
            const SizedBox(width: 8),

            // Driver chip
            _FilterChip(
              label: filter.driverName ?? 'Исполнитель',
              icon: Icons.person_outline,
              active: filter.driverId != null,
              onClear: filter.driverId != null
                  ? () => onFilterChanged(filter.copyWith(clearDriver: true))
                  : null,
              onTap: () async {
                final result = await SummaryReportFilterSheet.show(
                  context: context,
                  initialFilter: filter,
                  availableItems: availableItems,
                );
                if (result != null) onFilterChanged(result);
              },
            ),
            const SizedBox(width: 8),

            // Work conditions chip
            _FilterChip(
              label: filter.workRuleName ?? 'Условия работы',
              icon: Icons.work_outline,
              active: filter.workRuleId != null,
              onClear: filter.workRuleId != null
                  ? () => onFilterChanged(filter.copyWith(clearWorkRule: true))
                  : null,
              onTap: () async {
                final result = await SummaryReportFilterSheet.show(
                  context: context,
                  initialFilter: filter,
                  availableItems: availableItems,
                );
                if (result != null) onFilterChanged(result);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? AppTheme.buttonColor : AppTheme.controlsColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close,
                    size: 14, color: AppTheme.textSecondary),
              ),
            ] else ...[
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down,
                  size: 16, color: AppTheme.textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Drivers content

class _DriversContent extends StatelessWidget {
  final List<DriverSummaryItem> items;
  final DriverSummaryTotal total;
  final Future<void> Function() onRefresh;

  const _DriversContent({
    required this.items,
    required this.total,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Нет данных за выбранный период',
            style: AppTheme.captionSecondary),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _DriverCard(item: items[i]),
            ),
          ),
        ),
        _TotalsBar(total: total, count: items.length),
      ],
    );
  }
}

// Helpers 

String _fmtMoney(double v) {
  final abs = v.abs();
  final str = abs == abs.truncateToDouble()
      ? abs.toInt().toString()
      : abs.toStringAsFixed(2);
  final formatted = str.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]} ',
  );
  return '${v < 0 ? '−' : ''}$formatted ₽';
}

Color _moneyColor(double v) {
  if (v > 0) return const Color(0xFF1A9A44);
  if (v < 0) return const Color(0xFFD0021B);
  return AppTheme.textSecondary;
}

// Driver card

class _DriverCard extends StatelessWidget {
  final DriverSummaryItem item;
  const _DriverCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final driver = item.driver;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (driver.licenseNumber.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        driver.licenseNumber,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.car.callsign.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.controlsColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.car.callsign,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 10),

          // Stats row
          Row(
            children: [
              _Cell(
                label: 'Заказов',
                value: '${item.countOrdersCompleted}',
                sub: 'из ${item.countOrdersAll}',
              ),
              _dividerV(),
              _Cell(
                label: 'Время на линии',
                value: item.workTimeFormatted,
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 10),

          // Financials grid
          Row(
            children: [
              Expanded(
                child: _MoneyCell(
                    label: 'Наличные', value: item.priceCash),
              ),
              Expanded(
                child: _MoneyCell(
                    label: 'Безналичные', value: item.priceCashless),
              ),
              Expanded(
                child: _MoneyCell(
                    label: 'Ком. платф.',
                    value: item.pricePlatformCommission),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MoneyCell(
                    label: 'Ком. парка',
                    value: item.priceParkCommission),
              ),
              Expanded(
                child: _MoneyCell(
                    label: 'Прочее', value: item.priceOtherGas),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dividerV() => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: const Color(0xFFF0F0F0),
      );
}

class _Cell extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  const _Cell({required this.label, required this.value, this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (sub != null) ...[
              const SizedBox(width: 4),
              Text(
                sub!,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
        Text(
          label,
          style: const TextStyle(
              fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _MoneyCell extends StatelessWidget {
  final String label;
  final double value;
  const _MoneyCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _fmtMoney(value),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _moneyColor(value),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
              fontSize: 10, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

// Totals bar

class _TotalsBar extends StatelessWidget {
  final DriverSummaryTotal total;
  final int count;
  const _TotalsBar({required this.total, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary line
          Text(
            'Итого · $count исп. · ${total.countOrdersCompleted} заказов · ${total.workTimeFormatted}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          // Financials grid
          Table(
            columnWidths: const {
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
            },
            children: [
              TableRow(children: [
                _TotalCell(
                    label: 'Наличные',
                    value: _fmtMoney(total.sumPriceCash),
                    color: _moneyColor(total.sumPriceCash)),
                _TotalCell(
                    label: 'Безналичные',
                    value: _fmtMoney(total.sumPriceCashless),
                    color: _moneyColor(total.sumPriceCashless)),
                _TotalCell(
                    label: 'Ком. платформы',
                    value: _fmtMoney(total.sumPricePlatformCommission),
                    color: _moneyColor(total.sumPricePlatformCommission)),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _TotalCell(
                      label: 'Ком. парка',
                      value: _fmtMoney(total.sumPriceParkCommission),
                      color: _moneyColor(total.sumPriceParkCommission)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _TotalCell(
                      label: 'Прочее',
                      value: _fmtMoney(total.sumPriceOtherGas),
                      color: _moneyColor(total.sumPriceOtherGas)),
                ),
                const SizedBox(),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _TotalCell(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppTheme.textSecondary)),
      ],
    );
  }
}

// Tab: by cars

class _ByCarsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(carSummaryProvider);
    final notifier = ref.read(carSummaryProvider.notifier);

    if (state.isLoading && state.data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.data == null) {
      return _ErrorView(
          error: state.error!, onRetry: () => notifier.refresh());
    }

    final items = state.data?.items ?? [];
    final total = state.data?.total;

    return Column(
      children: [
        _CarFilterToolbar(
          filter: state.filter,
          onFilterChanged: notifier.applyFilter,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: notifier.refresh,
            child: items.isEmpty
                ? const Center(child: Text('Нет данных'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) => _CarCard(item: items[i]),
                  ),
          ),
        ),
        if (total != null)
          _CarTotalsBar(total: total, count: items.length),
      ],
    );
  }
}

// Car filter toolbar

class _CarFilterToolbar extends StatelessWidget {
  final CarSummaryFilter filter;
  final ValueChanged<CarSummaryFilter> onFilterChanged;

  const _CarFilterToolbar({
    required this.filter,
    required this.onFilterChanged,
  });

  bool get _hasActiveFilters =>
      filter.sortField != 'car_id' || filter.sortDirection != 'asc';

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
            // Filter button
            GestureDetector(
              onTap: () async {
                final result = await _CarFilterSheet.show(
                  context: context,
                  initialFilter: filter,
                );
                if (result != null) onFilterChanged(result);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _hasActiveFilters
                      ? AppTheme.buttonColor
                      : AppTheme.controlsColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune, size: 18,
                    color: AppTheme.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            // Date chip
            _FilterChip(
              label:
                  '${_fmt(filter.dateFrom)} – ${_fmt(filter.dateTo)}',
              icon: Icons.calendar_today_outlined,
              active: false,
              onTap: () async {
                final range =
                    await CustomDateRangePickerBottomSheet.show(
                  context: context,
                  title: 'Выберите период',
                  startDate: filter.dateFrom,
                  endDate: filter.dateTo,
                );
                if (range != null) {
                  onFilterChanged(filter.copyWith(
                    dateFrom: range.start,
                    dateTo: range.end,
                  ));
                }
              },
            ),
          ],
      ),
    );
  }
}

// Car filter bottom sheet

class _CarFilterSheet extends StatefulWidget {
  final CarSummaryFilter initialFilter;

  const _CarFilterSheet({required this.initialFilter});

  static Future<CarSummaryFilter?> show({
    required BuildContext context,
    required CarSummaryFilter initialFilter,
  }) {
    return showModalBottomSheet<CarSummaryFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CarFilterSheet(initialFilter: initialFilter),
    );
  }

  @override
  State<_CarFilterSheet> createState() => _CarFilterSheetState();
}

class _CarFilterSheetState extends State<_CarFilterSheet> {
  late String _sortField;
  late String _sortDirection;

  @override
  void initState() {
    super.initState();
    _sortField = widget.initialFilter.sortField;
    _sortDirection = widget.initialFilter.sortDirection;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: AppTheme.borderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Сортировка',
                        style: AppTheme.listTitle),
                    Row(children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          final def = CarSummaryFilter.defaultFilter;
                          _sortField = def.sortField;
                          _sortDirection = def.sortDirection;
                        }),
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
                    ]),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sheetLabel('Поле сортировки'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: kCarSortOptions.map((opt) =>
                          CustomFilterChip(
                            label: opt.label,
                            isSelected: _sortField == opt.field,
                            onTap: () => setState(
                                () => _sortField = opt.field),
                            borderRadius: 20,
                          ),
                        ).toList(),
                      ),
                      const SizedBox(height: 16),
                      _sheetLabel('Направление'),
                      Row(children: [
                        Expanded(
                          child: CustomFilterChip(
                            label: 'По возрастанию ↑',
                            isSelected: _sortDirection == 'asc',
                            onTap: () => setState(
                                () => _sortDirection = 'asc'),
                            borderRadius: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomFilterChip(
                            label: 'По убыванию ↓',
                            isSelected: _sortDirection == 'desc',
                            onTap: () => setState(
                                () => _sortDirection = 'desc'),
                            borderRadius: 10,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.buttonColor,
                      foregroundColor: Colors.black,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(
                      context,
                      CarSummaryFilter(
                        dateFrom: widget.initialFilter.dateFrom,
                        dateTo: widget.initialFilter.dateTo,
                        sortField: _sortField,
                        sortDirection: _sortDirection,
                      ),
                    ),
                    child: const Text('Применить',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary)),
      );
}

// Car card

class _CarCard extends StatelessWidget {
  final CarSummaryItem item;
  const _CarCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final car = item.car;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      car.number,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              if (car.callsign.isNotEmpty &&
                  car.callsign != car.number)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.controlsColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    car.callsign,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary),
                  ),
                ),
            ],
          ),

          // Drivers
          if (item.drivers.isNotEmpty) ...[
            const SizedBox(height: 10),
            _DriversRow(drivers: item.drivers),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 10),

          // Utilization bar
          Row(
            children: [
              Expanded(
                child: _UtilBar(percent: item.utilization),
              ),
              const SizedBox(width: 10),
              Text(
                '${item.utilization}%',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 16),
              Text(
                '${item.utilizationDays} д. / ${item.utilizationDays + item.noUtilizationDays} д.',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 10),

          // Stats + financials grid
          Row(
            children: [
              Expanded(
                  child: _Cell(
                      label: 'Заказов',
                      value: '${item.countOrdersAll}')),
              Expanded(
                  child: _Cell(
                      label: 'Пробег',
                      value: '${item.distanceKm} км')),
              Expanded(
                  child: _MoneyCell(
                      label: 'Аренда', value: item.priceRent)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _MoneyCell(
                      label: 'Наличные', value: item.priceCash)),
              Expanded(
                  child: _MoneyCell(
                      label: 'Безналичные',
                      value: item.priceCashless)),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

class _DriversRow extends StatelessWidget {
  final List<CarSummaryDriver> drivers;
  const _DriversRow({required this.drivers});

  static const _avatarColors = [
    Color(0xFF4A90D9),
    Color(0xFF7B68EE),
    Color(0xFF50C878),
    Color(0xFFFF7043),
    Color(0xFFFFB300),
  ];

  @override
  Widget build(BuildContext context) {
    const maxShow = 4;
    final shown = drivers.take(maxShow).toList();
    final extra = drivers.length - maxShow;

    return Row(
      children: [
        // Stacked avatars
        SizedBox(
          height: 28,
          width: shown.isEmpty ? 0 : (shown.length - 1) * 22.0 + 28 + (extra > 0 ? 28 : 0),
          child: Stack(
            children: [
              for (int i = 0; i < shown.length; i++)
                Positioned(
                  left: i * 22.0,
                  child: _Avatar(
                    initials: shown[i].initials,
                    color: _avatarColors[i % _avatarColors.length],
                  ),
                ),
              if (extra > 0)
                Positioned(
                  left: shown.length * 22.0,
                  child: _Avatar(
                    initials: '+$extra',
                    color: AppTheme.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            drivers.length == 1
                ? drivers.first.fullName
                : '${drivers.first.fullName}${drivers.length > 1 ? ', ещё ${drivers.length - 1}' : ''}',
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;
  const _Avatar({required this.initials, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white),
      ),
    );
  }
}

class _UtilBar extends StatelessWidget {
  final int percent;
  const _UtilBar({required this.percent});

  Color get _barColor {
    if (percent >= 75) return const Color(0xFF1A9A44);
    if (percent >= 40) return const Color(0xFFFFB300);
    return const Color(0xFFD0021B);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: percent / 100,
        minHeight: 6,
        backgroundColor: const Color(0xFFE5E5EA),
        valueColor: AlwaysStoppedAnimation<Color>(_barColor),
      ),
    );
  }
}

// Car totals bar

class _CarTotalsBar extends StatelessWidget {
  final CarSummaryTotal total;
  final int count;
  const _CarTotalsBar({required this.total, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Итого · ${total.countCars} авт. · ${total.countDrivers} вод. · ${total.avgUtilization}% сдав.',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
            },
            children: [
              TableRow(children: [
                _TotalCell(
                    label: 'Заказов',
                    value: '${total.countOrdersAll}',
                    color: AppTheme.textPrimary),
                _TotalCell(
                    label: 'Пробег',
                    value: '${total.distanceKm} км',
                    color: AppTheme.textPrimary),
                _TotalCell(
                    label: 'Аренда',
                    value: _fmtMoney(total.sumPriceRent),
                    color: _moneyColor(total.sumPriceRent)),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _TotalCell(
                      label: 'Наличные',
                      value: _fmtMoney(total.sumPriceCash),
                      color: _moneyColor(total.sumPriceCash)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _TotalCell(
                      label: 'Безналичные',
                      value: _fmtMoney(total.sumPriceCashless),
                      color: _moneyColor(total.sumPriceCashless)),
                ),
                const SizedBox(),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

// Tab: by dates

class _ByDatesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parkSummaryProvider);
    final notifier = ref.read(parkSummaryProvider.notifier);

    if (state.isLoading && state.data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.data == null) {
      return _ErrorView(
          error: state.error!, onRetry: () => notifier.refresh());
    }

    final items = state.data?.items ?? [];

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: items.isEmpty
          ? const Center(child: Text('Нет данных'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _MonthCard(item: items[i]),
            ),
    );
  }
}

class _MonthCard extends StatefulWidget {
  final ParkSummaryItem item;
  const _MonthCard({required this.item});

  @override
  State<_MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends State<_MonthCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.monthLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Key metrics
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity grid 2x2
                Row(children: [
                  Expanded(child: _Pill(
                    icon: HugeIcons.strokeRoundedCar01,
                    label: '${item.countActiveCars}',
                    sublabel: 'автомобилей',
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _Pill(
                    icon: HugeIcons.strokeRoundedUser,
                    label: '${item.countActiveDrivers}',
                    sublabel: 'водителей',
                  )),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _Pill(
                    icon: HugeIcons.strokeRoundedUserAdd01,
                    label: '+${item.countNewDrivers}',
                    sublabel: 'новых вод.',
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _Pill(
                    icon: HugeIcons.strokeRoundedUserRemove01,
                    label: '${item.ratioDriverChurn.toStringAsFixed(1)}%',
                    sublabel: 'отток вод.',
                    warning: item.ratioDriverChurn > 50,
                  )),
                ]),
                const SizedBox(height: 10),
                // Orders row
                Row(children: [
                  Expanded(
                    child: _Stat(
                      label: 'Завершено',
                      value: '${item.countOrdersCompleted} / ${item.countOrdersAll}',
                    ),
                  ),
                  Expanded(
                    child: _Stat(
                      label: 'Отмен вод.',
                      value: '${item.countOrdersCancelledByDriver}',
                    ),
                  ),
                  Expanded(
                    child: _Stat(
                      label: 'Отмен кл.',
                      value: '${item.countOrdersCancelledByClient}',
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                // Time row
                Row(children: [
                  Expanded(
                    child: _Stat(
                      label: 'Вод. на линии',
                      value: ParkSummaryItem.fmtSeconds(
                          item.avgDriversWorkTimeSeconds),
                    ),
                  ),
                  Expanded(
                    child: _Stat(
                      label: 'Авто на линии',
                      value: ParkSummaryItem.fmtSeconds(
                          item.avgCarsWorkTimeSeconds),
                    ),
                  ),
                ]),
              ],
            ),
          ),

          // Expanded financials
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Финансы',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: _MoneyCell(
                            label: 'Наличные', value: item.priceCash)),
                    Expanded(
                        child: _MoneyCell(
                            label: 'Безналичные',
                            value: item.priceCashless)),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(
                        child: _MoneyCell(
                            label: 'Ком. платформы',
                            value: item.pricePlatformCommission)),
                    Expanded(
                        child: _MoneyCell(
                            label: 'Ком. парка',
                            value: item.priceParkCommission)),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(
                        child: _MoneyCell(
                            label: 'Диспетчерская',
                            value: item.priceSoftwareCommission)),
                    Expanded(
                        child: _MoneyCell(
                            label: 'Привлечение',
                            value: item.priceHiringServices)),
                  ]),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final String sublabel;
  final bool warning;

  const _Pill({
    required this.icon,
    required this.label,
    required this.sublabel,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = warning ? const Color(0xFFE65100) : AppTheme.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: warning
            ? const Color(0xFFFFF8F0)
            : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, size: 15, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                sublabel,
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppTheme.textSecondary)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
      ],
    );
  }
}

// Placeholder tab

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded,
              size: 48, color: AppTheme.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text('$label — в разработке',
              style: AppTheme.captionSecondary),
        ],
      ),
    );
  }
}

// Error view

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: AppTheme.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
