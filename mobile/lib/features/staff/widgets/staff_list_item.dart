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
                image: staff.avatarUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(staff.avatarUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: staff.avatarUrl.isEmpty 
               ? Center(
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
                )
               : null,
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
                      Text(
                        staff.timeOnShift,
                        style: const TextStyle(
                          fontFamily: 'Yandex Sans Text',
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Телефон
                      Expanded(
                        child: Text(
                          '· ',
                          style: const TextStyle(
                            fontFamily: 'Yandex Sans Text',
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w400,
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
