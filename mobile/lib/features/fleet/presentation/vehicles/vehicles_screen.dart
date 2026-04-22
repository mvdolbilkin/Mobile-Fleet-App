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
  bool _isSelectionMode = false;
  final Set<String> _selectedVehicles = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedVehicles.clear();
      }
    });
  }

  void _onVehicleSelect(String id, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedVehicles.add(id);
      } else {
        _selectedVehicles.remove(id);
      }
    });
  }

  String _getStatusName(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.working: return 'Работает';
      case VehicleStatus.service: return 'Сервис';
      case VehicleStatus.noDriver: return 'Нет водителя';
      case VehicleStatus.preparation: return 'Подготовка';
      case VehicleStatus.other: return 'Другое';
      case VehicleStatus.notWorking: return 'Не работает';
      default: return 'Неизвестно';
    }
  }

  void _showStatusUpdateDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Изменить статус',
                  style: AppTheme.listTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ...VehicleStatus.values.map((status) => ListTile(
                      title: Text(_getStatusName(status)),
                      onTap: () async {
                        Navigator.pop(context);
                        
                        // Сохраняем ScaffoldMessenger до async операции
                        final messenger = ScaffoldMessenger.of(context);
                        
                        // Показываем индикатор загрузки
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Обновление статуса ${_selectedVehicles.length} автомобилей...'),
                            duration: const Duration(seconds: 30),
                          ),
                        );
                        
                        try {
                          final service = ref.read(vehiclesServiceProvider);
                          await service.updateVehiclesStatus(
                            _selectedVehicles.toList(),
                            status,
                          );
                          
                          // Обновляем список автомобилей
                          ref.invalidate(vehiclesProvider);
                          
                          if (mounted) {
                            messenger.hideCurrentSnackBar();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Статус "${_getStatusName(status)}" применен к ${_selectedVehicles.length} автомобилям'),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            _toggleSelectionMode();
                          }
                        } catch (e) {
                          if (mounted) {
                            messenger.hideCurrentSnackBar();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Ошибка: ${e.toString().replaceAll('Exception: ', '')}'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Автомобили', style: AppTheme.appBarTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _toggleSelectionMode,
              child: Text(
                _isSelectionMode ? 'Отмена' : 'Выбрать',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
                      child: const Center(
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
            child: Stack(
              children: [
                ref.watch(vehiclesProvider).when(
                  data: (vehicles) {
                    if (vehicles.isEmpty) {
                      return const Center(child: Text('Ничего не найдено'));
                    }
                    return ListView.builder(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 0,
                        bottom: _isSelectionMode ? 140 : 16,
                      ),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return VehicleListItem(
                          vehicle: vehicle,
                          isSelectionMode: _isSelectionMode,
                          isSelected: _selectedVehicles.contains(vehicle.id),
                          onSelect: (val) => _onVehicleSelect(vehicle.id, val),
                          onTap: () {
                            if (_isSelectionMode) {
                              _onVehicleSelect(vehicle.id, !_selectedVehicles.contains(vehicle.id));
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VehicleInfoScreen(
                                  vehicle: vehicle,
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
                
                // Всплывающая панель при выделении
                if (_isSelectionMode)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_selectedVehicles.length} выбранных автомобиля',
                            style: AppTheme.listTitle,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Некоторые действия недоступны, так как они применимы только для парковых автомобилей',
                            style: AppTheme.captionSecondary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                  ),
                                  onPressed: _selectedVehicles.isEmpty ? null : _showStatusUpdateDialog,
                                  child: const Text('Статус'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.controlsColor,
                                    foregroundColor: AppTheme.textPrimary,
                                    elevation: 0,
                                  ),
                                  onPressed: _selectedVehicles.isEmpty ? null : () {},
                                  child: const Text('Адрес'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.controlsColor,
                                    foregroundColor: AppTheme.textPrimary,
                                    elevation: 0,
                                  ),
                                  onPressed: _selectedVehicles.isEmpty ? null : () {},
                                  child: const Text('Условия аренды'),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
              ],
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
