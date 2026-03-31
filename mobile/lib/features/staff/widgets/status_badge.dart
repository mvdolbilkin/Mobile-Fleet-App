import 'package:flutter/material.dart';
import 'package:mobile/features/staff/domain/staff.dart';

class StatusBadge extends StatelessWidget {
  final StaffStatus status;

  const StatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String text;
    bool showIcon = false;

    switch (status) {
      case StaffStatus.free:
        backgroundColor = const Color(0xFF00CA50);
        text = 'Свободен';
        break;
      case StaffStatus.busy:
        backgroundColor = const Color(0xFFFA3E2C);
        text = 'Занят';
        break;
      case StaffStatus.onOrder:
        backgroundColor = const Color(0xFFFF9011);
        text = 'На заказе';
        break;
      case StaffStatus.fired:
        backgroundColor = const Color(0xFF333333);
        text = 'Уволен';
        break;
      case StaffStatus.offline:
        backgroundColor = const Color(0xFFEEEEEE);
        textColor = const Color(0xFF8A8A8A);
        text = 'Оффлайн';
        showIcon = true;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
             Icon(Icons.lock_outline, size: 10, color: textColor),
             const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Yandex Sans Text',
              fontSize: 11,
              height: 12/11,
              color: textColor,
              letterSpacing: 0.11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
