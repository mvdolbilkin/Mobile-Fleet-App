import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/menu/models/loyalty_program_model.dart';
import 'package:mobile/features/menu/providers/loyalty_program_provider.dart';
import 'package:mobile/shared/widgets/info_card.dart';
import 'package:mobile/features/menu/widgets/menu_icon.dart';

class LoyaltyProgramCard extends ConsumerWidget {
  const LoyaltyProgramCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loyaltyAsync = ref.watch(loyaltyProgramDataProvider);

    return loyaltyAsync.when(
      data: (data) {
        final goal = data.currentGoal;
        if (goal == null) {
          return const SizedBox.shrink();
        }

        return InfoCard(
          title: goal.title,
          subtitle: goal.periodText,
          icon: const MenuIcon(
            assetPath: 'assets/images/menu_loyalty_program.svg',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...goal.rewards.map((reward) => _buildRewardSection(reward)),
            ],
          ),
        );
      },
      loading: () => InfoCard(
        title: 'Программа лояльности',
        icon: const MenuIcon(
          assetPath: 'assets/images/menu_loyalty_program.svg',
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => InfoCard(
        title: 'Программа лояльности',
        icon: const MenuIcon(
          assetPath: 'assets/images/menu_loyalty_program.svg',
        ),
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

  Widget _buildRewardSection(Reward reward) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LevelHeader(
          icon: SvgPicture.asset(reward.iconAsset, width: 24, height: 24),
          text: reward.title,
          isLocked: !reward.isCompleted,
        ),
        if (reward.subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(
              reward.subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontFamily: 'Yandex Sans Text',
              ),
            ),
          ),
        ],
        if (reward.benefitItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: reward.benefitItems
                  .map(
                    (item) => _BenefitBadge(
                      text: item.value,
                      assetPath: 'assets/images/menu_loyalty_lock.svg',
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        if (reward.keyPerformanceIndicators.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...reward.keyPerformanceIndicators.map(
            (kpi) => Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: _RequirementRow(
                text: kpi.title,
                state: kpi.isCompleted
                    ? _RequirementState.completed
                    : _RequirementState.failed,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
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
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isLocked ? const Color(0xFF9E9E9E) : const Color(0xFF455A64),
            fontFamily: 'Yandex Sans Text',
          ),
        ),
      ],
    );
  }
}

class _BenefitBadge extends StatelessWidget {
  final String text;
  final String assetPath;

  const _BenefitBadge({required this.text, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8E8E93),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: SvgPicture.asset(
              assetPath,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
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

  const _RequirementRow({required this.text, required this.state});

  @override
  Widget build(BuildContext context) {
    String assetPath;

    switch (state) {
      case _RequirementState.completed:
        assetPath = 'assets/images/menu_accept.svg';
        break;
      case _RequirementState.failed:
        assetPath = 'assets/images/menu_reject.svg';
        break;
      case _RequirementState.neutral:
        assetPath = 'assets/images/menu_stuff.svg';
        break;
    }

    return Row(
      children: [
        SizedBox(width: 20, height: 20, child: SvgPicture.asset(assetPath)),
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
