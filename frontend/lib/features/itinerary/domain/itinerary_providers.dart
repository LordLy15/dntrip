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
  int? _lastTripId;
  HiveStorage? _storage;
  bool _initialized = false;

  void _ensureInitialized() {
    if (!_initialized) {
      _storage = ref.read(hiveStorageProvider);
      _initialized = true;
    }
  }

  @override
  ItineraryData? build() {
    _ensureInitialized();
    return null;
  }

  Future<void> loadItinerary(int tripId, {bool forceRefresh = false}) async {
    _ensureInitialized();

    // Try cache first
    if (!forceRefresh && _storage != null) {
      try {
        final cached = _storage!.getItinerary(tripId);
        if (cached != null && _storage!.isItineraryCacheValid(tripId)) {
          state = ItineraryData.fromJson(cached);
          _lastTripId = tripId;
          _fetchInBackground(tripId);
          return;
        }
      } catch (_) {}
    }

    // If we have data, update in background
    if (state != null && !forceRefresh) {
      _lastTripId = tripId;
      _fetchInBackground(tripId);
      return;
    }

    // Fetch from network
    _lastTripId = tripId;
    try {
      final data = await ref.read(itineraryRepositoryProvider).getItinerary(tripId);
      state = data;
      _storage?.saveItinerary(tripId, data.toJson());
    } catch (_) {}
  }

  Future<void> _fetchInBackground(int tripId) async {
    if (_lastTripId != tripId) return;
    try {
      final data = await ref.read(itineraryRepositoryProvider).getItinerary(tripId);
      if (_lastTripId == tripId) {
        state = data;
        _storage?.saveItinerary(tripId, data.toJson());
      }
    } catch (_) {}
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

    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final optimisticActivity = _createTempActivity(tempId, tripDayId, title, description, category, estimatedCost);

    final updatedDays = currentData.days.map((day) {
      if (day.id == tripDayId) {
        return _updateDayWithActivity(day, optimisticActivity);
      }
      return day;
    }).toList();

    state = ItineraryData(tripId: currentData.tripId, days: updatedDays);

    try {
      final activity = await ref.read(itineraryRepositoryProvider).createActivity(
        tripId: tripId, tripDayId: tripDayId, title: title,
        description: description, category: category, estimatedCost: estimatedCost,
      );

      final finalDays = state?.days.map((day) {
        if (day.id == tripDayId) {
          return _replaceTempActivity(day, tempId, activity);
        }
        return day;
      }).toList();

      if (finalDays != null) {
        state = ItineraryData(tripId: state!.tripId, days: finalDays);
      }
    } catch (_) {
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

    int? targetDayId;
    for (final day in currentData.days) {
      for (final a in day.activities) {
        if (a.id == activityId) { targetDayId = day.id; break; }
      }
      if (targetDayId != null) break;
    }
    if (targetDayId == null) return;

    final updatedDays = currentData.days.map((day) {
      if (day.id == targetDayId) return _markActivityComplete(day, activityId, actualCost);
      return day;
    }).toList();

    state = ItineraryData(tripId: tripId, days: updatedDays);

    try {
      await ref.read(itineraryRepositoryProvider).completeActivity(
        tripId: tripId, activityId: activityId, actualCost: actualCost,
      );
    } catch (_) {
      state = currentData;
    }
  }

  Future<void> deleteActivity(int activityId) async {
    final currentData = state;
    if (currentData == null) return;
    final tripId = currentData.tripId;
    if (tripId == null) return;

    final updatedDays = currentData.days.map((day) => _removeActivity(day, activityId)).toList();
    state = ItineraryData(tripId: currentData.tripId, days: updatedDays);

    try {
      await ref.read(itineraryRepositoryProvider).deleteActivity(tripId, activityId);
    } catch (_) {
      state = currentData;
    }
  }

  ActivityModel _createTempActivity(int id, int tripDayId, String title, String? desc, String category, int? cost) {
    return ActivityModel(id: id, title: title, description: desc, category: category, estimatedCost: cost ?? 0, isUnplanned: false);
  }

  TripDayModel _updateDayWithActivity(TripDayModel day, ActivityModel activity) {
    return TripDayModel(id: day.id, dayNumber: day.dayNumber, date: day.date, notes: day.notes, activities: [...day.activities, activity]);
  }

  TripDayModel _replaceTempActivity(TripDayModel day, int tempId, ActivityModel real) {
    return TripDayModel(id: day.id, dayNumber: day.dayNumber, date: day.date, notes: day.notes, activities: day.activities.map((a) => a.id == tempId ? real : a).toList());
  }

  TripDayModel _markActivityComplete(TripDayModel day, int activityId, int actualCost) {
    return TripDayModel(
      id: day.id, dayNumber: day.dayNumber, date: day.date, notes: day.notes,
      activities: day.activities.map((a) {
        if (a.id == activityId) {
          return ActivityModel(id: a.id, title: a.title, description: a.description, category: a.category, estimatedCost: a.estimatedCost, actualCost: actualCost, status: 'completed', isUnplanned: a.isUnplanned, plannedStartTime: a.plannedStartTime, plannedEndTime: a.plannedEndTime, actualStartTime: a.actualStartTime, actualEndTime: a.actualEndTime);
        }
        return a;
      }).toList(),
    );
  }

  TripDayModel _removeActivity(TripDayModel day, int activityId) {
    return TripDayModel(id: day.id, dayNumber: day.dayNumber, date: day.date, notes: day.notes, activities: day.activities.where((a) => a.id != activityId).toList());
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

  Future<SuddenExpenseModel> addExpense({required String name, int? categoryId, required double amount, String? description}) async {
    final repo = ref.read(itineraryRepositoryProvider);
    final expense = await repo.addSuddenExpense(tripId: tripId, name: name, categoryId: categoryId, amount: amount, description: description);
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
Future<ExpenseCategory> customCategory(CustomCategoryRef ref, {required String categoryName, String icon = 'category', String? description}) async {
  return ref.read(itineraryRepositoryProvider).createCustomCategory(name: categoryName, icon: icon, description: description);
}

@riverpod
Future<BudgetSummaryModel> budgetSummary(BudgetSummaryRef ref, int tripId) async {
  final repo = ref.watch(itineraryRepositoryProvider);
  final itineraryData = await repo.getItinerary(tripId);
  double totalActual = 0;
  for (final day in itineraryData.days) {
    for (final activity in day.activities) {
      if (activity.isCompleted) totalActual += activity.actualCost ?? 0;
    }
  }
  final suddenExpenses = await repo.getSuddenExpenses(tripId);
  final totalSudden = suddenExpenses.fold<double>(0, (sum, e) => sum + e.amount);
  totalActual += totalSudden;
  return BudgetSummaryModel(totalActualActivities: totalActual - totalSudden, totalSuddenExpenses: totalSudden, totalActual: totalActual, variance: totalActual);
}

@riverpod
Future<Map<String, int>> activityTimeStats(ActivityTimeStatsRef ref, int tripId) async {
  final repo = ref.watch(itineraryRepositoryProvider);
  final itineraryData = await repo.getItinerary(tripId);
  int total = 0, onTime = 0;
  for (final day in itineraryData.days) {
    for (final activity in day.activities) {
      if (!activity.isUnplanned) {
        total++;
        if (activity.isCompleted && activity.startedOnTime) onTime++;
      }
    }
  }
  return {'total': total, 'onTime': onTime, 'late': total - onTime};
}
