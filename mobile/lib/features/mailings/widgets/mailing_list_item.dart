import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/mailings/models/mailing_model.dart';

class MailingListItem extends StatelessWidget {
  final Mailing mailing;
  final VoidCallback onTap;

  const MailingListItem({
    Key? key,
    required this.mailing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mailing.preview,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Yandex Sans Text',
                      decoration: mailing.isDeleted 
                          ? TextDecoration.lineThrough 
                          : null,
                      color: mailing.isDeleted
                          ? theme.colorScheme.onSurfaceVariant
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: mailing.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  mailing.author,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'Yandex Sans Text',
                  ),
                ),
                const SizedBox(width: 16),
                if (mailing.sentToNumber != null) ...[
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${mailing.sentToNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                ],
              ],
            ),
            if (mailing.sentAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(mailing.sentAt!.toLocal()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                ],
              ),
            ],
            if (mailing.readByNumber != null && mailing.readPercent != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Прочитано: ${mailing.readByNumber} (${mailing.readPercent}%)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                ],
              ),
            ],
            if (mailing.isDeleted && mailing.deletedBy != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Удалено: ${mailing.deletedBy}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case 'sent':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        text = 'Отправлено';
        break;
      case 'deleted_by_dispatcher':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red.shade700;
        text = 'Удалено';
        break;
      default:
        backgroundColor = theme.colorScheme.surfaceVariant;
        textColor = theme.colorScheme.onSurfaceVariant;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontFamily: 'Yandex Sans Text',
        ),
      ),
    );
  }
}
