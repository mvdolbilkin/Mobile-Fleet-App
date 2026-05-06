import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/competitions/models/competition_model.dart';
import 'package:mobile/shared/api/dio_provider.dart';

class CompetitionsRepository {
  final Dio _dio;

  CompetitionsRepository(this._dio);

  Future<CompetitionsResponse> getCompetitions() async {
    try {
      final response = await _dio.post(
        '/api/competitions/list',
        data: {},
      );

      return CompetitionsResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching competitions: $e');
      rethrow;
    }
  }

  Future<CompetitionDetails> getCompetitionDetails(String competitionUuid) async {
    try {
      final response = await _dio.post(
        '/api/competitions/details',
        data: {
          'competition_uuid': competitionUuid,
        },
      );

      return CompetitionDetails.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching competition details: $e');
      rethrow;
    }
  }
}

final competitionsRepositoryProvider = Provider<CompetitionsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CompetitionsRepository(dio);
});

final competitionsProvider = FutureProvider<CompetitionsResponse>((ref) async {
  final repository = ref.watch(competitionsRepositoryProvider);
  return repository.getCompetitions();
});

final competitionDetailsProvider = FutureProvider.family<CompetitionDetails, String>((ref, competitionUuid) async {
  final repository = ref.watch(competitionsRepositoryProvider);
  return repository.getCompetitionDetails(competitionUuid);
});
