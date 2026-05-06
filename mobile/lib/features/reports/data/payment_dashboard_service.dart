import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/reports/domain/payment_dashboard.dart';
import 'package:mobile/shared/api/dio_provider.dart';

final paymentDashboardServiceProvider =
    Provider<PaymentDashboardService>((ref) {
  return PaymentDashboardService(ref.watch(dioProvider));
});

class PaymentDashboardService {
  final Dio _dio;
  PaymentDashboardService(this._dio);

  static const _payoutTypes = ['single_payout', 'instant_payout', 'statement_payout'];
  static const _topupTypes = ['topup'];

  Map<String, dynamic> _body(String from, String to, bool isTopup) => {
        'date_period': {'from': from, 'to': to},
        'filters': {'transaction_types': isTopup ? _topupTypes : _payoutTypes},
      };

  Future<DashboardWidgetResponse> getTransactionsSummary({
    required String from,
    required String to,
    required bool isTopup,
  }) async {
    final r = await _dio.post('api/payments/dashboard/transactions/summary',
        data: _body(from, to, isTopup));
    return DashboardWidgetResponse.fromJson(r.data as Map<String, dynamic>);
  }

  Future<DashboardWidgetResponse> getFeesSummary({
    required String from,
    required String to,
    required bool isTopup,
  }) async {
    final r = await _dio.post('api/payments/dashboard/fees/summary',
        data: _body(from, to, isTopup));
    return DashboardWidgetResponse.fromJson(r.data as Map<String, dynamic>);
  }

  Future<TransactionDriversResponse> getTransactionsDrivers({
    required String from,
    required String to,
    required bool isTopup,
  }) async {
    final r = await _dio.post('api/payments/dashboard/transactions/drivers',
        data: _body(from, to, isTopup));
    return TransactionDriversResponse.fromJson(r.data as Map<String, dynamic>);
  }

  Future<DashboardWidgetResponse> getTransactionsCount({
    required String from,
    required String to,
    required bool isTopup,
  }) async {
    final r = await _dio.post('api/payments/dashboard/transactions/count',
        data: _body(from, to, isTopup));
    return DashboardWidgetResponse.fromJson(r.data as Map<String, dynamic>);
  }

  Future<TransactionStatusesResponse> getTransactionsStatuses({
    required String from,
    required String to,
    required bool isTopup,
  }) async {
    final r = await _dio.post('api/payments/dashboard/transactions/statuses',
        data: _body(from, to, isTopup));
    return TransactionStatusesResponse.fromJson(r.data as Map<String, dynamic>);
  }
}
