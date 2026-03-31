import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/domain/vehicle.dart';
import 'package:mobile/features/fleet/data/vehicles_service.dart';
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
      _filter = VehicleFilter(searchQuery: _filter.searchQuery); // Сохраняем только поиск
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
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
                    const Text('Фильтры', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Сбросить', style: TextStyle(color: Colors.red)),
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
                      onChanged: (values) => setState(() => _filter = _filter.copyWith(types: values)),
                      labelBuilder: (type) {
                        switch (type) {
                          case VehicleType.automobile: return 'Автомобиль';
                          case VehicleType.motorcycle: return 'Мотоцикл';
                          case VehicleType.rickshaw: return 'Рикша';
                        }
                      },
                    ),
                    _buildFilterSection<VehicleOwner>(
                      title: 'Владелец',
                      items: VehicleOwner.values,
                      selectedItems: _filter.owners ?? [],
                      onChanged: (values) => setState(() => _filter = _filter.copyWith(owners: values)),
                      labelBuilder: (owner) {
                        switch (owner) {
                          case VehicleOwner.taxiPark: return 'Таксопарк';
                          case VehicleOwner.other: return 'Другое';
                          case VehicleOwner.notSpecified: return 'Не указан';
                        }
                      },
                    ),
                    _buildFilterSection<VehicleUsageRight>(
                      title: 'Право использования',
                      items: VehicleUsageRight.values,
                      selectedItems: _filter.usageRights ?? [],
                      onChanged: (values) => setState(() => _filter = _filter.copyWith(usageRights: values)),
                      labelBuilder: (right) {
                        switch (right) {
                          case VehicleUsageRight.confirmed: return 'Подтвержден';
                          case VehicleUsageRight.notConfirmed: return 'Не подтвержден';
                        }
                      },
                    ),
                    _buildFilterSection<VehicleStatus>(
                      title: 'Статусы',
                      items: VehicleStatus.values,
                      selectedItems: _filter.statuses ?? [],
                      onChanged: (values) => setState(() => _filter = _filter.copyWith(statuses: values)),
                      labelBuilder: (status) {
                        switch (status) {
                          case VehicleStatus.working: return 'Работает';
                          case VehicleStatus.noDriver: return 'Нет водителя';
                          case VehicleStatus.service: return 'Сервис';
                          case VehicleStatus.preparation: return 'Подготовка';
                          case VehicleStatus.notWorking: return 'Не работает';
                          case VehicleStatus.other: return 'Другое';
                        }
                      },
                    ),
                    _buildFilterSection<VehicleCategory>(
                      title: 'Категории',
                      items: VehicleCategory.values,
                      selectedItems: _filter.categories ?? [],
                      onChanged: (values) => setState(() => _filter = _filter.copyWith(categories: values)),
                      labelBuilder: (cat) {
                        switch (cat) {
                          case VehicleCategory.econom: return 'Эконом';
                          case VehicleCategory.comfort: return 'Комфорт';
                          case VehicleCategory.comfortPlus: return 'Комфорт+';
                          case VehicleCategory.business: return 'Бизнес';
                          case VehicleCategory.minivan: return 'Минивен';
                          case VehicleCategory.vip: return 'VIP';
                          case VehicleCategory.wagon: return 'Универсальный';
                          case VehicleCategory.pool: return 'Pool';
                          case VehicleCategory.start: return 'Старт';
                          case VehicleCategory.standart: return 'Стандарт';
                          case VehicleCategory.ultimate: return 'Премьер';
                          case VehicleCategory.maybach: return 'Elite';
                          case VehicleCategory.promo: return 'Промо';
                          case VehicleCategory.premiumVan: return 'Круиз';
                          case VehicleCategory.premiumSuv: return 'Премиум Внедорожник';
                          case VehicleCategory.suv: return 'Внедорожник';
                          case VehicleCategory.personalDriver: return 'Персональный Водитель';
                          case VehicleCategory.express: return 'Доставка';
                          case VehicleCategory.cargo: return 'Грузовой';
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Применить', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
            ],
          );
        },
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
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(labelBuilder(item)),
              selected: isSelected,
              onSelected: (selected) {
                final newSelected = List<T>.from(selectedItems);
                if (selected) {
                  newSelected.add(item);
                } else {
                  newSelected.remove(item);
                }
                onChanged(newSelected);
              },
              backgroundColor: AppTheme.controlsColor,
              selectedColor: Colors.black12,
              checkmarkColor: Colors.black,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
