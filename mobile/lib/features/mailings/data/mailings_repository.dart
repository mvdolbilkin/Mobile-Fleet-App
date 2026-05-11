import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/mailings/models/mailing_model.dart';
import 'package:mobile/shared/api/dio_provider.dart';

class MailingsRepository {
  final Dio _dio;

  MailingsRepository(this._dio);

  Future<MailingsResponse> getMailings({
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final response = await _dio.post(
        '/api/mailings/list',
        data: {
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );

      return MailingsResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching mailings: $e');
      rethrow;
    }
  }

  Future<MailingDetails> getMailingDetails(String mailingId) async {
    try {
      final response = await _dio.get(
        '/api/mailings/details',
        queryParameters: {
          'id': mailingId,
        },
      );

      return MailingDetails.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching mailing details: $e');
      rethrow;
    }
  }
}

final mailingsRepositoryProvider = Provider<MailingsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MailingsRepository(dio);
});

final mailingsProvider = FutureProvider<MailingsResponse>((ref) async {
  final repository = ref.watch(mailingsRepositoryProvider);
  return repository.getMailings();
});

final mailingDetailsProvider = FutureProvider.family<MailingDetails, String>((ref, mailingId) async {
  final repository = ref.watch(mailingsRepositoryProvider);
  return repository.getMailingDetails(mailingId);
});
