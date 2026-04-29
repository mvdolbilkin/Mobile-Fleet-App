import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/menu/models/contractors_model.dart';

class ExecutorsChart extends StatelessWidget {
  final Indicator indicator;

  const ExecutorsChart({super.key, required this.indicator});

  @override
  Widget build(BuildContext context) {
    // Generate scale values
    final total = indicator.total;
    int maxGridLine = 30; // default minimum
    if (total > 0) {
      maxGridLine = ((total / 10).ceil() + 1) * 10;
      if (maxGridLine - total > 10) maxGridLine -= 10;
    }

    const int step = 10;
    final int linesCount = (maxGridLine ~/ step) + 1;

    const double chartHeight = 120.0;
    final double barHeight = total == 0 ? 0 : (total / maxGridLine) * chartHeight;

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
                    width: 20,
                    child: Text(
                      '$val',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1, // Remove extra line height
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              ),
            );
          }),
          // 3 Bars
          if (total > 0)
            Positioned(
              right: 36, // space from labels
              bottom: 0,
              child: SizedBox(
                height: chartHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildBar(
                      value: indicator.free,
                      max: maxGridLine,
                      chartHeight: chartHeight,
                      color: AppTheme.statusGreen,
                    ),
                    const SizedBox(width: 4),
                    _buildBar(
                      value: indicator.inOrder,
                      max: maxGridLine,
                      chartHeight: chartHeight,
                      color: AppTheme.statusOrange,
                    ),
                    const SizedBox(width: 4),
                    _buildBar(
                      value: indicator.busy,
                      max: maxGridLine,
                      chartHeight: chartHeight,
                      color: AppTheme.statusRed,
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
      // Adding minimal border radius so it doesn't look cut off and thick
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
        ),
      ),
    );
  }
}


