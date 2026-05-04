import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/providers/garage_providers.dart';
import 'package:mobile/shared/widgets/custom_selector_bottom_sheet.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class GarageFilter {
  final String? officeId;
  final String? officeLabel;
  final String? carId;
  final String? carLabel;
  final String? status;
  final String? statusLabel;

  const GarageFilter({
    this.officeId,
    this.officeLabel,
    this.carId,
    this.carLabel,
    this.status,
    this.statusLabel,
  });

  static const GarageFilter empty = GarageFilter();

  bool get isModified =>
      officeId != null || carId != null || status != null;

  GarageFilter copyWith({
    String? officeId,
    String? officeLabel,
    String? carId,
    String? carLabel,
    String? status,
    String? statusLabel,
    bool clearOffice = false,
    bool clearCar = false,
    bool clearStatus = false,
  }) {
    return GarageFilter(
      officeId: clearOffice ? null : (officeId ?? this.officeId),
      officeLabel: clearOffice ? null : (officeLabel ?? this.officeLabel),
      carId: clearCar ? null : (carId ?? this.carId),
      carLabel: clearCar ? null : (carLabel ?? this.carLabel),
      status: clearStatus ? null : (status ?? this.status),
      statusLabel: clearStatus ? null : (statusLabel ?? this.statusLabel),
    );
  }

  Map<String, dynamic> toQuery() {
    final q = <String, dynamic>{};
    if (officeId != null) q['office_ids'] = [officeId];
    if (carId != null) q['vehicle_ids'] = [carId];
    if (status != null) q['status'] = status;
    return q;
  }
}

class GarageFilterSheet extends ConsumerStatefulWidget {
  final GarageFilter initialFilter;

  const GarageFilterSheet({Key? key, required this.initialFilter})
      : super(key: key);

  static Future<GarageFilter?> show({
    required BuildContext context,
    required GarageFilter initialFilter,
  }) {
    return showModalBottomSheet<GarageFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => GarageFilterSheet(initialFilter: initialFilter),
    );
  }

  @override
  ConsumerState<GarageFilterSheet> createState() => _GarageFilterSheetState();
}

class _GarageFilterSheetState extends ConsumerState<GarageFilterSheet> {
  late GarageFilter _filter;

  static const _statusOptions = [
    {'value': 'posted', 'label': 'Опубликовано в Гараже'},
    {'value': 'not_posted', 'label': 'Не опубликовано'},
  ];

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  Future<void> _pickOffice(List<Map<String, dynamic>> offices) async {
    final labels = offices.map((o) => o['address'] as String? ?? '').toList();

    final selected = await CustomSelectorBottomSheet.show(
      context: context,
      title: 'Адрес офиса',
      items: labels,
      selectedValue: _filter.officeLabel,
      activeColor: AppTheme.buttonColor,
    );

    if (selected != null) {
      final idx = labels.indexOf(selected);
      setState(() {
        _filter = _filter.copyWith(
          officeId: offices[idx]['office_id'] as String?,
          officeLabel: selected,
        );
      });
    }
  }

  Future<void> _pickCar(List<Map<String, dynamic>> cars) async {
    final labels = cars.map((c) {
      final number = c['number'] as String? ?? '';
      final brand = c['brand'] as String? ?? '';
      final model = c['model'] as String? ?? '';
      return '$number $brand $model'.trim();
    }).toList();

    final selected = await CustomSelectorBottomSheet.show(
      context: context,
      title: 'Автомобиль',
      items: labels,
      selectedValue: _filter.carLabel,
      activeColor: AppTheme.buttonColor,
    );

    if (selected != null) {
      final idx = labels.indexOf(selected);
      setState(() {
        _filter = _filter.copyWith(
          carId: cars[idx]['id'] as String?,
          carLabel: selected,
        );
      });
    }
  }

  Future<void> _pickStatus() async {
    final labels = _statusOptions.map((s) => s['label']!).toList();

    final selected = await CustomSelectorBottomSheet.show(
      context: context,
      title: 'Статус публикации',
      items: labels,
      selectedValue: _filter.statusLabel,
      showSearch: false,
      activeColor: AppTheme.buttonColor,
    );

    if (selected != null) {
      final idx = labels.indexOf(selected);
      setState(() {
        _filter = _filter.copyWith(
          status: _statusOptions[idx]['value'],
          statusLabel: selected,
        );
      });
    }
  }

  Widget _buildSelectorField({
    required String label,
    required bool isPlaceholder,
    VoidCallback? onTap,
    bool isLoading = false,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: isPlaceholder
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (!isPlaceholder && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
              )
            else
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final officesAsync = ref.watch(garageOfficesProvider);
    final carsAsync = ref.watch(garageCarsProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 72),
                  const Text(
                    'Фильтры',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Отмена'),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSelectorField(
                      label: _filter.officeLabel ?? 'Адрес офиса',
                      isPlaceholder: _filter.officeLabel == null,
                      onTap: () {
                        if (officesAsync.hasValue) _pickOffice(officesAsync.value!);
                      },
                      isLoading: officesAsync.isLoading,
                      onClear: _filter.officeLabel != null
                          ? () => setState(() => _filter = _filter.copyWith(clearOffice: true))
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildSelectorField(
                      label: _filter.carLabel ?? 'Автомобиль',
                      isPlaceholder: _filter.carLabel == null,
                      onTap: () {
                        if (carsAsync.hasValue) _pickCar(carsAsync.value!);
                      },
                      isLoading: carsAsync.isLoading,
                      onClear: _filter.carLabel != null
                          ? () => setState(() => _filter = _filter.copyWith(clearCar: true))
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildSelectorField(
                      label: _filter.statusLabel ?? 'Статус публикации',
                      isPlaceholder: _filter.statusLabel == null,
                      onTap: _pickStatus,
                      onClear: _filter.statusLabel != null
                          ? () => setState(() => _filter = _filter.copyWith(clearStatus: true))
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16, 8, 16, 16 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FadingButton(
                      onTap: () {
                        Navigator.of(context).pop(GarageFilter.empty);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.controlsColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Сбросить',
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
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FadingButton(
                      onTap: () {
                        Navigator.of(context).pop(_filter);
                      },
                      child: Container(
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
          ],
        ),
      ),
    );
  }
}
