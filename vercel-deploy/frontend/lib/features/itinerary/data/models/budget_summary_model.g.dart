// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetSummaryModelImpl _$$BudgetSummaryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$BudgetSummaryModelImpl(
      totalEstimated: (json['total_estimated'] as num).toInt(),
      totalActual: (json['total_actual'] as num).toInt(),
      variance: (json['variance'] as num).toInt(),
      isOverbudget: json['is_overbudget'] as bool,
    );

Map<String, dynamic> _$$BudgetSummaryModelImplToJson(
        _$BudgetSummaryModelImpl instance) =>
    <String, dynamic>{
      'total_estimated': instance.totalEstimated,
      'total_actual': instance.totalActual,
      'variance': instance.variance,
      'is_overbudget': instance.isOverbudget,
    };
