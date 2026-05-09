import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/map/data/map_repository.dart';
import 'package:mobile/features/map/domain/map_driver.dart';
import 'package:mobile/shared/widgets/filter_chip.dart';
import 'package:mobile/features/fleet/providers/rents_filters_provider.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

// Некеширующий (autoDispose) carCategoriesProvider оборачиваем в постоянный,
// чтобы данные не сбрасывались при каждом открытии листа.
final _persistentCarCategoriesProvider =
    FutureProvider<List<CarCategory>>((ref) {
  return ref.watch(carCategoriesProvider.future);
});

const _yellow = Color(0xFFFCE000);
const _yellowBorder = Color(0xFFC4A700);


const _sortOptions = [
  _SortOption('status_duration', 'desc', 'По времени в статусе'),
  _SortOption('full_name', 'asc', 'По фамилии'),
  _SortOption('balance', 'asc', 'Баланс (по возрастанию)'),
  _SortOption('balance', 'desc', 'Баланс (по убыванию)'),
];

class _SortOption {
  final String field;
  final String direction;
  final String label;
  const _SortOption(this.field, this.direction, this.label);
}

// Main widget

class MapFilterSheet extends ConsumerStatefulWidget {
  const MapFilterSheet({super.key});

  @override
  ConsumerState<MapFilterSheet> createState() => _MapFilterSheetState();
}

class _MapFilterSheetState extends ConsumerState<MapFilterSheet> {
  late MapFilterState _local;
  String _rulesSearch = '';

  @override
  void initState() {
    super.initState();
    _local = ref.read(mapFilterProvider);
  }

  bool get _isSortSelected {
    return _local.sortField == 'status_duration' &&
        _local.sortDirection == 'desc';
  }

  bool _isSortOption(_SortOption opt) =>
      _local.sortField == opt.field && _local.sortDirection == opt.direction;

  void _toggleList(List<String> list, String value) {
    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workRulesAsync = ref.watch(workRulesProvider);
    final carCategoriesAsync = ref.watch(_persistentCarCategoriesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.controlsColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Фильтры',
                      style: TextStyle(
                        fontFamily: 'Yandex Sans Text',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() => _local = const MapFilterState()),
                      child: const Text(
                        'Сбросить',
                        style: TextStyle(
                          fontFamily: 'Yandex Sans Text',
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  children: [
                    _sectionTitle('Сортировка'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: _sortOptions.map((opt) {
                          final selected = _isSortOption(opt);
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _local = _local.copyWith(
                                  sortField: opt.field,
                                  sortDirection: opt.direction,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      opt.label,
                                      style: TextStyle(
                                        fontFamily: 'Yandex Sans Text',
                                        fontSize: 15,
                                        color: AppTheme.textPrimary,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        color: _yellow,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check,
                                          size: 13, color: Colors.black),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment method
                    _sectionTitle('Способ оплаты'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        CustomFilterChip(
                          label: 'Наличные',
                          isSelected: _local.paymentMethods.contains('cash'),
                          onTap: () {
                            final list = [..._local.paymentMethods];
                            _toggleList(list, 'cash');
                            setState(() =>
                                _local = _local.copyWith(paymentMethods: list));
                          },
                        ),
                        CustomFilterChip(
                          label: 'Банковская карта',
                          isSelected: _local.paymentMethods.contains('card'),
                          onTap: () {
                            final list = [..._local.paymentMethods];
                            _toggleList(list, 'card');
                            setState(() =>
                                _local = _local.copyWith(paymentMethods: list));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Car type
                    _sectionTitle('Тип машины'),
                    const SizedBox(height: 8),
                    carCategoriesAsync.when(
                      data: (cats) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: cats.map((c) {
                          return CustomFilterChip(
                            label: c.name,
                            isSelected: _local.carCategories.contains(c.id),
                            onTap: () {
                              final list = [..._local.carCategories];
                              _toggleList(list, c.id);
                              setState(() =>
                                  _local = _local.copyWith(carCategories: list));
                            },
                          );
                        }).toList(),
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),

                    // Work rules
                    _sectionTitle('Условия работы'),
                    const SizedBox(height: 8),
                    workRulesAsync.when(
                      data: (rules) => _buildWorkRulesList(rules),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Не удалось загрузить условия работы',
                    style: TextStyle(
                        fontFamily: 'Yandex Sans Text',
                        color: AppTheme.textSecondary),
                  ),
                ),
              ),
                  ],
                ),
              ),
              // Apply button
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
                child: FadingButton(
                  onTap: () {
                    ref.read(mapFilterProvider.notifier).update(_local);
                    Navigator.of(context).pop();
                  },
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
                        fontFamily: 'Yandex Sans Text',
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

  Widget _buildWorkRulesList(List<WorkRule> rules) {
    final filtered = _rulesSearch.isEmpty
        ? rules
        : rules
            .where((r) =>
                r.name.toLowerCase().contains(_rulesSearch.toLowerCase()))
            .toList();

    return Column(
      children: [
        // Поиск по условиям работы
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.controlsColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            onChanged: (v) => setState(() => _rulesSearch = v),
            style: const TextStyle(fontFamily: 'Yandex Sans Text', fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Поиск...',
              hintStyle: TextStyle(
                  fontFamily: 'Yandex Sans Text',
                  fontSize: 14,
                  color: AppTheme.textSecondary),
              prefixIcon:
                  Icon(Icons.search, size: 18, color: AppTheme.textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Список (max 5 видимых, остальные через прокрутку)
        Container(
          constraints: const BoxConstraints(maxHeight: 260),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: filtered.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Ничего не найдено',
                    style: TextStyle(
                        fontFamily: 'Yandex Sans Text',
                        color: AppTheme.textSecondary),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFEFEDE9)),
                  itemBuilder: (_, i) {
                    final rule = filtered[i];
                    final selected = _local.workRuleIds.contains(rule.id);
                    return InkWell(
                      onTap: () {
                        final list = [..._local.workRuleIds];
                        _toggleList(list, rule.id);
                        setState(() =>
                            _local = _local.copyWith(workRuleIds: list));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rule.name,
                                    style: TextStyle(
                                      fontFamily: 'Yandex Sans Text',
                                      fontSize: 14,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Комиссия: ${rule.commissionPercent}%',
                                    style: const TextStyle(
                                      fontFamily: 'Yandex Sans Text',
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: _yellow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    size: 13, color: Colors.black),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontFamily: 'Yandex Sans Text',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      );
}

