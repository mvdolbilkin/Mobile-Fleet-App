import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/goals/providers/goals_provider.dart';
import 'package:mobile/features/goals/widgets/expandable_goal_card.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGoalsAsync = ref.watch(currentGoalsProvider);
    final previousGoalsAsync = ref.watch(previousGoalsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Цели'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentGoalsProvider);
            ref.invalidate(previousGoalsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Goals Section
                currentGoalsAsync.when(
                  data: (data) {
                    final goal = data.goals.isNotEmpty ? data.goals.first : null;
                    return ExpandableGoalCard(
                      title: 'Текущие цели',
                      subtitle: goal?.periodText ?? 'Нет данных',
                      goal: goal,
                    );
                  },
                  loading: () => const ExpandableGoalCard(
                    title: 'Текущие цели',
                    subtitle: 'Загрузка...',
                    isLoading: true,
                  ),
                  error: (error, stack) => ExpandableGoalCard(
                    title: 'Текущие цели',
                    subtitle: 'Ошибка загрузки',
                    error: 'Не удалось загрузить данные',
                  ),
                ),
                
                // Previous Goals Section
                previousGoalsAsync.when(
                  data: (data) {
                    final goal = data.goals.isNotEmpty ? data.goals.first : null;
                    return ExpandableGoalCard(
                      title: 'Предыдущие цели',
                      subtitle: goal?.periodText ?? 'Нет данных',
                      goal: goal,
                    );
                  },
                  loading: () => const ExpandableGoalCard(
                    title: 'Предыдущие цели',
                    subtitle: 'Загрузка...',
                    isLoading: true,
                  ),
                  error: (error, stack) => ExpandableGoalCard(
                    title: 'Предыдущие цели',
                    subtitle: 'Ошибка загрузки',
                    error: 'Не удалось загрузить данные',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
