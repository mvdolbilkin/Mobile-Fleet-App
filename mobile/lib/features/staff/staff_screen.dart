import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/staff/data/staff_repository.dart';
import 'package:mobile/features/staff/domain/staff.dart';
import 'package:mobile/features/staff/widgets/staff_filter_section.dart';
import 'package:mobile/features/staff/widgets/staff_list_item.dart';
import 'package:mobile/features/staff/staff_details_screen.dart';
import 'package:mobile/features/staff/widgets/source_action_bottom_sheet.dart';
import 'package:mobile/features/staff/widgets/work_conditions_action_bottom_sheet.dart';
import 'package:mobile/features/staff/widgets/work_status_action_bottom_sheet.dart';
import 'package:mobile/features/staff/widgets/mailing_action_bottom_sheet.dart';
import '../../../../app/theme.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  String? _selectedStatus;
  String? _selectedVehicle;
  String _searchQuery = '';
  bool _isSelectionMode = false;
  final Set<String> _selectedStaff = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedStaff.clear();
      }
    });
  }

  void _onStaffSelect(String id, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedStaff.add(id);
      } else {
        _selectedStaff.remove(id);
      }
    });
  }

  List<Staff> _filterStaffList(List<Staff> staffList) {
    if (staffList.isEmpty) return [];

    final lowerQuery = _searchQuery.toLowerCase();

    final filtered = staffList.where((staff) {
      if (lowerQuery.isNotEmpty) {
        final matchesName = staff.searchName.contains(lowerQuery);
        final matchesPhone = staff.searchPhone.contains(lowerQuery);

        if (!matchesName && !matchesPhone) {
          return false;
        }
      }

      if (_selectedStatus != null) {
        String staffStatusStr;
        switch (staff.status) {
          case StaffStatus.free:
            staffStatusStr = 'Свободен';
            break;
          case StaffStatus.busy:
            staffStatusStr = 'Занят';
            break;
          case StaffStatus.onOrder:
            staffStatusStr = 'На заказе';
            break;
          case StaffStatus.offline:
            staffStatusStr = 'Оффлайн';
            break;
          case StaffStatus.fired:
            staffStatusStr = 'Уволен';
            break;
        }
        if (staffStatusStr != _selectedStatus) {
          return false;
        }
      }

      if (_selectedVehicle != null) {
        if (staff.vehicleType != _selectedVehicle) {
          return false;
        }
      }

      return true;
    }).toList();

    // Сортируем с кэшированием или без выделения кучи новых строк каждую итерацию.
    // Поскольку `build` вызывается часто, используем более дешевое сравнение.
    filtered.sort((a, b) => a.searchName.compareTo(b.searchName));

    return filtered;
  }

  void _onFilterChanged(String? status, String? vehicle) {
    setState(() {
      _selectedStatus = status;
      _selectedVehicle = vehicle;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffAsyncValue = ref.watch(staffListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F2), // Background from Figma
      appBar: AppBar(
        title: const Text(
          'Персонал',
          style: TextStyle(
            fontFamily: 'Yandex Sans Text',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF21201F),
          ),
        ),
        backgroundColor: const Color(0xFFF5F4F2),
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
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
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: const Color(0xFF21201F),
            backgroundColor: const Color(0xFFFCE000),
            onRefresh: () async {
              return await ref.refresh(staffListProvider.future);
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: StaffFilterSection(
                      selectedStatus: _selectedStatus,
                      selectedVehicle: _selectedVehicle,
                      onFilterChanged: _onFilterChanged,
                      onSearchChanged: _onSearchChanged,
                    ),
                  ),
                ),
                staffAsyncValue.when(
                  data: (staffList) {
                    final filteredStaff = _filterStaffList(staffList);
                    if (filteredStaff.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'Ничего не найдено',
                            style: TextStyle(fontFamily: 'Yandex Sans Text'),
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: _isSelectionMode ? 140 : 16,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final staff = filteredStaff[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: StaffListItem(
                              staff: staff,
                              isSelectionMode: _isSelectionMode,
                              isSelected: _selectedStaff.contains(staff.id),
                              onSelect: (val) => _onStaffSelect(staff.id, val),
                              onTap: () {
                                if (_isSelectionMode) {
                                  _onStaffSelect(
                                    staff.id,
                                    !_selectedStaff.contains(staff.id),
                                  );
                                  return;
                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StaffDetailsScreen(staff: staff),
                                  ),
                                );
                              },
                            ),
                          );
                        }, childCount: filteredStaff.length),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFFCE000)),
                    ),
                  ),
                  error: (err, stack) => SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Ошибка загрузки: $err',
                        style: const TextStyle(
                          fontFamily: 'Yandex Sans Text',
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Всплывающая панель при выделении
          if (_isSelectionMode)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 16, bottom: 32, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_selectedStaff.length} выбранных исполнителей',
                      style: const TextStyle(
                        fontFamily: 'Yandex Sans Text',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF21201F),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Некоторые действия недоступны, так как они применимы только для парковых автомобилей',
                      style: TextStyle(
                        fontFamily: 'Yandex Sans Text',
                        fontSize: 14,
                        color: Color(0xFF9E9B98),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPillButton(
                            label: 'Источник',
                            onTap: () => _showSourceAction(),
                          ),
                          const SizedBox(width: 8),
                          _buildPillButton(
                            label: 'Условия',
                            onTap: () => _showWorkConditionsAction(),
                          ),
                          const SizedBox(width: 8),
                          _buildPillButton(
                            label: 'Статус',
                            onTap: () => _showWorkStatusAction(),
                          ),
                          const SizedBox(width: 8),
                          _buildPillButton(
                            label: 'Рассылка',
                            onTap: () => _showMailingAction(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    required VoidCallback onTap,
  }) {
    final isEnabled = _selectedStaff.isNotEmpty;
    return Material(
      color: isEnabled ? const Color(0xFFFCE000) : const Color(0xFFF0F0F0),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Yandex Sans Text',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isEnabled ? const Color(0xFF21201F) : const Color(0xFF9E9B98),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSourceAction() async {
    final selectedIds = _selectedStaff.toList();
    final result = await SourceActionBottomSheet.show(
      context: context,
      selectedCount: selectedIds.length,
      selectedStaffIds: selectedIds,
    );

    if (result == true && mounted) {
      ref.invalidate(staffListProvider);
      setState(() {
        _isSelectionMode = false;
        _selectedStaff.clear();
      });
    }
  }

  Future<void> _showWorkConditionsAction() async {
    final selectedIds = _selectedStaff.toList();
    final result = await WorkConditionsActionBottomSheet.show(
      context: context,
      selectedCount: selectedIds.length,
      selectedStaffIds: selectedIds,
    );

    if (result == true && mounted) {
      ref.invalidate(staffListProvider);
      setState(() {
        _isSelectionMode = false;
        _selectedStaff.clear();
      });
    }
  }

  Future<void> _showWorkStatusAction() async {
    final selectedIds = _selectedStaff.toList();
    final result = await WorkStatusActionBottomSheet.show(
      context: context,
      selectedCount: selectedIds.length,
      selectedStaffIds: selectedIds,
    );

    if (result == true && mounted) {
      ref.invalidate(staffListProvider);
      setState(() {
        _isSelectionMode = false;
        _selectedStaff.clear();
      });
    }
  }

  Future<void> _showMailingAction() async {
    final selectedIds = _selectedStaff.toList();
    final result = await MailingActionBottomSheet.show(
      context: context,
      selectedCount: selectedIds.length,
      selectedStaffIds: selectedIds,
    );

    if (result == true && mounted) {
      ref.invalidate(staffListProvider);
      setState(() {
        _isSelectionMode = false;
        _selectedStaff.clear();
      });
    }
  }
}
