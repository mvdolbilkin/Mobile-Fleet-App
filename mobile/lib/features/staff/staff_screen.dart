import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/staff/data/staff_repository.dart';
import 'package:mobile/features/staff/domain/staff.dart';
import 'package:mobile/features/staff/widgets/staff_filter_section.dart';
import 'package:mobile/features/staff/widgets/staff_list_item.dart';
import 'package:mobile/features/staff/staff_details_screen.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  String? _selectedStatus;
  String? _selectedVehicle;
  String _searchQuery = '';

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
      ),
      body: RefreshIndicator(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final staff = filteredStaff[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: StaffListItem(
                          staff: staff,
                          onTap: () {
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
    );
  }
}
