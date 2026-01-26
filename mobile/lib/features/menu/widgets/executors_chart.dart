import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';

class ExecutorsChart extends StatelessWidget {
  const ExecutorsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          // Grid lines
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
                4, (index) => Container(height: 1, color: AppTheme.borderColor)),
          ),
          // Bar
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              height: 100, // Roughly matching the "30" mark
              decoration: BoxDecoration(
                color: AppTheme.statusRed,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Y-Axis Labels
          const _ChartLabel(text: '30', top: 0),
          const _ChartLabel(text: '20', top: 35),
          const _ChartLabel(text: '10', top: 70),
          const _ChartLabel(text: '0', bottom: 0),
        ],
      ),
    );
  }
}

class _ChartLabel extends StatelessWidget {
  final String text;
  final double? top;
  final double? bottom;

  const _ChartLabel({required this.text, this.top, this.bottom});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: top,
      bottom: bottom,
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}
