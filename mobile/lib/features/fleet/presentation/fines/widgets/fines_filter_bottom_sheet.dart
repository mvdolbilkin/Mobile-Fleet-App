import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/presentation/fines/providers/fines_provider.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';
import 'package:mobile/shared/widgets/fading_button.dart';
import 'package:mobile/shared/widgets/filter_chip.dart';

class FinesFilterBottomSheet extends ConsumerStatefulWidget {
  final FinesFilter initialFilter;

  const FinesFilterBottomSheet({super.key, required this.initialFilter});

  static Future<FinesFilter?> show({
    required BuildContext context,
    required FinesFilter initialFilter,
  }) {
    return showModalBottomSheet<FinesFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FinesFilterBottomSheet(initialFilter: initialFilter),
    );
  }

  @override
  ConsumerState<FinesFilterBottomSheet> createState() => _FinesFilterBottomSheetState();
}

class _FinesFilterBottomSheetState extends ConsumerState<FinesFilterBottomSheet> {
  late DateTime? _dateFrom;
  late DateTime? _dateTo;
  late String? _carId;
  late String? _driverId;
  late Set<String> _contractorPaymentStatuses;
  late Set<String> _contractorAssignmentStatuses;
  late bool? _wasLoadedBankClient;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilter;
    _dateFrom = f.dateFrom;
    _dateTo = f.dateTo;
    _carId = f.carId;
    _driverId = f.driverId;
    _contractorPaymentStatuses = Set.from(f.contractorPaymentStatuses ?? []);
    _contractorAssignmentStatuses = Set.from(f.contractorAssignmentStatuses ?? []);
    _wasLoadedBankClient = f.wasLoadedBankClient;
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  String _driverLabel(Map<String, dynamic> d) {
    final parts = [d['last_name'], d['first_name'], d['middle_name']]
        .where((p) => p != null && (p as String).isNotEmpty)
        .join(' ');
    return parts.isNotEmpty ? parts : d['id'] ?? '';
  }

  String _carLabel(Map<String, dynamic> c) {
    final brand = c['brand'] ?? '';
    final model = c['model'] ?? '';
    final number = c['number'] ?? '';
    return '$brand $model  $number'.trim();
  }

  void _togglePaymentStatus(String value) {
    setState(() {
      if (_contractorPaymentStatuses.contains(value)) {
        _contractorPaymentStatuses.remove(value);
      } else {
        _contractorPaymentStatuses.add(value);
      }
    });
  }

  void _toggleAssignmentStatus(String value) {
    setState(() {
      if (_contractorAssignmentStatuses.contains(value)) {
        _contractorAssignmentStatuses.remove(value);
      } else {
        _contractorAssignmentStatuses.add(value);
      }
    });
  }

  FinesFilter _buildResult() => FinesFilter(
        statusFilter: widget.initialFilter.statusFilter,
        searchQuery: widget.initialFilter.searchQuery,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        carId: _carId,
        driverId: _driverId,
        contractorPaymentStatuses:
            _contractorPaymentStatuses.isEmpty ? null : _contractorPaymentStatuses.toList(),
        contractorAssignmentStatuses:
            _contractorAssignmentStatuses.isEmpty ? null : _contractorAssignmentStatuses.toList(),
        wasLoadedBankClient: _wasLoadedBankClient,
      );

