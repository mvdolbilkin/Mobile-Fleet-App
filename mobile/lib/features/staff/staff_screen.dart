import 'package:flutter/material.dart';
import 'package:mobile/features/staff/data/mock_staff.dart';
import 'package:mobile/features/staff/widgets/staff_filter_section.dart';
import 'package:mobile/features/staff/widgets/staff_list_item.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  // Тут в будущем будет контроллер для поиска и стейт фильтров

  @override
  Widget build(BuildContext context) {
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
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: StaffFilterSection(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final staff = mockStaff[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: StaffListItem(
                      staff: staff,
                      onTap: () {
                        // Navigate to details
                      },
                    ),
                  );
                },
                childCount: mockStaff.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
