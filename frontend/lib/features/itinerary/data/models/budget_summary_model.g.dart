// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetSummaryModelImpl _$$BudgetSummaryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$BudgetSummaryModelImpl(
      planBudget: (json['planBudget'] as num?)?.toDouble(),
      totalActualActivities:
          (json['totalActualActivities'] as num?)?.toDouble(),
      totalSuddenExpenses: (json['totalSuddenExpenses'] as num?)?.toDouble(),
      totalActual: (json['totalActual'] as num?)?.toDouble(),
      variance: (json['variance'] as num?)?.toDouble(),
      isOverbudget: json['isOverbudget'] as bool? ?? false,
      status: json['status'] as String?,
      statusAmount: (json['statusAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$BudgetSummaryModelImplToJson(
        _$BudgetSummaryModelImpl instance) =>
    <String, dynamic>{
      'planBudget': instance.planBudget,
      'totalActualActivities': instance.totalActualActivities,
      'totalSuddenExpenses': instance.totalSuddenExpenses,
      'totalActual': instance.totalActual,
      'variance': instance.variance,
      'isOverbudget': instance.isOverbudget,
      'status': instance.status,
      'statusAmount': instance.statusAmount,
    };
