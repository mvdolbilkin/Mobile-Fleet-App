import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/providers/rents_filters_provider.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class RentsFiltersSheet extends ConsumerStatefulWidget {
  final RentsFilter initialFilter;

  const RentsFiltersSheet({Key? key, required this.initialFilter})
      : super(key: key);

  static Future<RentsFilter?> show({
    required BuildContext context,
    required RentsFilter initialFilter,
  }) {
    return showModalBottomSheet<RentsFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RentsFiltersSheet(initialFilter: initialFilter),
    );
  }

  @override
  ConsumerState<RentsFiltersSheet> createState() => _RentsFiltersSheetState();
}

class _RentsFiltersSheetState extends ConsumerState<RentsFiltersSheet> {
  late List<String> _selectedCategories;
  late List<String> _selectedStatuses;
  late bool _isRental;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.initialFilter.categories);
    _selectedStatuses = List.from(widget.initialFilter.statuses);
    _isRental = widget.initialFilter.isRental;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(carCategoriesProvider);
    final statusesAsync = ref.watch(carStatusesProvider);
    final tariffsAsync = ref.watch(regularChargeTariffsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
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
                  const Text('Фильтры', style: AppTheme.listTitle),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        color: AppTheme.textSecondary, size: 24),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rental toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Только арендованные',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Switch(
                          value: _isRental,
                          onChanged: (value) {
                            setState(() => _isRental = value);
                          },
                          activeColor: AppTheme.buttonColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Categories
                    const Text(
                      'Категории',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    categoriesAsync.when(
                      data: (categories) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((category) {
                          final isSelected = _selectedCategories.contains(category.id);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedCategories.remove(category.id);
                                } else {
                                  _selectedCategories.add(category.id);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.buttonColor
                                    : AppTheme.controlsColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.black
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => Text(
                        'Ошибка загрузки категорий',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Statuses
                    const Text(
                      'Статусы',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    statusesAsync.when(
                      data: (statuses) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: statuses.map((status) {
                          final isSelected = _selectedStatuses.contains(status.id);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedStatuses.remove(status.id);
                                } else {
                                  _selectedStatuses.add(status.id);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.buttonColor
                                    : AppTheme.controlsColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.black
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => Text(
                        'Ошибка загрузки статусов',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
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
                onTap: () => Navigator.pop(
                  context,
                  RentsFilter(
                    categories: _selectedCategories,
                    statuses: _selectedStatuses,
                    isRental: _isRental,
                  ),
                ),
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
                      fontWeight: FontWeight.w600,
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
