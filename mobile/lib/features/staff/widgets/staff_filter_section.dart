import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/widgets/filter_chip.dart';
import 'package:mobile/shared/widgets/search_field.dart';

class StaffFilterSection extends StatefulWidget {
  final String? selectedStatus;
  final String? selectedVehicle;
  final void Function(String? status, String? vehicle) onFilterChanged;
  final ValueChanged<String>? onSearchChanged;

  const StaffFilterSection({
    super.key,
    this.selectedStatus,
    this.selectedVehicle,
    required this.onFilterChanged,
    this.onSearchChanged,
  });

  @override
  State<StaffFilterSection> createState() => _StaffFilterSectionState();
}

class _StaffFilterSectionState extends State<StaffFilterSection> {
  final List<String> _statuses = [
    'Работает',
    'Свободен',
    'На заказе',
    'Занят',
    'Оффлайн',
  ];
  final List<String> _vehicles = ['Авто', 'Мото', 'Рикша'];

  void _showFilterBottomSheet() {
    String? tempStatus = widget.selectedStatus;
    String? tempVehicle = widget.selectedVehicle;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Фильтры',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  tempStatus = null;
                                  tempVehicle = null;
                                });
                              },
                              child: const Text(
                                'Сбросить',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Body
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16.0),
                          children: [
                            const Text(
                              'Статус на линии',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _statuses.map((status) {
                                final isSelected = tempStatus == status;
                                return CustomFilterChip(
                                  label: status,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setModalState(() {
                                      tempStatus = isSelected ? null : status;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Тип ТС',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _vehicles.map((vehicle) {
                                final isSelected = tempVehicle == vehicle;
                                return CustomFilterChip(
                                  label: vehicle,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setModalState(() {
                                      tempVehicle = isSelected ? null : vehicle;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      // Footer
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            widget.onFilterChanged(tempStatus, tempVehicle);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.buttonColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Применить',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _resetFilters() {
    widget.onFilterChanged(null, null);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Свободен':
        return const Color(0xFF00CA50);
      case 'Занят':
        return AppTheme.statusRed;
      case 'На заказе':
        return Colors.orange;
      case 'Оффлайн':
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchField(
            hint: 'Поиск по имени, ВУ или позывному',
            onChanged: widget.onSearchChanged,
            suffixIcon: GestureDetector(
              onTap: _showFilterBottomSheet,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.tune,
                      size: 22,
                      color: AppTheme.textSecondary,
                    ),
                    if (widget.selectedStatus != null ||
                        widget.selectedVehicle != null)
                      Positioned(
                        right: 0,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.statusRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Filter Row
        if (widget.selectedStatus != null || widget.selectedVehicle != null)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Filter Pill: Status
              if (widget.selectedStatus != null) ...[
                _buildFilterPill(
                  label: 'Статус на линии: ',
                  valueWidget: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.selectedStatus!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.selectedStatus!,
                      style: const TextStyle(
                        fontFamily: 'Yandex Sans Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 14 / 12,
                      ),
                    ),
                  ),
                  onClear: () {
                    widget.onFilterChanged(null, widget.selectedVehicle);
                  },
                ),
                const SizedBox(width: 8),
              ],

              // Filter Pill: Car Type
              if (widget.selectedVehicle != null)
                _buildFilterPill(
                  label: 'Тип ТС: ${widget.selectedVehicle}',
                  onClear: () {
                    widget.onFilterChanged(widget.selectedStatus, null);
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Reset Link
        if (widget.selectedStatus != null || widget.selectedVehicle != null)
          GestureDetector(
            onTap: _resetFilters,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Сбросить все фильтры',
                style: const TextStyle(
                  fontFamily: 'Yandex Sans Text',
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterPill({
    required String label,
    Widget? valueWidget,
    required VoidCallback onClear,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              fontFamily: 'Yandex Sans Text',
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          if (valueWidget != null) ...[valueWidget],
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
