import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/staff/domain/staff.dart';
import 'package:mobile/features/staff/data/staff_repository.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class TransactionBottomSheet extends ConsumerStatefulWidget {
  final Staff staff;

  const TransactionBottomSheet({super.key, required this.staff});

  static Future<void> show({
    required BuildContext context,
    required Staff staff,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white, // Light background matching the image
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TransactionBottomSheet(staff: staff),
    );
  }

  @override
  ConsumerState<TransactionBottomSheet> createState() => _TransactionBottomSheetState();
}

class _TransactionBottomSheetState extends ConsumerState<TransactionBottomSheet> {
  bool _isDeposit = true; // true = Пополнения, false = Списания
  String _selectedCategory = 'Бонус';
  String? _selectedCategoryId;
  bool _isSubmitting = false;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _feeAmountController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _childDriverIdController = TextEditingController();
  final TextEditingController _vehicleIdController = TextEditingController();
  final TextEditingController _parkFeeController = TextEditingController();
  final TextEditingController _fuelValueController = TextEditingController();
  final TextEditingController _fuelUnitsController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  // Deposit category IDs that should appear in "Пополнения" tab
  final Set<String> _depositCategoryIds = {
    'partner_service_external_event_topup',      // Пополнение
    'partner_service_external_event_bonus',      // Бонус
    'partner_service_external_event_referal',    // Реферальная программа
    'partner_service_external_event_other',      // Прочие переводы
  };

  // Withdrawal category IDs that should appear in "Списания" tab
  final Set<String> _withdrawalCategoryIds = {
    'partner_service_external_event_payout',     // Выплата
    'partner_service_external_event_rent',       // Аренда
    'partner_service_external_event_deposit',    // Депозит
    'partner_service_external_event_fine',       // Штраф
    'partner_service_external_event_insurance',  // Страховка
    'partner_service_external_event_damage',     // Ущерб
    'partner_service_external_event_fuel',       // Топливо
  };

  @override
  void dispose() {
    _amountController.dispose();
    _feeAmountController.dispose();
    _conditionController.dispose();
    _commentController.dispose();
    _childDriverIdController.dispose();
    _vehicleIdController.dispose();
    _parkFeeController.dispose();
    _fuelValueController.dispose();
    _fuelUnitsController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  // Helper method to get the kind from category_id
  String _getKindFromCategoryId() {
    if (_selectedCategoryId == null) return '';
    
    if (_selectedCategoryId!.startsWith('partner_service_external_event_')) {
      return _selectedCategoryId!.replaceFirst('partner_service_external_event_', '');
    }
    return _selectedCategoryId!;
  }

  @override
  Widget build(BuildContext context) {
    // We adjust for the keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStaffCard(),
                  const SizedBox(height: 16),
                  _buildTabs(),
                  const SizedBox(height: 16),
                  _buildCategories(),
                  const SizedBox(height: 24),
                  _buildManualCategoriesSection(),
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.borderColor, height: 1),
                  const SizedBox(height: 24),
                  _buildForm(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Выплаты и списания',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontFamily: 'Yandex Sans Text',
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, color: AppTheme.textPrimary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.staff.initials.isNotEmpty ? widget.staff.initials[0] : '1',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.staff.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Баланс: ${widget.staff.balance} • Лимит: 5 ₽',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OutlinedButton(
                  text: 'В профиль',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OutlinedButton(
                  text: 'Выбрать другого',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _isDeposit = false;
                // Reset selected category when switching tabs
                _selectedCategoryId = null;
                _selectedCategory = 'Выплата';
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isDeposit ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isDeposit
                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Списания',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: !_isDeposit ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _isDeposit = true;
                // Reset selected category when switching tabs
                _selectedCategoryId = null;
                _selectedCategory = 'Бонус';
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isDeposit ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isDeposit
                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Пополнения',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _isDeposit ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categoriesAsync = ref.watch(transactionCategoriesProvider);
    
    return categoriesAsync.when(
      data: (allCategories) {
        // Filter categories based on current tab
        final filteredCategories = allCategories.where((cat) {
          final isEnabled = cat['is_enabled'] == true;
          final isCustom = cat['is_custom'] == true;
          final categoryId = cat['category_id'] as String? ?? '';
          
          if (!isEnabled) return false;
          
          if (_isDeposit) {
            // For deposits: only show specific deposit categories
            return _depositCategoryIds.contains(categoryId);
          } else {
            // For withdrawals: show withdrawal categories only (no custom categories in withdrawals)
            return _withdrawalCategoryIds.contains(categoryId);
          }
        }).toList();
        
        if (filteredCategories.isEmpty) {
          return const Text(
            'Нет доступных категорий',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          );
        }
        
        // Initialize selected category ID if not set or when switching tabs
        if (_selectedCategoryId == null && filteredCategories.isNotEmpty) {
          final defaultCategory = _isDeposit
              ? filteredCategories.firstWhere(
                  (cat) => cat['name'] == 'Бонус',
                  orElse: () => filteredCategories.first,
                )
              : filteredCategories.firstWhere(
                  (cat) => cat['name'] == 'Выплата',
                  orElse: () => filteredCategories.first,
                );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedCategoryId = defaultCategory['category_id'] as String?;
                _selectedCategory = defaultCategory['name'] as String? ?? 'Без названия';
              });
            }
          });
        }
        
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filteredCategories.map((category) {
            final name = category['name'] as String? ?? 'Без названия';
            final categoryId = category['category_id'] as String? ?? '';
            final isSelected = _selectedCategory == name;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedCategory = name;
                _selectedCategoryId = categoryId;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppTheme.textPrimary : AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Text(
        'Ошибка загрузки категорий',
        style: TextStyle(color: Colors.red.shade700, fontSize: 14),
      ),
    );
  }

