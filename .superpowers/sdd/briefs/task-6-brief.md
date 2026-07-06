# Task 6: Frontend - Providers

## Overview
Add Riverpod providers for sudden expenses, budget summary, and activity time stats.

## Context from Previous Tasks
- Task 5: Repository with sudden expense methods is available

## Files to Modify

### Modify: `frontend/lib/features/itinerary/domain/itinerary_providers.dart`

Add these providers (place them in the appropriate location in the file):

```dart
// Sudden Expenses Providers
@riverpod
Future<List<SuddenExpenseModel>> suddenExpenses(
  SuddenExpensesRef ref,
  int tripId,
) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  return repository.getSuddenExpenses(tripId);
}

@riverpod
class SuddenExpenseNotifier extends _$SuddenExpenseNotifier {
  @override
  FutureOr<List<SuddenExpenseModel>> build(int tripId) async {
    final repository = ref.watch(itineraryRepositoryProvider);
    return repository.getSuddenExpenses(tripId);
  }

  Future<SuddenExpenseModel> addExpense({
    required String name,
    int? categoryId,
    required double amount,
    String? description,
  }) async {
    final repository = ref.read(itineraryRepositoryProvider);
    final expense = await repository.addSuddenExpense(
      tripId: tripId,
      name: name,
      categoryId: categoryId,
      amount: amount,
      description: description,
    );
    ref.invalidateSelf();
    return expense;
  }

  Future<void> deleteExpense(int expenseId) async {
    final repository = ref.read(itineraryRepositoryProvider);
    await repository.deleteSuddenExpense(tripId, expenseId);
    ref.invalidateSelf();
  }
}

// Expense Categories Provider
@riverpod
Future<List<ExpenseCategory>> expenseCategories(ExpenseCategoriesRef ref) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  return repository.getExpenseCategories();
}

// Custom category creation
@riverpod
Future<ExpenseCategory> customCategory(CustomCategoryRef ref, {
  required String name,
  String icon = 'category',
  String? description,
}) async {
  final repository = ref.read(itineraryRepositoryProvider);
  return repository.createCustomCategory(
    name: name,
    icon: icon,
    description: description,
  );
}

// Combined Budget Summary Provider
@riverpod
Future<BudgetSummaryModel> budgetSummary(BudgetSummaryRef ref, int tripId) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  final trip = await repository.getTrip(tripId);
  final activities = await repository.getItineraryData(tripId);
  
  double totalEstimated = 0;
  double totalActual = 0;
  
  for (final day in activities.days) {
    for (final activity in day.activities) {
      if (!activity.isUnplanned) {
        totalEstimated += activity.estimatedCost;
      }
      if (activity.isCompleted) {
        totalActual += activity.actualCost ?? 0;
      }
    }
  }
  
  final suddenExpenses = await repository.getSuddenExpenses(tripId);
  final totalSudden = suddenExpenses.fold<double>(0, (sum, e) => sum + e.amount);
  
  totalActual += totalSudden;
  
  return BudgetSummaryModel(
    planBudget: trip.planBudget?.toDouble(),
    totalActualActivities: totalActual - totalSudden,
    totalSuddenExpenses: totalSudden,
    totalActual: totalActual,
    variance: totalActual - (trip.planBudget?.toDouble() ?? 0),
  );
}

// On Time Statistics Provider
@riverpod
Map<String, int> activityTimeStats(ActivityTimeStatsRef ref, int tripId) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  final activities = await repository.getItineraryData(tripId);
  
  int totalActivities = 0;
  int onTimeActivities = 0;
  
  for (final day in activities.days) {
    for (final activity in day.activities) {
      if (!activity.isUnplanned) {
        totalActivities++;
        if (activity.isCompleted && activity.startedOnTime) {
          onTimeActivities++;
        }
      }
    }
  }
  
  return {
    'total': totalActivities,
    'onTime': onTimeActivities,
    'late': totalActivities - onTimeActivities,
  };
}
```

Also add these imports:
```dart
import '../data/models/sudden_expense_model.dart';
import '../data/models/expense_category_model.dart';
import '../data/models/budget_summary_model.dart';
```

## Acceptance Criteria

- [ ] suddenExpenses provider created
- [ ] SuddenExpenseNotifier created with addExpense/deleteExpense methods
- [ ] expenseCategories provider created
- [ ] customCategory provider created
- [ ] budgetSummary provider created
- [ ] activityTimeStats provider created
- [ ] Run build_runner after

## Notes

- Read existing itinerary_providers.dart to understand the pattern used
- Run `cd frontend && dart run build_runner build --delete-conflicting-outputs` after
