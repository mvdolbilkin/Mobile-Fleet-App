import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/widgets/fading_button.dart';
import 'package:mobile/shared/widgets/custom_selector_bottom_sheet.dart';
import 'package:mobile/shared/widgets/custom_date_picker_bottom_sheet.dart';
import 'package:mobile/shared/widgets/custom_switch.dart';
import '../providers/add_vehicle_provider.dart';

// Константы для выпадающих списков
class VehicleFormConstants {
  // Годы от текущего до 1970
  static List<String> get years {
    final currentYear = DateTime.now().year;
    return List.generate(
      currentYear - 1969,
      (index) => (currentYear - index).toString(),
    );
  }

  // Типы КПП
  static const List<String> transmissions = [
    'Механическая',
    'Автоматическая',
    'Роботизированная',
    'Вариатор',
  ];

  // Цвета (из API Яндекса)
  static const List<String> colors = [
    'Белый',
    'Желтый',
    'Бежевый',
    'Черный',
    'Голубой',
    'Серый',
    'Красный',
    'Оранжевый',
    'Синий',
    'Зеленый',
    'Коричневый',
    'Фиолетовый',
    'Розовый',
  ];

  // Типы топлива
  static const List<String> fuelTypes = [
    'Бензин',
    'Метан',
    'Пропан',
    'Электричество',
  ];
}

class AddVehicleBottomSheet extends ConsumerStatefulWidget {
  const AddVehicleBottomSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => const AddVehicleBottomSheet(),
    );
  }

  @override
  ConsumerState<AddVehicleBottomSheet> createState() =>
      _AddVehicleBottomSheetState();
}

