import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/presentation/regular_charges/regular_charges_models.dart';
import 'package:mobile/shared/widgets/badge.dart';

class RegularChargeDetailSheet extends StatelessWidget {
  final RegularCharge charge;
  final String stateLabel;
  final BadgeType badgeType;

  const RegularChargeDetailSheet({
    Key? key,
    required this.charge,
    required this.stateLabel,
    required this.badgeType,
  }) : super(key: key);

  static void show({
    required BuildContext context,
    required RegularCharge charge,
    required String stateLabel,
    required BadgeType badgeType,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => RegularChargeDetailSheet(
        charge: charge,
        stateLabel: stateLabel,
        badgeType: badgeType,
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '—';
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatMoney(String? value) {
    if (value == null || value.isEmpty) return '0 ₽';
    final val = double.tryParse(value);
    if (val == null) return '$value ₽';
    final isNegative = val < 0;
    final abs = val.abs();
    final whole = abs.truncate();
    final frac = ((abs - whole) * 100).round().toString().padLeft(2, '0');
    final wholeStr = whole.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '\u00A0',
    );
    return '${isNegative ? '-' : ''}$wholeStr,$frac ₽';
  }

  Color _getDriverColor(String lastName) {
    final colors = [
      Colors.red.shade900,
      Colors.orange.shade700,
      Colors.blue.shade800,
      Colors.green.shade800,
      Colors.purple.shade900,
      Colors.brown.shade800,
      Colors.pink.shade300,
      const Color(0xFF6B7280),
    ];
    if (lastName.isEmpty) return colors[0];
    return colors[lastName.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final driver = charge.driver;
    final car = charge.asset.car;
    final agg = charge.aggregate;

    final initials = () {
      final f = driver.firstName.isNotEmpty ? driver.firstName[0] : '';
      final l = driver.lastName.isNotEmpty ? driver.lastName[0] : '';
      final r = (f + l).toUpperCase();
      return r.isEmpty ? '?' : r;
    }();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Списание #${charge.serialId}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Yandex Sans Text',
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.close, size: 18, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Status badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CustomBadge(type: badgeType, text: stateLabel),
                const Spacer(),
                Text(
                  _formatMoney(charge.charging.dailyPrice),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Yandex Sans Text',
                    color: AppTheme.textPrimary,
                    fontFeatures: [FontFeature.liningFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Driver + car
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _getDriverColor(driver.lastName),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.fullName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Yandex Sans Text',
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (car != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${car.displayName}${car.number != null ? ' · ${car.number}' : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Yandex Sans Text',
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Scrollable details
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16, 0, 16, 16 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  _buildSection('Даты', [
                    _DetailRow('Дата создания', _formatDate(charge.dateFrom)),
                    _DetailRow('Дата начала списания', _formatDate(charge.chargingAt)),
                    _DetailRow('Дата завершения', _formatDate(charge.dateTo ?? charge.terminatedAt)),
                  ]),

                  const SizedBox(height: 12),

                  _buildSection('Финансы', [
                    _DetailRow('Начислено', _formatMoney(agg != null ? _sumStrings(agg.withhold, agg.withdraw) : null)),
                    _DetailRow('Удержано', _formatMoney(agg?.withdraw)),
                    _DetailRow('К удержанию', _formatMoney(agg?.withhold)),
                    _DetailRow('Отменено', _formatMoney(agg?.cancel)),
                    _DetailRow('Баланс водителя', _formatMoney(driver.balance)),
                    if (charge.notificationLimit != null && charge.notificationLimit!.isNotEmpty)
                      _DetailRow('Лимит для уведомлений', _formatMoney(charge.notificationLimit)),
                  ]),

                  const SizedBox(height: 12),

                  _buildSection('Списание', [
                    _DetailRow('За что', charge.charging.typeLabel),
                    if (charge.charging.periodicity != null)
                      _DetailRow('Алгоритм списания', charge.charging.periodicity!.label),
                    if (charge.comment != null && charge.comment!.isNotEmpty)
                      _DetailRow('Комментарий', charge.comment!),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _sumStrings(String a, String b) {
    final va = double.tryParse(a);
    final vb = double.tryParse(b);
    if (va == null && vb == null) return null;
    return ((va ?? 0) + (vb ?? 0)).toString();
  }

  Widget _buildSection(String title, List<_DetailRow> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Yandex Sans Text',
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          ...rows.map((row) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    row.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Yandex Sans Text',
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(
                    row.value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Yandex Sans Text',
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;
  _DetailRow(this.label, this.value);
}
