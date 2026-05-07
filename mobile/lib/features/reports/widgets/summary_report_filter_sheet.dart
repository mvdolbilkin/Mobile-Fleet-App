import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/map/data/map_repository.dart';
import 'package:mobile/features/map/domain/map_driver.dart';
import 'package:mobile/features/reports/domain/driver_summary.dart';
import 'package:mobile/features/reports/providers/summary_report_provider.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';
import 'package:mobile/shared/widgets/fading_button.dart';
import 'package:mobile/shared/widgets/filter_chip.dart';

class SummaryReportFilterSheet extends ConsumerStatefulWidget {
  final SummaryReportFilter initialFilter;
  final List<DriverSummaryItem> availableItems;

  const SummaryReportFilterSheet({
    super.key,
    required this.initialFilter,
    required this.availableItems,
  });

  static Future<SummaryReportFilter?> show({
    required BuildContext context,
    required SummaryReportFilter initialFilter,
    required List<DriverSummaryItem> availableItems,
  }) {
    return showModalBottomSheet<SummaryReportFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SummaryReportFilterSheet(
        initialFilter: initialFilter,
        availableItems: availableItems,
      ),
    );
  }

  @override
  ConsumerState<SummaryReportFilterSheet> createState() =>
      _SummaryReportFilterSheetState();
}

