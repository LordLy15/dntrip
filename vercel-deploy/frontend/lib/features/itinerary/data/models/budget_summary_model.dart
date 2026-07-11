import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_summary_model.freezed.dart';
part 'budget_summary_model.g.dart';

enum BudgetStatus {
  onBudget,
  underbudget,
  deficit,
  surplus,
  offBudget,
}

@freezed
class BudgetSummaryModel with _$BudgetSummaryModel {
  const BudgetSummaryModel._();

  const factory BudgetSummaryModel({
    double? planBudget,
    double? totalActualActivities,
    double? totalSuddenExpenses,
    double? totalActual,
    double? variance,
    @Default(false) bool isOverbudget,
    String? status,
    double? statusAmount,
  }) = _BudgetSummaryModel;

  factory BudgetSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetSummaryModelFromJson(json);

  /// Calculate budget status based on 5% margin
  BudgetStatus get budgetStatus {
    final plan = planBudget ?? 0;
    final actual = totalActual ?? 0;

    if (plan == 0) return BudgetStatus.onBudget;

    final margin = 0.05;
    final lowerThreshold = plan * (1 - margin);
    final upperThreshold = plan * (1 + margin);

    if (actual >= lowerThreshold && actual <= upperThreshold) {
      return BudgetStatus.onBudget;
    } else if (actual < lowerThreshold) {
      return BudgetStatus.underbudget;
    } else {
      return BudgetStatus.deficit;
    }
  }

  /// Get remaining budget (potential surplus)
  double get remainingBudget => (planBudget ?? 0) - (totalActual ?? 0);

  /// Get deficit amount
  double get deficitAmount => (totalActual ?? 0) > (planBudget ?? 0)
      ? (totalActual ?? 0) - (planBudget ?? 0)
      : 0;
}
