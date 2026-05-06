import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/map/data/map_repository.dart';
import 'package:mobile/features/map/domain/map_driver.dart';
import 'package:mobile/features/map/widgets/map_filter_sheet.dart';

class DriverListSheet extends ConsumerStatefulWidget {
  final String? selectedFilter;
  final void Function(MapCombinedDriver)? onDriverTap;

  const DriverListSheet({
    required this.selectedFilter,
    this.onDriverTap,
    super.key,
  });

  @override
  ConsumerState<DriverListSheet> createState() => _DriverListSheetState();
}

class _DriverListSheetState extends ConsumerState<DriverListSheet> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapCombinedDriver> _applyFilters(List<MapCombinedDriver> drivers) {
    var filtered = drivers;
    if (widget.selectedFilter != null) {
      if (widget.selectedFilter == 'no_gps') {
        filtered = filtered.where((d) => !d.hasGps).toList();
      } else {
        filtered =
            filtered.where((d) => d.status == widget.selectedFilter).toList();
      }
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (d) =>
                d.fullName.toLowerCase().contains(q) ||
                (d.vehicleNumber?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    return filtered;
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.controlsColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MapFilterSheet(),
    );
  }

  Widget _buildSearchBar({int? driverCount}) {
    final activeCount = ref.watch(mapFilterProvider).activeFilterCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.controlsColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (driverCount != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$driverCount',
                        style: const TextStyle(
                          fontFamily: 'Yandex Sans Text',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(
                  fontFamily: 'Yandex Sans Text',
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText: 'Поиск',
                  hintStyle: TextStyle(
                    fontFamily: 'Yandex Sans Text',
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 22,
              color: AppTheme.textSecondary.withOpacity(0.20),
            ),
            GestureDetector(
              onTap: _showFilterSheet,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.tune,
                      size: 20,
                      color: activeCount > 0
                          ? Colors.black87
                          : AppTheme.textSecondary,
                    ),
                    if (activeCount > 0)
                      Positioned(
                        right: 7,
                        top: 7,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE000),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFC4A700), width: 0.5),
                          ),
                          child: Center(
                            child: Text(
                              '$activeCount',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(filteredDriverListProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.12,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.12, 0.35, 0.92],
      builder: (context, scrollController) {
        final decoration = BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        );

        return Container(
          decoration: decoration,
          child: dataAsync.when(
            data: (data) {
              final drivers = _applyFilters(data);
              return CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _buildHandle()),
                  SliverToBoxAdapter(child: _buildSearchBar(driverCount: drivers.length)),
                  if (drivers.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: const Center(
                        child: Text(
                          'Нет водителей',
                          style: TextStyle(
                            fontFamily: 'Yandex Sans Text',
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _DriverCard(
                            driver: drivers[i],
                            onTap: widget.onDriverTap,
                          ),
                          childCount: drivers.length,
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(child: _buildHandle()),
                SliverToBoxAdapter(child: _buildSearchBar()),
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
            error: (e, _) => CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(child: _buildHandle()),
                SliverToBoxAdapter(child: _buildSearchBar()),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppTheme.textSecondary),
                      const SizedBox(height: 8),
                      const Text(
                        'Ошибка загрузки',
                        style: TextStyle(
                          fontFamily: 'Yandex Sans Text',
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref.invalidate(mapDataProvider),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Карточка водителя ────────────────────────────────────────────────────────

class _DriverCard extends StatelessWidget {
  final MapCombinedDriver driver;
  final void Function(MapCombinedDriver)? onTap;

  const _DriverCard({required this.driver, this.onTap});

  Widget _defaultAvatar() => Container(
        width: 48,
        height: 48,
        color: AppTheme.controlsColor,
        child: const Icon(Icons.person, color: Color(0xFF9E9B98), size: 28),
      );

  Color get _statusColor {
    switch (driver.status) {
      case 'free':
        return AppTheme.statusGreen;
      case 'in_order':
        return AppTheme.statusOrange;
      default:
        return const Color(0xFFFF6B3D);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(driver),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        driver.fullName,
                        style: const TextStyle(
                          fontFamily: 'Yandex Sans Text',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!driver.hasGps) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NO GPS',
                          style: TextStyle(
                            fontFamily: 'Yandex Sans Text',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  driver.statusDurationLabel,
                  style: const TextStyle(
                    fontFamily: 'Yandex Sans Text',
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      driver.balanceFormatted,
                      style: const TextStyle(
                        fontFamily: 'Yandex Sans Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (driver.vehicleNumber != null) ...[
                      const Text(
                        ' · ',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        driver.vehicleNumber!,
                        style: const TextStyle(
                          fontFamily: 'Yandex Sans Text',
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textSecondary,
            size: 20,
          ),
        ],
      ),
      ),
    );
  }
}
