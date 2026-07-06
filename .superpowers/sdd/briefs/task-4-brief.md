# Task 4: Frontend - Data Models

## Overview
Create Freezed models for sudden expenses and update existing models for budget tracking.

## Files to Create/Modify

### 1. Create: `frontend/lib/features/itinerary/data/models/sudden_expense_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sudden_expense_model.freezed.dart';
part 'sudden_expense_model.g.dart';

@freezed
class SuddenExpenseModel with _$SuddenExpenseModel {
  const factory SuddenExpenseModel({
    required int id,
    required int tripId,
    required String name,
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    required double amount,
    String? description,
    required DateTime createdAt,
  }) = _SuddenExpenseModel;

  factory SuddenExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$SuddenExpenseModelFromJson(json);
}
```

### 2. Modify: `frontend/lib/features/itinerary/data/models/budget_summary_model.dart`

```dart
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
```

### 3. Modify: `frontend/lib/features/itinerary/data/models/expense_category_model.dart`

Add to `ExpenseCategoryExtension`:
```dart
/// Find category by id
ExpenseCategory? findById(int id) {
  try {
    return firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

/// Get all categories including custom
List<ExpenseCategory> get allCategories => this;
```

## After Implementation

1. Run `cd frontend && dart run build_runner build --delete-conflicting-outputs`
2. Verify the generated files (.freezed.dart, .g.dart) are created
3. Report at `.superpowers/sdd/reports/task-4-report.md`

## Acceptance Criteria

- [ ] SuddenExpenseModel created
- [ ] BudgetSummaryModel updated with budgetStatus getter
- [ ] ExpenseCategoryModel extended with findById method
- [ ] Build runner generates all files successfully
