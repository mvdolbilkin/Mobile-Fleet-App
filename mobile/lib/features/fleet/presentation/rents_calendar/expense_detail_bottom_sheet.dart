import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/presentation/rents_calendar/rents_calendar_models.dart';
import 'package:mobile/features/fleet/presentation/rents_calendar/rents_repository.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class ExpenseDetailBottomSheet extends ConsumerStatefulWidget {
  final RentInfo rent;
  final RentDriver? driver;
  final VehicleWithRents vehicle;
  final DateTime cellDate;

  const ExpenseDetailBottomSheet({
    Key? key,
    required this.rent,
    required this.driver,
    required this.vehicle,
    required this.cellDate,
  }) : super(key: key);

  static void show({
    required BuildContext context,
    required RentInfo rent,
    required RentDriver? driver,
    required VehicleWithRents vehicle,
    required DateTime cellDate,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ExpenseDetailBottomSheet(
        rent: rent,
        driver: driver,
        vehicle: vehicle,
        cellDate: cellDate,
      ),
    );
  }

  @override
  ConsumerState<ExpenseDetailBottomSheet> createState() =>
      _ExpenseDetailBottomSheetState();
}

class _ExpenseDetailBottomSheetState
    extends ConsumerState<ExpenseDetailBottomSheet> {
  bool _isLoadingBalance = true;
  double? _todayBalance;

  @override
  void initState() {
    super.initState();
    if (!_isFuture) {
      _loadBalance();
    } else {
      _isLoadingBalance = false;
    }
  }

  Future<void> _loadBalance() async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final yesterdayEnd =
          DateTime(today.year, today.month, today.day - 1, 23, 59, 59, 999);

      final response =
          await ref.read(rentsRepositoryProvider).getDriverBalanceHistory(
                driverId: widget.rent.driverId,
                dateFrom: yesterdayEnd,
                dateTo: todayStart,
              );

      if (!mounted) return;
      setState(() {
        _todayBalance = response.balances.isNotEmpty
            ? response.balances.first.balance
            : 0.0;
        _isLoadingBalance = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _todayBalance = null;
        _isLoadingBalance = false;
      });
    }
  }

  String _formatBalance(double? value) {
    if (value == null) return '—';
    final isNegative = value < 0;
    final abs = value.abs();
    final whole = abs.truncate();
    final frac = ((abs - whole) * 100).round().toString().padLeft(2, '0');
    final wholeStr = whole
        .toString()
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => '\u00A0',
        );
    return '${isNegative ? '-' : ''}$wholeStr,$frac \u20BD';
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

  String get _initials {
    final d = widget.driver;
    if (d == null) return '?';
    final first =
        (d.firstName != null && d.firstName!.isNotEmpty) ? d.firstName![0] : '';
    final last =
        (d.lastName != null && d.lastName!.isNotEmpty) ? d.lastName![0] : '';
    final result = (first + last).toUpperCase();
    return result.isEmpty ? '?' : result;
  }

  String get _driverFullName {
    final d = widget.driver;
    if (d == null) return '—';
    return [d.lastName, d.firstName, d.middleName]
        .where((p) => p != null && p.isNotEmpty)
        .join(' ')
        .trim()
        .let((s) => s.isEmpty ? '—' : s);
  }

  String get _vehicleInfo {
    final brand = widget.vehicle.brand ?? '';
    final model = widget.vehicle.model ?? '';
    final number = widget.vehicle.number ?? '';
    final carName = [brand, model].where((s) => s.isNotEmpty).join(' ');
    if (carName.isNotEmpty && number.isNotEmpty) return '$carName · $number';
    if (carName.isNotEmpty) return carName;
    return number;
  }

  bool get _isFuture {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    return widget.cellDate.isAfter(todayStart);
  }

  @override
  Widget build(BuildContext context) {
    final lastName = widget.driver?.lastName ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _isFuture ? 'Списание ожидается' : 'Списание выполнено',
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
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _getDriverColor(lastName),
                child: Text(
                  _initials,
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
                      _driverFullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Yandex Sans Text',
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _vehicleInfo,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Yandex Sans Text',
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.rent.dailyPrice} \u20BD',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Yandex Sans Text',
                  color: AppTheme.textSecondary,
                  fontFeatures: [FontFeature.liningFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!_isFuture) ...[
            if (_isLoadingBalance)
              Row(
                children: const [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Загрузка баланса...',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Yandex Sans Text',
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              )
            else
              Text(
                'Сегодня на балансе ${_formatBalance(_todayBalance)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Yandex Sans Text',
                  color: AppTheme.textPrimary,
                ),
              ),
            const SizedBox(height: 28),
          ] else
            const SizedBox(height: 28),
          FadingButton(
            onTap: () {
              // TODO: Navigate to income history
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.buttonColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'История дохода',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Yandex Sans Text',
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.open_in_new, size: 18, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
