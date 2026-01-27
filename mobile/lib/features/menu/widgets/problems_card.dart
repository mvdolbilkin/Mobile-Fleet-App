import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/widgets/info_card.dart';
import 'package:mobile/features/menu/widgets/menu_icon.dart';

class ProblemsCard extends StatelessWidget {
  const ProblemsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Проблемы 7',
      // Red icon with exclamation mark
      icon: const MenuIcon(assetPath: 'assets/images/menu_problems.svg'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _ProblemRow(
            badgeContent: _IconBadgeContent(iconAsset: 'assets/images/menu_problems_down.svg'), // Placeholder for arrow down
            text: 'Низкая конверсия в 1 поездку',
          ),
          SizedBox(height: 12),
          _ProblemRow(
            badgeContent: _IconBadgeContent(iconAsset: 'assets/images/menu_problems_down.svg'),
            text: 'Низкая конверсия в 50 поездок',
          ),
          SizedBox(height: 12),
          _ProblemRow(
            badgeContent: _TextBadgeContent(text: '108'),
            text: 'Имеют проблемы с фотоконтролем',
          ),
          SizedBox(height: 12),
          _ProblemRow(
            badgeContent: _TextBadgeContent(text: '43'),
            text: 'Проверки фото термосумки не пройдены',
          ),
        ],
      ),
    );
  }
}

class _ProblemRow extends StatelessWidget {
  final Widget badgeContent;
  final String text;

  const _ProblemRow({
    required this.badgeContent,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align top if text wraps
      children: [
        Container(
          width: 36,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.statusRed,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: badgeContent,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              fontFamily: 'Yandex Sans Text',
              height: 1.2, 
            ),
          ),
        ),
      ],
    );
  }
}

class _TextBadgeContent extends StatelessWidget {
  final String text;

  const _TextBadgeContent({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Yandex Sans Text',
      ),
    );
  }
}

class _IconBadgeContent extends StatelessWidget {
  final String iconAsset;

  const _IconBadgeContent({required this.iconAsset});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconAsset,
      width: 14,
      height: 14,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
  }
}
