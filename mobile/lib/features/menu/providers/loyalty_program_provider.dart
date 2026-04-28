import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/menu/models/loyalty_program_model.dart';
import 'package:mobile/features/menu/services/menu_service.dart';

// Provider for loyalty program data
final loyaltyProgramDataProvider = FutureProvider<LoyaltyProgramData>((ref) async {
  final menuService = ref.watch(menuServiceProvider);
  return await menuService.getLoyaltyProgram();
});
