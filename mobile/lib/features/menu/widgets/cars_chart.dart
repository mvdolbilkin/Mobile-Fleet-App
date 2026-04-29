import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/menu/models/cars_model.dart';
import 'dart:math' as math;

class CarsChart extends StatelessWidget {
  final CarsIndicator indicator;

  const CarsChart({super.key, required this.indicator});

  @override
  Widget build(BuildContext context) {
    // Find absolute maximum value
    final values = [
      indicator.working.count,
      indicator.noDriver.count,
      indicator.repairing.count,
      indicator.pending.count,
      indicator.unknown.count,
    ];
    final maxValue = values.reduce(math.max);

    // Calculate grid step
    int step = 1000;
    if (maxValue < 100) {
      step = 10;
    } else if (maxValue < 1000) {
      step = 100;
    } else if (maxValue < 10000) {
      step = 1000;
    }

    int maxGridLine = ((maxValue / step).ceil() + 1) * step;
    if (maxGridLine - maxValue > step) maxGridLine -= step;
    if (maxGridLine == 0) maxGridLine = step;

    final int linesCount = (maxGridLine ~/ step) + 1;
    const double chartHeight = 120.0;

    return SizedBox(
      height: chartHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Grid lines
          ...List.generate(linesCount, (index) {
            final val = index * step;
            final double bottomPos = (val / maxGridLine) * chartHeight;
            return Positioned(
              left: 0,
              right: 0,
              bottom: bottomPos - 6,
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                   Expanded(
                    child: Container(
                      height: 1,
                      color: AppTheme.borderColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      _formatLabel(val),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              ),
            );
          }),
          // Bars
          if (maxValue > 0)
            Positioned(
              left: 40, // padding from left
              right: 48, // space from labels
              bottom: 0,
              child: SizedBox(
                height: chartHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildBar(
                      value: indicator.working.count,
                      max: maxGridLine,
                      chartHeight: chartHeight,
                      color: AppTheme.statusGreen,
                    ),
                    const SizedBox(width: 8),
                    _buildBar(
                      value: indicator.noDriver.count,
                      max: maxGridLine,
                      chartHeight: chartHeight,
                      color: AppTheme.statusOrange,
                    ),
                    const SizedBox(width: 8),
                    _buildBar(
                      value: indicator.repairing.count,
                      max: maxGridLine,
                      chartHeight: chartHeight,
                      color: AppTheme.statusRed,
                    ),
                    const SizedBox(width: 8),
                    _buildBar(
                      value: indicator.pending.count,
                      max: maxGridLine,
                      chartHeight: chartHeight,
                      color: AppTheme.statusBlue,
                    ),
                    const SizedBox(width: 8),
                    _buildBar(
                      value: indicator.unknown.count,
                      max: maxGridLine,
                      chartHeight: chartHeight,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required int value,
    required int max,
    required double chartHeight,
    required Color color,
  }) {
    if (value == 0) {
      return const SizedBox(width: 32);
    }
    return Container(
      width: 32,
      height: (value / max) * chartHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
        ),
      ),
    );
  }

  String _formatLabel(int val) {
    if (val == 0) return '0';
    if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(0)} тыс.';
    }
    return val.toString();
  }
}
