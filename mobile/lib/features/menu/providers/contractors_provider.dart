import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/menu/models/contractors_model.dart';
import 'package:mobile/features/menu/services/menu_service.dart';

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

// Provider for contractors data
final contractorsDataProvider = FutureProvider<ContractorsData>((ref) async {
  final menuService = ref.watch(menuServiceProvider);
  
  // Default to last 7 days
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  
  return await menuService.getContractorsWidget(
    dateFrom: _formatDate(weekAgo),
    dateTo: _formatDate(now),
  );
});
