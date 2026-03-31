import 'package:flutter/material.dart';

class StaffFilterSection extends StatelessWidget {
  const StaffFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 36,
            padding: const EdgeInsets.only(left: 8, right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF8A8A8A), size: 20),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Поиск по имени, ВУ или позывному',
                    style: const TextStyle(
                      fontFamily: 'Yandex Sans Text',
                      fontSize: 12,
                      color: Color(0xFF8A8A8A),
                      height: 1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Filter Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Checkbox Circle
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.black),
              ),
              const SizedBox(width: 8),
              
              // Filter Icon Circle
              Container(
                width: 34,
                height: 34, // No bg color in Figma? Wait, React says "relative shrink-0 size-[34px]" containing imgFrame...
                // Assuming it's a button, maybe greyish or transparent
                decoration: const BoxDecoration(
                  // color: Color(0xFFEEEEEE), // Assuming similar to checkbox
                  shape: BoxShape.circle,
                ),
                 // Using generic icon for filter
                child: const Icon(Icons.tune, size: 20, color: Colors.black),
              ),
              const SizedBox(width: 8),
              
              // Filter Pill: Status
              _buildFilterPill(
                label: 'Статус на линии:',
                valueWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00CA50),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Свободен',
                    style: TextStyle(
                      fontFamily: 'Yandex Sans Text',
                      fontSize: 11,
                      color: Colors.white,
                      height: 12/11,
                      letterSpacing: 0.11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Filter Pill: Car Type
              _buildFilterPill(
                label: 'Тип ТС:  Автомобиль',
                valueWidget: null, // Text is part of label or separate?
                // Figma: Text is "Тип ТС: Автомобиль" all in one.
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Reset Link
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Сбросить все фильтры',
            style: const TextStyle(
              fontFamily: 'Yandex Sans Text',
              fontSize: 13,
              color: Color(0xFF8A8A8A),
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.solid, // dashed? Figma says solid
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPill({required String label, Widget? valueWidget}) {
    return Container(
      height: 32,
      padding: const EdgeInsets.only(left: 11.5, right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF5C5A57).withOpacity(0.1), // ControlMinor with opacity? Figma React: var(--control-minor,rgba(92,90,87,0.1))
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Yandex Sans Text',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF21201F),
            ),
          ),
          if (valueWidget != null) ...[
            const SizedBox(width: 7.5),
            valueWidget,
          ],
          const SizedBox(width: 7.5),
          const Icon(Icons.keyboard_arrow_down, size: 12, color: Color(0xFF21201F)), // assuming arrow icon
        ],
      ),
    );
  }
}
