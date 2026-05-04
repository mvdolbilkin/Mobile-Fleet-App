import 'package:flutter/material.dart';
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
      initialChildSize: 0.75,
      minChildSize: 0.4,
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Штраф',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.1),
                    ),
                    const SizedBox(height: 20),

                    // Amount
                    Text(
                      formatMoney(fd.payment),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // UIN
                    _DetailRow(label: 'Постановление (УИН)', value: fd.uin),

                    // Article
                    if (fd.article != null)
                      _DetailRow(label: 'Вид', value: fd.article!),

                    // Status + Payment button
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 140,
                          child: Text(
                            'Статус оплаты',
                            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.3),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fd.statusDisplayName,
                                style: const TextStyle(fontSize: 14, height: 1.3),
                              ),
                              if (fd.paymentLink != null) ...[
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final url = Uri.parse(fd.paymentLink!);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.buttonColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Оплатить через ЮMoney',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 18,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Vehicle
                    if (detail.vehicle != null)
                      _InfoRow(
                        icon: Icons.directions_car_outlined,
                        label: detail.vehicle!.displayName,
                        sublabel: detail.vehicle!.licensePlate,
                      ),

                    // Driver
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: detail.contractor.displayName,
                      sublabel: detail.contractor.name ?? 'Водитель',
                    ),

                    const SizedBox(height: 8),

                    // Action buttons
                    _ActionButton(
                      label: 'Провести списание с баланса водителя',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _ActionButton(
                      label: 'Назначить исполнителя',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _ActionButton(
                      label: 'Удалить водителя',
                      onTap: () {},
                      isDestructive: true,
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Dates & location
                    _DetailRow(
                      label: 'Дата и время нарушения',
                      value: _formatDateTime(fd.offenseAt),
                    ),
                    _DetailRow(
                      label: 'Дата и время постановления',
                      value: _formatDateTime(fd.issuedAt),
                    ),
                    if (fd.offenseAddress != null)
                      _DetailRow(label: 'Место', value: fd.offenseAddress!),
                    if (fd.issuedBy != null)
                      _DetailRow(label: 'Орган власти', value: fd.issuedBy!),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.3),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                if (sublabel != null)
                  Text(
                    sublabel!,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDestructive ? Colors.red.shade200 : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDestructive ? Colors.red.shade700 : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
