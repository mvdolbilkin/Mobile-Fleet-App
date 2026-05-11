class LoyaltyProgramData {
  final List<Goal> goals;
  final ParkInfo parkInfo;

  LoyaltyProgramData({required this.goals, required this.parkInfo});

  factory LoyaltyProgramData.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgramData(
      goals: (json['goals'] as List).map((g) => Goal.fromJson(g)).toList(),
      parkInfo: ParkInfo.fromJson(json['park_info']),
    );
  }

  Goal? get currentGoal => goals.isNotEmpty ? goals.first : null;
}

class Goal {
  final String id;
  final String type;
  final String title;
  final String status;
  final Period period;
  final List<Reward> rewards;

  Goal({
    required this.id,
    required this.type,
    required this.title,
    required this.status,
    required this.period,
    required this.rewards,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      status: json['status'],
      period: Period.fromJson(json['period']),
      rewards: (json['rewards'] as List)
          .map((r) => Reward.fromJson(r))
          .toList(),
    );
  }

  String get periodText {
    // Use finish date to determine the month, as start date might be in previous month due to timezone
    final finish = DateTime.parse(period.finish);
    final months = [
      'январе',
      'феврале',
      'марте',
      'апреле',
      'мае',
      'июне',
      'июле',
      'августе',
      'сентябре',
      'октябре',
      'ноябре',
      'декабре',
    ];
    return 'Прогресс в ${months[finish.month - 1]}';
  }
}

class Period {
  final String start;
  final String finish;
  final String type;

  Period({required this.start, required this.finish, required this.type});

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      start: json['start'],
      finish: json['finish'],
      type: json['type'],
    );
  }
}

class Reward {
  final String title;
  final String? subtitle;
  final bool isCompleted;
  final String loyaltyStatus;
  final List<RewardItem> items;
  final int kpisToComplete;
  final List<KPI> keyPerformanceIndicators;

  Reward({
    required this.title,
    this.subtitle,
    required this.isCompleted,
    required this.loyaltyStatus,
    required this.items,
    required this.kpisToComplete,
    required this.keyPerformanceIndicators,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      title: json['title'],
      subtitle: json['subtitle'],
      isCompleted: json['is_completed'],
      loyaltyStatus: json['loyalty_status'],
      items: (json['items'] as List)
          .map((i) => RewardItem.fromJson(i))
          .toList(),
      kpisToComplete: json['kpis_to_complete'],
      keyPerformanceIndicators: (json['key_performance_indicators'] as List)
          .map((k) => KPI.fromJson(k))
          .toList(),
    );
  }

  List<RewardItem> get benefitItems =>
      items.where((item) => item.type == 'text').toList();

  String get iconAsset {
    switch (loyaltyStatus) {
      case 'basic':
        return 'assets/images/menu_loyalty_base.svg';
      case 'bronze':
        return 'assets/images/menu_loyalty_bronze.svg';
      case 'silver':
        return 'assets/images/menu_loyalty_silver.svg';
      case 'gold':
        return 'assets/images/menu_loyalty_silver.svg'; // Using silver for gold
      default:
        return 'assets/images/menu_loyalty_base.svg';
    }
  }
}

class RewardItem {
  final String type;
  final String value;

  RewardItem({required this.type, required this.value});

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(type: json['type'], value: json['value']);
  }
}

class KPI {
  final String type;
  final String title;
  final String status;
  final KPIValue value;

  KPI({
    required this.type,
    required this.title,
    required this.status,
    required this.value,
  });

  factory KPI.fromJson(Map<String, dynamic> json) {
    return KPI(
      type: json['type'],
      title: json['title'],
      status: json['status'],
      value: KPIValue.fromJson(json['value']),
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isNotCompleted => status == 'not_completed';
}

class KPIValue {
  final String type;
  final dynamic current;
  final dynamic target;
  final String order;

  KPIValue({
    required this.type,
    required this.current,
    required this.target,
    required this.order,
  });

  factory KPIValue.fromJson(Map<String, dynamic> json) {
    return KPIValue(
      type: json['type'],
      current: json['current'],
      target: json['target'],
      order: json['order'],
    );
  }
}

class ParkInfo {
  final String loyaltyStatus;

  ParkInfo({required this.loyaltyStatus});

  factory ParkInfo.fromJson(Map<String, dynamic> json) {
    return ParkInfo(loyaltyStatus: json['loyalty_status']);
  }
}
