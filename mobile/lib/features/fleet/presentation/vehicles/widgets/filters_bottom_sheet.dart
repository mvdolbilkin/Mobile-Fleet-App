import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/domain/vehicle.dart';
import 'package:mobile/features/fleet/data/vehicles_service.dart';
import 'package:mobile/shared/widgets/filter_chip.dart';
import '../providers/vehicles_provider.dart';

class FiltersBottomSheet extends ConsumerStatefulWidget {
  const FiltersBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FiltersBottomSheet(),
    );
  }

  @override
  ConsumerState<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends ConsumerState<FiltersBottomSheet> {
  late VehicleFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(vehiclesFilterProvider);
  }

  void _applyFilters() {
    ref.read(vehiclesFilterProvider.notifier).updateFilter(_filter);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _filter = VehicleFilter(
        searchQuery: _filter.searchQuery,
      ); // Сохраняем только поиск
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Фильтры',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text(
                        'Сбросить',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildFilterSection<VehicleType>(
                      title: 'Тип ТС',
                      items: VehicleType.values,
                      selectedItems: _filter.types ?? [],
                      onChanged: (values) => setState(
                        () => _filter = _filter.copyWith(types: values),
                      ),
                      labelBuilder: (type) {
                        switch (type) {
                          case VehicleType.automobile:
                            return 'Автомобиль';
                          case VehicleType.motorcycle:
                            return 'Мотоцикл';
                          case VehicleType.rickshaw:
                            return 'Рикша';
                        }
                      },
                    ),
                    _buildFilterSection<VehicleOwner>(
                      title: 'Владелец',
                      items: VehicleOwner.values,
                      selectedItems: _filter.owners ?? [],
                      onChanged: (values) => setState(
                        () => _filter = _filter.copyWith(owners: values),
                      ),
                      labelBuilder: (owner) {
                        switch (owner) {
                          case VehicleOwner.taxiPark:
                            return 'Таксопарк';
                          case VehicleOwner.other:
                            return 'Другое';
                          case VehicleOwner.notSpecified:
                            return 'Не указан';
                        }
                      },
                    ),
                    _buildFilterSection<VehicleUsageRight>(
                      title: 'Право использования',
                      items: VehicleUsageRight.values,
                      selectedItems: _filter.usageRights ?? [],
                      onChanged: (values) => setState(
                        () => _filter = _filter.copyWith(usageRights: values),
                      ),
                      labelBuilder: (right) {
                        switch (right) {
                          case VehicleUsageRight.confirmed:
                            return 'Подтвержден';
                          case VehicleUsageRight.notConfirmed:
                            return 'Не подтвержден';
                        }
                      },
                    ),
                    _buildFilterSection<VehicleStatus>(
                      title: 'Статусы',
                      items: VehicleStatus.values,
                      selectedItems: _filter.statuses ?? [],
                      onChanged: (values) => setState(
                        () => _filter = _filter.copyWith(statuses: values),
                      ),
                      labelBuilder: (status) {
                        switch (status) {
                          case VehicleStatus.working:
                            return 'Работает';
                          case VehicleStatus.noDriver:
                            return 'Нет водителя';
                          case VehicleStatus.service:
                            return 'Сервис';
                          case VehicleStatus.preparation:
                            return 'Подготовка';
                          case VehicleStatus.notWorking:
                            return 'Не работает';
                          case VehicleStatus.other:
                            return 'Другое';
                        }
                      },
                    ),
                    _buildCategoriesSection(),
                    _buildRadioSection<VehicleBrandingFilter>(
                      title: 'Брендинг',
                      items: VehicleBrandingFilter.values,
                      selected: _filter.branding,
                      onChanged: (v) => setState(() => _filter = _filter.copyWith(branding: v, clearBranding: v == null)),
                      labelBuilder: (v) {
                        switch (v) {
                          case VehicleBrandingFilter.confirmed: return 'Брендинг подтверждён';
                          case VehicleBrandingFilter.none: return 'Без брендинга';
                        }
                      },
                    ),
                    _buildRadioSection<VehicleOsagoFilter>(
                      title: 'Запрет на поездки без ОСАГО',
                      items: VehicleOsagoFilter.values,
                      selected: _filter.osago,
                      onChanged: (v) => setState(() => _filter = _filter.copyWith(osago: v, clearOsago: v == null)),
                      labelBuilder: (v) {
                        switch (v) {
                          case VehicleOsagoFilter.restricted: return 'Ограничить поездки без ОСАГО';
                          case VehicleOsagoFilter.none: return 'Без ограничений';
                        }
                      },
                    ),
                    _buildRadioSection<VehicleOsagoCompensationFilter>(
                      title: 'Компенсация ОСАГО исполнителю',
                      items: VehicleOsagoCompensationFilter.values,
                      selected: _filter.osagoCompensation,
                      onChanged: (v) => setState(() => _filter = _filter.copyWith(osagoCompensation: v, clearOsagoCompensation: v == null)),
                      labelBuilder: (v) {
                        switch (v) {
                          case VehicleOsagoCompensationFilter.compensate: return 'Компенсировать подневное ОСАГО исполнителю';
                          case VehicleOsagoCompensationFilter.none: return 'Без компенсаций';
                        }
                      },
                    ),
                    _buildRadioSection<VehicleOtherParksFilter>(
                      title: 'Запрет на поездки в других парках',
                      items: VehicleOtherParksFilter.values,
                      selected: _filter.otherParks,
                      onChanged: (v) => setState(() => _filter = _filter.copyWith(otherParks: v, clearOtherParks: v == null)),
                      labelBuilder: (v) {
                        switch (v) {
                          case VehicleOtherParksFilter.restricted: return 'Ограничить поездки в других парках';
                          case VehicleOtherParksFilter.none: return 'Без ограничений';
                        }
                      },
                    ),
                    _buildArchiveSection(),
                  ],
                ),
              ),
              // Footer
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16, 12, 16, 12 + MediaQuery.of(context).padding.bottom,
                ),
                child: GestureDetector(
                  onTap: _applyFilters,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.buttonColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Применить',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categoriesAsync = ref.watch(carCategoriesProvider);
    final selectedCategories = _filter.categories ?? [];

    return categoriesAsync.when(
      data: (categoryNames) {
        final items = categoryNames.entries
            .map((e) => MapEntry(e.key, VehicleCategory.fromId(e.key)))
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Категории',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((entry) {
                final cat = entry.value;
                final isSelected = selectedCategories.contains(cat);
                return CustomFilterChip(
                  label: categoryNames[entry.key] ?? entry.key,
                  isSelected: isSelected,
                  onTap: () {
                    final newSelected = List<VehicleCategory>.from(
                      selectedCategories,
                    );
                    if (isSelected) {
                      newSelected.remove(cat);
                    } else {
                      newSelected.add(cat);
                    }
                    setState(
                      () => _filter = _filter.copyWith(categories: newSelected),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
      loading: () => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Категории',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Center(child: CircularProgressIndicator()),
          SizedBox(height: 24),
        ],
      ),
      error: (_, __) => _buildFilterSection<VehicleCategory>(
        title: 'Категории',
        items: VehicleCategory.values,
        selectedItems: selectedCategories,
        onChanged: (values) => setState(() => _filter = _filter.copyWith(categories: values)),
        labelBuilder: (cat) => cat.id,
      ),
    );
  }

  Widget _buildFilterSection<T>({
    required String title,
    required List<T> items,
    required List<T> selectedItems,
    required void Function(List<T>) onChanged,
    required String Function(T) labelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return CustomFilterChip(
              label: labelBuilder(item),
              isSelected: isSelected,
              onTap: () {
                final newSelected = List<T>.from(selectedItems);
                if (isSelected) {
                  newSelected.remove(item);
                } else {
                  newSelected.add(item);
                }
                onChanged(newSelected);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRadioSection<T>({
    required String title,
    required List<T> items,
    required T? selected,
    required void Function(T?) onChanged,
    required String Function(T) labelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selected == item;
            return CustomFilterChip(
              label: labelBuilder(item),
              isSelected: isSelected,
              onTap: () => onChanged(isSelected ? null : item),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildArchiveSection() {
    final isSelected = _filter.archived == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Прочее', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        CustomFilterChip(
          label: 'Архив',
          isSelected: isSelected,
          onTap: () => setState(() => _filter = _filter.copyWith(
            archived: isSelected ? null : true,
            clearArchived: isSelected,
          )),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
