import 'package:flutter/material.dart';
import 'package:mobile/features/fleet/domain/vehicle.dart';
import 'package:mobile/shared/widgets/filter_chip.dart';
import 'package:mobile/shared/widgets/search_field.dart';
import 'package:mobile/shared/widgets/animated_icon_button.dart';
import '../../../../app/theme.dart';
import '../../data/mock_vehicles.dart';
import 'widgets/vehicle_list_item.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isCheckboxSelected = false;
  bool _isOwnerFilterSelected = true;
  bool _isTypeFilterSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Автомобили'),
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
                      // Логика поиска
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedIconButton(
                  onTap: () {
                    // Логика добавления автомобиля
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
                // Чекбокс фильтр
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCheckboxSelected = !_isCheckboxSelected;
                    });
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
                        _isCheckboxSelected ? Icons.check : Icons.check_box_outline_blank,
                        size: 20,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Кнопка фильтров
                GestureDetector(
                  onTap: () {
                    // Открыть расширенные фильтры
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
                
                // Фильтр "Владелец: Таксопарк"
                CustomFilterChip(
                  label: 'Владелец: Таксопарк',
                  isSelected: _isOwnerFilterSelected,
                  hasNotification: true,
                  onTap: () {
                    setState(() {
                      _isOwnerFilterSelected = !_isOwnerFilterSelected;
                    });
                  },
                ),
                const SizedBox(width: 8),
                
                // Фильтр "Тип ТС: Автомобиль"
                CustomFilterChip(
                  label: 'Тип ТС: Автомобиль',
                  isSelected: _isTypeFilterSelected,
                  onTap: () {
                    setState(() {
                      _isTypeFilterSelected = !_isTypeFilterSelected;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Кнопка "Сбросить все фильтры"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isCheckboxSelected = false;
                    _isOwnerFilterSelected = false;
                    _isTypeFilterSelected = false;
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Сбросить все фильтры',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: mockVehicles.length,
              itemBuilder: (context, index) {
                return VehicleListItem(
                  vehicle: mockVehicles[index],
                  onTap: () {
                    // Навигация на детальную страницу
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