class _AddVehicleBottomSheetState extends ConsumerState<AddVehicleBottomSheet> {
  // Для больших форм лучше использовать контроллеры, чтобы курсор не сбрасывался при наборе
  // Для простоты реализации свяжем их через initialValue (ниже в _buildTextField).

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(addVehicleFormProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(formData),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: formData.step == 1
                    ? _buildStep1(formData)
                    : _buildStep2(formData),
              ),
            ),
            _buildFooter(formData),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AddVehicleFormData formData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 60,
            child: formData.step == 2
                ? GestureDetector(
                    onTap: () =>
                        ref.read(addVehicleFormProvider.notifier).setStep(1),
                    child: const Icon(Icons.arrow_back_ios, size: 20),
                  )
                : null,
          ),
          const Text('Новое ТС', style: AppTheme.appBarTitle),
          SizedBox(
            width: 60,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Отмена',
                textAlign: TextAlign.right,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(AddVehicleFormData formData) {
    final notifier = ref.read(addVehicleFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTypeCard(
                title: 'Автомобиль',
                icon: Icons.directions_car,
                isSelected: !formData.isTruck,
                onTap: () => notifier.setIsTruck(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeCard(
                title: 'Грузовой автомобиль',
                icon: Icons.local_shipping,
                isSelected: formData.isTruck,
                onTap: () => notifier.setIsTruck(true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Детали',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'СТС',
          initialValue: formData.sts,
          onChanged: (v) => notifier.updateField(sts: v),
          fieldName: 'sts',
        ),
        const SizedBox(height: 8),
        _buildTextField(
          'Гос.номер',
          initialValue: formData.plateNumber,
          onChanged: (v) => notifier.updateField(plateNumber: v),
          fieldName: 'plateNumber',
        ),
        const SizedBox(height: 8),
        _buildBrandDropdown(
          'Марка',
          value: formData.brand,
          onChanged: (v) {
            notifier.updateField(brand: v, model: '');
          },
          fieldName: 'brand',
        ),
        const SizedBox(height: 8),
        _buildModelDropdown(
          'Модель',
          brand: formData.brand,
          value: formData.model,
          onChanged: (v) => notifier.updateField(model: v),
          fieldName: 'model',
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          'Год',
          value: formData.year,
          onChanged: (v) => notifier.updateField(year: v),
          fieldName: 'year',
          items: VehicleFormConstants.years,
        ),
        const SizedBox(height: 8),
        _buildDateField(
          'Дата выдачи СТС',
          value: formData.stsIssueDate,
          onChanged: (v) => notifier.updateField(stsIssueDate: v),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          'VIN',
          initialValue: formData.vin,
          onChanged: (v) => notifier.updateField(vin: v),
          fieldName: 'vin',
        ),
        const SizedBox(height: 8),
        _buildTextField(
          'Номер кузова',
          hintDesc: 'Необязательно',
          initialValue: formData.bodyNumber,
          onChanged: (v) => notifier.updateField(bodyNumber: v),
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          'Цвет',
          value: formData.color,
          onChanged: (v) => notifier.updateField(color: v),
          fieldName: 'color',
          items: VehicleFormConstants.colors,
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          'Вид топлива',
          value: formData.fuelType,
          onChanged: (v) => notifier.updateField(fuelType: v),
          fieldName: 'fuelType',
          items: VehicleFormConstants.fuelTypes,
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          'КПП',
          value: formData.transmission,
          onChanged: (v) => notifier.updateField(transmission: v),
          fieldName: 'transmission',
          items: VehicleFormConstants.transmissions,
        ),
      ],
    );
  }

  Widget _buildStep2(AddVehicleFormData formData) {
    final notifier = ref.read(addVehicleFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (formData.isTruck) ...[
          const Text(
            'Параметры грузового отсека',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            'Длина (в см)',
            initialValue: formData.length,
            onChanged: (v) => notifier.updateField(length: v),
            fieldName: 'length',
          ),
          const SizedBox(height: 8),
          _buildTextField(
            'Высота (в см)',
            initialValue: formData.height,
            onChanged: (v) => notifier.updateField(height: v),
            fieldName: 'height',
          ),
          const SizedBox(height: 8),
          _buildTextField(
            'Ширина (в см)',
            initialValue: formData.width,
            onChanged: (v) => notifier.updateField(width: v),
            fieldName: 'width',
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8, left: 16),
            child: Text(
              'Для каблуков указывается расстояние между колёсными арками',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          _buildTextField(
            'Грузоподъемность (в кг)',
            initialValue: formData.capacity,
            onChanged: (v) => notifier.updateField(capacity: v),
            fieldName: 'capacity',
          ),
          const SizedBox(height: 24),
        ],
        const Text(
          'Владелец',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildSwitchField(
          'Парковый автомобиль',
          formData.isParkVehicle,
          (v) => notifier.setIsParkVehicle(v),
        ),
        const SizedBox(height: 24),
        const Text(
          'Комплектация',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildSwitchField(
          'Есть кондиционер',
          formData.hasAirConditioner,
          (v) => notifier.setHasAirConditioner(v),
        ),
        const SizedBox(height: 24),
        const Text(
          'Дополнительно',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Позывной',
          hintDesc: 'Необязательно                            0/500',
          initialValue: formData.callsign,
          onChanged: (v) => notifier.updateField(callsign: v),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          'Адрес парковки',
          hintDesc: 'Необязательно',
          initialValue: formData.parkingAddress,
          onChanged: (v) => notifier.updateField(parkingAddress: v),
        ),
      ],
    );
  }

  Widget _buildFooter(AddVehicleFormData formData) {
    final notifier = ref.read(addVehicleFormProvider.notifier);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white, // Matching background
      ),
      child: FadingButton(
        onTap: () async {
          if (formData.step == 1) {
            notifier.setStep(2);
          } else {
            // Проверяем валидацию шага 2
            if (!formData.isStep2Valid) {
              // Показываем ошибки валидации
              notifier.showValidationErrors();
              return; // Не отправляем запрос и не закрываем modal
            }

            // Save logic to API
            final error = await notifier.submit();
            if (mounted) {
              // Показываем результат
              if (error == null) {
                // Закрываем sheet только при успехе
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Автомобиль успешно создан'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else {
                // При ошибке не закрываем sheet, показываем ошибку
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            }
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.buttonColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            formData.step == 1 ? 'Далее' : 'Сохранить',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.textPrimary : AppTheme.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppTheme.textPrimary),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    String? hintDesc,
    String? initialValue,
    ValueChanged<String>? onChanged,
    String? fieldName,
  }) {
    final formData = ref.watch(addVehicleFormProvider);
    final errorMessage = fieldName != null
        ? formData.getFieldError(fieldName)
        : null;
    final showError = errorMessage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(16),
            border: showError
                ? Border.all(color: Colors.red, width: 1.5)
                : null,
          ),
          child: TextFormField(
            initialValue: initialValue,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              isDense: true,
              hintStyle: TextStyle(
                color: showError ? Colors.red.shade300 : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
            child: Text(
              errorMessage,
              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            ),
          )
        else if (hintDesc != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
            child: Text(
              hintDesc,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField(
    String hint, {
    String? value,
    ValueChanged<String?>? onChanged,
    String? fieldName,
    List<String>? items,
  }) {
    final formData = ref.watch(addVehicleFormProvider);
    final showError =
        formData.showValidationErrors &&
        fieldName != null &&
        !formData.isFieldValid(fieldName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: items != null && items.isNotEmpty
              ? () async {
                  final selected = await CustomSelectorBottomSheet.show(
                    context: context,
                    title: hint,
                    items: items,
                    selectedValue: value,
                    showSearch: items.length > 10,
                  );
                  if (selected != null && onChanged != null) {
                    onChanged(selected);
                  }
                }
              : null,
          child: Container(
            height: 56,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(16),
              border: showError
                  ? Border.all(color: Colors.red, width: 1.5)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value != null && value.isNotEmpty ? value : hint,
                    style: TextStyle(
                      fontSize: 16,
                      color: showError
                          ? Colors.red.shade300
                          : (value != null && value.isNotEmpty
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: showError ? Colors.red.shade300 : AppTheme.textPrimary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
            child: Text(
              'Обязательное поле',
              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            ),
          ),
      ],
    );
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('.');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Ignore parse errors
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Widget _buildDateField(
    String hint, {
    String? value,
    ValueChanged<String>? onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        DateTime? initialDate;
        if (value != null && value.isNotEmpty) {
          initialDate = _parseDate(value) ?? DateTime.now();
        }

        final selectedDate = await CustomDatePickerBottomSheet.show(
          context: context,
          title: hint,
          selectedDate: initialDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (selectedDate != null && onChanged != null) {
          final formattedDate = _formatDate(selectedDate);
          onChanged(formattedDate);
        }
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null && value.isNotEmpty ? value : hint,
              style: TextStyle(
                color: value != null && value.isNotEmpty
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: AppTheme.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchField(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
          CustomSwitch(value: value, onChanged: onChanged ?? (_) {}),
        ],
      ),
    );
  }

  Widget _buildBrandDropdown(
    String hint, {
    String? value,
    ValueChanged<String?>? onChanged,
    String? fieldName,
  }) {
    final formData = ref.watch(addVehicleFormProvider);
    final showError =
        formData.showValidationErrors &&
        fieldName != null &&
        !formData.isFieldValid(fieldName);
    final brandsAsync = ref.watch(brandsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            if (brandsAsync.isLoading) return;
            final items = brandsAsync.value ?? [];
            if (items.isEmpty) return;
            final selected = await CustomSelectorBottomSheet.show(
              context: context,
              title: hint,
              items: items,
              selectedValue: value,
              showSearch: items.length > 10,
            );
            if (selected != null && onChanged != null) {
              onChanged(selected);
            }
          },
          child: Container(
            height: 56,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(16),
              border: showError
                  ? Border.all(color: Colors.red, width: 1.5)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value != null && value.isNotEmpty ? value : hint,
                    style: TextStyle(
                      fontSize: 16,
                      color: showError
                          ? Colors.red.shade300
                          : (value != null && value.isNotEmpty
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: showError ? Colors.red.shade300 : AppTheme.textPrimary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
            child: Text(
              'Обязательное поле',
              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            ),
          ),
      ],
    );
  }

  Widget _buildModelDropdown(
    String hint, {
    required String brand,
    String? value,
    ValueChanged<String?>? onChanged,
    String? fieldName,
  }) {
    final formData = ref.watch(addVehicleFormProvider);
    final showError =
        formData.showValidationErrors &&
        fieldName != null &&
        !formData.isFieldValid(fieldName);
    final modelsAsync = brand.isNotEmpty
        ? ref.watch(modelsProvider(brand))
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            if (modelsAsync?.isLoading ?? false) return;
            final items = modelsAsync?.value ?? [];
            if (items.isEmpty) return;
            final selected = await CustomSelectorBottomSheet.show(
              context: context,
              title: hint,
              items: items,
              selectedValue: value,
              showSearch: items.length > 10,
            );
            if (selected != null && onChanged != null) {
              onChanged(selected);
            }
          },
          child: Container(
            height: 56,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(16),
              border: showError
                  ? Border.all(color: Colors.red, width: 1.5)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: brand.isEmpty
                      ? Text(
                          hint,
                          style: TextStyle(
                            fontSize: 16,
                            color: showError
                                ? Colors.red.shade300
                                : AppTheme.textSecondary,
                          ),
                        )
                      : Text(
                          value != null && value.isNotEmpty ? value : hint,
                          style: TextStyle(
                            fontSize: 16,
                            color: showError
                                ? Colors.red.shade300
                                : (value != null && value.isNotEmpty
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary),
                          ),
                        ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: showError ? Colors.red.shade300 : AppTheme.textPrimary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
            child: Text(
              'Обязательное поле',
              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            ),
          ),
      ],
    );
  }
}
