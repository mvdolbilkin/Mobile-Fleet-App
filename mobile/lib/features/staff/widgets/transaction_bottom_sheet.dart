import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/staff/domain/staff.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class TransactionBottomSheet extends StatefulWidget {
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
  State<TransactionBottomSheet> createState() => _TransactionBottomSheetState();
}

class _TransactionBottomSheetState extends State<TransactionBottomSheet> {
  bool _isDeposit = true; // true = Пополнения, false = Списания
  String _selectedCategory = 'Бонус';

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  final List<String> _depositCategories = ['Бонус', 'Пополнение', 'Реферальная программа', 'Прочие переводы'];
  final List<String> _manualCategories = ['test', 'Штрафы2', 'Телефон', '11', 'АРЕНДА', '1Test'];

  @override
  void dispose() {
    _amountController.dispose();
    _conditionController.dispose();
    _commentController.dispose();
    super.dispose();
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
              onTap: () => setState(() => _isDeposit = false),
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
              onTap: () => setState(() => _isDeposit = true),
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _depositCategories.map((category) {
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category),
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
              category,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildManualCategoriesSection() {
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
            ..._manualCategories.map((category) {
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
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
                    category,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: () {},
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
  }

  Widget _buildForm() {
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
        _buildTextField(
          controller: _conditionController,
          hintText: 'Краткое условие',
          helperText: 'Будет виден в транзакции в Диспетчерской, а также исполнителю в Про',
        ),
        const SizedBox(height: 16),
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
        onTap: () {
          // TODO: Implement transaction submit
          Navigator.of(context).pop();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.buttonColor, // Yellow button
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
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
