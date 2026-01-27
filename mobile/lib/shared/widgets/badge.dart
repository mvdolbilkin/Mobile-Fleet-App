import 'package:flutter/material.dart';
import '../../app/theme.dart';

enum BadgeType {
  working,
  service,
  noDriver,
  preparation,
}

class CustomBadge extends StatelessWidget {
  final BadgeType type;
  final String text;

  const CustomBadge({
    Key? key,
    required this.type,
    required this.text,
  }) : super(key: key);

  Color get backgroundColor {
    switch (type) {
      case BadgeType.working:
        return const Color(0xFF34C759);
      case BadgeType.service:
        return const Color(0xFFFF3B30);
      case BadgeType.noDriver:
        return const Color(0xFFFF9500);
      case BadgeType.preparation:
        return const Color(0xFF007AFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTheme.badgeText,
      ),
    );
  }
}
