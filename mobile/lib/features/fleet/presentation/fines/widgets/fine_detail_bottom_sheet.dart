import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/domain/traffic_fine.dart';
import 'package:url_launcher/url_launcher.dart';

class FineDetailBottomSheet extends StatelessWidget {
  final Future<TrafficFine> future;
  final String Function(String) formatMoney;
  final String Function(DateTime) formatDate;
  final TrafficFine fallbackFine;

  const FineDetailBottomSheet({
    super.key,
    required this.future,
    required this.formatMoney,
    required this.formatDate,
    required this.fallbackFine,
  });

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    final months = [
      '', 'янв.', 'февр.', 'мар.', 'апр.', 'мая', 'июня',
      'июля', 'авг.', 'сент.', 'окт.', 'нояб.', 'дек.',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year} г., '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: FutureBuilder<TrafficFine>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              }

              final detail = snapshot.data ?? fallbackFine;
              final fd = detail.fine;

              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Штраф',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close, size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Amount
                    _DetailItem(
                      label: 'Сумма',
                      value: formatMoney(fd.payment),
                    ),

                    // UIN
                    _DetailItem(
                      label: 'Постановление (УИН)',
                      value: fd.uin,
                      trailing: GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: fd.uin));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('УИН скопирован')),
                          );
                        },
                        child: const Icon(Icons.copy_outlined, size: 20, color: Colors.black),
                      ),
                    ),

                    // Article
                    if (fd.article != null)
                      _DetailItem(
                        label: 'Вид',
                        value: fd.article!,
                        valueMaxLines: 3,
                      ),

                    // Status / Payment button
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'Статус оплаты',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.3),
                      ),
                    ),
                    if (fd.paymentLink != null)
                      GestureDetector(
                        onTap: () async {
                          final url = Uri.parse(fd.paymentLink!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD400), // Яндекс Деньги / ЮMoney yellow
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Оплатить через ЮMoney',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.open_in_new, size: 18, color: Colors.black),
                            ],
                          ),
                        ),
                      )
                    else
                      Text(
                        fd.statusDisplayName,
                        style: const TextStyle(fontSize: 16, color: Colors.black, height: 1.3),
                      ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 24),

                    // Vehicle
                    if (detail.vehicle != null)
                      _NavigationItem(
                        label: 'Автомобиль',
                        title: detail.vehicle!.brand,
                        subtitle: detail.vehicle!.model,
                      ),

                    // Driver
                    _NavigationItem(
                      label: 'Водитель',
                      title: detail.contractor.displayName,
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    _ActionButton(
                      label: 'Провести списание с баланса водителя',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _ActionButton(
                              label: 'Назначить исполнителя',
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              label: 'Удалить водителя',
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 24),

                    // Dates & location
                    _DetailItem(
                      label: 'Дата и время нарушения',
                      value: _formatDateTime(fd.offenseAt),
                    ),
                    _DetailItem(
                      label: 'Дата и время постановления',
                      value: _formatDateTime(fd.issuedAt),
                    ),
                    if (fd.offenseAddress != null)
                      _DetailItem(
                        label: 'Место',
                        value: fd.offenseAddress!,
                        valueMaxLines: 4,
                      ),
                    if (fd.issuedBy != null)
                      _DetailItem(
                        label: 'Орган власти',
                        value: fd.issuedBy!,
                        valueMaxLines: 3,
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  final int valueMaxLines;

  const _DetailItem({
    required this.label,
    required this.value,
    this.trailing,
    this.valueMaxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black, height: 1.3),
                  maxLines: valueMaxLines,
                  overflow: valueMaxLines == 1 ? TextOverflow.ellipsis : null,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final String label;
  final String title;
  final String? subtitle;

  const _NavigationItem({
    required this.label,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, color: Colors.black, height: 1.3, fontFamily: 'Roboto'), // or your default font
                    children: [
                      TextSpan(text: title),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        TextSpan(
                          text: ' $subtitle',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 24, color: Colors.black54),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
