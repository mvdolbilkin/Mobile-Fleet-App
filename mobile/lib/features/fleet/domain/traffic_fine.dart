class TrafficFine {
  final TrafficFineVehicle? vehicle;
  final TrafficFineContractor contractor;
  final TrafficFineDetails fine;
  final bool wasLoadedBankClient;
  final TrafficFineCompany? company;
  final DateTime loadedAt;

  const TrafficFine({
    this.vehicle,
    required this.contractor,
    required this.fine,
    required this.wasLoadedBankClient,
    this.company,
    required this.loadedAt,
  });

  factory TrafficFine.fromJson(Map<String, dynamic> json) {
    return TrafficFine(
      vehicle: json['vehicle'] != null
          ? TrafficFineVehicle.fromJson(json['vehicle'])
          : null,
      contractor: TrafficFineContractor.fromJson(json['contractor']),
      fine: TrafficFineDetails.fromJson(json['fine']),
      wasLoadedBankClient: json['was_loaded_bank_client'] ?? false,
      company: json['company'] != null
          ? TrafficFineCompany.fromJson(json['company'])
          : null,
      loadedAt: DateTime.parse(json['loaded_at']),
    );
  }
}

class TrafficFineVehicle {
  final String id;
  final String licensePlate;
  final String? registrationCert;
  final String brand;
  final String model;
  final bool isStoppedUpdatingFines;

  const TrafficFineVehicle({
    required this.id,
    required this.licensePlate,
    this.registrationCert,
    required this.brand,
    required this.model,
    required this.isStoppedUpdatingFines,
  });

  factory TrafficFineVehicle.fromJson(Map<String, dynamic> json) {
    return TrafficFineVehicle(
      id: json['id'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      registrationCert: json['registration_cert'],
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      isStoppedUpdatingFines: json['is_stopped_updating_fines'] ?? false,
    );
  }

  String get displayName => '$brand $model';
}

class TrafficFineContractor {
  final String status;
  final String? contractorId;
  final String? name;
  final TrafficFinePayment payment;

  const TrafficFineContractor({
    required this.status,
    this.contractorId,
    this.name,
    required this.payment,
  });

  factory TrafficFineContractor.fromJson(Map<String, dynamic> json) {
    return TrafficFineContractor(
      status: json['status'] ?? 'planned',
      contractorId: json['contractor_id'],
      name: json['name'],
      payment: TrafficFinePayment.fromJson(json['payment'] ?? {}),
    );
  }

  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (status == 'missing') return 'Определяем водителя';
    if (status == 'planned') return 'Определяем водителя';
    return 'Не назначен';
  }
}

class TrafficFinePayment {
  final String status;
  final String? amount;

  const TrafficFinePayment({
    required this.status,
    this.amount,
  });

  factory TrafficFinePayment.fromJson(Map<String, dynamic> json) {
    return TrafficFinePayment(
      status: json['status'] ?? 'planned',
      amount: json['amount']?.toString(),
    );
  }
}

class TrafficFineDetails {
  final String uin;
  final String status;
  final DateTime issuedAt;
  final String? issuedBy;
  final String amount;
  final String paidAmount;
  final TrafficFineDiscount? discount;
  final String payment;
  final DateTime? offenseAt;
  final String? offenseAddress;
  final String? article;
  final int numberOfPhotos;
  final String? paymentLink;

  const TrafficFineDetails({
    required this.uin,
    required this.status,
    required this.issuedAt,
    this.issuedBy,
    required this.amount,
    required this.paidAmount,
    this.discount,
    required this.payment,
    this.offenseAt,
    this.offenseAddress,
    this.article,
    required this.numberOfPhotos,
    this.paymentLink,
  });

  factory TrafficFineDetails.fromJson(Map<String, dynamic> json) {
    return TrafficFineDetails(
      uin: json['uin'] ?? '',
      status: json['status'] ?? 'issued',
      issuedAt: DateTime.parse(json['issued_at']),
      issuedBy: json['issued_by'],
      amount: json['amount']?.toString() ?? '0',
      paidAmount: json['paid_amount']?.toString() ?? '0',
      discount: json['discount'] != null
          ? TrafficFineDiscount.fromJson(json['discount'])
          : null,
      payment: json['payment']?.toString() ?? '0',
      offenseAt: json['offense_at'] != null
          ? DateTime.parse(json['offense_at'])
          : null,
      offenseAddress: json['offense_address'],
      article: json['article'],
      numberOfPhotos: json['number_of_photos'] ?? 0,
      paymentLink: json['payment_link'],
    );
  }

  String get statusDisplayName {
    switch (status) {
      case 'issued':
        return 'Не оплачен';
      case 'paid':
        return 'Оплачен';
      case 'overdue':
        return 'Просрочен';
      default:
        return status;
    }
  }
}

class TrafficFineDiscount {
  final String amount;
  final DateTime until;

  const TrafficFineDiscount({
    required this.amount,
    required this.until,
  });

  factory TrafficFineDiscount.fromJson(Map<String, dynamic> json) {
    return TrafficFineDiscount(
      amount: json['amount']?.toString() ?? '0',
      until: DateTime.parse(json['until']),
    );
  }
}

class TrafficFineCompany {
  final String title;
  final String? inn;
  final String? kpp;

  const TrafficFineCompany({
    required this.title,
    this.inn,
    this.kpp,
  });

  factory TrafficFineCompany.fromJson(Map<String, dynamic> json) {
    final requisites = json['requisites'] as Map<String, dynamic>?;
    return TrafficFineCompany(
      title: json['title'] ?? '',
      inn: requisites?['inn'],
      kpp: requisites?['kpp'],
    );
  }
}

class TrafficFinesTotal {
  final int count;
  final String sum;

  const TrafficFinesTotal({required this.count, required this.sum});

  factory TrafficFinesTotal.fromJson(Map<String, dynamic> json) {
    final total = json['total'] as Map<String, dynamic>? ?? json;
    return TrafficFinesTotal(
      count: total['count'] ?? 0,
      sum: total['sum']?.toString() ?? '0',
    );
  }
}

enum FineStatusFilter {
  all,
  unpaid,
  paymentSent,
  paid,
  overdue,
}

extension FineStatusFilterExt on FineStatusFilter {
  String get displayName {
    switch (this) {
      case FineStatusFilter.all:
        return 'Все';
      case FineStatusFilter.unpaid:
        return 'Неоплаченные';
      case FineStatusFilter.paymentSent:
        return 'Оплата отправлена';
      case FineStatusFilter.paid:
        return 'Оплаченные';
      case FineStatusFilter.overdue:
        return 'Просроченные';
    }
  }
}
