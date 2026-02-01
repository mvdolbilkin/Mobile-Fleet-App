import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/staff/domain/staff.dart';
import 'package:mobile/features/staff/widgets/status_badge.dart';

class StaffListItem extends StatelessWidget {
  final Staff staff;
  final VoidCallback? onTap;

  const StaffListItem({
    required this.staff,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Аватар
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.controlsColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  staff.initials,
                  style: const TextStyle(
                    fontFamily: 'Yandex Sans Text',
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9E9B98),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Информация о сотруднике
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    staff.name,
                    style: AppTheme.bodyText.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 19/14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StatusBadge(status: staff.status),
                      const SizedBox(width: 8),
                      // Время на смене
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Text(
                          staff.timeOnShift,
                          style: const TextStyle(
                            fontFamily: 'Yandex Sans Text',
                            fontSize: 11,
                            color: AppTheme.textPrimary,
                            height: 14/11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Телефон
                      Expanded(
                        child: Text(
                          '∙ ${staff.phoneNumber}',
                          style: AppTheme.searchHint.copyWith(
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Стрелка
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
