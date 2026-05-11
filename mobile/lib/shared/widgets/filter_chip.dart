import 'package:flutter/material.dart';

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? selectedBorderColor;
  final Color? unselectedColor;
  final Color? unselectedBorderColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final double borderRadius;

  const CustomFilterChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
    this.selectedBorderColor,
    this.unselectedColor,
    this.unselectedBorderColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.borderRadius = 8,
  }) : super(key: key);

  static const Color _defaultSelectedColor = Color(0xFFFCE000);
  static const Color _defaultSelectedBorderColor = Color(0xFFC4A700);
  static const Color _defaultUnselectedColor = Colors.white;
  static const Color _defaultUnselectedBorderColor = Color(0xFFE5E5EA);

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (selectedColor ?? _defaultSelectedColor)
        : (unselectedColor ?? _defaultUnselectedColor);
    final borderColor = isSelected
        ? (selectedBorderColor ?? _defaultSelectedBorderColor)
        : (unselectedBorderColor ?? _defaultUnselectedBorderColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Yandex Sans Text',
            color: isSelected
                ? (selectedTextColor ?? Colors.black)
                : (unselectedTextColor ?? const Color(0xFF1C1C1E)),
          ),
        ),
      ),
    );
  }
}
