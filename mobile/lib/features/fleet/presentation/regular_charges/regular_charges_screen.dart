import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/presentation/regular_charges/regular_charges_models.dart';
import 'package:mobile/features/fleet/presentation/regular_charges/regular_charges_repository.dart';
import 'package:mobile/features/fleet/presentation/regular_charges/regular_charges_filter_sheet.dart';
import 'package:mobile/features/fleet/presentation/regular_charges/regular_charge_detail_sheet.dart';
import 'package:mobile/features/fleet/providers/rents_filters_provider.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:mobile/shared/widgets/badge.dart';
import 'package:mobile/shared/widgets/fading_button.dart';
import 'package:mobile/features/fleet/providers/report_downloads_provider.dart';
import 'package:mobile/features/fleet/presentation/expenses/widgets/report_downloads_sheet.dart';

class RegularChargesScreen extends ConsumerStatefulWidget {
  const RegularChargesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegularChargesScreen> createState() => _RegularChargesScreenState();
}

class RegularChargesFilter {
  final String dateType;
  final List<String> states;
  final int pageSize;
  final DateTime dateFrom;
  final DateTime dateTo;

  RegularChargesFilter({
    this.dateType = 'date_from',
    this.states = const [],
    this.pageSize = 50,
    DateTime? dateFrom,
    DateTime? dateTo,
  })  : dateFrom = dateFrom ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
        dateTo = dateTo ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 5));

  static RegularChargesFilter get defaultFilter => RegularChargesFilter();

  bool get isModified =>
      dateType != 'date_from' || states.isNotEmpty || pageSize != 50;

  RegularChargesFilter copyWith({
    String? dateType,
    List<String>? states,
    int? pageSize,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return RegularChargesFilter(
      dateType: dateType ?? this.dateType,
      states: states ?? this.states,
      pageSize: pageSize ?? this.pageSize,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }
}

class _RegularChargesScreenState extends ConsumerState<RegularChargesScreen> {
  bool _isLoading = false;
  List<RegularCharge> _charges = [];
  RegularChargesFilter _filter = RegularChargesFilter.defaultFilter;
  Map<String, String> _stateNames = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final parkId = await ref.read(secureStorageServiceProvider).getParkId();
      if (parkId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await ref.read(regularChargesRepositoryProvider).getRegularCharges(
        parkId: parkId,
        page: 1,
        limit: _filter.pageSize,
        dateType: _filter.dateType,
        states: _filter.states.isNotEmpty ? _filter.states : null,
        dateFrom: _filter.dateFrom,
        dateTo: _filter.dateTo,
      );

      if (!mounted) return;

      setState(() {
        _charges = response.regularCharges;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      print('❌ Regular charges error: $e');
    }
  }

  String _dateTypeLabel(String type) {
    switch (type) {
      case 'date_from':
        return 'Дата создания';
      case 'date_end':
        return 'Дата завершения';
      case 'charging_at':
        return 'Дата начала списания';
      default:
        return type;
    }
  }

  String _stateLabel(String state) {
    return _stateNames[state] ?? state;
  }

  BadgeType _stateBadgeType(String state) {
    switch (state) {
      case 'accepted':
        return BadgeType.working;
      case 'ended':
        return BadgeType.noDriver;
      case 'park_terminated':
      case 'driver_terminated':
        return BadgeType.service;
      case 'suspended':
      case 'rejected':
        return BadgeType.noDriver;
      default:
        return BadgeType.preparation;
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatPrice(String? price) {
    if (price == null) return '—';
    final val = double.tryParse(price);
    if (val == null) return price;
    return val == val.truncateToDouble() ? '${val.toInt()} ₽' : '$price ₽';
  }

  @override
  Widget build(BuildContext context) {
    final statesAsync = ref.watch(regularChargeTariffsProvider);
    statesAsync.when(
      data: (tariffs) {},
      error: (_, __) {},
      loading: () {},
    );

    if (_stateNames.isEmpty) {
      _stateNames = {
        'new': 'Предложено',
        'accepted': 'Действующее',
        'ended': 'Завершено',
        'rejected': 'Отклонено',
        'suspended': 'Приостановлено',
        'park_terminated': 'Прекращено парком',
        'driver_terminated': 'Прекращено водителем',
        'will_begin': 'Начнётся',
      };
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Периодические списания'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _buildAppBarDownloadBadge(ref),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildDownloadButton(context, ref),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final result = await RegularChargesFilterSheet.show(
                      context: context,
                      initialFilter: _filter,
                      stateNames: _stateNames,
                    );
                    if (result != null) {
                      setState(() => _filter = result);
                      _loadData();
                    }
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _filter.isModified
                          ? AppTheme.buttonColor
                          : AppTheme.controlsColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tune_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Фильтры',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.controlsColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.swap_vert_rounded, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _dateTypeLabel(_filter.dateType),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _charges.isEmpty
                    ? const Center(
                        child: Text('Нет данных', style: TextStyle(color: AppTheme.textSecondary)),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _charges.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _buildChargeCard(_charges[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarDownloadBadge(WidgetRef ref) {
    final downloads = ref.watch(reportDownloadsProvider);
    final activeCount = downloads.where((d) => d.isActive || d.canDownload).length;

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.download_rounded),
          onPressed: () {
            ReportDownloadsSheet.show(context);
          },
        ),
        if (activeCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppTheme.buttonColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '$activeCount',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDownloadButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await ref.read(reportDownloadsProvider.notifier).startReportDownload(
          reportType: 'regular_charges',
          filters: {'date_type': _filter.dateType},
          dateFrom: _filter.dateFrom,
          dateTo: _filter.dateTo,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Создание отчета начато'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: AppTheme.controlsColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.download_rounded, size: 20),
      ),
    );
  }

  Widget _buildChargeCard(RegularCharge charge) {
    final car = charge.asset.car;
    final driver = charge.driver;

    return FadingButton(
      onTap: () {
        RegularChargeDetailSheet.show(
          context: context,
          charge: charge,
          stateLabel: _stateLabel(charge.state),
          badgeType: _stateBadgeType(charge.state),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: serial + state + price
            Row(
              children: [
                Text(
                  '#${charge.serialId}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                CustomBadge(
                  type: _stateBadgeType(charge.state),
                  text: _stateLabel(charge.state),
                ),
                const Spacer(),
                Text(
                  _formatPrice(charge.charging.dailyPrice),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: car info
            if (car != null)
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${car.number ?? ''} ${car.displayName}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 6),

            // Row 3: driver + date
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: AppTheme.textSecondary.withOpacity(0.2),
                  child: Text(
                    driver.lastName.isNotEmpty ? driver.lastName[0] : '?',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    driver.shortName,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDate(charge.dateFrom),
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
