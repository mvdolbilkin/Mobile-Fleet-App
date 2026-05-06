import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/reports/domain/payment_transaction.dart'; // PaymentTransaction, PaymentTransactionDetail
import 'package:mobile/shared/api/dio_provider.dart';

final paymentTransactionsServiceProvider =
    Provider<PaymentTransactionsService>((ref) {
  return PaymentTransactionsService(ref.watch(dioProvider));
});

class PaymentTransactionsFilter {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final List<String> transactionTypes;
  final List<String> statuses;
  final List<String> errors;
  final String? paymentSystemId;
  final String? search;

  const PaymentTransactionsFilter({
    this.dateFrom,
    this.dateTo,
    this.transactionTypes = const [],
    this.statuses = const [],
    this.errors = const [],
    this.paymentSystemId,
    this.search,
  });

  bool get isModified =>
      dateFrom != null ||
      transactionTypes.isNotEmpty ||
      statuses.isNotEmpty ||
      errors.isNotEmpty ||
      paymentSystemId != null;

  PaymentTransactionsFilter copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    List<String>? transactionTypes,
    List<String>? statuses,
    List<String>? errors,
    String? paymentSystemId,
    String? search,
    bool clearDates = false,
  }) {
    return PaymentTransactionsFilter(
      dateFrom: clearDates ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDates ? null : (dateTo ?? this.dateTo),
      transactionTypes: transactionTypes ?? this.transactionTypes,
      statuses: statuses ?? this.statuses,
      errors: errors ?? this.errors,
      paymentSystemId: paymentSystemId ?? this.paymentSystemId,
      search: search ?? this.search,
    );
  }
}

class PaymentTransactionsService {
  final Dio _dio;
  PaymentTransactionsService(this._dio);

  static const _endpoint = '/api/payments/transactions/list';

  Future<PaymentTransactionListResponse> getTransactions({
    required PaymentTransactionsFilter filter,
    String? cursor,
  }) async {
    final tz = DateTime.now().timeZoneOffset;
    final sign = tz.isNegative ? '-' : '+';
    final h = tz.inHours.abs().toString().padLeft(2, '0');
    final m = (tz.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final tzStr = '$sign$h:$m';

    String _fmt(DateTime d) =>
        '${d.year}-${_p(d.month)}-${_p(d.day)}T00:00:00$tzStr';

    final query = <String, dynamic>{
      'time_range': (filter.dateFrom != null && filter.dateTo != null)
          ? {'from': _fmt(filter.dateFrom!), 'to': _fmt(filter.dateTo!)}
          : <String, dynamic>{},
    };
    if (filter.transactionTypes.isNotEmpty) {
      query['transaction_types'] = filter.transactionTypes;
    }
    if (filter.statuses.isNotEmpty) {
      query['statuses'] = filter.statuses;
    }
    if (filter.errors.isNotEmpty) {
      query['errors'] = filter.errors;
    }
    if (filter.paymentSystemId != null) {
      query['payment_system_id'] = filter.paymentSystemId;
    }

    final body = <String, dynamic>{'query': query};
    if (cursor != null) body['cursor'] = cursor;

    final resp = await _dio.post<Map<String, dynamic>>(
      _endpoint,
      data: body,
    );
    return PaymentTransactionListResponse.fromJson(resp.data!);
  }

  Future<PaymentTransactionDetail> getTransactionById({
    required String transactionId,
    required String transactionType,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/api/payments/transactions/by-id',
      queryParameters: {
        'transaction_id': transactionId,
        'transaction_type': transactionType,
      },
    );
    return PaymentTransactionDetail.fromJson(resp.data!);
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}
