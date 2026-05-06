import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile/shared/widgets/fading_button.dart';
import 'package:mobile/features/staff/staff_list_screen.dart';
import 'package:mobile/features/mailings/mailings_screen.dart';
import 'package:mobile/features/competitions/competitions_screen.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Персонал'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _SectionCard(
            children: [
              _MenuRow(
                title: 'Исполнители',
                subtitle: 'Список всех исполнителей',
                icon: HugeIcons.strokeRoundedUserMultiple,
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) => const StaffListScreen())),
              ),
              const _RowDivider(),
              _MenuRow(
                title: 'Турниры',
                subtitle: 'Соревнования и награды',
                icon: HugeIcons.strokeRoundedAward01,
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) => const CompetitionsScreen())),
              ),
              const _RowDivider(),
              _MenuRow(
                title: 'Рассылки',
                subtitle: 'Уведомления и сообщения',
                icon: HugeIcons.strokeRoundedMail01,
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (_) => const MailingsScreen())),
              ),
              const _RowDivider(),
              _MenuRow(
                title: 'Условия работы',
                subtitle: 'Тарифы и графики',
                icon: HugeIcons.strokeRoundedSettings02,
                onTap: () {
                  // TODO: Navigate to work conditions
                },
              ),
              const _RowDivider(),
              _MenuRow(
                title: 'Отчет по привлечению',
                subtitle: 'Статистика и показатели',
                icon: HugeIcons.strokeRoundedAnalytics02,
                onTap: () {
                  // TODO: Navigate to recruitment report
                },
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final dynamic icon;
  final VoidCallback onTap;

  const _MenuRow({
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurfaceVariant;

    return FadingButton(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            HugeIcon(
              icon: icon,
              color: iconColor,
              size: 24,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'Yandex Sans Text',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.outline.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
