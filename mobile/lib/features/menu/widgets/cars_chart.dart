import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';

class CarsChart extends StatelessWidget {
  const CarsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          // Grid lines and Labels
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _ChartLine(label: '2 тыс.'),
              _ChartLine(label: '1 тыс.'),
              _ChartLine(label: '0'),
            ],
          ),
          // Bars
          Positioned(
            bottom:
                25, // Start from the '0' line (approx text height + padding)
            left: 0,
            right: 50, // Leave space for right-side labels
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(width: 40), // Left padding
                Container(
                  width: 60,
                  height: 140, // Visual approximation for > 2000
                  decoration: const BoxDecoration(
                    color: AppTheme.statusGreen,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 6, // Visual approximation for ~67
                  decoration: const BoxDecoration(
                    color: AppTheme.statusOrange,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLine extends StatelessWidget {
  final String label;

  const _ChartLine({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppTheme.borderColor)),
        const SizedBox(width: 8),
        SizedBox(
          width: 40, // Fixed width for labels
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9E9E9E), // Colors.grey
              fontSize: 12,
              fontFamily: 'Yandex Sans Text',
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
