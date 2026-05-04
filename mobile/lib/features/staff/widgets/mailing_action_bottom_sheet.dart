import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/staff/data/staff_repository.dart';

class MailingActionBottomSheet extends ConsumerStatefulWidget {
  final int selectedCount;
  final List<String> selectedStaffIds;

  const MailingActionBottomSheet({
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
      builder: (context) => MailingActionBottomSheet(
        selectedCount: selectedCount,
        selectedStaffIds: selectedStaffIds,
      ),
    );
  }

  @override
  ConsumerState<MailingActionBottomSheet> createState() => _MailingActionBottomSheetState();
}

class _MailingActionBottomSheetState extends ConsumerState<MailingActionBottomSheet> {
  final TextEditingController _messageController = TextEditingController();
  String _selectedType = 'sms';
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Введите текст сообщения',
            style: TextStyle(fontFamily: 'Yandex Sans Text'),
          ),
          backgroundColor: AppTheme.statusRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(staffRepositoryProvider);
      await repository.bulkMailing(
        contractorIds: widget.selectedStaffIds,
        messageType: _selectedType,
        message: _messageController.text.trim(),
      );
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Сообщение отправлено ${widget.selectedCount} исполнителям',
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
      padding: EdgeInsets.only(
        top: 24,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
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
                'Рассылка',
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
              
              // Message type selector
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      type: 'sms',
                      label: 'SMS',
                      icon: Icons.sms_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      type: 'push',
                      label: 'Push',
                      icon: Icons.notifications_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      type: 'email',
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Message input
              TextField(
                controller: _messageController,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Введите текст сообщения...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Yandex Sans Text',
                    color: AppTheme.textSecondary,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F4F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: const TextStyle(
                  fontFamily: 'Yandex Sans Text',
                  fontSize: 16,
                  color: Color(0xFF21201F),
                ),
              ),
              const SizedBox(height: 24),
              
              // Send button
              ElevatedButton(
                onPressed: _isLoading ? null : _sendMessage,
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
                        'Отправить',
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
      ),
    );
  }

  Widget _buildTypeButton({
    required String type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedType == type;
    
    return Material(
      color: isSelected ? AppTheme.primaryColor : const Color(0xFFF5F4F2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF21201F) : AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Yandex Sans Text',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF21201F) : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