  @override
  Widget build(BuildContext context) {
    final carsAsync = ref.watch(finesSuggestCarsProvider);
    final driversAsync = ref.watch(finesSuggestDriversProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Фильтры', style: AppTheme.listTitle),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _dateFrom = null;
                              _dateTo = null;
                              _carId = null;
                              _driverId = null;
                              _contractorPaymentStatuses.clear();
                              _contractorAssignmentStatuses.clear();
                              _wasLoadedBankClient = null;
                            });
                          },
                          child: const Text(
                            'Сбросить',
                            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: AppTheme.textSecondary, size: 24),
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
                      // Период
                      _sectionLabel('Период'),
                      GestureDetector(
                        onTap: () async {
                          final range = await CustomDateRangePickerBottomSheet.show(
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
                          label: (_dateFrom != null && _dateTo != null)
                              ? '${_fmt(_dateFrom!)} — ${_fmt(_dateTo!)}'
                              : 'Любой период',
                          hasValue: _dateFrom != null,
                          onClear: () => setState(() {
                            _dateFrom = null;
                            _dateTo = null;
                          }),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Автомобиль
                      _sectionLabel('Автомобиль'),
                      carsAsync.when(
                        data: (cars) => _searchablePickerControl(
                          items: cars,
                          labelBuilder: _carLabel,
                          idBuilder: (c) => c['id'] as String? ?? '',
                          selectedId: _carId,
                          placeholder: 'Все автомобили',
                          onSelected: (id) => setState(() => _carId = id),
                          onClear: () => setState(() => _carId = null),
                        ),
                        loading: () => const _LoadingRow(),
                        error: (_, __) => const _ErrorRow('Не удалось загрузить автомобили'),
                      ),
                      const SizedBox(height: 20),

                      // Водитель
                      _sectionLabel('Водитель'),
                      driversAsync.when(
                        data: (drivers) => _searchablePickerControl(
                          items: drivers,
                          labelBuilder: _driverLabel,
                          idBuilder: (d) => d['id'] as String? ?? '',
                          selectedId: _driverId,
                          placeholder: 'Все водители',
                          onSelected: (id) => setState(() => _driverId = id),
                          onClear: () => setState(() => _driverId = null),
                        ),
                        loading: () => const _LoadingRow(),
                        error: (_, __) => const _ErrorRow('Не удалось загрузить водителей'),
                      ),
                      const SizedBox(height: 20),

                      // Статус платежа
                      _sectionLabel('Статус платежа'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          CustomFilterChip(
                            label: 'Списано',
                            isSelected: _contractorPaymentStatuses.contains('paid'),
                            onTap: () => _togglePaymentStatus('paid'),
                            borderRadius: 20,
                          ),
                          CustomFilterChip(
                            label: 'Не списано',
                            isSelected: _contractorPaymentStatuses.contains('planned'),
                            onTap: () => _togglePaymentStatus('planned'),
                            borderRadius: 20,
                          ),
                          CustomFilterChip(
                            label: 'В процессе',
                            isSelected: _contractorPaymentStatuses.contains('processing'),
                            onTap: () => _togglePaymentStatus('processing'),
                            borderRadius: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Статус определения водителя
                      _sectionLabel('Статус определения водителя'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          CustomFilterChip(
                            label: 'Определен',
                            isSelected: _contractorAssignmentStatuses.contains('determined') ||
                                _contractorAssignmentStatuses.contains('user_set'),
                            onTap: () {
                              final group = ['determined', 'user_set'];
                              final allPresent = group.every(_contractorAssignmentStatuses.contains);
                              setState(() {
                                if (allPresent) {
                                  group.forEach(_contractorAssignmentStatuses.remove);
                                } else {
                                  _contractorAssignmentStatuses.addAll(group);
                                }
                              });
                            },
                            borderRadius: 20,
                          ),
                          CustomFilterChip(
                            label: 'В процессе определения',
                            isSelected: _contractorAssignmentStatuses.contains('planned') ||
                                _contractorAssignmentStatuses.contains('ambiguous'),
                            onTap: () {
                              final group = ['planned', 'ambiguous'];
                              final allPresent = group.every(_contractorAssignmentStatuses.contains);
                              setState(() {
                                if (allPresent) {
                                  group.forEach(_contractorAssignmentStatuses.remove);
                                } else {
                                  _contractorAssignmentStatuses.addAll(group);
                                }
                              });
                            },
                            borderRadius: 20,
                          ),
                          CustomFilterChip(
                            label: 'Не удалось определить',
                            isSelected: _contractorAssignmentStatuses.contains('missing') ||
                                _contractorAssignmentStatuses.contains('user_remove'),
                            onTap: () {
                              final group = ['missing', 'user_remove'];
                              final allPresent = group.every(_contractorAssignmentStatuses.contains);
                              setState(() {
                                if (allPresent) {
                                  group.forEach(_contractorAssignmentStatuses.remove);
                                } else {
                                  _contractorAssignmentStatuses.addAll(group);
                                }
                              });
                            },
                            borderRadius: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Выгрузка в банк-клиент
                      _sectionLabel('Выгрузка в банк-клиент'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          CustomFilterChip(
                            label: 'Выгружен',
                            isSelected: _wasLoadedBankClient == true,
                            onTap: () => setState(() {
                              _wasLoadedBankClient = _wasLoadedBankClient == true ? null : true;
                            }),
                            borderRadius: 20,
                          ),
                          CustomFilterChip(
                            label: 'Не выгружен',
                            isSelected: _wasLoadedBankClient == false,
                            onTap: () => setState(() {
                              _wasLoadedBankClient = _wasLoadedBankClient == false ? null : false;
                            }),
                            borderRadius: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
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
              child: const Icon(Icons.close, size: 18, color: AppTheme.textSecondary),
            )
          else
            const Icon(Icons.keyboard_arrow_right, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _searchablePickerControl({
    required List<Map<String, dynamic>> items,
    required String Function(Map<String, dynamic>) labelBuilder,
    required String Function(Map<String, dynamic>) idBuilder,
    required String? selectedId,
    required String placeholder,
    required ValueChanged<String> onSelected,
    required VoidCallback onClear,
  }) {
    final selectedItem = selectedId != null
        ? items.where((i) => idBuilder(i) == selectedId).firstOrNull
        : null;

    return GestureDetector(
      onTap: () async {
        final result = await _showPickerSheet(
          context: context,
          items: items,
          labelBuilder: labelBuilder,
          idBuilder: idBuilder,
          selectedId: selectedId,
        );
        if (result != null) onSelected(result);
      },
      child: _rowControl(
        icon: Icons.search,
        label: selectedItem != null ? labelBuilder(selectedItem) : placeholder,
        hasValue: selectedId != null,
        onClear: onClear,
      ),
    );
  }

  Future<String?> _showPickerSheet({
    required BuildContext context,
    required List<Map<String, dynamic>> items,
    required String Function(Map<String, dynamic>) labelBuilder,
    required String Function(Map<String, dynamic>) idBuilder,
    required String? selectedId,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PickerSheet(
        items: items,
        labelBuilder: labelBuilder,
        idBuilder: idBuilder,
        selectedId: selectedId,
      ),
    );
  }

}

class _PickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic>) labelBuilder;
  final String Function(Map<String, dynamic>) idBuilder;
  final String? selectedId;

  const _PickerSheet({
    required this.items,
    required this.labelBuilder,
    required this.idBuilder,
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
        .where((i) => widget.labelBuilder(i).toLowerCase().contains(_query.toLowerCase()))
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
                    hintText: 'Поиск...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                    return ListTile(
                      title: Text(widget.labelBuilder(item)),
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
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 12),
          Text('Загрузка...', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final String message;
  const _ErrorRow(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
    );
  }
}
