import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/tariff_utils.dart';
import '../providers/vehicles_provider.dart';
import '../../../../../shared/widgets/custom_switch.dart';
import '../../../../../shared/widgets/fading_button.dart';
import '../../../../../app/theme.dart';

class TariffEditBottomSheet extends ConsumerStatefulWidget {
  final List<String>? currentTariffs;
  final Function(List<String>) onSave;

  const TariffEditBottomSheet({
    super.key,
    this.currentTariffs,
    required this.onSave,
  });

  @override
  ConsumerState<TariffEditBottomSheet> createState() => _TariffEditBottomSheetState();
}

class _TariffEditBottomSheetState extends ConsumerState<TariffEditBottomSheet> {
  late Map<String, bool> _tariffStates;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Инициализируем состояния тарифов
    _tariffStates = {};
    for (var key in TariffUtils.tariffNames.keys) {
      _tariffStates[key] = widget.currentTariffs?.contains(key) ?? false;
    }
  }

  Future<void> _handleSave() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedTariffs = _tariffStates.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      
      await widget.onSave(selectedTariffs);
      
      // Если успешно - закрываем sheet
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Если ошибка - оставляем sheet открытым
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getVehicleType() {
    // Определяем тип ТС по наличию тарифа 'cargo'
    final hasCargo = widget.currentTariffs?.contains('cargo') ?? false;
    return hasCargo ? 'Грузовой автомобиль' : 'Легковой автомобиль';
  }

  Map<String, String> _getAvailableTariffs() {
    final categoryNamesMap = ref.watch(carCategoriesProvider).value ?? {};
    final isTruckVehicle = _getVehicleType() == 'Грузовой автомобиль';

    String displayName(String key) => categoryNamesMap[key] ?? TariffUtils.tariffNames[key] ?? key;
    
    if (isTruckVehicle) {
      // Для грузовых автомобилей доступны только cargo и express
      return {
        'cargo': displayName('cargo'),
        'express': displayName('express'),
      };
    }
    
    // Для легковых автомобилей все тарифы кроме cargo
    return Map.fromEntries(
      TariffUtils.tariffNames.entries
          .where((entry) => entry.key != 'cargo')
          .map((entry) => MapEntry(entry.key, displayName(entry.key))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовок
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Редактировать тарифы',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer to center the title
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Тип ТС: ${_getVehicleType()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Список тарифов
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _getAvailableTariffs().length,
              itemBuilder: (context, index) {
                final tariffs = _getAvailableTariffs();
                final key = tariffs.keys.elementAt(index);
                final name = tariffs[key]!;
                return _buildTariffItem(key, name);
              },
            ),
          ),
          // Кнопка сохранить
          _buildSaveButton(context),
        ],
      ),
    );
  }

  Widget _buildTariffItem(String key, String name) {
    final iconPath = TariffUtils.tariffIcons[key] ?? 'assets/images/TariffEditSheet/fallback-9U2fbpSe.png';
    
    // Проверяем, является ли это тариф 'cargo' для грузового автомобиля
    final isCargoTariff = key == 'cargo';
    final isTruckVehicle = _getVehicleType() == 'Грузовой автомобиль';
    final isDisabled = isCargoTariff && isTruckVehicle;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 1, 16, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                iconPath,
                width: 56,
                height: 56,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.local_taxi, size: 38),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'YSText-Regular',
                    color: isDisabled ? Colors.grey[600] : Colors.black,
                  ),
                ),
              ),
              Opacity(
                opacity: isDisabled ? 0.5 : 1.0,
                child: CustomSwitch(
                  value: _tariffStates[key] ?? false,
                  onChanged: isDisabled
                      ? (_) {} // Пустая функция для disabled состояния
                      : (value) {
                          setState(() {
                            _tariffStates[key] = value;
                          });
                        },
                ),
              ),
            ],
          ),
          if (isDisabled)
            Padding(
              padding: const EdgeInsets.only(left: 68, top: 4, bottom: 8),
              child: Text(
                'Всегда включён для грузового автомобиля',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'YSText-Regular',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: FadingButton(
        onTap: _isLoading ? null : _handleSave,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _isLoading ? AppTheme.buttonColor.withOpacity(0.6) : AppTheme.buttonColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 20,
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text(
                      'Сохранить',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
