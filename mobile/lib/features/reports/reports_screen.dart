import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile/features/reports/payment_summary_screen.dart';
import 'package:mobile/features/reports/payment_transactions_screen.dart';
import 'package:mobile/features/reports/summary_report_screen.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчёты'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _SectionHeader(title: 'ОБЩИЕ'),
          _SectionCard(
            children: [
              _MenuRow(
                title: 'Сводные отчёты',
                icon: HugeIcons.strokeRoundedAnalytics02,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SummaryReportScreen(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _SectionHeader(title: 'ФИНАНСЫ'),
          _SectionCard(
            children: [
              _MenuRow(
                title: 'Экономика парка',
                icon: HugeIcons.strokeRoundedPiggyBank,
                onTap: () {},
              ),
              const _RowDivider(),
              _MenuRow(
                title: 'Транзакционный счёт',
                icon: HugeIcons.strokeRoundedTransaction,
                onTap: () {},
              ),
              const _RowDivider(),
              _MenuRow(
                title: 'Сводка по расчётам с исполнителями',
                icon: HugeIcons.strokeRoundedBarChart,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PaymentSummaryScreen(),
                  ),
                ),
              ),
              const _RowDivider(),
              _MenuRow(
                title: 'Отчёт по расчётам с исполнителями',
                icon: HugeIcons.strokeRoundedInvoice,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PaymentTransactionsScreen(),
                  ),
                ),
              ),
              const _RowDivider(),
              _MenuRow(
                title: 'Расчёты',
                icon: HugeIcons.strokeRoundedCalculator,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.8,
          fontFamily: 'Yandex Sans Text',
        ),
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
