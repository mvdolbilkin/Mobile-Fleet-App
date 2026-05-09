class WorkRule {
  final String id;
  final bool canArchive;
  final bool canEdit;
  final bool canSetDefault;
  final String name;
  final bool isArchived;
  final bool isDefault;
  final int contractorsCount;

  WorkRule({
    required this.id,
    required this.canArchive,
    required this.canEdit,
    required this.canSetDefault,
    required this.name,
    required this.isArchived,
    required this.isDefault,
    required this.contractorsCount,
  });

  factory WorkRule.fromJson(Map<String, dynamic> json) {
    return WorkRule(
      id: json['id'] as String,
      canArchive: json['can_archive'] as bool,
      canEdit: json['can_edit'] as bool,
      canSetDefault: json['can_set_default'] as bool,
      name: json['name'] as String,
      isArchived: json['is_archived'] as bool,
      isDefault: json['is_default'] as bool,
      contractorsCount: json['contractors_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'can_archive': canArchive,
      'can_edit': canEdit,
      'can_set_default': canSetDefault,
      'name': name,
      'is_archived': isArchived,
      'is_default': isDefault,
      'contractors_count': contractorsCount,
    };
  }
}

class WorkRulesResponse {
  final int totalCount;
  final String? nextCursor;
  final List<WorkRule> workRules;

  WorkRulesResponse({
    required this.totalCount,
    this.nextCursor,
    required this.workRules,
  });

  factory WorkRulesResponse.fromJson(Map<String, dynamic> json) {
    return WorkRulesResponse(
      totalCount: json['total_count'] as int,
      nextCursor: json['next_cursor'] as String?,
      workRules: (json['work_rules'] as List)
          .map((item) => WorkRule.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WorkRuleDetails {
  final String id;
  final List<dynamic> calcTable;
  final WorkRuleInfo workRule;
  final DefaultCommission defaultCommission;
  final CommissionClauses? commissionClauses;

  WorkRuleDetails({
    required this.id,
    required this.calcTable,
    required this.workRule,
    required this.defaultCommission,
    this.commissionClauses,
  });

  factory WorkRuleDetails.fromJson(Map<String, dynamic> json) {
    return WorkRuleDetails(
      id: json['id'] as String,
      calcTable: json['calc_table'] as List<dynamic>,
      workRule: WorkRuleInfo.fromJson(json['work_rule'] as Map<String, dynamic>),
      defaultCommission: DefaultCommission.fromJson(json['default_commission'] as Map<String, dynamic>),
      commissionClauses: json['commission_clauses'] != null
          ? CommissionClauses.fromJson(json['commission_clauses'] as Map<String, dynamic>)
          : null,
    );
  }
}

class WorkRuleInfo {
  final bool canArchive;
  final bool canEdit;
  final bool canSetDefault;
  final String commissionForDriverFixPercent;
  final String commissionForSubventionPercent;
  final String commissionForWorkshiftPercent;
  final bool isArchived;
  final bool isCommissionIfPlatformCommissionIsNullEnabled;
  final bool isCommissionForOrdersCancelledByClientEnabled;
  final bool isDefault;
  final bool isDriverFixEnabled;
  final bool isDynamicPlatformCommissionEnabled;
  final bool isEnabled;
  final bool isWorkshiftEnabled;
  final String name;
  final String type;
  final String typeDescription;

  WorkRuleInfo({
    required this.canArchive,
    required this.canEdit,
    required this.canSetDefault,
    required this.commissionForDriverFixPercent,
    required this.commissionForSubventionPercent,
    required this.commissionForWorkshiftPercent,
    required this.isArchived,
    required this.isCommissionIfPlatformCommissionIsNullEnabled,
    required this.isCommissionForOrdersCancelledByClientEnabled,
    required this.isDefault,
    required this.isDriverFixEnabled,
    required this.isDynamicPlatformCommissionEnabled,
    required this.isEnabled,
    required this.isWorkshiftEnabled,
    required this.name,
    required this.type,
    required this.typeDescription,
  });

  factory WorkRuleInfo.fromJson(Map<String, dynamic> json) {
    return WorkRuleInfo(
      canArchive: json['can_archive'] as bool,
      canEdit: json['can_edit'] as bool,
      canSetDefault: json['can_set_default'] as bool,
      commissionForDriverFixPercent: json['commission_for_driver_fix_percent'] as String,
      commissionForSubventionPercent: json['commission_for_subvention_percent'] as String,
      commissionForWorkshiftPercent: json['commission_for_workshift_percent'] as String,
      isArchived: json['is_archived'] as bool,
      isCommissionIfPlatformCommissionIsNullEnabled: json['is_commission_if_platform_commission_is_null_enabled'] as bool,
      isCommissionForOrdersCancelledByClientEnabled: json['is_commission_for_orders_cancelled_by_client_enabled'] as bool,
      isDefault: json['is_default'] as bool,
      isDriverFixEnabled: json['is_driver_fix_enabled'] as bool,
      isDynamicPlatformCommissionEnabled: json['is_dynamic_platform_commission_enabled'] as bool,
      isEnabled: json['is_enabled'] as bool,
      isWorkshiftEnabled: json['is_workshift_enabled'] as bool,
      name: json['name'] as String,
      type: json['type'] as String,
      typeDescription: json['type_description'] as String,
    );
  }
}

class DefaultCommission {
  final String fixed;
  final String percent;

  DefaultCommission({
    required this.fixed,
    required this.percent,
  });

  factory DefaultCommission.fromJson(Map<String, dynamic> json) {
    return DefaultCommission(
      fixed: json['fixed'] as String,
      percent: json['percent'] as String,
    );
  }
}

class CommissionClauses {
  final NewbiesClause? newbies;

  CommissionClauses({
    this.newbies,
  });

  factory CommissionClauses.fromJson(Map<String, dynamic> json) {
    return CommissionClauses(
      newbies: json['newbies'] != null
          ? NewbiesClause.fromJson(json['newbies'] as Map<String, dynamic>)
          : null,
    );
  }
}

class NewbiesClause {
  final int days;
  final String percent;

  NewbiesClause({
    required this.days,
    required this.percent,
  });

  factory NewbiesClause.fromJson(Map<String, dynamic> json) {
    return NewbiesClause(
      days: json['days'] as int,
      percent: json['percent'] as String,
    );
  }
}
