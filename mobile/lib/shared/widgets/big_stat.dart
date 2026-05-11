import 'package:flutter/material.dart';

class BigStat extends StatelessWidget {
  final String value;
  final String label;
  final bool isFlexibleLabel;

  const BigStat({
    super.key,
    required this.value,
    required this.label,
    this.isFlexibleLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            height: 1,
            fontFamily: 'Yandex Sans Text',
            letterSpacing: -1,
          ),
        ),
        const SizedBox(width: 8),
        if (isFlexibleLabel)
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xCC000000), // ~80% opacity
                fontFamily: 'Yandex Sans Text',
                height: 1.1,
              ),
            ),
          )
        else
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.8),
              fontFamily: 'Yandex Sans Text',
            ),
          ),
      ],
    );
  }
}
