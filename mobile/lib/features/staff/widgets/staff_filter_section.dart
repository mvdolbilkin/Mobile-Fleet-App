import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Фильтры',
                    style: TextStyle(
                      fontFamily: 'Yandex Sans Text',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Статус на линии',
                    style: TextStyle(
                      fontFamily: 'Yandex Sans Text',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _statuses.map((status) {
                      final isSelected = widget.selectedStatus == status;
                      return ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            widget.onFilterChanged(
                              selected ? status : null,
                              widget.selectedVehicle,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Тип ТС',
                    style: TextStyle(
                      fontFamily: 'Yandex Sans Text',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _vehicles.map((vehicle) {
                      final isSelected = widget.selectedVehicle == vehicle;
                      return ChoiceChip(
                        label: Text(vehicle),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            widget.onFilterChanged(
                              widget.selectedStatus,
                              selected ? vehicle : null,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.controlsColor,
                        foregroundColor: Colors.black,
                        elevation: 0,
                      ),
                      child: const Text('Применить'),
                    ),
                  ),
                ],
              ),
            );
          },
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
          ),
        ),
        const SizedBox(height: 12),

        // Filter Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Checkbox Circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.controlsColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 20, color: Colors.black),
              ),
              const SizedBox(width: 8),

              // Filter Icon Circle
              GestureDetector(
                onTap: _showFilterBottomSheet,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.controlsColor,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.tune, size: 20, color: Colors.black),
                      if (widget.selectedStatus != null ||
                          widget.selectedVehicle != null)
                        Positioned(
                          right: 8,
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
              const SizedBox(width: 8),

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
