import 'package:dio/dio.dart';
import 'package:mobile/features/summary/models/profile_model.dart';
import 'package:mobile/features/summary/models/active_drivers_model.dart';
import 'package:intl/intl.dart';

class SummaryService {
  final Dio _client;
  static final _fmt = DateFormat('yyyy-MM-dd');

  SummaryService(this._client);

  Future<ProfileResponse> getProfile() async {
    final response = await _client.get('/api/summary/profile');
    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(response.data);
    } else {
      throw Exception('Не удалось загрузить данные профиля: ${response.statusMessage}');
    }
  }

  // ─── generic series POST ───────────────────────────────────────────────────
  Future<ActiveDriversResponse> _postSeries(
    String path,
    DateTime from,
    DateTime to, {
    Map<String, dynamic> extra = const {},
  }) async {
    final response = await _client.post(path, data: {
      'date_from': _fmt.format(from),
      'date_to': _fmt.format(to.add(const Duration(days: 1))),
      ...extra,
    });
    if (response.statusCode == 200) {
      return ActiveDriversResponse.fromJson(response.data);
    }
    throw Exception('Ошибка: ${response.statusMessage}');
  }

  Future<ActiveDriversResponse> getActiveDrivers(DateTime from, DateTime to) =>
      _postSeries('/api/summary/active-drivers', from, to);

  Future<ActiveDriversResponse> getOrders(DateTime from, DateTime to, String group) =>
      _postSeries('/api/summary/orders', from, to, extra: {'group': group});

  Future<ActiveDriversResponse> getSupplyHours(DateTime from, DateTime to) =>
      _postSeries('/api/summary/supply-hours', from, to);

  Future<ActiveDriversResponse> getProfit(DateTime from, DateTime to) =>
      _postSeries('/api/summary/profit', from, to);

  Future<ActiveDriversResponse> getOrdersSum(DateTime from, DateTime to) =>
      _postSeries('/api/summary/orders-sum', from, to);

  Future<Map<String, dynamic>> getCertification() async {
    final response = await _client.get('/api/summary/certification');
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(response.data);
    }
    throw Exception('Ошибка: ${response.statusMessage}');
  }
}
