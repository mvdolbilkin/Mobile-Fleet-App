import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/competitions/models/competition_model.dart';

class CompetitionListItem extends StatelessWidget {
  final Competition competition;
  final VoidCallback? onTap;

  const CompetitionListItem({
    Key? key,
    required this.competition,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy');

    Color statusColor;
    Color statusBackgroundColor;
    
    if (competition.isActive) {
      statusColor = Colors.green.shade700;
      statusBackgroundColor = Colors.green.withOpacity(0.1);
    } else if (competition.isCompleted) {
      statusColor = Colors.blue.shade700;
      statusBackgroundColor = Colors.blue.withOpacity(0.1);
    } else if (competition.isCancelled) {
      statusColor = Colors.grey.shade700;
      statusBackgroundColor = Colors.grey.withOpacity(0.1);
    } else {
      statusColor = Colors.red.shade700;
      statusBackgroundColor = Colors.red.withOpacity(0.1);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
                  Expanded(
                    child: Text(
                      competition.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'Yandex Sans Text',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      competition.statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'Yandex Sans Text',
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(competition.competitionPeriod.beginDate.toLocal())} - ${dateFormat.format(competition.competitionPeriod.endDate.toLocal())}',
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
