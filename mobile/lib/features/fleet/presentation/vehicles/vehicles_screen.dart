import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/data/vehicles_service.dart';
import 'package:mobile/features/fleet/domain/vehicle.dart';
import 'package:mobile/shared/widgets/fading_button.dart';
import 'package:mobile/shared/widgets/filter_chip.dart';
import 'package:mobile/shared/widgets/search_field.dart';
import 'package:mobile/shared/widgets/animated_icon_button.dart';
import '../../../../app/theme.dart';
import 'widgets/vehicle_list_item.dart';
import 'widgets/add_vehicle_bottom_sheet.dart';
import 'widgets/filters_bottom_sheet.dart';
import 'vehicle_info_screen.dart';
import 'providers/vehicles_provider.dart';

class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isCheckboxSelected = false;
  bool _isOwnerFilterSelected = true;
  bool _isTypeFilterSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Автомобили', style: AppTheme.appBarTitle),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedIconButton(
            onTap: () => Navigator.of(context).pop(),
            icon: const Padding(
              padding: EdgeInsets.only(left: 6.0),
              child: Icon(Icons.arrow_back_ios, size: 20, color: AppTheme.textPrimary),
            ),
            color: Colors.transparent,
            size: 40,
            borderRadius: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Поиск и кнопка добавления
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    hint: 'Поиск по марке, модели, номеру',
                    controller: _searchController,
                    onChanged: (value) {
                      ref.read(vehiclesFilterProvider.notifier).updateSearch(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedIconButton(
                  onTap: () {
                    AddVehicleBottomSheet.show(context);
                  },
                  icon: const Icon(Icons.add, size: 28, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Фильтры
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Кнопка фильтров
                GestureDetector(
                  onTap: () {
                    FiltersBottomSheet.show(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.controlsColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.tune,
                        size: 20,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Активные фильтры (Отображение)
                ..._buildActiveFilterChips(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Кнопка "Сбросить все фильтры"
          if (!ref.watch(vehiclesFilterProvider).isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FadingButton(
                  onTap: () {
                    ref.read(vehiclesFilterProvider.notifier).updateFilter(const VehicleFilter());
                    _searchController.clear();
                  },
                  child: Text(
                    'Сбросить все фильтры',
                    style: AppTheme.captionSecondary.copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          
          // Список автомобилей
          Expanded(
            child: ref.watch(vehiclesProvider).when(
              data: (vehicles) {
                if (vehicles.isEmpty) {
                  return const Center(child: Text('Ничего не найдено'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    return VehicleListItem(
                      vehicle: vehicles[index],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VehicleInfoScreen(
                              vehicle: vehicles[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Ошибка: $err')),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActiveFilterChips() {
    final filter = ref.watch(vehiclesFilterProvider);
    final chips = <Widget>[];

    if (filter.types != null && filter.types!.isNotEmpty) {
      chips.add(CustomFilterChip(
        label: 'Тип ТС: ${filter.types!.length}',
        isSelected: true,
        onTap: () {
          ref.read(vehiclesFilterProvider.notifier).updateFilter(filter.copyWith(types: []));
        },
      ));
      chips.add(const SizedBox(width: 8));
    }
    
    if (filter.owners != null && filter.owners!.isNotEmpty) {
      chips.add(CustomFilterChip(
        label: 'Владелец: ${filter.owners!.length}',
        isSelected: true,
        onTap: () {
          ref.read(vehiclesFilterProvider.notifier).updateFilter(filter.copyWith(owners: []));
        },
      ));
      chips.add(const SizedBox(width: 8));
    }

    if (filter.statuses != null && filter.statuses!.isNotEmpty) {
      chips.add(CustomFilterChip(
        label: 'Статус: ${filter.statuses!.length}',
        isSelected: true,
        onTap: () {
          ref.read(vehiclesFilterProvider.notifier).updateFilter(filter.copyWith(statuses: []));
        },
      ));
      chips.add(const SizedBox(width: 8));
    }

    return chips;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
