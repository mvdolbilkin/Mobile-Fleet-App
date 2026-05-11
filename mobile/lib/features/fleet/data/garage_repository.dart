import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/api/dio_provider.dart';
import 'package:mobile/shared/providers/logger_provider.dart';
import 'package:mobile/features/fleet/domain/posting.dart';

final garageRepositoryProvider = Provider<GarageRepository>((ref) {
  return GarageRepository(
    dio: ref.watch(dioProvider),
    logger: ref.watch(loggerProvider),
  );
});

class PostingsListResponse {
  final List<Posting> postings;
  final int total;
  final String? cursor;

  PostingsListResponse({
    required this.postings,
    required this.total,
    this.cursor,
  });
}

class GarageRepository {
  final Dio dio;
  final dynamic logger;

  GarageRepository({required this.dio, required this.logger});

  Future<PostingsListResponse> getPostingsList({
    required String parkId,
    int limit = 20,
    String? cursor,
    Map<String, dynamic>? query,
  }) async {
    try {
      logger.i('Fetching postings list for park: $parkId');

      final data = <String, dynamic>{
        'query': query ?? {},
        'limit': limit,
      };
      if (cursor != null) {
        data['cursor'] = cursor;
      }

      final response = await dio.post(
        '/api/garage/postings/list',
        data: data,
        options: Options(headers: {'X-Park-ID': parkId}),
      );

      final responseData = response.data as Map<String, dynamic>;
      final postingsJson = responseData['postings'] as List<dynamic>? ?? [];
      final postings = postingsJson
          .map((e) => Posting.fromJson(e as Map<String, dynamic>))
          .toList();

      return PostingsListResponse(
        postings: postings,
        total: responseData['total'] as int? ?? 0,
        cursor: responseData['cursor'] as String?,
      );
    } on DioException catch (e) {
      logger.e('Failed to fetch postings list: ${e.message}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOfficeAddressList({
    required String parkId,
  }) async {
    try {
      final response = await dio.post(
        '/api/garage/offices/list',
        data: {},
        options: Options(headers: {'X-Park-ID': parkId}),
      );

      final data = response.data as Map<String, dynamic>;
      final offices = data['offices'] as List<dynamic>? ?? [];
      return offices.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      logger.e('Failed to fetch office list: ${e.message}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCarsSuggest({
    required String parkId,
  }) async {
    try {
      final response = await dio.get(
        '/api/garage/cars/suggest',
        options: Options(headers: {'X-Park-ID': parkId}),
      );

      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      return items.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      logger.e('Failed to fetch cars suggest: ${e.message}');
      rethrow;
    }
  }
}