class _SummaryReportFilterSheetState
    extends ConsumerState<SummaryReportFilterSheet> {
  late DateTime _dateFrom;
  late DateTime _dateTo;
  String? _driverId;
  String? _driverName;
  String? _workRuleId;
  String? _workRuleName;
  late String _sortField;
  late String _sortDirection;

  @override
  void initState() {
    super.initState();
    _dateFrom = widget.initialFilter.dateFrom;
    _dateTo = widget.initialFilter.dateTo;
    _driverId = widget.initialFilter.driverId;
    _driverName = widget.initialFilter.driverName;
    _workRuleId = widget.initialFilter.workRuleId;
    _workRuleName = widget.initialFilter.workRuleName;
    _sortField = widget.initialFilter.sortField;
    _sortDirection = widget.initialFilter.sortDirection;
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  SummaryReportFilter _buildResult() => SummaryReportFilter(
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        driverId: _driverId,
        driverName: _driverName,
        workRuleId: _workRuleId,
        workRuleName: _workRuleName,
        sortField: _sortField,
        sortDirection: _sortDirection,
      );

  @override
  Widget build(BuildContext context) {
    final workRulesAsync = ref.watch(workRulesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: AppTheme.borderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Фильтры', style: AppTheme.listTitle),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            final def = SummaryReportFilter.defaultFilter;
                            _dateFrom = def.dateFrom;
                            _dateTo = def.dateTo;
                            _driverId = null;
                            _driverName = null;
                            _workRuleId = null;
                            _workRuleName = null;
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
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Период ──────────────────────────────────────────
                      _sectionLabel('Период'),
                      GestureDetector(
                        onTap: () async {
                          final range =
                              await CustomDateRangePickerBottomSheet.show(
                            context: context,
                            title: 'Выберите период',
                            startDate: _dateFrom,
                            endDate: _dateTo,
                          );
                          if (range != null) {
                            setState(() {
                              _dateFrom = range.start;
                              _dateTo = range.end;
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

                      // ─── Исполнитель ─────────────────────────────────────
                      _sectionLabel('Исполнитель'),
                      GestureDetector(
                        onTap: () async {
                          final drivers = widget.availableItems
                              .map((i) => {
                                    'id': i.driver.id,
                                    'label': i.driver.fullName,
                                    'sub': i.car.callsign,
                                  })
                              .toList();

                          final result = await _showPickerSheet(
                            context: context,
                            items: drivers,
                            labelBuilder: (d) => d['label'] as String,
                            subBuilder: (d) => d['sub'] as String? ?? '',
                            idBuilder: (d) => d['id'] as String,
                            selectedId: _driverId,
                            hint: 'Поиск исполнителя...',
                          );
                          if (result != null) {
                            final item = drivers.firstWhere(
                                (d) => d['id'] == result,
                                orElse: () => {});
                            setState(() {
                              _driverId = result;
                              _driverName = item['label'] as String?;
                            });
                          }
                        },
                        child: _rowControl(
                          icon: Icons.person_outline,
                          label: _driverName ?? 'Все исполнители',
                          hasValue: _driverId != null,
                          onClear: _driverId != null
                              ? () => setState(() {
                                    _driverId = null;
                                    _driverName = null;
                                  })
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ─── Условия работы ───────────────────────────────────
                      _sectionLabel('Условия работы'),
                      workRulesAsync.when(
                        data: (rules) => GestureDetector(
                          onTap: () async {
                            final items = rules
                                .map((r) => {
                                      'id': r.id,
                                      'label': r.name,
                                      'sub':
                                          '${r.commissionPercent}%',
                                    })
                                .toList();
                            final result = await _showPickerSheet(
                              context: context,
                              items: items,
                              labelBuilder: (d) => d['label'] as String,
                              subBuilder: (d) => d['sub'] as String? ?? '',
                              idBuilder: (d) => d['id'] as String,
                              selectedId: _workRuleId,
                              hint: 'Поиск условия работы...',
                            );
                            if (result != null) {
                              final item = items.firstWhere(
                                  (d) => d['id'] == result,
                                  orElse: () => {});
                              setState(() {
                                _workRuleId = result;
                                _workRuleName = item['label'] as String?;
                              });
                            }
                          },
                          child: _rowControl(
                            icon: Icons.work_outline,
                            label: _workRuleName ?? 'Все условия работы',
                            hasValue: _workRuleId != null,
                            onClear: _workRuleId != null
                                ? () => setState(() {
                                      _workRuleId = null;
                                      _workRuleName = null;
                                    })
                                : null,
                          ),
                        ),
                        loading: () => _rowControl(
                          icon: Icons.work_outline,
                          label: 'Загрузка...',
                          hasValue: false,
                        ),
                        error: (_, __) => _rowControl(
                          icon: Icons.work_outline,
                          label: 'Все условия работы',
                          hasValue: false,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ─── Сортировка ────────────────────────────────────────────
                      _sectionLabel('Сортировка'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: kSortOptions.map((opt) =>
                          CustomFilterChip(
                            label: opt.label,
                            isSelected: _sortField == opt.field,
                            onTap: () =>
                                setState(() => _sortField = opt.field),
                            borderRadius: 20,
                          ),
                        ).toList(),
                      ),
                      const SizedBox(height: 12),
                      // ── Direction toggle ───────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: CustomFilterChip(
                              label: 'По возрастанию ↑',
                              isSelected: _sortDirection == 'asc',
                              onTap: () =>
                                  setState(() => _sortDirection = 'asc'),
                              borderRadius: 10,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomFilterChip(
                              label: 'По убыванию ↓',
                              isSelected: _sortDirection == 'desc',
                              onTap: () =>
                                  setState(() => _sortDirection = 'desc'),
                              borderRadius: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Apply button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: FadingButton(
                  onTap: () => Navigator.pop(context, _buildResult()),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                          color: Colors.black),
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
                color: hasValue ? AppTheme.textPrimary : AppTheme.textSecondary,
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

  Future<String?> _showPickerSheet({
    required BuildContext context,
    required List<Map<String, dynamic>> items,
    required String Function(Map<String, dynamic>) labelBuilder,
    required String Function(Map<String, dynamic>) subBuilder,
    required String Function(Map<String, dynamic>) idBuilder,
    required String? selectedId,
    required String hint,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        items: items,
        labelBuilder: labelBuilder,
        subBuilder: subBuilder,
        idBuilder: idBuilder,
        selectedId: selectedId,
        hint: hint,
      ),
    );
  }
}

class _PickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic>) labelBuilder;
  final String Function(Map<String, dynamic>) subBuilder;
  final String Function(Map<String, dynamic>) idBuilder;
  final String? selectedId;
  final String hint;

  const _PickerSheet({
    required this.items,
    required this.labelBuilder,
    required this.subBuilder,
    required this.idBuilder,
    required this.hint,
    this.selectedId,
  });

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((i) =>
            widget.labelBuilder(i).toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final id = widget.idBuilder(item);
                    final isSelected = id == widget.selectedId;
                    final sub = widget.subBuilder(item);
                    return ListTile(
                      title: Text(widget.labelBuilder(item)),
                      subtitle: sub.isNotEmpty ? Text(sub) : null,
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.black)
                          : null,
                      onTap: () => Navigator.pop(context, id),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
