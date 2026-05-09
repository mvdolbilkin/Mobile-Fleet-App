import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/menu/models/problems_model.dart';
import 'package:mobile/features/menu/providers/problems_provider.dart';
import 'package:mobile/shared/widgets/info_card.dart';
import 'package:mobile/shared/widgets/pulse_box.dart';
import 'package:mobile/features/menu/widgets/menu_icon.dart';

class ProblemsCard extends ConsumerWidget {
  const ProblemsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problemsAsync = ref.watch(problemsDataProvider);

    return problemsAsync.when(
      data: (data) => InfoCard(
        title: 'Проблемы ${data.total}',
        icon: const MenuIcon(assetPath: 'assets/images/menu_problems.svg'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < data.badges.length; i++) ...[
              _ProblemRow(badge: data.badges[i]),
              if (i < data.badges.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      loading: () => InfoCard(
        title: 'Проблемы',
        icon: const MenuIcon(assetPath: 'assets/images/menu_problems.svg'),
        child: Column(
          children: [
            for (var i = 0; i < 4; i++) ...[  
              Row(
                children: [
                  PulseBox(width: 36, height: 24, borderRadius: 6),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PulseBox(
                      width: null,
                      height: 16,
                      borderRadius: 6,
                    ),
                  ),
                ],
              ),
              if (i < 3) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      error: (error, stack) => InfoCard(
        title: 'Проблемы',
        icon: const MenuIcon(assetPath: 'assets/images/menu_problems.svg'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(
                'Ошибка загрузки данных',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProblemRow extends StatelessWidget {
  final ProblemBadge badge;

  const _ProblemRow({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.statusRed,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: _buildBadgeContent(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            badge.text,
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

  Widget _buildBadgeContent() {
    if (badge.icon.hasValue) {
      return Text(
        '${badge.icon.value}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Yandex Sans Text',
        ),
      );
    } else if (badge.icon.hasPicture) {
      // For picture icons like "ArrowDownRoundFill", use the down arrow asset
      return SvgPicture.asset(
        'assets/images/menu_problems_down.svg',
        width: 14,
        height: 14,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    }
    return const SizedBox.shrink();
  }
}
