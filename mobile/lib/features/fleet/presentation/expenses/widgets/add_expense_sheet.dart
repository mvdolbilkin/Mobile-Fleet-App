import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/data/expenses_repository.dart';
import 'package:mobile/features/fleet/domain/expense.dart';
import 'package:mobile/features/fleet/providers/expenses_suggestions_provider.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:mobile/shared/widgets/custom_selector_bottom_sheet.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

const _svgExpense = '''
<svg width="24" height="24" viewBox="0 0 24 24">
  <path d="M16 15.5c0-.512-.045-1.014-.132-1.502 1.761-.021 3.403-.194 4.678-.488A8.836 8.836 0 0 0 22 13.055V15.5c0 .8-2.713 1.454-6.132 1.498.087-.486.132-.987.132-1.498ZM22 10.5V8.055a8.83 8.83 0 0 1-1.454.455C19.183 8.824 17.4 9 15.5 9c-.93 0-1.832-.042-2.67-.122a8.53 8.53 0 0 1 2.418 3.121L15.5 12c3.59 0 6.5-.671 6.5-1.5ZM9 5.5C9 6.33 11.91 7 15.5 7S22 6.33 22 5.5v-1c0-.828-2.91-1.5-6.5-1.5S9 3.672 9 4.5v1ZM7.5 22a6.5 6.5 0 1 0 0-13 6.5 6.5 0 0 0 0 13Z" fill="currentColor"/>
</svg>
''';

const _svgCar = '''
<svg width="24" height="24" fill="none" viewBox="0 0 24 24">
  <path fill="currentColor" fill-rule="evenodd" d="M3 20h5l1-2h6l1 2h5v-4.316a1.5 1.5 0 0 1-.92.316h-.731c-.099 0-.197-.01-.294-.03l-2.896-.578a.88.88 0 0 1 .063-1.739L21 13l2-1v-1.5a.5.5 0 0 0-.5-.5h-2.924l-.593-2.956a1.993 1.993 0 0 0-1.568-1.568c-.47-.091-.94-.175-1.415-.24C14.934 5.089 13.698 5 12 5s-2.934.089-4 .236c-.474.065-.945.149-1.415.24a1.993 1.993 0 0 0-1.568 1.568L4.424 10H1.5a.5.5 0 0 0-.5.5V12l2 1 4.645.653c.432.056.755.43.755.875 0 .42-.29.781-.692.864l-2.832.579a1.44 1.44 0 0 1-.288.029h-.714c-.317 0-.623-.105-.874-.296V20ZM7.496 6.89c1.19-.265 2.42-.445 4.504-.445 1.27 0 3.315.18 4.504.445.976.217 1.048.57 1.246 1.54.137.673.279 1.344.419 2.015 0 0-3.753-.444-6.169-.444-2.416 0-6.169.444-6.169.444.14-.671.282-1.342.419-2.014.198-.971.27-1.324 1.246-1.541Z" clip-rule="evenodd"/>
</svg>
''';

Future<bool?> showAddExpenseSheet(
  BuildContext context, {
  Expense? expense,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _AddExpenseSheet(
      expense: expense,
    ),
  );
}

class _AddExpenseSheet extends ConsumerStatefulWidget {
  final Expense? expense;

  const _AddExpenseSheet({
    this.expense,
  });

  @override
  ConsumerState<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<_AddExpenseSheet> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();

  String? _selectedCarId;
  String? _selectedCarLabel;
  String? _selectedTypeId;
  String? _selectedTypeLabel;
  bool _saving = false;
  bool _showValidationErrors = false;

  bool get _isEditing => widget.expense != null;

