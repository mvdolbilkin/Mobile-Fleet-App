import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/domain/vehicle_details.dart';
import 'package:mobile/shared/widgets/fading_button.dart';
import 'package:mobile/shared/widgets/custom_selector_bottom_sheet.dart';
import 'package:mobile/shared/widgets/custom_date_picker_bottom_sheet.dart';
import 'package:mobile/shared/widgets/custom_switch.dart';
import '../providers/edit_vehicle_provider.dart';
import 'add_vehicle_bottom_sheet.dart';

class EditVehicleBottomSheet extends ConsumerStatefulWidget {
  final String vehicleId;
  final VehicleDetails vehicleDetails;

  const EditVehicleBottomSheet({
    Key? key,
    required this.vehicleId,
    required this.vehicleDetails,
  }) : super(key: key);

  static void show(
    BuildContext context,
    String vehicleId,
    VehicleDetails vehicleDetails,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: EditVehicleBottomSheet(
          vehicleId: vehicleId,
          vehicleDetails: vehicleDetails,
        ),
      ),
    );
  }

  @override
  ConsumerState<EditVehicleBottomSheet> createState() =>
      _EditVehicleBottomSheetState();
}

class _EditVehicleBottomSheetState
    extends ConsumerState<EditVehicleBottomSheet> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editVehicleFormProvider.notifier).initialize(
            widget.vehicleId,
            widget.vehicleDetails,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(editVehicleFormProvider);

    if (formData == null) {
      return Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: _buildForm(formData),
              ),
            ),
            _buildFooter(formData),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 60),
          const Text('Редактировать ТС', style: AppTheme.appBarTitle),
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

  Widget _buildForm(EditVehicleFormData formData) {
    final notifier = ref.read(editVehicleFormProvider.notifier);

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
                onTap: null, // Disabled
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeCard(
                title: 'Грузовой автомобиль',
                icon: Icons.local_shipping,
                isSelected: formData.isTruck,
                onTap: null, // Disabled
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
        _buildDateField(
          'Дата выдачи СТС',
          value: formData.stsIssueDate,
          onChanged: (v) => notifier.updateField(stsIssueDate: v),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          'Гос.номер',
          initialValue: formData.plateNumber,
          onChanged: (v) => notifier.updateField(plateNumber: v),
          fieldName: 'plateNumber',
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
          'Марка',
          initialValue: formData.brand,
          onChanged: (v) => notifier.updateField(brand: v),
          fieldName: 'brand',
        ),
        const SizedBox(height: 8),
        _buildTextField(
          'Модель',
          initialValue: formData.model,
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
          'КПП',
          value: formData.transmission,
          onChanged: (v) => notifier.updateField(transmission: v),
          fieldName: 'transmission',
          items: VehicleFormConstants.transmissions,
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          'Вид топлива',
          value: formData.fuelType,
          onChanged: (v) => notifier.updateField(fuelType: v),
          fieldName: 'fuelType',
          items: VehicleFormConstants.fuelTypes,
        ),
        const SizedBox(height: 24),
        const Text(
          'Адрес парковки',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Адрес парковки',
          hintDesc: 'Необязательно',
          initialValue: formData.parkingAddress,
          onChanged: (v) => notifier.updateField(parkingAddress: v),
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
          'Дополнительная информация',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Дополнительная информация',
          hintDesc: 'Необязательно',
          initialValue: formData.additionalInfo,
          onChanged: (v) => notifier.updateField(additionalInfo: v),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildFooter(EditVehicleFormData formData) {
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
        onTap: _isLoading ? null : () async {
          setState(() => _isLoading = true);

          final notifier = ref.read(editVehicleFormProvider.notifier);
          final error = await notifier.submit();

          if (mounted) {
            setState(() => _isLoading = false);

            if (error == null) {
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
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

  Widget _buildTypeCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade300 : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? Colors.grey.shade400
                : (isSelected ? AppTheme.textPrimary : AppTheme.borderColor),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: isDisabled ? Colors.grey.shade500 : AppTheme.textPrimary,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDisabled ? Colors.grey.shade600 : Colors.black,
              ),
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
    int maxLines = 1,
  }) {
    final formData = ref.watch(editVehicleFormProvider);
    final errorMessage =
        fieldName != null && formData != null ? formData.getFieldError(fieldName) : null;
    final showError = errorMessage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(minHeight: 56),
          alignment: maxLines > 1 ? Alignment.topLeft : Alignment.centerLeft,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(16),
            border: showError ? Border.all(color: Colors.red, width: 1.5) : null,
          ),
          child: TextFormField(
            initialValue: initialValue,
            onChanged: onChanged,
            maxLines: maxLines,
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
    final formData = ref.watch(editVehicleFormProvider);
    final showError = formData != null &&
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
              border:
                  showError ? Border.all(color: Colors.red, width: 1.5) : null,
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
          CustomSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
