import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/presentation/regular_charges/regular_charges_screen.dart';
import 'package:mobile/shared/widgets/filter_chip.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class RegularChargesFilterSheet extends StatefulWidget {
  final RegularChargesFilter initialFilter;
  final Map<String, String> stateNames;

  const RegularChargesFilterSheet({
    Key? key,
    required this.initialFilter,
    required this.stateNames,
  }) : super(key: key);

  static Future<RegularChargesFilter?> show({
    required BuildContext context,
    required RegularChargesFilter initialFilter,
    required Map<String, String> stateNames,
  }) {
    return showModalBottomSheet<RegularChargesFilter>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RegularChargesFilterSheet(
        initialFilter: initialFilter,
        stateNames: stateNames,
      ),
    );
  }

  @override
  State<RegularChargesFilterSheet> createState() => _RegularChargesFilterSheetState();
}

class _RegularChargesFilterSheetState extends State<RegularChargesFilterSheet> {
  late String _dateType;
  late List<String> _selectedStates;
  late int _selectedPageSize;

  static const List<int> _pageSizeOptions = [25, 50, 100];

  static const Map<String, String> _dateTypes = {
    'date_from': 'Дата создания',
    'date_end': 'Дата завершения',
    'charging_at': 'Дата начала списания',
  };

  @override
  void initState() {
    super.initState();
    _dateType = widget.initialFilter.dateType;
    _selectedStates = List.from(widget.initialFilter.states);
    _selectedPageSize = widget.initialFilter.pageSize;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _dateType = 'date_from';
                        _selectedStates.clear();
                        _selectedPageSize = 50;
                      });
                    },
                    child: const Text(
                      'Сбросить',
                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                  ),
                  const Text(
                    'Фильтры',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date type
                    const Text(
                      'Сортировка по',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _dateTypes.entries.map((entry) {
                        return CustomFilterChip(
                          label: entry.value,
                          isSelected: _dateType == entry.key,
                          onTap: () => setState(() => _dateType = entry.key),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // States
                    const Text(
                      'Статус',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.stateNames.entries
                          .where((e) => e.key != 'will_begin')
                          .map((entry) {
                        final isSelected = _selectedStates.contains(entry.key);
                        return CustomFilterChip(
                          label: entry.value,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedStates.remove(entry.key);
                              } else {
                                _selectedStates.add(entry.key);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Page size
                    const Text(
                      'Показывать по',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _pageSizeOptions.map((size) {
                        return CustomFilterChip(
                          label: '$size',
                          isSelected: _selectedPageSize == size,
                          onTap: () => setState(() => _selectedPageSize = size),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Apply button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FadingButton(
                onTap: () {
                  Navigator.pop(
                    context,
                    RegularChargesFilter(
                      dateType: _dateType,
                      states: _selectedStates,
                      pageSize: _selectedPageSize,
                      dateFrom: widget.initialFilter.dateFrom,
                      dateTo: widget.initialFilter.dateTo,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.buttonColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Применить',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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
