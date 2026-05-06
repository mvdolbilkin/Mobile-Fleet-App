import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/competitions/models/competition_model.dart';
import 'package:mobile/features/competitions/data/competitions_repository.dart';

class CompetitionDetailsScreen extends ConsumerWidget {
  final String competitionId;
  final String competitionName;

  const CompetitionDetailsScreen({
    Key? key,
    required this.competitionId,
    required this.competitionName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final detailsAsync = ref.watch(competitionDetailsProvider(competitionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали турнира'),
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
                _StatusCard(details: details),
                
                const SizedBox(height: 16),

                // Основная информация
                _InfoCard(
                  title: 'Основная информация',
                  children: [
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Период',
                      value: '${dateFormat.format(details.competitionPeriod.beginDate.toLocal())} - ${dateFormat.format(details.competitionPeriod.endDate.toLocal())}',
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.people_outline,
                      label: 'Участников',
                      value: '${details.participantsCount}',
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.emoji_events_outlined,
                      label: 'Победителей',
                      value: '${details.winnerCount}',
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.payment_outlined,
                      label: 'Призы выплачены',
                      value: details.prizePaid ? 'Да' : 'Нет',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Условия турнира
                _InfoCard(
                  title: 'Условия',
                  children: [
                    _InfoRow(
                      icon: Icons.category_outlined,
                      label: 'Тип',
                      value: details.specification == 'delivery' ? 'Доставка' : details.specification,
                    ),
                    if (details.geoareasList.isNotEmpty) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Регионы',
                        value: details.geoareasList.map((e) => e.localizedName).join(', '),
                      ),
                    ],
                    if (details.professionsList.isNotEmpty) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.work_outline,
                        label: 'Профессии',
                        value: details.professionsList.map((e) => e.localizedName).join(', '),
                      ),
                    ],
                  ],
                ),

                if (details.winnersParticipantList.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _WinnersCard(winners: details.winnersParticipantList),
                ],
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(competitionDetailsProvider(competitionId));
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

class _StatusCard extends StatelessWidget {
  final CompetitionDetails details;

  const _StatusCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (details.isActive) {
      backgroundColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green.shade700;
      icon = Icons.play_circle_outline;
    } else if (details.isCompleted) {
      backgroundColor = Colors.blue.withOpacity(0.1);
      textColor = Colors.blue.shade700;
      icon = Icons.check_circle_outline;
    } else {
      backgroundColor = Colors.grey.withOpacity(0.1);
      textColor = Colors.grey.shade700;
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'Yandex Sans Text',
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details.statusText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Yandex Sans Text',
                    color: textColor,
                  ),
                ),
              ],
            ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'Yandex Sans Text',
              fontWeight: FontWeight.w600,
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
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'Yandex Sans Text',
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Yandex Sans Text',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WinnersCard extends StatelessWidget {
  final List<Winner> winners;

  const _WinnersCard({required this.winners});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber.shade700,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Победители',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Yandex Sans Text',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...winners.asMap().entries.map((entry) {
            final index = entry.key;
            final winner = entry.value;
            return Column(
              children: [
                if (index > 0) const Divider(height: 24),
                _WinnerRow(winner: winner),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _WinnerRow extends StatelessWidget {
  final Winner winner;

  const _WinnerRow({required this.winner});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color rankColor;
    IconData rankIcon;

    switch (winner.rank) {
      case 1:
        rankColor = Colors.amber.shade700;
        rankIcon = Icons.looks_one;
        break;
      case 2:
        rankColor = Colors.grey.shade600;
        rankIcon = Icons.looks_two;
        break;
      case 3:
        rankColor = Colors.brown.shade600;
        rankIcon = Icons.looks_3;
        break;
      default:
        rankColor = Colors.grey.shade600;
        rankIcon = Icons.emoji_events_outlined;
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: winner.rank <= 3
                ? Icon(rankIcon, color: rankColor, size: 24)
                : Text(
                    '${winner.rank}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'Yandex Sans Text',
                      fontWeight: FontWeight.w600,
                      color: rankColor,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                winner.driverName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Yandex Sans Text',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Баллы: ${winner.score}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'Yandex Sans Text',
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        if (winner.prize?.amount != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${winner.prize!.amount} ₽',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Yandex Sans Text',
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ),
      ],
    );
  }
}
