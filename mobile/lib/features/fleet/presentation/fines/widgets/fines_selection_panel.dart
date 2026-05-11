import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class FinesSelectionPanel extends StatelessWidget {
  final int selectedCount;
  final String totalFormatted;
  final String? paymentLink;

  const FinesSelectionPanel({
    super.key,
    required this.selectedCount,
    required this.totalFormatted,
    this.paymentLink,
  });

  String _fineWord(int n) {
    final mod100 = n % 100;
    final mod10 = n % 10;
    if (mod100 >= 11 && mod100 <= 19) return 'штрафов';
    if (mod10 == 1) return 'штраф';
    if (mod10 >= 2 && mod10 <= 4) return 'штрафа';
    return 'штрафов';
  }

  @override
  Widget build(BuildContext context) {
    final canPaySingle = selectedCount == 1 && paymentLink != null;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + bottomPad),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: count + amount
          Row(
            children: [
              Text(
                '$selectedCount ${_fineWord(selectedCount)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                totalFormatted,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: buttons side by side, equal height
          IntrinsicHeight(
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _PanelButton(
                  title: 'Оплатить через ЮMoney',
                  subtitle: canPaySingle ? 'Возможна комиссия' : 'Только единичные оплаты',
                  icon: Icons.open_in_new,
                  enabled: canPaySingle,
                  onTap: canPaySingle
                      ? () async {
                          final url = Uri.parse(paymentLink!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PanelButton(
                  title: 'Выгрузить в банк-клиент',
                  enabled: false,
                  onTap: null,
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

class _PanelButton extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _PanelButton({
    required this.title,
    this.subtitle,
    this.icon,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? const Color(0xFFF5F5F5) : const Color(0xFFF0F0F0);
    final textColor = enabled ? AppTheme.textPrimary : AppTheme.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 4),
                  Icon(icon, size: 14, color: textColor),
                ],
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 11,
                  color: enabled ? AppTheme.textSecondary : AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
