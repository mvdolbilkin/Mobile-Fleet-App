import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/work_rules/models/work_rule_model.dart';
import 'package:mobile/features/work_rules/data/work_rules_repository.dart';

class WorkRuleDetailsScreen extends ConsumerWidget {
  final String workRuleId;
  final String workRuleName;

  const WorkRuleDetailsScreen({
    Key? key,
    required this.workRuleId,
    required this.workRuleName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final detailsAsync = ref.watch(workRuleDetailsProvider(workRuleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Условия работы'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: detailsAsync.when(
        data: (details) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название и статус
                _HeaderCard(details: details),
                
                const SizedBox(height: 16),

                // Комиссии
                _InfoCard(
                  title: 'Комиссии',
                  children: [
                    _InfoRow(
                      label: 'Базовая комиссия',
                      value: '${details.defaultCommission.percent}%',
                    ),
                    if (details.defaultCommission.fixed != '0') ...[
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'Фиксированная комиссия',
                        value: '${details.defaultCommission.fixed} ₽',
                      ),
                    ],
                    const Divider(height: 24),
                    _InfoRow(
                      label: 'Комиссия за субвенцию',
                      value: '${details.workRule.commissionForSubventionPercent}%',
                    ),
                    if (details.workRule.isDriverFixEnabled) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'Комиссия за фикс',
                        value: '${details.workRule.commissionForDriverFixPercent}%',
                      ),
                    ],
                    if (details.workRule.isWorkshiftEnabled) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'Комиссия за смену',
                        value: '${details.workRule.commissionForWorkshiftPercent}%',
                      ),
                    ],
                  ],
                ),

                if (details.commissionClauses?.newbies != null) ...[
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'Условия для новичков',
                    children: [
                      _InfoRow(
                        label: 'Период',
                        value: '${details.commissionClauses!.newbies!.days} дней',
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'Комиссия',
                        value: '${details.commissionClauses!.newbies!.percent}%',
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Настройки
                _InfoCard(
                  title: 'Настройки',
                  children: [
                    _SwitchRow(
                      label: 'Динамическая комиссия платформы',
                      value: details.workRule.isDynamicPlatformCommissionEnabled,
                    ),
                    const Divider(height: 24),
                    _SwitchRow(
                      label: 'Комиссия при отмене клиентом',
                      value: details.workRule.isCommissionForOrdersCancelledByClientEnabled,
                    ),
                    const Divider(height: 24),
                    _SwitchRow(
                      label: 'Комиссия если комиссия платформы null',
                      value: details.workRule.isCommissionIfPlatformCommissionIsNullEnabled,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Информация
                _InfoCard(
                  title: 'Информация',
                  children: [
                    _InfoRow(
                      label: 'Тип',
                      value: details.workRule.type == 'park' ? 'Парк' : details.workRule.type,
                    ),
                    if (details.workRule.typeDescription.isNotEmpty) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'Описание типа',
                        value: details.workRule.typeDescription,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка загрузки деталей',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Yandex Sans Text',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'Yandex Sans Text',
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(workRuleDetailsProvider(workRuleId));
                },
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final WorkRuleDetails details;

  const _HeaderCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  details.workRule.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'Yandex Sans Display',
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              if (details.workRule.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'По умолчанию',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: 'Yandex Sans Text',
                      color: theme.colorScheme.onPrimary,
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
                details.workRule.isEnabled ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: details.workRule.isEnabled
                    ? Colors.green
                    : theme.colorScheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                details.workRule.isEnabled ? 'Активно' : 'Неактивно',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Yandex Sans Text',
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              if (details.workRule.isArchived) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.archive,
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  'В архиве',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Yandex Sans Text',
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'Yandex Sans Display',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Yandex Sans Text',
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Yandex Sans Text',
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;

  const _SwitchRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Yandex Sans Text',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          value ? Icons.check_circle : Icons.cancel,
          size: 20,
          color: value ? Colors.green : theme.colorScheme.error,
        ),
      ],
    );
  }
}
