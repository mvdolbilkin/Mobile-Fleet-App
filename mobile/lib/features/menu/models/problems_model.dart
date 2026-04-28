class ProblemsData {
  final int total;
  final List<ProblemBadge> badges;

  ProblemsData({
    required this.total,
    required this.badges,
  });

  factory ProblemsData.fromJson(Map<String, dynamic> json) {
    return ProblemsData(
      total: json['total'],
      badges: (json['badges'] as List)
          .map((b) => ProblemBadge.fromJson(b))
          .toList(),
    );
  }
}

class ProblemBadge {
  final String id;
  final ProblemIcon icon;
  final String text;
  final ProblemAction action;

  ProblemBadge({
    required this.id,
    required this.icon,
    required this.text,
    required this.action,
  });

  factory ProblemBadge.fromJson(Map<String, dynamic> json) {
    return ProblemBadge(
      id: json['id'],
      icon: ProblemIcon.fromJson(json['icon']),
      text: json['text'],
      action: ProblemAction.fromJson(json['action']),
    );
  }
}

class ProblemIcon {
  final int? value;
  final String? picture;

  ProblemIcon({
    this.value,
    this.picture,
  });

  factory ProblemIcon.fromJson(Map<String, dynamic> json) {
    return ProblemIcon(
      value: json['value'],
      picture: json['picture'],
    );
  }

  bool get hasValue => value != null;
  bool get hasPicture => picture != null;
}

class ProblemAction {
  final String actionType;
  final String? url;
  final bool? isUrlExternal;
  final String? scenarioId;
  final bool? openScenario;

  ProblemAction({
    required this.actionType,
    this.url,
    this.isUrlExternal,
    this.scenarioId,
    this.openScenario,
  });

  factory ProblemAction.fromJson(Map<String, dynamic> json) {
    return ProblemAction(
      actionType: json['action_type'],
      url: json['url'],
      isUrlExternal: json['is_url_external'],
      scenarioId: json['scenario_id'],
      openScenario: json['open_scenario'],
    );
  }
}
