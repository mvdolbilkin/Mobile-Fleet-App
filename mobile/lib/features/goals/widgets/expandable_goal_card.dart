import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/goals/models/goals_model.dart';

class ExpandableGoalCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Goal? goal;
  final bool isLoading;
  final String? error;

  const ExpandableGoalCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.goal,
    this.isLoading = false,
    this.error,
  });

  @override
  State<ExpandableGoalCard> createState() => _ExpandableGoalCardState();
}

class _ExpandableGoalCardState extends State<ExpandableGoalCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: widget.isLoading ? null : _toggleExpanded,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Yandex Sans Text',
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Yandex Sans Text',
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 32,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            if (widget.error != null)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      widget.error!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                        fontFamily: 'Yandex Sans Text',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else if (widget.goal != null)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...widget.goal!.rewards.map((reward) => _buildRewardSection(reward)),
                  ],
                ),
              ),
          ],
        ],
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
                      isLocked: !reward.isCompleted,
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
  final bool isLocked;

  const _BenefitBadge({
    required this.text,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFF8E8E93) : const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: SvgPicture.asset(
              isLocked
                  ? 'assets/images/menu_loyalty_lock.svg'
                  : 'assets/images/menu_accept.svg',
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