  Widget _buildManualCategoriesSection() {
    final categoriesAsync = ref.watch(transactionCategoriesProvider);
    
    return categoriesAsync.when(
      data: (allCategories) {
        // Get only custom categories that are enabled
        final customCategories = allCategories.where((cat) {
          return cat['is_custom'] == true && cat['is_enabled'] == true;
        }).toList();
        
        if (customCategories.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Show only first 6 custom categories
        final displayedCategories = customCategories.take(6).toList();
        final hasMore = customCategories.length > 6;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Созданные вручную',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    children: [
                      Text(
                        'Перейти',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: AppTheme.textPrimary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...displayedCategories.map((category) {
                  final name = category['name'] as String? ?? 'Без названия';
                  final categoryId = category['category_id'] as String? ?? '';
                  final isSelected = _selectedCategory == name;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory = name;
                      _selectedCategoryId = categoryId;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppTheme.textPrimary : AppTheme.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  );
                }),
                if (hasMore)
                  GestureDetector(
                    onTap: _showAllCategories,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderColor, width: 1),
                      ),
                      child: const Text(
                        'Показать все',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  void _showAllCategories() {
    final categoriesAsync = ref.read(transactionCategoriesProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Созданные вручную',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Yandex Sans Text',
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: AppTheme.textPrimary, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: categoriesAsync.when(
                data: (allCategories) {
                  // Show only custom categories that are enabled
                  final customCategories = allCategories.where((cat) {
                    return cat['is_custom'] == true && cat['is_enabled'] == true;
                  }).toList();
                  
                  if (customCategories.isEmpty) {
                    return const Center(
                      child: Text(
                        'Категории не найдены',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: customCategories.length,
                    itemBuilder: (context, index) {
                      final category = customCategories[index];
                      final name = category['name'] ?? 'Без названия';
                      final categoryId = category['category_id'] as String? ?? '';
                      final isSelected = _selectedCategory == name;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = name;
                            _selectedCategoryId = categoryId;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF2F2F2) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppTheme.textPrimary : AppTheme.borderColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Ошибка загрузки категорий: $error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
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

  Widget _buildForm() {
    final kind = _getKindFromCategoryId();
    final isTopup = kind == 'topup';
    final isReferal = kind == 'referal';
    final isBonus = kind == 'bonus';
    final isOther = kind == 'other';
    final isRent = kind == 'rent';
    final isDeposit = kind == 'deposit';
    final isPayout = kind == 'payout';
    final isInsurance = kind == 'insurance';
    final isFine = kind == 'fine';
    final isDamage = kind == 'damage';
    final isFuel = kind == 'fuel';
    final isCustom = _selectedCategoryId?.startsWith('partner_service_manual_') ?? false;
    
    // For custom categories: show only comment
    // For "other" in deposits: show only comment
    // For "other" in withdrawals: show reason field
    final showOnlyComment = isCustom || (isOther && _isDeposit);
    final showReasonForOther = isOther && !_isDeposit;
    
    // Categories that require vehicle ID (rent, deposit, insurance, fine, damage, fuel)
    final requiresVehicleId = isRent || isDeposit || isInsurance || isFine || isDamage || isFuel;
    
    // Categories that support fee_amount
    final supportsFeeAmount = isTopup || isPayout;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedCategory,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _amountController,
          hintText: 'Сумма пополнения',
          keyboardType: TextInputType.number,
          showErrorText: false,
          hasBorder: true,
        ),
        if (!showOnlyComment) ...[
          const SizedBox(height: 24),
          const Text(
            'Дополнительно (необязательно)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Помогут вам и исполнителю уточнить условия или узнать детали',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
        ],
        // For topup and payout: show fee_amount
        if (supportsFeeAmount) ...[
          _buildTextField(
            controller: _feeAmountController,
            hintText: 'Комиссия',
            keyboardType: TextInputType.number,
            helperText: 'Будет виден в транзакции в Диспетчерской, а также исполнителю в Про',
          ),
          const SizedBox(height: 16),
        ],
        // For referal: show child_driver_id field
        if (isReferal) ...[
          _buildTextField(
            controller: _childDriverIdController,
            hintText: 'За кого',
            helperText: 'ID водителя для реферальной программы',
          ),
          const SizedBox(height: 16),
        ],
        // For rent, deposit, insurance, fine, damage, fuel: show vehicle_id field
        if (requiresVehicleId) ...[
          _buildTextField(
            controller: _vehicleIdController,
            hintText: 'ID автомобиля',
            helperText: 'ID автомобиля',
          ),
          const SizedBox(height: 16),
        ],
        // For fine: show park_fee field
        if (isFine) ...[
          _buildTextField(
            controller: _parkFeeController,
            hintText: 'Комиссия парка',
            keyboardType: TextInputType.number,
            helperText: 'Комиссия парка за штраф',
          ),
          const SizedBox(height: 16),
        ],
        // For fuel: show value and units fields
        if (isFuel) ...[
          _buildTextField(
            controller: _fuelValueController,
            hintText: 'Количество',
            keyboardType: TextInputType.number,
            helperText: 'Количество топлива',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _fuelUnitsController,
            hintText: 'Единицы измерения',
            helperText: 'Например: liters, gallons',
          ),
          const SizedBox(height: 16),
        ],
        // For bonus: show receipt_condition
        if (isBonus) ...[
          _buildTextField(
            controller: _conditionController,
            hintText: 'Краткое условие',
            helperText: 'Будет виден в транзакции в Диспетчерской, а также исполнителю в Про',
          ),
          const SizedBox(height: 16),
        ],
        // For "other" in withdrawals: show reason field
        if (showReasonForOther) ...[
          _buildTextField(
            controller: _reasonController,
            hintText: 'Причина',
            helperText: 'Причина прочих расходов',
          ),
          const SizedBox(height: 16),
        ],
        // Comment field for all categories
        if (showOnlyComment) const SizedBox(height: 24),
        _buildTextField(
          controller: _commentController,
          hintText: 'Комментарий',
          helperText: 'Будет виден партнёру в карточке транзакции в Диспетчерской, а исполнителю — в Про',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? helperText,
    TextInputType keyboardType = TextInputType.text,
    bool showErrorText = false,
    bool hasBorder = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: hasBorder ? Colors.white : const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
            border: showErrorText 
                ? Border.all(color: Colors.red, width: 1) 
                : hasBorder 
                    ? Border.all(color: AppTheme.textPrimary, width: 1) 
                    : null,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (showErrorText) ...[
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'Обязательное поле',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              helperText,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: FadingButton(
        onTap: _isSubmitting ? null : _handleSubmit,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _isSubmitting ? AppTheme.borderColor : AppTheme.buttonColor,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textPrimary),
                  ),
                )
              : Text(
                  _isDeposit ? 'Пополнить' : 'Списать',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    // Validate amount
    final amount = _amountController.text.trim();
    if (amount.isEmpty) {
      _showError('Пожалуйста, введите сумму');
      return;
    }

    final amountValue = double.tryParse(amount);
    if (amountValue == null || amountValue <= 0) {
      _showError('Пожалуйста, введите корректную сумму');
      return;
    }

    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      _showError('Пожалуйста, выберите категорию');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(staffRepositoryProvider);
      
      // Extract the kind from category_id
      final kind = _getKindFromCategoryId();

      // Format amount to 4 decimal places
      // For withdrawals (списания), use negative amount
      final formattedAmount = _isDeposit
          ? amountValue.toStringAsFixed(4)
          : (-amountValue).toStringAsFixed(4);

      await repository.createTransaction(
        contractorProfileId: widget.staff.id,
        amount: formattedAmount,
        kind: kind,
        categoryId: _selectedCategoryId,
        balanceMin: _conditionController.text.trim().isNotEmpty
            ? _conditionController.text.trim()
            : null,
        receiptCondition: _conditionController.text.trim().isNotEmpty
            ? _conditionController.text.trim()
            : null,
        description: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
        feeAmount: _feeAmountController.text.trim().isNotEmpty
            ? _feeAmountController.text.trim()
            : null,
        childDriverId: _childDriverIdController.text.trim().isNotEmpty
            ? _childDriverIdController.text.trim()
            : null,
        objectId: _vehicleIdController.text.trim().isNotEmpty
            ? _vehicleIdController.text.trim()
            : null,
        objectType: _vehicleIdController.text.trim().isNotEmpty
            ? 'vechicle'
            : null,
        parkFee: _parkFeeController.text.trim().isNotEmpty
            ? _parkFeeController.text.trim()
            : null,
        fuelValue: _fuelValueController.text.trim().isNotEmpty
            ? _fuelValueController.text.trim()
            : null,
        fuelUnits: _fuelUnitsController.text.trim().isNotEmpty
            ? _fuelUnitsController.text.trim()
            : null,
        reason: _reasonController.text.trim().isNotEmpty
            ? _reasonController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Транзакция успешно создана'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Ошибка создания транзакции: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _OutlinedButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
