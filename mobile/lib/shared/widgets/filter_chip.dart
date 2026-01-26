import 'package:flutter/material.dart';
import '../../app/theme.dart';

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool hasNotification;

  const CustomFilterChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.hasNotification = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.controlsColor : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasNotification) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.statusRed,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTheme.filterChip,
            ),
            if (isSelected) ...[
              SizedBox(width: 6),
              Icon(Icons.close, size: 16, color: AppTheme.textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}
