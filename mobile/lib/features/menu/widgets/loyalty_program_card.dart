import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/widgets/info_card.dart';
import 'package:mobile/features/menu/widgets/menu_icon.dart';

class LoyaltyProgramCard extends StatelessWidget {
  const LoyaltyProgramCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Программа лояльности',
      subtitle: 'Прогресс в январе',
      icon: const MenuIcon(assetPath: 'assets/images/menu_loyalty_program.svg'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Basic Level
          _LevelHeader(
            icon: SvgPicture.asset(
              'assets/images/menu_loyalty_base.svg',
              width: 24,
              height: 24,
            ),
            text: 'Базовый',
          ),

          const SizedBox(height: 16),

          // Bronze Level (Locked/Upcoming)
          _LevelHeader(
            icon: SvgPicture.asset(
              'assets/images/menu_loyalty_bronze.svg', // Placeholder asset
              width: 24,
              height: 24,
            ), 
            text: 'Бронзовый',
            isLocked: true,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32.0, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _BenefitBadge(
                        text: 'Галочка в Про',
                        assetPath: 'assets/images/menu_loyalty_lock.svg'),
                    _BenefitBadge(
                        text: 'Обратный звонок',
                        assetPath: 'assets/images/menu_loyalty_lock.svg'),
                  ],
                ),
                const SizedBox(height: 12),
                const _RequirementRow(
                  text: '2000 поездок в месяц',
                  state: _RequirementState.failed,
                ),
                const SizedBox(height: 8),
                const _RequirementRow(
                  text: 'Заполнен профиль партнёра',
                  state: _RequirementState.completed,
                ),
                const SizedBox(height: 8),
                const _RequirementRow(
                  text: 'Исполнители подтвердили занятость',
                  state: _RequirementState.completed,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Silver Level
          _LevelHeader(
            icon: SvgPicture.asset(
              'assets/images/menu_loyalty_silver.svg', // Placeholder asset
              width: 24,
              height: 24,
            ),
            text: 'Серебряный',
            isLocked: true,
          ),
            Padding(
            padding: const EdgeInsets.only(left: 32.0, top: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const _BenefitBadge(
                text: 'Скидка на Диспетчерскую',
                assetPath: 'assets/images/menu_loyalty_lock.svg'),
            ),
            ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: AppTheme.borderColor),
          const SizedBox(height: 12),

          const Text(
            'Можно выбрать показатель «Часы на линии».\nПодтвердите право собственности на 7 из 10 авто',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontFamily: 'Yandex Sans Text',
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  final Widget icon;
  final String text;
  final bool isLocked;

  const _LevelHeader({
    required this.icon,
    required this.text,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 24, // Use large font for level names as in image
            fontWeight: FontWeight.w700,
            color: isLocked ? const Color(0xFF9E9E9E) : const Color(0xFF455A64),
            fontFamily: 'Yandex Sans Text',
          ),
        ),
        if (isLocked) ...[
          const SizedBox(width: 6),
          // const Icon(Icons.lock_outline, size: 16, color: Color(0xFF9E9E9E)),
          // Image doesn't explicitly show separate lock icon, the shield IS the lock metaphor often
        ]
      ],
    );
  }
}

class _BenefitBadge extends StatelessWidget {
  final String text;
  final String assetPath;

  const _BenefitBadge({
    required this.text,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8E8E93), // Grey background
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // const Icon(Icons.lock, size: 12, color: Colors.white),
          SizedBox(
            width: 12,
            height: 12,
            child: SvgPicture.asset(
              assetPath,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Yandex Sans Text',
            ),
          ),
        ],
      ),
    );
  }
}

enum _RequirementState { completed, failed, neutral }

class _RequirementRow extends StatelessWidget {
  final String text;
  final _RequirementState state;

  const _RequirementRow({
    required this.text,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    // IconData iconData;
    String assetPath;

    switch (state) {
      case _RequirementState.completed:
        assetPath = 'assets/images/menu_accept.svg'; // Placeholder
        // iconData = Icons.check_circle;
        break;
      case _RequirementState.failed:
        assetPath = 'assets/images/menu_reject.svg'; // Placeholder
        // iconData = Icons.cancel;
        break;
      case _RequirementState.neutral:
        assetPath = 'assets/images/menu_stuff.svg'; // Placeholder
        // iconData = Icons.circle_outlined;
        break;
    }

    return Row(
      children: [
        // Icon(iconData, color: iconColor, size: 20),
        SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset(
              assetPath,
            )),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              fontFamily: 'Yandex Sans Text',
            ),
          ),
        ),
      ],
    );
  }
}
