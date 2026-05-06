import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/work_rules/data/work_rules_repository.dart';
import 'package:mobile/features/work_rules/widgets/work_rule_list_item.dart';
import 'package:mobile/features/work_rules/work_rule_details_screen.dart';

class WorkRulesScreen extends ConsumerStatefulWidget {
  const WorkRulesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkRulesScreen> createState() => _WorkRulesScreenState();
}

class _WorkRulesScreenState extends ConsumerState<WorkRulesScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workRulesAsync = ref.watch(workRulesProvider(_showArchived));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Условия работы'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Toggle for active/archived
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _ToggleButton(
                    label: 'Активные',
                    isSelected: !_showArchived,
                    onTap: () {
                      setState(() {
                        _showArchived = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ToggleButton(
                    label: 'Архивные',
                    isSelected: _showArchived,
                    onTap: () {
                      setState(() {
                        _showArchived = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: workRulesAsync.when(
              data: (response) {
                if (response.workRules.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showArchived
                              ? 'Нет архивных условий работы'
                              : 'Нет активных условий работы',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'Yandex Sans Text',
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(workRulesProvider(_showArchived));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: response.workRules.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final workRule = response.workRules[index];
                      return WorkRuleListItem(
                        workRule: workRule,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => WorkRuleDetailsScreen(
                                workRuleId: workRule.id,
                                workRuleName: workRule.name,
                              ),
                            ),
                          );
                        },
                      );
                    },
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
                      'Ошибка загрузки условий работы',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'Yandex Sans Text',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'Yandex Sans Text',
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(workRulesProvider(_showArchived));
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected ? Colors.black : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Yandex Sans Text',
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
