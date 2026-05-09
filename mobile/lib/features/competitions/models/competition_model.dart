class CompetitionPeriod {
  final DateTime beginDate;
  final DateTime endDate;

  CompetitionPeriod({
    required this.beginDate,
    required this.endDate,
  });

  factory CompetitionPeriod.fromJson(Map<String, dynamic> json) {
    return CompetitionPeriod(
      beginDate: DateTime.parse(json['begin_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'begin_date': beginDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}

class Competition {
  final String id;
  final String name;
  final String status;
  final CompetitionPeriod competitionPeriod;

  Competition({
    required this.id,
    required this.name,
    required this.status,
    required this.competitionPeriod,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      competitionPeriod: CompetitionPeriod.fromJson(
        json['competition_period'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'competition_period': competitionPeriod.toJson(),
    };
  }

  String get statusText {
    switch (status) {
      case 'active':
        return 'Активный';
      case 'completed':
        return 'Завершен';
      case 'cancelled':
        return 'Отменен';
      case 'creation-failed':
        return 'Ошибка создания';
      default:
        return status;
    }
  }

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isCreationFailed => status == 'creation-failed';
}

class CompetitionsResponse {
  final List<Competition> competitions;

  CompetitionsResponse({
    required this.competitions,
  });

  factory CompetitionsResponse.fromJson(Map<String, dynamic> json) {
    return CompetitionsResponse(
      competitions: (json['competitions'] as List)
          .map((item) => Competition.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LocalizedItem {
  final String key;
  final String localizedName;

  LocalizedItem({
    required this.key,
    required this.localizedName,
  });

  factory LocalizedItem.fromJson(Map<String, dynamic> json) {
    return LocalizedItem(
      key: json['key'] as String,
      localizedName: json['localized_name'] as String,
    );
  }
}

class Prize {
  final String? amount;

  Prize({this.amount});

  factory Prize.fromJson(Map<String, dynamic> json) {
    return Prize(
      amount: json['amount'] as String?,
    );
  }
}

class Winner {
  final String dbidUuid;
  final String driverName;
  final String score;
  final int rank;
  final Prize? prize;

  Winner({
    required this.dbidUuid,
    required this.driverName,
    required this.score,
    required this.rank,
    this.prize,
  });

  factory Winner.fromJson(Map<String, dynamic> json) {
    return Winner(
      dbidUuid: json['dbid_uuid'] as String,
      driverName: json['driver_name'] as String,
      score: json['score'] as String,
      rank: json['rank'] as int,
      prize: json['prize'] != null
          ? Prize.fromJson(json['prize'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CompetitionDetails {
  final String name;
  final String status;
  final CompetitionPeriod competitionPeriod;
  final String scoreType;
  final String specification;
  final List<String> categories;
  final List<String> geoareas;
  final List<String> professions;
  final List<dynamic>? categoriesList;
  final List<LocalizedItem>? geoareasList;
  final List<LocalizedItem>? professionsList;
  final int participantsCount;
  final int winnerCount;
  final List<Winner> winnersParticipantList;
  final bool prizePaid;

  CompetitionDetails({
    required this.name,
    required this.status,
    required this.competitionPeriod,
    required this.scoreType,
    required this.specification,
    required this.categories,
    required this.geoareas,
    required this.professions,
    this.categoriesList,
    this.geoareasList,
    this.professionsList,
    required this.participantsCount,
    required this.winnerCount,
    required this.winnersParticipantList,
    required this.prizePaid,
  });

  factory CompetitionDetails.fromJson(Map<String, dynamic> json) {
    return CompetitionDetails(
      name: json['name'] as String,
      status: json['status'] as String,
      competitionPeriod: CompetitionPeriod.fromJson(
        json['competition_period'] as Map<String, dynamic>,
      ),
      scoreType: json['score_type'] as String,
      specification: json['specification'] as String,
      categories: (json['categories'] as List?)?.map((e) => e as String).toList() ?? [],
      geoareas: (json['geoareas'] as List?)?.map((e) => e as String).toList() ?? [],
      professions: (json['professions'] as List?)?.map((e) => e as String).toList() ?? [],
      categoriesList: json['categories_list'] as List?,
      geoareasList: (json['geoareas_list'] as List?)
          ?.map((e) => LocalizedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      professionsList: (json['professions_list'] as List?)
          ?.map((e) => LocalizedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      participantsCount: json['participants_count'] as int,
      winnerCount: json['winner_count'] as int,
      winnersParticipantList: (json['winners_participant_list'] as List?)
          ?.map((e) => Winner.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      prizePaid: json['prize_paid'] as bool,
    );
  }

  String get statusText {
    switch (status) {
      case 'active':
        return 'Активный';
      case 'completed':
        return 'Завершен';
      case 'cancelled':
        return 'Отменен';
      case 'creation-failed':
        return 'Ошибка создания';
      default:
        return status;
    }
  }

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}
