import 'package:flutter/material.dart';
import 'package:mobile/features/work_rules/models/work_rule_model.dart';

class WorkRuleListItem extends StatelessWidget {
  final WorkRule workRule;
  final VoidCallback? onTap;

  const WorkRuleListItem({
    Key? key,
    required this.workRule,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workRule.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'Yandex Sans Text',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (workRule.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'По умолчанию',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'Yandex Sans Text',
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${workRule.contractorsCount} исполнителей',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Yandex Sans Text',
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
