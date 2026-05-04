import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/data/fines_service.dart';
import 'package:mobile/features/fleet/domain/traffic_fine.dart';
import 'package:mobile/features/fleet/presentation/fines/providers/fines_provider.dart';
import 'package:mobile/features/fleet/presentation/fines/widgets/fine_detail_bottom_sheet.dart';
import 'package:mobile/shared/widgets/animated_icon_button.dart';
import 'package:mobile/shared/widgets/search_field.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';

class FinesScreen extends ConsumerStatefulWidget {
  const FinesScreen({super.key});

  @override
  ConsumerState<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends ConsumerState<FinesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(finesProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(finesProvider.notifier).setSearchQuery(value);
    });
  }

  String _formatMoney(String amount) {
    final value = double.tryParse(amount) ?? 0;
    if (value == value.truncateToDouble()) {
      return '${value.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} ₽';
    }
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$intPart,${parts[1]} ₽';
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'янв.', 'февр.', 'мар.', 'апр.', 'мая', 'июня',
      'июля', 'авг.', 'сент.', 'окт.', 'нояб.', 'дек.',
    ];
    return '${date.day} ${months[date.month]} ${date.year} г.';
  }

  String _formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final finesState = ref.watch(finesProvider);
    final notifier = ref.read(finesProvider.notifier);
    final totalAsync = ref.watch(finesTotalProvider);
    final currentFilter = notifier.filter;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Штрафы ГИБДД', style: AppTheme.appBarTitle),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedIconButton(
            onTap: () => Navigator.of(context).pop(),
            icon: const Padding(
              padding: EdgeInsets.only(left: 6.0),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: AppTheme.textPrimary,
              ),
            ),
            color: Colors.transparent,
            size: 40,
            borderRadius: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Total summary
          totalAsync.when(
            data: (total) => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Всего: ${total.count} шт. на ${_formatMoney(total.sum)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Status tabs
          _buildStatusTabs(currentFilter.statusFilter, notifier),

          const SizedBox(height: 8),

          // Search + filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    hint: 'Поиск по УИН',
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterButton(currentFilter, notifier),
              ],
            ),
          ),

          // Active filters display
          if (currentFilter.dateFrom != null || currentFilter.carId != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (currentFilter.dateFrom != null && currentFilter.dateTo != null)
                      _buildActiveChip(
                        '${_formatShortDate(currentFilter.dateFrom!)} – ${_formatShortDate(currentFilter.dateTo!)}',
                        () => notifier.setDateRange(null, null),
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Fines list
          Expanded(
            child: _buildFinesList(finesState),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(FineStatusFilter current, FinesNotifier notifier) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: FineStatusFilter.values.map((filter) {
          final isSelected = filter == current;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => notifier.setStatusFilter(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter.displayName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterButton(FinesFilter filter, FinesNotifier notifier) {
    return AnimatedIconButton(
      onTap: () async {
        final result = await CustomDateRangePickerBottomSheet.show(
          context: context,
          title: 'Период',
          startDate: filter.dateFrom,
          endDate: filter.dateTo,
        );
        if (result != null) {
          notifier.setDateRange(result.start, result.end);
        }
      },
      icon: Icon(
        Icons.tune,
        size: 22,
        color: filter.dateFrom != null ? AppTheme.primaryColor : AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildActiveChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFinesList(FinesState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка: ${state.error}', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(finesProvider.notifier).refresh(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (state.filteredFines.isEmpty) {
      return const Center(
        child: Text('Штрафов не найдено', style: AppTheme.captionSecondary),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.read(finesProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.filteredFines.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.filteredFines.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _FineCard(
            fine: state.filteredFines[index],
            formatMoney: _formatMoney,
            formatDate: _formatDate,
            ref: ref,
          );
        },
      ),
    );
  }
}

class _FineCard extends StatelessWidget {
  final TrafficFine fine;
  final String Function(String) formatMoney;
  final String Function(DateTime) formatDate;
  final WidgetRef ref;

  const _FineCard({
    required this.fine,
    required this.formatMoney,
    required this.formatDate,
    required this.ref,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'issued':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fineDetails = fine.fine;
    final hasDiscount = fineDetails.discount != null;
    final offenseDate = fineDetails.offenseAt ?? fineDetails.issuedAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showFineDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor(fineDetails.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fineDetails.statusDisplayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(fineDetails.status),
                        ),
                      ),
                    ),
                    Text(
                      formatDate(offenseDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Vehicle info
                if (fine.vehicle != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.directions_car_outlined, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${fine.vehicle!.displayName}  ${fine.vehicle!.licensePlate}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                // Driver
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        fine.contractor.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          color: fine.contractor.name != null
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Amount row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatMoney(fineDetails.payment),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (hasDiscount)
                          Text(
                            '${formatMoney(fineDetails.amount)} после ${_formatDiscountDate(fineDetails.discount!.until)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDiscountDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
  }

  void _showFineDetails(BuildContext context) {
    final service = ref.read(finesServiceProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FineDetailBottomSheet(
        future: service.getFineDetail(fine.fine.uin),
        formatMoney: formatMoney,
        formatDate: formatDate,
        fallbackFine: fine,
      ),
    );
  }
}
