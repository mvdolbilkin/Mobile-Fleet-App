import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/widgets/fading_button.dart';
import 'package:mobile/features/fleet/providers/rents_filters_provider.dart';

class RentsFilter {
  final List<String> categories;
  final List<String> statuses;

  const RentsFilter({
    this.categories = const [],
    this.statuses = const [],
  });
}

class RentsFilterBottomSheet extends ConsumerStatefulWidget {
  final RentsFilter initialFilter;

  const RentsFilterBottomSheet({Key? key, required this.initialFilter}) : super(key: key);

  static Future<RentsFilter?> show({
    required BuildContext context,
    required RentsFilter initialFilter,
  }) {
    return showModalBottomSheet<RentsFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RentsFilterBottomSheet(initialFilter: initialFilter),
    );
  }

  @override
  ConsumerState<RentsFilterBottomSheet> createState() => _RentsFilterBottomSheetState();
}

class _RentsFilterBottomSheetState extends ConsumerState<RentsFilterBottomSheet> {
  late List<String> _selectedCategories;
  late List<String> _selectedStatuses;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.initialFilter.categories);
    _selectedStatuses = List.from(widget.initialFilter.statuses);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(carCategoriesProvider);
    final statusesAsync = ref.watch(carStatusesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ильтры',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('атегория', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              categoriesAsync.when(
                data: (cats) => _buildSelectionList(
                  items: cats.map((e) => {"id": e['id'], "name": e['name'] ?? e['id']}).toList(),
                  selectedIds: _selectedCategories,
                  onToggle: (id) => setState(() {
                    if (_selectedCategories.contains(id)) {
                      _selectedCategories.remove(id);
                    } else {
                      _selectedCategories.add(id);
                    }
                  }),
                ),
                loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                error: (e, st) => const Padding(padding: EdgeInsets.all(16), child: Text("шибка загрузки")),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Статус', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              statusesAsync.when(
                data: (stats) => _buildSelectionList(
                  items: stats.map((e) => {"id": e['id'] ?? e['code'], "name": e['name'] ?? e['id'] ?? e['code']}).toList(),
                  selectedIds: _selectedStatuses,
                  onToggle: (id) => setState(() {
                    if (_selectedStatuses.contains(id)) {
                      _selectedStatuses.remove(id);
                    } else {
                      _selectedStatuses.add(id);
                    }
                  }),
                ),
                loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                error: (e, st) => const Padding(padding: EdgeInsets.all(16), child: Text("шибка загрузки")),
              ),
              
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: FadingButton(
                        onTap: () {
                          setState(() {
                            _selectedCategories.clear();
                            _selectedStatuses.clear();
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.controlsColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Сбросить', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FadingButton(
                        onTap: () {
                          Navigator.pop(
                            context,
                            RentsFilter(categories: _selectedCategories, statuses: _selectedStatuses),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.buttonColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('рименить', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionList({
    required List<Map<String, dynamic>> items,
    required List<String> selectedIds,
    required Function(String id) onToggle,
  }) {
    if (items.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text("ет данных", style: TextStyle(color: AppTheme.textSecondary)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final id = item['id'].toString();
            final name = item['name'].toString();
            final isSelected = selectedIds.contains(id);

            return FilterChip(
              label: Text(name),
              selected: isSelected,
              onSelected: (_) => onToggle(id),
              backgroundColor: AppTheme.controlsColor,
              selectedColor: AppTheme.buttonColor,
              checkmarkColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.transparent)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
