import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/menu/models/cars_model.dart';
import 'package:mobile/features/menu/services/menu_service.dart';
import 'package:mobile/features/menu/providers/date_range_provider.dart';

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

// Provider for cars data
final carsDataProvider = FutureProvider<CarsData>((ref) async {
  final menuService = ref.watch(menuServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return await menuService.getCarsWidget(
    dateFrom: _formatDate(dateRange.startDate),
    dateTo: _formatDate(dateRange.endDate),
  );
});
