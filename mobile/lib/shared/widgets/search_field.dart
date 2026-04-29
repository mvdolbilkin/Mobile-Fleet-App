import 'package:flutter/material.dart';
import '../../app/theme.dart';

class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final double borderRadius;
  final double height;

  const SearchField({
    Key? key,
    required this.hint,
    this.onChanged,
    this.controller,
    this.suffixIcon,
    this.borderRadius = 12.0,
    this.height = 52.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.controlsColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTheme.bodyText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.searchHint,
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.textSecondary,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: (height - 20) / 2),
          isDense: true,
        ),
      ),
    );
  }
}
