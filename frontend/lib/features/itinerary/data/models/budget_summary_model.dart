import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_summary_model.freezed.dart';
part 'budget_summary_model.g.dart';

@freezed
class BudgetSummaryModel with _$BudgetSummaryModel {
  const factory BudgetSummaryModel({
    required int totalEstimated,
    required int totalActual,
    required int variance,
    required bool isOverbudget,
  }) = _BudgetSummaryModel;

  factory BudgetSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetSummaryModelFromJson(json);
}
