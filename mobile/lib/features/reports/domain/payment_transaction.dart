class PaymentTransactionContractor {
  final String id;
  final String name;
  final String? avatarUrl;

  const PaymentTransactionContractor({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory PaymentTransactionContractor.fromJson(Map<String, dynamic> j) =>
      PaymentTransactionContractor(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        avatarUrl: j['avatar_url'] as String?,
      );
}

class PaymentTransaction {
  final String id;
  final String amount;
  final PaymentTransactionContractor contractor;
  final DateTime createdAt;
  final String? paymentSystemLogoUrl;
  final String? paymentSystemProvider;
  final String? status;
  final String transactionType;
  final String? errorText;

  const PaymentTransaction({
    required this.id,
    required this.amount,
    required this.contractor,
    required this.createdAt,
    this.paymentSystemLogoUrl,
    this.paymentSystemProvider,
    this.status,
    required this.transactionType,
    this.errorText,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> j) {
    final contractorRaw = j['contractor'];
    return PaymentTransaction(
      id: (j['id'] ?? '').toString(),
      amount: (j['amount'] ?? '0').toString(),
      contractor: contractorRaw is Map<String, dynamic>
          ? PaymentTransactionContractor.fromJson(contractorRaw)
          : PaymentTransactionContractor(id: '', name: 'Неизвестно'),
      createdAt: j['created_at'] != null
          ? DateTime.parse(j['created_at'] as String)
          : DateTime.now(),
      paymentSystemLogoUrl: j['payment_system_logo_url']?.toString(),
      paymentSystemProvider: j['payment_system_provider']?.toString(),
      status: j['status']?.toString(),
      transactionType: (j['transaction_type'] ?? '').toString(),
      errorText: j['error_text']?.toString(),
    );
  }

  bool get isError => status == 'error';
  bool get isCompleted => status == 'completed';
  bool get isTopup => transactionType == 'topup';

  String get typeLabel {
    switch (transactionType) {
      case 'instant_payout':
        return 'Моментальная выплата';
      case 'topup':
        return 'Пополнение';
      case 'statement_payout':
        return 'Ведомость';
      case 'single_payout':
        return 'Выплата';
      default:
        return transactionType;
    }
  }

  String get amountFormatted {
    final val = double.tryParse(amount) ?? 0;
    final abs = val.abs();
    final formatted = abs == abs.truncateToDouble()
        ? '${abs.toInt()},00'
        : abs.toStringAsFixed(2).replaceAll('.', ',');
    return isTopup ? '+$formatted' : '-$formatted';
  }
}

class PaymentTransactionDetail {
  final String id;
  final String amount;
  final PaymentTransactionContractor contractor;
  final DateTime createdAt;
  final String? parkReceived;
  final String? driverBalanceTopup;
  final String? partnerFee;
  final String? driverReceived;
  final String? paymentSystemProvider;
  final String? status;
  final String transactionType;
  final String? errorText;

  const PaymentTransactionDetail({
    required this.id,
    required this.amount,
    required this.contractor,
    required this.createdAt,
    this.parkReceived,
    this.driverBalanceTopup,
    this.partnerFee,
    this.driverReceived,
    this.paymentSystemProvider,
    this.status,
    required this.transactionType,
    this.errorText,
  });

  factory PaymentTransactionDetail.fromJson(Map<String, dynamic> j) {
    final contractorRaw = j['contractor'];
    return PaymentTransactionDetail(
      id: (j['id'] ?? '').toString(),
      amount: (j['amount'] ?? '0').toString(),
      contractor: contractorRaw is Map<String, dynamic>
          ? PaymentTransactionContractor.fromJson(contractorRaw)
          : PaymentTransactionContractor(id: '', name: 'Неизвестно'),
      createdAt: j['created_at'] != null
          ? DateTime.parse(j['created_at'] as String)
          : DateTime.now(),
      parkReceived: j['park_received']?.toString(),
      driverBalanceTopup: j['driver_balance_topup']?.toString(),
      partnerFee: j['partner_fee']?.toString(),
      driverReceived: j['driver_received']?.toString(),
      paymentSystemProvider: j['payment_system_provider']?.toString(),
      status: j['status']?.toString(),
      transactionType: (j['transaction_type'] ?? '').toString(),
      errorText: j['error_text']?.toString(),
    );
  }

  bool get isTopup => transactionType == 'topup';

  String get typeLabel {
    switch (transactionType) {
      case 'instant_payout':
        return 'Моментальная выплата';
      case 'topup':
        return 'Пополнение';
      case 'statement_payout':
        return 'Ведомость';
      case 'single_payout':
        return 'Выплата';
      default:
        return transactionType;
    }
  }

  String get amountFormatted {
    final val = double.tryParse(amount) ?? 0;
    final abs = val.abs();
    final formatted = abs == abs.truncateToDouble()
        ? '${abs.toInt()},00'
        : abs.toStringAsFixed(2).replaceAll('.', ',');
    return isTopup ? '+$formatted' : '-$formatted';
  }

  String _fmtMoney(String? v) {
    if (v == null) return '—';
    final val = double.tryParse(v) ?? 0;
    return val == val.truncateToDouble()
        ? '${val.toInt()},00 ₽'
        : '${val.toStringAsFixed(2).replaceAll('.', ',')} ₽';
  }

  String get parkReceivedFmt => _fmtMoney(parkReceived);
  String get driverBalanceFmt => _fmtMoney(driverBalanceTopup);
  String get driverReceivedFmt => _fmtMoney(driverReceived);
  String get partnerFeeFmt => _fmtMoney(partnerFee);
}

class PaymentTransactionListResponse {
  final List<PaymentTransaction> transactions;
  final String? cursor;

  const PaymentTransactionListResponse({
    required this.transactions,
    this.cursor,
  });

  factory PaymentTransactionListResponse.fromJson(Map<String, dynamic> j) {
    final list = (j['transactions'] as List<dynamic>? ?? [])
        .map((e) => PaymentTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
    return PaymentTransactionListResponse(
      transactions: list,
      cursor: j['cursor'] as String?,
    );
  }
}
