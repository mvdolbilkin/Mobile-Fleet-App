import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/work_rules/models/work_rule_model.dart';
import 'package:mobile/shared/api/dio_provider.dart';

class WorkRulesRepository {
  final Dio _dio;

  WorkRulesRepository(this._dio);

  Future<WorkRulesResponse> getWorkRules({required bool isArchived}) async {
    try {
      final response = await _dio.get(
        '/api/work-rules/list',
        queryParameters: {
          'is_archived': isArchived.toString(),
        },
      );

      return WorkRulesResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch work rules: $e');
    }
  }

  Future<WorkRuleDetails> getWorkRuleDetails({required String workRuleId}) async {
    try {
      final response = await _dio.get(
        '/api/work-rules/details',
        queryParameters: {
          'work_rule_id': workRuleId,
        },
      );

      return WorkRuleDetails.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch work rule details: $e');
    }
  }
}

final workRulesRepositoryProvider = Provider<WorkRulesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return WorkRulesRepository(dio);
});

final workRulesProvider = FutureProvider.family<WorkRulesResponse, bool>((ref, isArchived) async {
  final repository = ref.watch(workRulesRepositoryProvider);
  return repository.getWorkRules(isArchived: isArchived);
});

final workRuleDetailsProvider = FutureProvider.family<WorkRuleDetails, String>((ref, workRuleId) async {
  final repository = ref.watch(workRulesRepositoryProvider);
  return repository.getWorkRuleDetails(workRuleId: workRuleId);
});
