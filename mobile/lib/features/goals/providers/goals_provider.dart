import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/features/goals/models/goals_model.dart';
import 'package:mobile/features/goals/services/goals_service.dart';

final goalsServiceProvider = Provider<GoalsService>((ref) {
  final dio = ref.watch(dioProvider);
  return GoalsService(dio);
});

final currentGoalsProvider = FutureProvider<GoalsResponse>((ref) async {
  final service = ref.watch(goalsServiceProvider);
  
  // Get current month date range
  final now = DateTime.now();
  final firstDay = DateTime(now.year, now.month, 1);
  final lastDay = DateTime(now.year, now.month + 1, 0);
  
  final dateFrom = '${firstDay.year}-${firstDay.month.toString().padLeft(2, '0')}-${firstDay.day.toString().padLeft(2, '0')}';
  final dateTo = '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}';
  
  return service.getCurrentGoals(
    dateFrom: dateFrom,
    dateTo: dateTo,
  );
});

final previousGoalsProvider = FutureProvider<GoalsResponse>((ref) async {
  final service = ref.watch(goalsServiceProvider);
  
  // Get previous month date range
  final now = DateTime.now();
  final firstDayPrevMonth = DateTime(now.year, now.month - 1, 1);
  final lastDayPrevMonth = DateTime(now.year, now.month, 0);
  
  final dateFrom = '${firstDayPrevMonth.year}-${firstDayPrevMonth.month.toString().padLeft(2, '0')}-${firstDayPrevMonth.day.toString().padLeft(2, '0')}';
  final dateTo = '${lastDayPrevMonth.year}-${lastDayPrevMonth.month.toString().padLeft(2, '0')}-${lastDayPrevMonth.day.toString().padLeft(2, '0')}';
  
  return service.getPreviousGoals(
    dateFrom: dateFrom,
    dateTo: dateTo,
  );
});
