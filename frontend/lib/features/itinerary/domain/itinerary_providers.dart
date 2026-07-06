import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dntrip/features/auth/domain/auth_providers.dart';
import '../data/datasources/itinerary_remote_datasource.dart';
import '../data/datasources/sudden_expense_remote_datasource.dart';
import '../data/itinerary_repository.dart';
import '../data/models/itinerary_data.dart';
import '../data/models/sudden_expense_model.dart';
import '../data/models/expense_category_model.dart';
import '../data/models/budget_summary_model.dart';

part 'itinerary_providers.g.dart';

@riverpod
ItineraryRemoteDatasource itineraryRemoteDatasource(ItineraryRemoteDatasourceRef ref) {
  return ItineraryRemoteDatasource(ref.watch(apiClientProvider));
}

@riverpod
SuddenExpenseRemoteDatasource suddenExpenseRemoteDatasource(SuddenExpenseRemoteDatasourceRef ref) {
  return SuddenExpenseRemoteDatasource(ref.watch(apiClientProvider));
}

@riverpod
ItineraryRepository itineraryRepository(ItineraryRepositoryRef ref) {
  return ItineraryRepository(
    ref.watch(itineraryRemoteDatasourceProvider),
    ref.watch(suddenExpenseRemoteDatasourceProvider),
  );
}

@riverpod
class ItineraryNotifier extends _$ItineraryNotifier {
  @override
  ItineraryData? build() => null;

  Future<void> loadItinerary(int tripId) async {
    state = await ref.read(itineraryRepositoryProvider).getItinerary(tripId);
  }

  Future<void> createActivity({
    required int tripDayId,
    required String title,
    String? description,
    required String category,
    int? estimatedCost,
  }) async {
    final tripId = state?.tripId;
    if (tripId == null) return;

    await ref.read(itineraryRepositoryProvider).createActivity(
      tripId: tripId,
      tripDayId: tripDayId,
      title: title,
      description: description,
      category: category,
      estimatedCost: estimatedCost,
    );

    await loadItinerary(tripId);
  }

  Future<void> completeActivity({
    required int activityId,
    required int actualCost,
  }) async {
    final tripId = state?.tripId;
    if (tripId == null) return;

    await ref.read(itineraryRepositoryProvider).completeActivity(
      tripId: tripId,
      activityId: activityId,
      actualCost: actualCost,
    );

    await loadItinerary(tripId);
  }

  Future<void> deleteActivity(int activityId) async {
    final tripId = state?.tripId;
    if (tripId == null) return;

    await ref.read(itineraryRepositoryProvider).deleteActivity(tripId, activityId);
    await loadItinerary(tripId);
  }
}

// Sudden Expenses Providers
@riverpod
Future<List<SuddenExpenseModel>> suddenExpenses(SuddenExpensesRef ref, int tripId) async {
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
  required String categoryName,
  String icon = 'category',
  String? description,
}) async {
  final repository = ref.read(itineraryRepositoryProvider);
  return repository.createCustomCategory(
    name: categoryName,
    icon: icon,
    description: description,
  );
}

// Budget Summary Provider
@riverpod
Future<BudgetSummaryModel> budgetSummary(BudgetSummaryRef ref, int tripId) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  final itineraryData = await repository.getItinerary(tripId);

  double totalActual = 0;

  for (final day in itineraryData.days) {
    for (final activity in day.activities) {
      if (activity.isCompleted) {
        totalActual += activity.actualCost ?? 0;
      }
    }
  }

  final suddenExpenses = await repository.getSuddenExpenses(tripId);
  final totalSudden = suddenExpenses.fold<double>(0, (sum, e) => sum + e.amount);

  totalActual += totalSudden;

  return BudgetSummaryModel(
    totalActualActivities: totalActual - totalSudden,
    totalSuddenExpenses: totalSudden,
    totalActual: totalActual,
    variance: totalActual,
  );
}

// On Time Statistics Provider
@riverpod
Future<Map<String, int>> activityTimeStats(ActivityTimeStatsRef ref, int tripId) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  final itineraryData = await repository.getItinerary(tripId);

  int totalActivities = 0;
  int onTimeActivities = 0;

  for (final day in itineraryData.days) {
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
