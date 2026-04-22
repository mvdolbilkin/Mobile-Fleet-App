import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/staff/data/staff_repository.dart';
import 'package:mobile/features/staff/domain/staff.dart';
import 'package:mobile/features/staff/widgets/status_badge.dart';
import 'package:mobile/shared/widgets/fading_button.dart';
import 'package:mobile/shared/widgets/info_block.dart';
import 'package:mobile/shared/widgets/info_card.dart';
import 'package:mobile/shared/widgets/badge.dart';

class StaffDetailsScreen extends ConsumerWidget {
  final Staff staff;

  const StaffDetailsScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(staffProfileProvider(staff.id));
    
    // Пока данные загружаются, используем базовые данные из списка (staff).
    // Если произошла ошибка, также показываем базовые данные.
    final displayStaff = profileAsync.value ?? staff;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(displayStaff.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
      ),
      body: profileAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(context, displayStaff),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                  _buildDetailsGrid(displayStaff),
                  const SizedBox(height: 24),
                  _buildIndicatorsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Staff displayStaff) {
    return InfoCard(
      title: displayStaff.name,
      subtitle: displayStaff.phoneNumber,
      icon: CircleAvatar(
        radius: 36,
        backgroundColor: AppTheme.controlsColor,
        backgroundImage: displayStaff.avatarUrl.isNotEmpty ? NetworkImage(displayStaff.avatarUrl) : null,
        child: displayStaff.avatarUrl.isEmpty
            ? Text(displayStaff.initials, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.textSecondary))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(status: displayStaff.status),
              if (displayStaff.employmentType.isNotEmpty)
                CustomBadge(type: BadgeType.working, text: displayStaff.employmentType),
              if (displayStaff.vehicleType.isNotEmpty)
                 CustomBadge(type: BadgeType.preparation, text: 'Парковый автомобиль'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    InfoBlock(title: 'ТЕЛЕФОН', value: displayStaff.phoneNumber, icon: Icons.phone_outlined),
                    const SizedBox(height: 8),
                    InfoBlock(title: 'EMAIL', value: displayStaff.email.isNotEmpty ? displayStaff.email : 'Не указан', icon: Icons.email_outlined),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    InfoBlock(title: 'ID', value: displayStaff.id, icon: Icons.badge_outlined),
                    const SizedBox(height: 8),
                    InfoBlock(title: 'ИНН', value: displayStaff.taxNumber.isNotEmpty ? displayStaff.taxNumber : 'Не указан', icon: Icons.receipt_long_outlined),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ActionButton(icon: Icons.chat_bubble_outline, label: 'Написать', onTap: () {}),
          const SizedBox(width: 8),
          _ActionButton(icon: Icons.work_outline, label: 'Сменить тип занятости', onTap: () {}),
          const SizedBox(width: 8),
          _ActionButton(icon: Icons.history, label: 'История изменений', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(Staff displayStaff) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(title: 'Баланс', value: displayStaff.balance, showBalanceActions: true)),
            const SizedBox(width: 12),
            const Expanded(child: _StatCard(title: 'Бонусы', value: 'Нет активных бонусов')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatCard(
                title: 'Комментарий',
                value: displayStaff.comment.isNotEmpty ? displayStaff.comment : 'Нет комментария',
                subtitle: 'Заметка об исполнителе',
                isEditable: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: displayStaff.vehicleType.isNotEmpty ? displayStaff.vehicleType : 'Детали авто',
                value: 'Ограничить поездки без ОСАГО\nОграничить поездки в других парках',
                subtitle: 'Детали авто',
                isEditable: true,
                valueFontSize: 13,
                valueColor: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIndicatorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Показатели',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Yandex Sans Text',
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
                  SizedBox(width: 6),
                  Text('16–22 апр.', style: AppTheme.captionSecondary),
                  SizedBox(width: 4),
                  Icon(Icons.close, size: 14, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: _IndicatorCard(title: 'Доход в Про', value: '0 ₽')),
            SizedBox(width: 8),
            Expanded(child: _IndicatorCard(title: 'Заказы', value: '0')),
            SizedBox(width: 8),
            Expanded(child: _IndicatorCard(title: 'Отмененные', value: '0')),
            SizedBox(width: 8),
            Expanded(child: _IndicatorCard(title: 'Время на линии', value: '0 мин')),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FadingButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF34C759)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontFamily: 'Yandex Sans Text', fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final bool showBalanceActions;
  final bool isEditable;
  final double valueFontSize;
  final Color valueColor;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.showBalanceActions = false,
    this.isEditable = false,
    this.valueFontSize = 20,
    this.valueColor = AppTheme.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Yandex Sans Text',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 16, color: AppTheme.textSecondary),
                      ],
                    ),
                  ),
                  if (showBalanceActions)
                    Row(
                      children: const [
                        Icon(Icons.remove_circle_outline, size: 22, color: AppTheme.textPrimary),
                        SizedBox(width: 8),
                        Icon(Icons.add_circle_outline, size: 22, color: AppTheme.textPrimary),
                      ],
                    ),
                  if (isEditable)
                    const Icon(Icons.edit_outlined, size: 20, color: AppTheme.textSecondary),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: AppTheme.captionSecondary),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w600,
              fontFamily: 'Yandex Sans Text',
              color: valueColor,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  final String title;
  final String value;

  const _IndicatorCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Yandex Sans Text',
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right, size: 14, color: AppTheme.textSecondary),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Yandex Sans Text',
            ),
          ),
        ],
      ),
    );
  }
}
