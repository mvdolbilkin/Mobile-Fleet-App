import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/data/vehicles_service.dart';
import 'package:mobile/features/fleet/domain/vehicle.dart';
import 'package:mobile/shared/widgets/custom_selector_bottom_sheet.dart';
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
      case VehicleStatus.working:
        return 'Работает';
      case VehicleStatus.service:
        return 'Сервис';
      case VehicleStatus.noDriver:
        return 'Нет водителя';
      case VehicleStatus.preparation:
        return 'Подготовка';
      case VehicleStatus.other:
        return 'Другое';
      case VehicleStatus.notWorking:
        return 'Не работает';
      default:
        return 'Неизвестно';
    }
  }

  Future<void> _showStatusUpdateDialog() async {
    final statusNames = VehicleStatus.values
        .map((s) => _getStatusName(s))
        .toList();

    final selected = await CustomSelectorBottomSheet.show(
      context: context,
      title: 'Изменить статус',
      items: statusNames,
      showSearch: false,
    );

    if (selected == null || !mounted) return;

    final status = VehicleStatus.values.firstWhere(
      (s) => _getStatusName(s) == selected,
    );

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
      content: Text('Обновление статуса ${_selectedVehicles.length} авто...'),
      duration: const Duration(seconds: 30),
    ));

    try {
      final service = ref.read(vehiclesServiceProvider);
      await service.updateVehiclesStatus(_selectedVehicles.toList(), status);
      ref.invalidate(vehiclesProvider);
      if (mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(
          content: Text(
            'Статус "$selected" применён к ${_selectedVehicles.length} авто',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ));
        _toggleSelectionMode();
      }
    } catch (e) {
      if (mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(
          content: Text('Ошибка: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ));
      }
    }
  }

  void _showOsagoConfirmation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, 24 + MediaQuery.of(ctx).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Компенсация ОСАГО',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: const Icon(Icons.close, size: 24, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'После включения опции парк будет компенсировать исполнителю стоимость подневного полиса ОСАГО, который тот купит через Про',
              style: TextStyle(fontSize: 15, color: AppTheme.textPrimary, height: 1.45),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _actionConfirmButton(
                    label: 'Включить',
                    yellow: true,
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _doOsagoAction(true);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionConfirmButton(
                    label: 'Выключить',
                    yellow: false,
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _doOsagoAction(false);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionConfirmButton({
    required String label,
    required bool yellow,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: yellow ? AppTheme.buttonColor : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: yellow ? Colors.black : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _doOsagoAction(bool enable) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
      content: Text(
        '${enable ? "Включение" : "Выключение"} ОСАГО для ${_selectedVehicles.length} авто...',
      ),
      duration: const Duration(seconds: 30),
    ));
    try {
      final service = ref.read(vehiclesServiceProvider);
      await service.updateOsagoCompensation(_selectedVehicles.toList(), enable);
      if (mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(
          content: Text(
            'Компенсация ОСАГО ${enable ? "включена" : "выключена"} для ${_selectedVehicles.length} авто',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ));
        _toggleSelectionMode();
      }
    } catch (e) {
      if (mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(
          content: Text('Ошибка: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ));
      }
    }
  }

  Future<void> _showAddressSelector() async {
    final offices = ref.read(officeAddressesProvider).value ?? [];
    if (offices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Адреса не загружены')),
      );
      return;
    }

    final items = offices
        .map((o) => o['address'] as String? ?? o['office_id'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    await CustomSelectorBottomSheet.show(
      context: context,
      title: 'Выбрать адрес',
      items: items,
      showSearch: items.length > 5,
    );
  }

  Widget _buildFilterPill(String label, VoidCallback onClear) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Preload office addresses while screen is open
    ref.watch(officeAddressesProvider);

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
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: AppTheme.textPrimary,
              ),
            ),
            color: Colors.transparent,
            size: 40,
            borderRadius: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Загружаем категории до автомобилей
          ref.watch(carCategoriesProvider).when(
            data: (_) => const SizedBox.shrink(),
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Поиск, фильтры и кнопка добавления
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    hint: 'Поиск по марке, модели, номеру',
                    controller: _searchController,
                    onChanged: (value) {
                      ref
                          .read(vehiclesFilterProvider.notifier)
                          .updateSearch(value);
                    },
                    suffixIcon: GestureDetector(
                      onTap: () {
                        FiltersBottomSheet.show(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.tune,
                          size: 22,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
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
          const SizedBox(height: 8),
          
          // Активные фильтры
          if (_buildActiveFilterChips().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _buildActiveFilterChips(),
                  ),
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
                    ref
                        .read(vehiclesFilterProvider.notifier)
                        .updateFilter(const VehicleFilter());
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
          const SizedBox(height: 4),

          // Список автомобилей
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                    color: AppTheme.primaryColor,
                    onRefresh: () async {
                      ref.invalidate(vehiclesProvider);
                      await ref.read(vehiclesProvider.future);
                    },
                    child: ref
                    .watch(vehiclesProvider)
                    .when(
                      data: (vehicles) {
                        if (vehicles.isEmpty) {
                          return ListView(
                            padding: const EdgeInsets.all(16),
                            children: const [
                              Center(child: Text('Ничего не найдено')),
                            ],
                          );
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
                              isSelected: _selectedVehicles.contains(
                                vehicle.id,
                              ),
                              onSelect: (val) =>
                                  _onVehicleSelect(vehicle.id, val),
                              onLongPress: () {
                                if (!_isSelectionMode) _toggleSelectionMode();
                                _onVehicleSelect(vehicle.id, true);
                              },
                              onTap: () {
                                if (_isSelectionMode) {
                                  _onVehicleSelect(
                                    vehicle.id,
                                    !_selectedVehicles.contains(vehicle.id),
                                  );
                                  return;
                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VehicleInfoScreen(vehicle: vehicle),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) =>
                          Center(child: Text('Ошибка: $err')),
                    ),
                ),

                // Всплывающая панель при выделении
                if (_isSelectionMode)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        16, 14, 16, 14 + MediaQuery.of(context).padding.bottom,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 16,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedVehicles.length} авто выбрано',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _selectionChipButton(
                                    label: 'Статус',
                                    enabled: _selectedVehicles.isNotEmpty,
                                    onTap: _selectedVehicles.isEmpty ? null : _showStatusUpdateDialog,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _selectionChipButton(
                                    label: 'Компенсация ОСАГО',
                                    enabled: _selectedVehicles.isNotEmpty,
                                    onTap: _selectedVehicles.isEmpty ? null : _showOsagoConfirmation,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _selectionChipButton(
                                    label: 'Адрес',
                                    enabled: _selectedVehicles.isNotEmpty,
                                    onTap: _selectedVehicles.isEmpty ? null : _showAddressSelector,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _selectionChipButton({
    required String label,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF2F2F2) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled ? const Color(0xFFDDDDDD) : const Color(0xFFEEEEEE),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  List<Widget> _buildActiveFilterChips() {
    final filter = ref.watch(vehiclesFilterProvider);
    final categoryNames = ref.watch(carCategoriesProvider).value ?? {};
    final chips = <Widget>[];

    void add(String label, VoidCallback onClear) {
      chips.add(_buildFilterPill(label, onClear));
      chips.add(const SizedBox(width: 8));
    }

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      add('"${filter.searchQuery}"', () {
        _searchController.clear();
        ref.read(vehiclesFilterProvider.notifier).updateSearch('');
      });
    }
    if (filter.types != null && filter.types!.isNotEmpty) {
      add('Тип ТС: ${filter.types!.length}',
          () => ref.read(vehiclesFilterProvider.notifier).updateFilter(filter.copyWith(types: [])));
    }
    if (filter.owners != null && filter.owners!.isNotEmpty) {
      add('Владелец: ${filter.owners!.length}',
          () => ref.read(vehiclesFilterProvider.notifier).updateFilter(filter.copyWith(owners: [])));
    }
    if (filter.usageRights != null && filter.usageRights!.isNotEmpty) {
      add('Право: ${filter.usageRights!.length}',
          () => ref.read(vehiclesFilterProvider.notifier).updateFilter(filter.copyWith(usageRights: [])));
    }
    if (filter.statuses != null && filter.statuses!.isNotEmpty) {
      add('Статус: ${filter.statuses!.length}',
          () => ref.read(vehiclesFilterProvider.notifier).updateFilter(filter.copyWith(statuses: [])));
    }
    if (filter.categories != null && filter.categories!.isNotEmpty) {
      final names = filter.categories!.map((c) => categoryNames[c.id] ?? c.name).join(', ');
      add(names,
          () => ref.read(vehiclesFilterProvider.notifier).updateFilter(filter.copyWith(categories: [])));
    }
    if (filter.branding != null) {
      add(filter.branding == VehicleBrandingFilter.confirmed ? 'Брендинг подтверждён' : 'Без брендинга',
          () => ref.read(vehiclesFilterProvider.notifier).updateFilter(filter.copyWith(clearBranding: true)));
    }
    if (filter.osago != null) {
      add(filter.osago == VehicleOsagoFilter.restricted ? 'Ограничить без ОСАГО' : 'Без ограничений (ОСАГО)',
          () => ref.read(vehiclesFilterProvider.notifier).updateFilter(filter.copyWith(clearOsago: true)));
    }
    if (filter.osagoCompensation != null) {
      add(filter.osagoCompensation == VehicleOsagoCompensationFilter.compensate ? 'Компенсировать ОСАГО' : 'Без компенсаций',
          () => ref.read(vehiclesFilterProvider.notifier).updateFilter(filter.copyWith(clearOsagoCompensation: true)));
    }
    if (filter.otherParks != null) {
      add(filter.otherParks == VehicleOtherParksFilter.restricted ? 'Ограничить другие парки' : 'Без ограничений (парки)',
          () => ref.read(vehiclesFilterProvider.notifier).updateFilter(filter.copyWith(clearOtherParks: true)));
    }
    if (filter.archived == true) {
      add('Архив',
          () => ref.read(vehiclesFilterProvider.notifier).updateFilter(filter.copyWith(clearArchived: true)));
    }

    return chips;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