  bool get _isAmountValid => _amountController.text.trim().isNotEmpty;
  bool get _isNameValid => _titleController.text.trim().isNotEmpty;
  bool get _isCarValid => _selectedCarId != null;
  bool get _isTypeValid => _selectedTypeId != null;
  bool get _isFormValid => _isAmountValid && _isNameValid && _isCarValid && _isTypeValid;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    if (e != null) {
      _amountController.text = e.amount;
      _titleController.text = e.name;
      _selectedCarId = e.car.id;
      _selectedCarLabel = '${e.car.number} ${e.car.details}';
      _selectedTypeId = e.type.id;
      _selectedTypeLabel = e.type.name;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickCar(List<Map<String, dynamic>> cars) async {
    final labels = cars.map((c) {
      final number = c['number'] as String? ?? '';
      final brand = c['brand'] as String? ?? '';
      final model = c['model'] as String? ?? '';
      return '$number $brand $model'.trim();
    }).toList();

    final selected = await CustomSelectorBottomSheet.show(
      context: context,
      title: 'Автомобиль',
      items: labels,
      selectedValue: _selectedCarLabel,
    );

    if (selected != null) {
      final idx = labels.indexOf(selected);
      setState(() {
        _selectedCarId = cars[idx]['id'] as String?;
        _selectedCarLabel = selected;
      });
    }
  }

  Future<void> _save() async {
    final amount = _amountController.text.trim();
    final name = _titleController.text.trim();
    final comment = _commentController.text.trim();

    if (!_isFormValid) {
      setState(() => _showValidationErrors = true);
      return;
    }

    setState(() => _saving = true);

    try {
      final parkId = await ref.read(secureStorageServiceProvider).getParkId();
      if (parkId == null) { setState(() => _saving = false); return; }

      final repo = ref.read(expensesRepositoryProvider);

      if (_isEditing) {
        await repo.updateCost(
          parkId: parkId,
          id: widget.expense!.id,
          amount: amount,
          carId: _selectedCarId!,
          typeId: _selectedTypeId!,
          name: name,
          comment: comment.isNotEmpty ? comment : null,
        );
      } else {
        await repo.createCost(
          parkId: parkId,
          amount: amount,
          carId: _selectedCarId!,
          typeId: _selectedTypeId!,
          name: name,
          comment: comment.isNotEmpty ? comment : null,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickType(List<Map<String, dynamic>> costTypes) async {
    final labels = costTypes.map((t) => t['name'] as String? ?? t['id'] as String).toList();

    final selected = await CustomSelectorBottomSheet.show(
      context: context,
      title: 'Тип расхода',
      items: labels,
      selectedValue: _selectedTypeLabel,
      showSearch: false,
      activeColor: AppTheme.buttonColor, // Желтый цвет
    );

    if (selected != null) {
      final idx = labels.indexOf(selected);
      setState(() {
        _selectedTypeId = costTypes[idx]['id'] as String?;
        _selectedTypeLabel = selected;
      });
    }
  }

  Widget _buildAmountField() {
    final showError = _showValidationErrors && !_isAmountValid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(16),
            border: showError ? Border.all(color: Colors.red, width: 1.5) : null,
          ),
          child: Row(
            children: [
              SvgPicture.string(
                _svgExpense,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppTheme.textPrimary, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Сумма, ₽',
                    isDense: true,
                    hintStyle: TextStyle(
                      color: showError ? Colors.red.shade300 : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 16, right: 16),
            child: Text(
              'Обязательное поле',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectorField({
    required String label,
    required bool isPlaceholder,
    VoidCallback? onTap,
    String? leadingIcon,
    required bool showError,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(16),
              border: showError ? Border.all(color: Colors.red, width: 1.5) : null,
            ),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  SvgPicture.string(
                    leadingIcon,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      showError ? Colors.red.shade300 : AppTheme.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      color: showError
                          ? Colors.red.shade300
                          : (isPlaceholder ? AppTheme.textSecondary : AppTheme.textPrimary),
                    ),
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: showError ? Colors.red.shade300 : AppTheme.textSecondary,
                  ),
              ],
            ),
          ),
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 16, right: 16),
            child: Text(
              'Обязательное поле',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildNameField() {
    final showError = _showValidationErrors && !_isNameValid;
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
            border: showError ? Border.all(color: Colors.red, width: 1.5) : null,
          ),
          child: TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Название расхода',
              isDense: true,
              hintStyle: TextStyle(
                color: showError ? Colors.red.shade300 : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 16, right: 16),
            child: Text(
              'Обязательное поле',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _commentController,
        maxLines: 4,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Комментарий',
          isDense: true,
          hintStyle: TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carsAsync = ref.watch(suggestCarsProvider);
    final typesAsync = ref.watch(costTypesProvider);

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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 72),
                  Text(
                    _isEditing ? 'Редактирование' : 'Новый расход',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Отмена'),
                  ),
                ],
              ),
            ),
            // Scrollable form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAmountField(),
                    const SizedBox(height: 12),
                    _buildSelectorField(
                      label: _selectedCarLabel ?? 'Автомобиль',
                      isPlaceholder: _selectedCarLabel == null,
                      onTap: () {
                        if (carsAsync.hasValue) _pickCar(carsAsync.value!);
                      },
                      leadingIcon: _svgCar,
                      showError: _showValidationErrors && !_isCarValid,
                      isLoading: carsAsync.isLoading,
                    ),
                    const SizedBox(height: 12),
                    _buildSelectorField(
                      label: _selectedTypeLabel ?? 'Тип расхода',
                      isPlaceholder: _selectedTypeLabel == null,
                      onTap: () {
                        if (typesAsync.hasValue) _pickType(typesAsync.value!);
                      },
                      showError: _showValidationErrors && !_isTypeValid,
                      isLoading: typesAsync.isLoading,
                    ),
                    const SizedBox(height: 12),
                    _buildNameField(),
                    const SizedBox(height: 12),
                    _buildCommentField(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Footer with button
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
              child: FadingButton(
                onTap: _saving ? null : _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.buttonColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _saving
                      ? const Center(child: SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        ))
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
          ],
        ),
      ),
    );
  }
}
