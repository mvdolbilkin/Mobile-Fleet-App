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
import 'package:mobile/features/fleet/presentation/fines/widgets/fines_filter_bottom_sheet.dart';
import 'package:mobile/features/fleet/presentation/fines/widgets/fines_selection_panel.dart';
import 'package:mobile/shared/widgets/filter_chip.dart';

class FinesScreen extends ConsumerStatefulWidget {
  const FinesScreen({super.key});

  @override
  ConsumerState<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends ConsumerState<FinesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  bool _isSelectionMode = false;
  final Set<String> _selectedFines = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedFines.clear();
    });
  }

  void _onFineSelect(String uin, bool selected) {
    setState(() {
      if (selected) {
        _selectedFines.add(uin);
      } else {
        _selectedFines.remove(uin);
      }
    });
  }

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

    // Preload cars & drivers while the screen is open; autoDispose clears them on exit
    ref.watch(finesSuggestCarsProvider);
    ref.watch(finesSuggestDriversProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Штрафы ГИБДД', style: AppTheme.appBarTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _toggleSelectionMode,
              child: Text(
                _isSelectionMode ? 'Отмена' : 'Выбрать',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
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

          // Search + filter button inside
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchField(
              hint: 'Поиск по УИН',
              controller: _searchController,
              onChanged: _onSearchChanged,
              suffixIcon: GestureDetector(
                onTap: () async {
                  final result = await FinesFilterBottomSheet.show(
                    context: context,
                    initialFilter: currentFilter,
                  );
                  if (result != null) notifier.applyAdvancedFilter(result);
                },
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: currentFilter.hasAdvancedFilters
                        ? AppTheme.buttonColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tune,
                    size: 22,
                    color: currentFilter.hasAdvancedFilters
                        ? Colors.black
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Active filter pills
          if (currentFilter.hasAdvancedFilters)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (currentFilter.dateFrom != null && currentFilter.dateTo != null) ...[
                  _buildFilterPill(
                    'Период: ${_formatShortDate(currentFilter.dateFrom!)} – ${_formatShortDate(currentFilter.dateTo!)}',
                    () => notifier.setDateRange(null, null),
                  ),
                  const SizedBox(width: 8),
                ],
                if (currentFilter.carId != null) ...[  
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    'Авто',
                    () => notifier.applyAdvancedFilter(currentFilter.copyWith(clearCarId: true)),
                  ),
                ],
                if (currentFilter.driverId != null) ...[  
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    'Водитель',
                    () => notifier.applyAdvancedFilter(currentFilter.copyWith(clearDriverId: true)),
                  ),
                ],
                if (currentFilter.contractorPaymentStatuses?.isNotEmpty ?? false) ...[  
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    'Статус платежа',
                    () => notifier.applyAdvancedFilter(currentFilter.copyWith(clearPaymentStatuses: true)),
                  ),
                ],
                if (currentFilter.contractorAssignmentStatuses?.isNotEmpty ?? false) ...[  
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    'Статус водителя',
                    () => notifier.applyAdvancedFilter(currentFilter.copyWith(clearAssignmentStatuses: true)),
                  ),
                ],
                if (currentFilter.wasLoadedBankClient != null) ...[  
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    currentFilter.wasLoadedBankClient! ? 'Выгружен' : 'Не выгружен',
                    () => notifier.applyAdvancedFilter(currentFilter.copyWith(clearBankClient: true)),
                  ),
                ],
              ],
            ),
          ),

          if (currentFilter.hasAdvancedFilters)
            GestureDetector(
              onTap: () => notifier.resetAdvancedFilters(),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  'Сбросить все фильтры',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Fines list + selection panel
          Expanded(
            child: Stack(
              children: [
                _buildFinesList(finesState),
                if (_isSelectionMode)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildSelectionPanel(finesState),
                  ),
              ],
            ),
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
            child: CustomFilterChip(
              label: filter.displayName,
              isSelected: isSelected,
              onTap: () => notifier.setStatusFilter(filter),
              selectedColor: Colors.black,
              selectedBorderColor: Colors.black,
              selectedTextColor: Colors.white,
              unselectedColor: const Color(0xFFF2F2F2),
              unselectedBorderColor: const Color(0xFFDDDDDD),
              unselectedTextColor: AppTheme.textPrimary,
              borderRadius: 20,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterPill(String label, VoidCallback onClear) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 16, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionPanel(FinesState state) {
    final selected = state.filteredFines
        .where((f) => _selectedFines.contains(f.fine.uin))
        .toList();
    final total = selected.fold<double>(
      0,
      (sum, f) => sum + (double.tryParse(f.fine.payment) ?? 0),
    );
    final paymentLink = selected.length == 1 ? selected.first.fine.paymentLink : null;
    return FinesSelectionPanel(
      selectedCount: _selectedFines.length,
      totalFormatted: _formatMoney(total.toStringAsFixed(2)),
      paymentLink: paymentLink,
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
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: _isSelectionMode ? 110 : 16,
        ),
        itemCount: state.filteredFines.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.filteredFines.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final fine = state.filteredFines[index];
          return _FineCard(
            fine: fine,
            formatMoney: _formatMoney,
            formatDate: _formatDate,
            ref: ref,
            isSelectionMode: _isSelectionMode,
            isSelected: _selectedFines.contains(fine.fine.uin),
            onSelect: (val) => _onFineSelect(fine.fine.uin, val),
            onEnterSelection: () {
              if (!_isSelectionMode) _toggleSelectionMode();
              _onFineSelect(fine.fine.uin, true);
            },
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
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool> onSelect;

  final VoidCallback? onEnterSelection;

  const _FineCard({
    required this.fine,
    required this.formatMoney,
    required this.formatDate,
    required this.ref,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onSelect,
    this.onEnterSelection,
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
          color: isSelected
              ? Colors.black
              : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isSelectionMode) {
              onSelect(!isSelected);
            } else {
              _showFineDetails(context);
            }
          },
          onLongPress: isSelectionMode ? null : onEnterSelection,
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
                    Row(
                      children: [
                        Text(
                          formatDate(offenseDate),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (isSelectionMode) ...[  
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (val) => onSelect(val ?? false),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              side: const BorderSide(color: AppTheme.textSecondary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ],
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
