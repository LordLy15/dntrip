import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dntrip/features/auth/domain/auth_providers.dart';
import '../data/datasources/itinerary_remote_datasource.dart';
import '../data/datasources/sudden_expense_remote_datasource.dart';
import '../data/itinerary_repository.dart';
import '../data/models/itinerary_data.dart';
import '../data/models/activity_model.dart';
import '../data/models/trip_day_model.dart';
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
  bool _isLoading = false;

  @override
  ItineraryData? build() => null;

  /// Load itinerary data from API
  Future<void> loadItinerary(int tripId) async {
    // Prevent duplicate calls
    if (_isLoading) return;
    if (_isLoading == false) {
      _isLoading = true;
    }

    try {
      final data = await ref.read(itineraryRepositoryProvider).getItinerary(tripId);
      state = data;
    } catch (e) {
      // On error, keep previous state or set empty
      if (state == null) {
        state = ItineraryData(tripId: tripId, days: []);
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Add new activity with optimistic update
  Future<void> createActivity({
    required int tripDayId,
    required String title,
    String? description,
    required String category,
    int? estimatedCost,
  }) async {
    final currentData = state;
    if (currentData == null) return;
    final tripId = currentData.tripId;
    if (tripId == null) return;

    // Create optimistic activity
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final tempActivity = ActivityModel(
      id: tempId,
      title: title,
      description: description,
      category: category,
      estimatedCost: estimatedCost ?? 0,
      isUnplanned: false,
    );

    // Update UI immediately
    final updatedDays = currentData.days.map((day) {
      if (day.id == tripDayId) {
        return TripDayModel(
          id: day.id,
          dayNumber: day.dayNumber,
          date: day.date,
          notes: day.notes,
          activities: [...day.activities, tempActivity],
        );
      }
      return day;
    }).toList();

    state = ItineraryData(tripId: currentData.tripId, days: updatedDays);

    // Send to server
    try {
      final activity = await ref.read(itineraryRepositoryProvider).createActivity(
        tripId: tripId,
        tripDayId: tripDayId,
        title: title,
        description: description,
        category: category,
        estimatedCost: estimatedCost,
      );

      // Replace temp with real
      final finalDays = state?.days.map((day) {
        if (day.id == tripDayId) {
          return TripDayModel(
            id: day.id,
            dayNumber: day.dayNumber,
            date: day.date,
            notes: day.notes,
            activities: day.activities.map((a) => a.id == tempId ? activity : a).toList(),
          );
        }
        return day;
      }).toList();

      if (finalDays != null) {
        state = ItineraryData(tripId: state!.tripId, days: finalDays);
      }
    } catch (_) {
      // Revert on error
      state = currentData;
    }
  }

  /// Complete an activity
  Future<void> completeActivity({
    required int activityId,
    required int actualCost,
  }) async {
    final currentData = state;
    if (currentData == null) return;
    final tripId = currentData.tripId;
    if (tripId == null) return;

    int? targetDayId;
    for (final day in currentData.days) {
      for (final a in day.activities) {
        if (a.id == activityId) { targetDayId = day.id; break; }
      }
      if (targetDayId != null) break;
    }
    if (targetDayId == null) return;

    // Optimistic update
    final updatedDays = currentData.days.map((day) {
      if (day.id == targetDayId) {
        return TripDayModel(
          id: day.id,
          dayNumber: day.dayNumber,
          date: day.date,
          notes: day.notes,
          activities: day.activities.map((a) {
            if (a.id == activityId) {
              return ActivityModel(
                id: a.id,
                title: a.title,
                description: a.description,
                category: a.category,
                estimatedCost: a.estimatedCost,
                actualCost: actualCost,
                status: 'completed',
                isUnplanned: a.isUnplanned,
                plannedStartTime: a.plannedStartTime,
                plannedEndTime: a.plannedEndTime,
                actualStartTime: a.actualStartTime,
                actualEndTime: a.actualEndTime,
              );
            }
            return a;
          }).toList(),
        );
      }
      return day;
    }).toList();

    state = ItineraryData(tripId: tripId, days: updatedDays);

    try {
      await ref.read(itineraryRepositoryProvider).completeActivity(
        tripId: tripId,
        activityId: activityId,
        actualCost: actualCost,
      );
    } catch (_) {
      state = currentData;
    }
  }

  /// Delete activity
  Future<void> deleteActivity(int activityId) async {
    final currentData = state;
    if (currentData == null) return;
    final tripId = currentData.tripId;
    if (tripId == null) return;

    final updatedDays = currentData.days.map((day) {
      return TripDayModel(
        id: day.id,
        dayNumber: day.dayNumber,
        date: day.date,
        notes: day.notes,
        activities: day.activities.where((a) => a.id != activityId).toList(),
      );
    }).toList();

    state = ItineraryData(tripId: currentData.tripId, days: updatedDays);

    try {
      await ref.read(itineraryRepositoryProvider).deleteActivity(tripId, activityId);
    } catch (_) {
      state = currentData;
    }
  }

  /// Skip/cancel an activity
  Future<void> skipActivity(int activityId) async {
    final currentData = state;
    if (currentData == null) return;
    final tripId = currentData.tripId;
    if (tripId == null) return;

    int? targetDayId;
    for (final day in currentData.days) {
      for (final a in day.activities) {
        if (a.id == activityId) { targetDayId = day.id; break; }
      }
      if (targetDayId != null) break;
    }
    if (targetDayId == null) return;

    // Optimistic update - mark as skipped
    final updatedDays = currentData.days.map((day) {
      if (day.id == targetDayId) {
        return TripDayModel(
          id: day.id,
          dayNumber: day.dayNumber,
          date: day.date,
          notes: day.notes,
          activities: day.activities.map((a) {
            if (a.id == activityId) {
              return ActivityModel(
                id: a.id,
                title: a.title,
                description: a.description,
                category: a.category,
                estimatedCost: a.estimatedCost,
                actualCost: null,
                status: 'skipped',
                isUnplanned: a.isUnplanned,
                plannedStartTime: a.plannedStartTime,
                plannedEndTime: a.plannedEndTime,
                actualStartTime: a.actualStartTime,
                actualEndTime: a.actualEndTime,
              );
            }
            return a;
          }).toList(),
        );
      }
      return day;
    }).toList();

    state = ItineraryData(tripId: tripId, days: updatedDays);

    try {
      await ref.read(itineraryRepositoryProvider).skipActivity(tripId, activityId);
    } catch (_) {
      state = currentData;
    }
  }
}

@riverpod
Future<List<SuddenExpenseModel>> suddenExpenses(SuddenExpensesRef ref, int tripId) async {
  return ref.watch(itineraryRepositoryProvider).getSuddenExpenses(tripId);
}

@riverpod
class SuddenExpenseNotifier extends _$SuddenExpenseNotifier {
  @override
  FutureOr<List<SuddenExpenseModel>> build(int tripId) async {
    return ref.watch(itineraryRepositoryProvider).getSuddenExpenses(tripId);
  }

  Future<SuddenExpenseModel> addExpense({
    required String name,
    int? categoryId,
    required double amount,
    String? description,
  }) async {
    final repo = ref.read(itineraryRepositoryProvider);
    final expense = await repo.addSuddenExpense(
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
    await ref.read(itineraryRepositoryProvider).deleteSuddenExpense(tripId, expenseId);
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<ExpenseCategory>> expenseCategories(ExpenseCategoriesRef ref) async {
  return ref.watch(itineraryRepositoryProvider).getExpenseCategories();
}

@riverpod
Future<ExpenseCategory> customCategory(CustomCategoryRef ref, {
  required String categoryName,
  String icon = 'category',
  String? description,
}) async {
  return ref.read(itineraryRepositoryProvider).createCustomCategory(
    name: categoryName,
    icon: icon,
    description: description,
  );
}

@riverpod
Future<BudgetSummaryModel> budgetSummary(BudgetSummaryRef ref, int tripId) async {
  final repo = ref.watch(itineraryRepositoryProvider);
  final data = await repo.getItinerary(tripId);
  double total = 0;
  for (final day in data.days) {
    for (final a in day.activities) {
      if (a.isCompleted) total += a.actualCost ?? 0;
    }
  }
  final sudden = await repo.getSuddenExpenses(tripId);
  final suddenTotal = sudden.fold<double>(0, (sum, e) => sum + e.amount);
  return BudgetSummaryModel(
    totalActualActivities: total,
    totalSuddenExpenses: suddenTotal,
    totalActual: total + suddenTotal,
    variance: total + suddenTotal,
  );
}
