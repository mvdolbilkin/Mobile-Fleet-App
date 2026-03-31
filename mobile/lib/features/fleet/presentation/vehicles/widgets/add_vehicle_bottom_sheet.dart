import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/widgets/fading_button.dart';
import '../providers/add_vehicle_provider.dart';

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
            _buildHeader(formData),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        ),
        const SizedBox(height: 8),
        _buildTextField(
          'Гос.номер',
          initialValue: formData.plateNumber,
          onChanged: (v) => notifier.updateField(plateNumber: v),
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          'Марка',
          value: formData.brand,
          onChanged: (v) => notifier.updateField(brand: v),
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          'Год',
          value: formData.year,
          onChanged: (v) => notifier.updateField(year: v),
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
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          'Модель',
          value: formData.model,
          onChanged: (v) => notifier.updateField(model: v),
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
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          'Вид топлива',
          value: formData.fuelType,
          onChanged: (v) => notifier.updateField(fuelType: v),
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          'КПП',
          value: formData.transmission,
          onChanged: (v) => notifier.updateField(transmission: v),
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
          ),
          const SizedBox(height: 8),
          _buildTextField(
            'Высота (в см)',
            initialValue: formData.height,
            onChanged: (v) => notifier.updateField(height: v),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            'Ширина (в см)',
            initialValue: formData.width,
            onChanged: (v) => notifier.updateField(width: v),
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
            // Save logic to API
            await notifier.submit();
            if (mounted) Navigator.pop(context);
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
  }) {
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
          ),
          child: TextFormField(
            initialValue: initialValue,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              isDense: true,
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ),
        if (hintDesc != null)
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
  }) {
    return Container(
      height: 56,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            value != null && value.isNotEmpty ? value : hint,
            style: TextStyle(
              color: value != null && value.isNotEmpty
                  ? AppTheme.textPrimary
                  : AppTheme.textSecondary,
            ),
          ),
          items: const [], // TODO: Add actual items
          onChanged: onChanged,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    String hint, {
    String? value,
    ValueChanged<String>? onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        // Эмуляция выбора даты
        // final date = await showDatePicker(...);
        // if (date != null && onChanged != null) onChanged(date.toIso8601String());
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppTheme.statusGreen,
          ),
        ],
      ),
    );
  }
}
