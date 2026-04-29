class GoalsResponse {
  final List<Goal> goals;

  GoalsResponse({required this.goals});

  factory GoalsResponse.fromJson(Map<String, dynamic> json) {
    var goalsList = json['goals'] as List? ?? [];
    return GoalsResponse(
      goals: goalsList.map((e) => Goal.fromJson(e)).toList(),
    );
  }
}

class Goal {
  final String id;
  final String title;
  final String periodText;
  final List<Reward> rewards;
  final List<KeyPerformanceIndicator> keyPerformanceIndicators;

  Goal({
    required this.id,
    required this.title,
    required this.periodText,
    required this.rewards,
    this.keyPerformanceIndicators = const [],
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    var rewardsList = json['rewards'] as List? ?? [];
    var kpiList = json['key_performance_indicators'] as List? ?? [];
    
    return Goal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      periodText: json['period_text'] ?? '',
      rewards: rewardsList.map((e) => Reward.fromJson(e)).toList(),
      keyPerformanceIndicators: kpiList.map((e) => KeyPerformanceIndicator.fromJson(e)).toList(),
    );
  }
}

class Reward {
  final String id;
  final String title;
  final String? subtitle;
  final bool isCompleted;
  final List<BenefitItem> benefitItems;
  final List<KeyPerformanceIndicator> keyPerformanceIndicators;

  Reward({
    required this.id,
    required this.title,
    this.subtitle,
    required this.isCompleted,
    this.benefitItems = const [],
    this.keyPerformanceIndicators = const [],
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    var benefitsList = json['benefit_items'] as List? ?? [];
    var kpiList = json['key_performance_indicators'] as List? ?? [];
    
    return Reward(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      isCompleted: json['is_completed'] ?? false,
      benefitItems: benefitsList.map((e) => BenefitItem.fromJson(e)).toList(),
      keyPerformanceIndicators: kpiList.map((e) => KeyPerformanceIndicator.fromJson(e)).toList(),
    );
  }

  // Helper to get icon asset based on reward level
  String get iconAsset {
    switch (id.toLowerCase()) {
      case 'basic':
        return 'assets/images/menu_loyalty_base.svg';
      case 'bronze':
        return 'assets/images/menu_loyalty_bronze.svg';
      case 'silver':
        return 'assets/images/menu_loyalty_silver.svg';
      case 'gold':
        return 'assets/images/menu_loyalty_gold.svg';
      default:
        return 'assets/images/menu_loyalty_base.svg';
    }
  }
}

class BenefitItem {
  final String value;

  BenefitItem({required this.value});

  factory BenefitItem.fromJson(Map<String, dynamic> json) {
    return BenefitItem(
      value: json['value'] ?? '',
    );
  }
}

class KeyPerformanceIndicator {
  final String id;
  final String title;
  final bool isCompleted;
  final int? current;
  final int? target;
  final int? percent;

  KeyPerformanceIndicator({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.current,
    this.target,
    this.percent,
  });

  factory KeyPerformanceIndicator.fromJson(Map<String, dynamic> json) {
    return KeyPerformanceIndicator(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      current: json['current'],
      target: json['target'],
      percent: json['percent'],
    );
  }
}
