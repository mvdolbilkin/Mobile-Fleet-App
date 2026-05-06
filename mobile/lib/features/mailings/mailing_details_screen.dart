import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/mailings/models/mailing_model.dart';
import 'package:mobile/features/mailings/data/mailings_repository.dart';

class MailingDetailsScreen extends ConsumerWidget {
  final String mailingId;
  final Mailing mailing;

  const MailingDetailsScreen({
    Key? key,
    required this.mailingId,
    required this.mailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final detailsAsync = ref.watch(mailingDetailsProvider(mailingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали рассылки'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: detailsAsync.when(
        data: (details) {
          final summary = details.mailingSummary;
          final template = details.mailingTemplate;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Статус
                _StatusCard(mailing: summary),
                
                const SizedBox(height: 16),

                // Заголовок и текст рассылки
                _InfoCard(
                  title: 'Сообщение',
                  children: [
                    Text(
                      template.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'Yandex Sans Text',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MarkdownBody(
                      data: template.message,
                      styleSheet: MarkdownStyleSheet(
                        p: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Yandex Sans Text',
                        ),
                        strong: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Yandex Sans Text',
                          fontWeight: FontWeight.bold,
                        ),
                        em: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Yandex Sans Text',
                          fontStyle: FontStyle.italic,
                        ),
                        h1: theme.textTheme.headlineLarge?.copyWith(
                          fontFamily: 'Yandex Sans Text',
                        ),
                        h2: theme.textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Yandex Sans Text',
                        ),
                        h3: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: 'Yandex Sans Text',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Основная информация
                _InfoCard(
                  title: 'Основная информация',
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Автор',
                      value: summary.author,
                    ),
                    if (summary.sentToNumber != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.people_outline,
                        label: 'Отправлено',
                        value: '${summary.sentToNumber} получателям',
                      ),
                    ],
                    if (summary.sentAt != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.access_time,
                        label: 'Дата отправки',
                        value: dateFormat.format(summary.sentAt!.toLocal()),
                      ),
                    ],
                    if (summary.readByNumber != null && summary.readPercent != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.visibility_outlined,
                        label: 'Прочитано',
                        value: '${summary.readByNumber} (${summary.readPercent}%)',
                      ),
                    ],
                  ],
                ),

                if (summary.isDeleted) ...[
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'Информация об удалении',
                    children: [
                      if (summary.deletedBy != null)
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Удалил',
                          value: summary.deletedBy!,
                        ),
                      if (summary.deletedAt != null) ...[
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.access_time,
                          label: 'Дата удаления',
                          value: dateFormat.format(summary.deletedAt!.toLocal()),
                        ),
                      ],
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Дополнительная информация
                _InfoCard(
                  title: 'Дополнительно',
                  children: [
                    _InfoRow(
                      icon: Icons.tag,
                      label: 'Тип',
                      value: summary.type,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.fingerprint,
                      label: 'ID рассылки',
                      value: summary.id,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.fingerprint,
                      label: 'ID операции',
                      value: template.operationId,
                    ),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(mailingDetailsProvider(mailingId));
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
  final Mailing mailing;

  const _StatusCard({required this.mailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (mailing.isDeleted) {
      backgroundColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red.shade700;
      icon = Icons.delete_outline;
    } else {
      backgroundColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green.shade700;
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Text(
            mailing.statusText,
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontFamily: 'Yandex Sans Text',
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
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'Yandex Sans Text',
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
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'Yandex Sans Text',
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
