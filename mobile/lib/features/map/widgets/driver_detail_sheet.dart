import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/staff/domain/staff.dart';
import 'package:mobile/features/staff/staff_details_screen.dart';
import 'package:mobile/features/map/data/map_repository.dart';
import 'package:mobile/features/map/domain/map_driver.dart';

class DriverDetailSheet extends ConsumerStatefulWidget {
  final String driverId;
  final void Function(MapCoordinates) onPositionUpdate;
  final VoidCallback onClose;

  const DriverDetailSheet({
    required this.driverId,
    required this.onPositionUpdate,
    required this.onClose,
    super.key,
  });

  @override
  ConsumerState<DriverDetailSheet> createState() => _DriverDetailSheetState();
}

class _DriverDetailSheetState extends ConsumerState<DriverDetailSheet> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      try {
        final repo = ref.read(mapRepositoryProvider);
        final item = await repo.fetchDriverItem(widget.driverId);
        if (item.coordinates != null && mounted) {
          widget.onPositionUpdate(item.coordinates!);
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(driverItemProvider(widget.driverId));
    final historyAsync =
        ref.watch(driverStatusHistoryProvider(widget.driverId));

    return DraggableScrollableSheet(
      initialChildSize: 0.50,
      minChildSize: 0.12,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.12, 0.50, 0.92],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: itemAsync.when(
            data: (item) =>
                _buildContent(context, scrollController, item, historyAsync),
            loading: () => ListView(
              controller: scrollController,
              children: [
                _buildHandleRow(),
                const SizedBox(height: 40),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
            error: (e, _) => ListView(
              controller: scrollController,
              children: [
                _buildHandleRow(),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Ошибка загрузки',
                    style: TextStyle(
                      fontFamily: 'Yandex Sans Text',
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Staff _toStaff(MapDriverItemDriver d) {
    StaffStatus status;
    switch (d.status) {
      case 'free':
        status = StaffStatus.free;
        break;
      case 'in_order':
        status = StaffStatus.onOrder;
        break;
      case 'busy':
        status = StaffStatus.busy;
        break;
      default:
        status = StaffStatus.offline;
    }
    final parts = d.fullName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (parts.isNotEmpty ? parts[0][0].toUpperCase() : '?');
    final h = d.statusDurationSeconds ~/ 3600;
    final m = (d.statusDurationSeconds % 3600) ~/ 60;
    final timeOnShift = h > 0 ? '${h}ч ${m}м' : '${m}м';
    return Staff(
      id: d.id,
      name: d.fullName,
      initials: initials,
      status: status,
      timeOnShift: timeOnShift,
      phoneNumber: d.phone,
      avatarUrl: d.avatarUrl ?? '',
      balance: '${d.balance.toStringAsFixed(2)} ₽',
    );
  }

  Widget _defaultAvatar() => Container(
        width: 48,
        height: 48,
        color: AppTheme.controlsColor,
        child: const Icon(Icons.person, color: Color(0xFF9E9B98), size: 28),
      );

  Widget _buildHandleRow() {
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.controlsColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Positioned(
            right: 4,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.controlsColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ScrollController scrollController,
    MapDriverItemResponse item,
    AsyncValue<MapDriverStatusHistoryResponse> historyAsync,
  ) {
    final driver = item.driver;
    final vehicle = item.vehicle;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _buildHandleRow(),
        // Driver card
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StaffDetailsScreen(staff: _toStaff(driver)),
            ),
          ),
          child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: driver.avatarUrl != null
                    ? Image.network(
                        driver.avatarUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _defaultAvatar(),
                      )
                    : _defaultAvatar(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.fullName,
                      style: const TextStyle(
                        fontFamily: 'Yandex Sans Text',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      driver.statusDurationLabel,
                      style: const TextStyle(
                        fontFamily: 'Yandex Sans Text',
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _StatusDot(status: driver.status),
                        const SizedBox(width: 5),
                        Text(
                          driver.balanceFormatted,
                          style: const TextStyle(
                            fontFamily: 'Yandex Sans Text',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (vehicle?.number != null) ...[
                          const Text(
                            ' · ',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.textSecondary),
                          ),
                          Text(
                            vehicle!.number!,
                            style: const TextStyle(
                              fontFamily: 'Yandex Sans Text',
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (driver.phone.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${driver.phone} · ${driver.license}',
                        style: const TextStyle(
                          fontFamily: 'Yandex Sans Text',
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.open_in_new,
                  size: 18, color: AppTheme.textSecondary),
            ],
          ),
        ),
        ),
        const SizedBox(height: 12),
        // Orders button
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.controlsColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Перейти к заказам',
              style: TextStyle(
                fontFamily: 'Yandex Sans Text',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Status history
        const Text(
          'Статусы за 24ч.',
          style: TextStyle(
            fontFamily: 'Yandex Sans Text',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        historyAsync.when(
          data: (history) => Column(
            children: [
              for (final hi in history.items) ...[
                const Divider(height: 1, color: Color(0xFFE8E5E0)),
                _StatusHistoryRow(item: hi),
              ],
              if (history.items.isNotEmpty)
                const Divider(height: 1, color: Color(0xFFE8E5E0)),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// Status dot

class _StatusDot extends StatelessWidget {
  final String status;

  const _StatusDot({required this.status});

  Color get _color {
    switch (status) {
      case 'free':
        return AppTheme.statusGreen;
      case 'in_order':
        return AppTheme.statusOrange;
      case 'busy':
        return const Color(0xFFFF6B3D);
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}

// Status history row

class _StatusHistoryRow extends StatelessWidget {
  final MapStatusHistoryItem item;

  const _StatusHistoryRow({required this.item});

  Color get _dotColor {
    switch (item.status) {
      case 'free':
        return AppTheme.statusGreen;
      case 'in_order':
        return AppTheme.statusOrange;
      case 'busy':
        return const Color(0xFFFF6B3D);
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.statusLabel,
              style: const TextStyle(
                fontFamily: 'Yandex Sans Text',
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            item.timeLabel,
            style: const TextStyle(
              fontFamily: 'Yandex Sans Text',
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
