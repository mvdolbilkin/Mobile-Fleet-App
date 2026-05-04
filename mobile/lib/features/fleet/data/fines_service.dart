import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mobile/features/fleet/domain/traffic_fine.dart';
import 'package:logger/logger.dart';

class FinesService {
  final Dio _dio;

  FinesService(this._dio);

  Future<FinesRetrieveResult> retrieveFines({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? carId,
    String? fineUin,
    String? cursor,
    Logger? logger,
  }) async {
    final query = <String, dynamic>{};

    String _formatIso(DateTime dt) {
      final s = dt.toUtc().toIso8601String().split('.')[0];
      return '${s}Z';
    }

    if (dateFrom != null && dateTo != null) {
      var to = dateTo;
      // Если время полночь — значит выбрана просто дата, ставим конец дня
      if (to.hour == 0 && to.minute == 0 && to.second == 0) {
        to = DateTime(to.year, to.month, to.day, 23, 59, 59);
      }

      query['time_range'] = {
        'from': _formatIso(dateFrom),
        'to': _formatIso(to),
      };
    }

    if (carId != null && carId.isNotEmpty) {
      query['car_id'] = carId;
    }

    if (fineUin != null && fineUin.isNotEmpty) {
      query['fine_uin'] = fineUin;
    }

    final body = <String, dynamic>{
      'query': query,
    };

    if (cursor != null && cursor.isNotEmpty) {
      body['cursor'] = cursor;
    }

    logger?.d('[FinesService] POST /api/fines/retrieve | body: ${jsonEncode(body)}');

    try {
      final response = await _dio.post(
        '/api/fines/retrieve',
        data: body,
      );

      logger?.d('[FinesService] Response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final finesList = (data['fines'] as List<dynamic>? ?? [])
            .map((e) => TrafficFine.fromJson(e as Map<String, dynamic>))
            .toList();
        final nextCursor = data['cursor'] as String?;

        return FinesRetrieveResult(
          fines: finesList,
          cursor: nextCursor,
        );
      }

      throw Exception('Failed to retrieve fines: status=${response.statusCode}');
    } on DioException catch (e) {
      logger?.e('[FinesService] DioException: ${e.type} | ${e.message} | ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      logger?.e('[FinesService] Exception: $e');
      rethrow;
    }
  }

  Future<TrafficFine> getFineDetail(String uin) async {
    final response = await _dio.get(
      '/api/fines/detail',
      queryParameters: {'uin': uin},
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final fine = data['fine'] as Map<String, dynamic>?;
      if (fine != null) {
        return TrafficFine.fromJson(fine);
      }
    }

    throw Exception('Failed to get fine detail for uin=$uin');
  }

  Future<TrafficFinesTotal> getTotal() async {
    final response = await _dio.post(
      '/api/fines/total',
      data: {'query': {}},
    );

    if (response.statusCode == 200 && response.data != null) {
      return TrafficFinesTotal.fromJson(response.data as Map<String, dynamic>);
    }

    throw Exception('Failed to get fines total');
  }
}

class FinesRetrieveResult {
  final List<TrafficFine> fines;
  final String? cursor;

  const FinesRetrieveResult({
    required this.fines,
    this.cursor,
  });
}
