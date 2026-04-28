import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/menu/models/problems_model.dart';
import 'package:mobile/features/menu/services/menu_service.dart';

// Provider for problems data
final problemsDataProvider = FutureProvider<ProblemsData>((ref) async {
  final menuService = ref.watch(menuServiceProvider);
  return await menuService.getProblems();
});
