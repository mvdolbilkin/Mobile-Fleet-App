import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/staff/data/staff_repository.dart';

class WorkConditionsActionBottomSheet extends ConsumerStatefulWidget {
  final int selectedCount;
  final List<String> selectedStaffIds;

  const WorkConditionsActionBottomSheet({
    super.key,
    required this.selectedCount,
    required this.selectedStaffIds,
  });

  static Future<bool?> show({
    required BuildContext context,
    required int selectedCount,
    required List<String> selectedStaffIds,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => WorkConditionsActionBottomSheet(
        selectedCount: selectedCount,
        selectedStaffIds: selectedStaffIds,
      ),
    );
  }

  @override
  ConsumerState<WorkConditionsActionBottomSheet> createState() => _WorkConditionsActionBottomSheetState();
}

class _WorkConditionsActionBottomSheetState extends ConsumerState<WorkConditionsActionBottomSheet> {
  String? _selectedCondition;
  bool _isLoading = false;
  bool _isLoadingRules = true;

  List<Map<String, dynamic>> _conditions = [];

  @override
  void initState() {
    super.initState();
    _loadWorkRules();
  }

  Future<void> _loadWorkRules() async {
    try {
      final repository = ref.read(staffRepositoryProvider);
      final rules = await repository.fetchWorkRules();
      if (mounted) {
        setState(() {
          _conditions = rules.map((r) => {
            'id': r['id'],
            'name': r['name'] ?? 'Неизвестно',
            'commission': r['default_commission']?['percent'] ?? '0.00',
            'is_default': r['is_default'] ?? false,
          }).toList();
          if (_conditions.isNotEmpty) {
            // Find default
            final defaultRule = _conditions.firstWhere(
              (r) => r['is_default'] == true,
              orElse: () => _conditions.first,
            );
            // Default selected rule is not set automatically to force explicit choice,
            // or we could set it:
            // _selectedCondition = defaultRule['id'];
          }
          _isLoadingRules = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRules = false);
        // Show error? Wait, we can just show empty list.
      }
    }
  }

  Future<void> _applyCondition() async {
    if (_selectedCondition == null) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(staffRepositoryProvider);
      await repository.bulkUpdateWorkConditions(
        contractorIds: widget.selectedStaffIds,
        condition: _selectedCondition!,
      );
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Условия работы обновлены для ${widget.selectedCount} исполнителей',
              style: const TextStyle(fontFamily: 'Yandex Sans Text'),
            ),
            backgroundColor: AppTheme.statusGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ошибка: $e',
              style: const TextStyle(fontFamily: 'Yandex Sans Text'),
            ),
            backgroundColor: AppTheme.statusRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Условия работы',
              style: const TextStyle(
                fontFamily: 'Yandex Sans Text',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF21201F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Выбрано исполнителей: ${widget.selectedCount}',
              style: const TextStyle(
                fontFamily: 'Yandex Sans Text',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Condition options
            if (_isLoadingRules)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                ),
              )
            else if (_conditions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Нет доступных условий',
                    style: TextStyle(
                      fontFamily: 'Yandex Sans Text',
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: SingleChildScrollView(
                  child: Column(
                    children: _conditions.map((condition) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildConditionOption(
                        id: condition['id'] as String,
                        name: condition['name'] as String,
                        commission: condition['commission'] as String,
                        isDefault: condition['is_default'] as bool? ?? false,
                      ),
                    )).toList(),
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Apply button
            ElevatedButton(
              onPressed: _selectedCondition == null || _isLoading ? null : _applyCondition,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: const Color(0xFF21201F),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF21201F)),
                      ),
                    )
                  : const Text(
                      'Применить',
                      style: TextStyle(
                        fontFamily: 'Yandex Sans Text',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text(
                'Отмена',
                style: TextStyle(
                  fontFamily: 'Yandex Sans Text',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionOption({
    required String id,
    required String name,
    required String commission,
    required bool isDefault,
  }) {
    final isSelected = _selectedCondition == id;
    
    return Material(
      color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : const Color(0xFFF5F4F2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _selectedCondition = id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Yandex Sans Text',
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        color: const Color(0xFF21201F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Комиссия: $commission%',
                      style: const TextStyle(
                        fontFamily: 'Yandex Sans Text',
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'По умолчанию',
                    style: TextStyle(
                      fontFamily: 'Yandex Sans Text',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
