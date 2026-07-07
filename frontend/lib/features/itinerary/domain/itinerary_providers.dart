import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dntrip/features/auth/domain/auth_providers.dart';
import 'package:dntrip/core/storage/hive_storage.dart';
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
  // Cache metadata
  int? _lastTripId;
  DateTime? _lastFetchTime;
  static const _cacheMaxAge = Duration(seconds: 30);

  HiveStorage get _storage => ref.read(hiveStorageProvider);

  bool get _isCacheValid =>
      _lastTripId != null &&
      _lastTripId == state?.tripId &&
      _lastFetchTime != null &&
      DateTime.now().difference(_lastFetchTime!) < _cacheMaxAge;

  @override
  ItineraryData? build() {
    // Try to load from persistent cache first
    return null;
  }

  /// Load itinerary - shows cached data immediately if valid, refreshes in background
  Future<void> loadItinerary(int tripId, {bool forceRefresh = false}) async {
    // Try local cache first
    if (!forceRefresh) {
      final cached = _storage.getItinerary(tripId);
      if (cached != null && _storage.isItineraryCacheValid(tripId)) {
        try {
          state = ItineraryData.fromJson(cached);
          _lastTripId = tripId;
          _lastFetchTime = DateTime.now();
          // Refresh in background
          _fetchInBackground(tripId);
          return;
        } catch (_) {
          // Invalid cache, continue to network
        }
      }
    }

    _lastTripId = tripId;

    // Must wait for network on first load or force refresh
    if (state == null || forceRefresh) {
      final data = await ref.read(itineraryRepositoryProvider).getItinerary(tripId);
      state = data;
      _lastFetchTime = DateTime.now();
      // Save to local cache
      _storage.saveItinerary(tripId, data.toJson());
      return;
    }

    // We have data - refresh in background without blocking UI
    _fetchInBackground(tripId);
  }

  Future<void> _fetchInBackground(int tripId) async {
    try {
      final data = await ref.read(itineraryRepositoryProvider).getItinerary(tripId);
      if (_lastTripId == tripId) {
        state = data;
        _lastFetchTime = DateTime.now();
        // Update local cache
        _storage.saveItinerary(tripId, data.toJson());
      }
    } catch (_) {
      // Silently fail background refresh - user still sees cached data
    }
  }

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

    // Create temporary activity for UI update
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final optimisticActivity = _createTempActivity(tempId, tripDayId, title, description, category, estimatedCost);

    // Optimistic update - add activity immediately to UI
    final updatedDays = currentData.days.map((day) {
      if (day.id == tripDayId) {
        return _updateDayWithActivity(day, optimisticActivity);
      }
      return day;
    }).toList();

    state = ItineraryData(
      tripId: currentData.tripId,
      days: updatedDays,
    );

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

      // Replace optimistic activity with real one
      final currentState = state;
      if (currentState != null) {
        final finalDays = currentState.days.map((day) {
          if (day.id == tripDayId) {
            return _replaceTempActivity(day, tempId, activity);
          }
          return day;
        }).toList();

        state = ItineraryData(
          tripId: currentState.tripId,
          days: finalDays,
        );
      }
    } catch (_) {
      // Revert on error - remove optimistic activity
      state = currentData;
    }
  }

  Future<void> completeActivity({
    required int activityId,
    required int actualCost,
  }) async {
    final currentData = state;
    if (currentData == null) return;
    final tripId = currentData.tripId;
    if (tripId == null) return;

    // Find target day
    int? targetDayId;
    for (final day in currentData.days) {
      for (final a in day.activities) {
        if (a.id == activityId) {
          targetDayId = day.id;
          break;
        }
      }
      if (targetDayId != null) break;
    }

    if (targetDayId == null) return;

    // Optimistic update - mark as completed immediately
    final updatedDays = currentData.days.map((day) {
      if (day.id == targetDayId) {
        return _markActivityComplete(day, activityId, actualCost);
      }
      return day;
    }).toList();

    state = ItineraryData(
      tripId: tripId,
      days: updatedDays,
    );

    // Send to server
    try {
      await ref.read(itineraryRepositoryProvider).completeActivity(
        tripId: tripId,
        activityId: activityId,
        actualCost: actualCost,
      );
    } catch (_) {
      // Revert on error
      state = currentData;
    }
  }

  Future<void> deleteActivity(int activityId) async {
    final currentData = state;
    if (currentData == null) return;
    final tripId = currentData.tripId;
    if (tripId == null) return;

    // Optimistic delete - remove from UI immediately
    final updatedDays = currentData.days.map((day) {
      return _removeActivity(day, activityId);
    }).toList();

    state = ItineraryData(
      tripId: currentData.tripId,
      days: updatedDays,
    );

    // Send to server
    try {
      await ref.read(itineraryRepositoryProvider).deleteActivity(tripId, activityId);
    } catch (_) {
      // Revert on error
      state = currentData;
    }
  }

  // Helper: Create temporary activity for optimistic update
  ActivityModel _createTempActivity(
    int id,
    int tripDayId,
    String title,
    String? description,
    String category,
    int? estimatedCost,
  ) {
    return ActivityModel(
      id: id,
      title: title,
      description: description,
      category: category,
      estimatedCost: estimatedCost ?? 0,
      isUnplanned: false,
    );
  }

  // Helper: Update day with new activity
  TripDayModel _updateDayWithActivity(TripDayModel day, ActivityModel activity) {
    return TripDayModel(
      id: day.id,
      dayNumber: day.dayNumber,
      date: day.date,
      notes: day.notes,
      activities: [...day.activities, activity],
    );
  }

  // Helper: Replace temp activity with real one
  TripDayModel _replaceTempActivity(TripDayModel day, int tempId, ActivityModel real) {
    return TripDayModel(
      id: day.id,
      dayNumber: day.dayNumber,
      date: day.date,
      notes: day.notes,
      activities: day.activities.map((a) => a.id == tempId ? real : a).toList(),
    );
  }

  // Helper: Mark activity as complete (optimistic)
  TripDayModel _markActivityComplete(TripDayModel day, int activityId, int actualCost) {
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

  // Helper: Remove activity from day
  TripDayModel _removeActivity(TripDayModel day, int activityId) {
    return TripDayModel(
      id: day.id,
      dayNumber: day.dayNumber,
      date: day.date,
      notes: day.notes,
      activities: day.activities.where((a) => a.id != activityId).toList(),
    );
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
