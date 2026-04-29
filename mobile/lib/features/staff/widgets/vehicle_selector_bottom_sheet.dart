import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/staff/data/staff_repository.dart';

class VehicleSelectorBottomSheet extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onVehicleSelected;

  const VehicleSelectorBottomSheet({
    super.key,
    required this.onVehicleSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required Function(Map<String, dynamic>) onVehicleSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VehicleSelectorBottomSheet(
        onVehicleSelected: onVehicleSelected,
      ),
    );
  }

  @override
  ConsumerState<VehicleSelectorBottomSheet> createState() =>
      _VehicleSelectorBottomSheetState();
}

class _VehicleSelectorBottomSheetState
    extends ConsumerState<VehicleSelectorBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allVehicles = [];
  List<Map<String, dynamic>> _filteredVehicles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _searchController.addListener(_filterVehicles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final repository = ref.read(staffRepositoryProvider);
      final vehicles = await repository.fetchVehicleSuggestions(limit: 100);

      setState(() {
        _allVehicles = vehicles;
        _filteredVehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterVehicles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredVehicles = _allVehicles;
      } else {
        _filteredVehicles = _allVehicles.where((vehicle) {
          final brand = (vehicle['brand'] as String? ?? '').toLowerCase();
          final model = (vehicle['model'] as String? ?? '').toLowerCase();
          final number = (vehicle['number'] as String? ?? '').toLowerCase();
          final color = (vehicle['color'] as String? ?? '').toLowerCase();
          return brand.contains(query) ||
              model.contains(query) ||
              number.contains(query) ||
              color.contains(query);
        }).toList();
      }
    });
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'working':
        return 'Работает';
      case 'no_driver':
        return 'Без водителя';
      default:
        return status ?? '—';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'working':
        return const Color(0xFF34C759);
      case 'no_driver':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Выбор автомобиля',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Yandex Sans Text',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по марке, модели, номеру...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                filled: true,
                fillColor: AppTheme.cardColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Ошибка загрузки: $_error',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadVehicles,
                                child: const Text('Повторить'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredVehicles.isEmpty
                        ? const Center(
                            child: Text(
                              'Автомобили не найдены',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredVehicles.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final vehicle = _filteredVehicles[index];
                              return InkWell(
                                onTap: () {
                                  widget.onVehicleSelected(vehicle);
                                  Navigator.of(context).pop();
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppTheme.cardColor,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.directions_car,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${vehicle['brand']} ${vehicle['model']}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Yandex Sans Text',
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  vehicle['number'] ?? '—',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '•',
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  vehicle['color'] ?? '—',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '•',
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  vehicle['year']?.toString() ??
                                                      '—',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                        vehicle['status'])
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                _getStatusText(
                                                    vehicle['status']),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: _getStatusColor(
                                                      vehicle['status']),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
