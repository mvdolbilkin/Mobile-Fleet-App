class Mailing {
  final String id;
  final String type;
  final String author;
  final String preview;
  final DateTime? sentAt;
  final int? sentToNumber;
  final int? readByNumber;
  final int? readPercent;
  final bool isLegacy;
  final String status;
  final DateTime? deletedAt;
  final String? deletedBy;

  Mailing({
    required this.id,
    required this.type,
    required this.author,
    required this.preview,
    this.sentAt,
    this.sentToNumber,
    this.readByNumber,
    this.readPercent,
    required this.isLegacy,
    required this.status,
    this.deletedAt,
    this.deletedBy,
  });

  factory Mailing.fromJson(Map<String, dynamic> json) {
    return Mailing(
      id: json['id'] as String,
      type: json['type'] as String,
      author: json['author'] as String,
      preview: json['preview'] as String,
      sentAt: json['sent_at'] != null 
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      sentToNumber: json['sent_to_number'] as int?,
      readByNumber: json['read_by_number'] as int?,
      readPercent: json['read_percent'] as int?,
      isLegacy: json['is_legacy'] as bool,
      status: json['status'] as String,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      deletedBy: json['deleted_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'author': author,
      'preview': preview,
      'sent_at': sentAt?.toIso8601String(),
      'sent_to_number': sentToNumber,
      'read_by_number': readByNumber,
      'read_percent': readPercent,
      'is_legacy': isLegacy,
      'status': status,
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
    };
  }

  String get statusText {
    switch (status) {
      case 'sent':
        return 'Отправлено';
      case 'deleted_by_dispatcher':
        return 'Удалено';
      default:
        return status;
    }
  }

  bool get isDeleted => status == 'deleted_by_dispatcher';
}

class MailingsResponse {
  final List<Mailing> mailings;
  final String? cursor;

  MailingsResponse({
    required this.mailings,
    this.cursor,
  });

  factory MailingsResponse.fromJson(Map<String, dynamic> json) {
    return MailingsResponse(
      mailings: (json['mailings'] as List)
          .map((item) => Mailing.fromJson(item as Map<String, dynamic>))
          .toList(),
      cursor: json['cursor'] as String?,
    );
  }
}

class MailingRecipients {
  final Map<String, dynamic> filters;
  final List<String> includedContractorIds;
  final List<String> excludedContractorIds;

  MailingRecipients({
    required this.filters,
    required this.includedContractorIds,
    required this.excludedContractorIds,
  });

  factory MailingRecipients.fromJson(Map<String, dynamic> json) {
    return MailingRecipients(
      filters: json['filters'] as Map<String, dynamic>? ?? {},
      includedContractorIds: (json['included_contractor_ids'] as List?)
          ?.map((e) => e as String)
          .toList() ?? [],
      excludedContractorIds: (json['excluded_contractor_ids'] as List?)
          ?.map((e) => e as String)
          .toList() ?? [],
    );
  }
}

class MailingTemplate {
  final String message;
  final String title;
  final String operationId;
  final MailingRecipients recipients;
  final String type;

  MailingTemplate({
    required this.message,
    required this.title,
    required this.operationId,
    required this.recipients,
    required this.type,
  });

  factory MailingTemplate.fromJson(Map<String, dynamic> json) {
    return MailingTemplate(
      message: json['message'] as String,
      title: json['title'] as String,
      operationId: json['operation_id'] as String,
      recipients: MailingRecipients.fromJson(json['recipients'] as Map<String, dynamic>),
      type: json['type'] as String,
    );
  }
}

class MailingDetails {
  final MailingTemplate mailingTemplate;
  final Mailing mailingSummary;

  MailingDetails({
    required this.mailingTemplate,
    required this.mailingSummary,
  });

  factory MailingDetails.fromJson(Map<String, dynamic> json) {
    return MailingDetails(
      mailingTemplate: MailingTemplate.fromJson(json['mailing_template'] as Map<String, dynamic>),
      mailingSummary: Mailing.fromJson(json['mailing_summary'] as Map<String, dynamic>),
    );
  }
}
