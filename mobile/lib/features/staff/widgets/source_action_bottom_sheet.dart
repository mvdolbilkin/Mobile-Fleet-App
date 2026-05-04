import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/staff/data/staff_repository.dart';

class SourceActionBottomSheet extends ConsumerStatefulWidget {
  final int selectedCount;
  final List<String> selectedStaffIds;

  const SourceActionBottomSheet({
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
      builder: (context) => SourceActionBottomSheet(
        selectedCount: selectedCount,
        selectedStaffIds: selectedStaffIds,
      ),
    );
  }

  @override
  ConsumerState<SourceActionBottomSheet> createState() => _SourceActionBottomSheetState();
}

class _SourceActionBottomSheetState extends ConsumerState<SourceActionBottomSheet> {
  String? _selectedSource;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _sources = [
    {'id': 'yandex', 'name': 'Яндекс', 'icon': Icons.search},
    {'id': 'referral', 'name': 'Рекомендация', 'icon': Icons.people_outline},
    {'id': 'social', 'name': 'Социальные сети', 'icon': Icons.share_outlined},
    {'id': 'direct', 'name': 'Прямое обращение', 'icon': Icons.phone_outlined},
    {'id': 'agency', 'name': 'Агентство', 'icon': Icons.business_outlined},
    {'id': 'other', 'name': 'Другое', 'icon': Icons.more_horiz},
  ];

  Future<void> _applySource() async {
    if (_selectedSource == null) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(staffRepositoryProvider);
      await repository.bulkUpdateSource(
        contractorIds: widget.selectedStaffIds,
        source: _selectedSource!,
      );
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Источник обновлен для ${widget.selectedCount} исполнителей',
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
              'Изменить источник',
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
            
            // Source options
            ..._sources.map((source) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildSourceOption(
                id: source['id'],
                name: source['name'],
                icon: source['icon'],
              ),
            )),
            
            const SizedBox(height: 24),
            
            // Apply button
            ElevatedButton(
              onPressed: _selectedSource == null || _isLoading ? null : _applySource,
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

  Widget _buildSourceOption({
    required String id,
    required String name,
    required IconData icon,
  }) {
    final isSelected = _selectedSource == id;
    
    return Material(
      color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : const Color(0xFFF5F4F2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _selectedSource = id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? const Color(0xFF21201F) : AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Yandex Sans Text',
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: const Color(0xFF21201F),
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
