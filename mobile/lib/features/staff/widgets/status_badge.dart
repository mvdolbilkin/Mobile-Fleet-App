import 'package:flutter/material.dart';
import 'package:mobile/features/staff/domain/staff.dart';

class StatusBadge extends StatelessWidget {
  final StaffStatus status;

  const StatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    String text;
    bool showIcon = false;

    switch (status) {
      case StaffStatus.free:
        backgroundColor = const Color(0xFF00CA50);
        text = 'Свободен';
        break;
      case StaffStatus.working:
        backgroundColor = const Color(0xFF00CA50);
        text = 'Работает';
        break;
      case StaffStatus.busy:
        backgroundColor = const Color(0xFFFA3E2C);
        text = 'Занят';
        break;
      case StaffStatus.onOrder:
        backgroundColor = const Color(0xFFFF9011);
        text = 'На заказе';
        break;
      case StaffStatus.offline:
        backgroundColor = const Color(0xFFA5A5A5);
        text = 'Оффлайн';
        showIcon = true; // Figma shows a small icon for offline
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Yandex Sans Text',
              fontSize: 11,
              height: 12/11,
              color: Colors.white,
              letterSpacing: 0.11,
            ),
          ),
          if (showIcon) ...[
            const SizedBox(width: 2),
             const Icon(Icons.flash_off, size: 8, color: Colors.white), // Placeholder icon for vector
          ],
        ],
      ),
    );
  }
}
