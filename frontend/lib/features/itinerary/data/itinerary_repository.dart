import 'package:dntrip/features/itinerary/data/datasources/itinerary_remote_datasource.dart';
import 'package:dntrip/features/itinerary/data/datasources/sudden_expense_remote_datasource.dart';
import 'package:dntrip/features/itinerary/data/models/itinerary_data.dart';
import 'package:dntrip/features/itinerary/data/models/activity_model.dart';
import 'package:dntrip/features/itinerary/data/models/budget_summary_model.dart';
import 'package:dntrip/features/itinerary/data/models/sudden_expense_model.dart';
import 'package:dntrip/features/itinerary/data/models/expense_category_model.dart';
import 'package:dntrip/features/trips/data/models/trip_model.dart';

class ItineraryRepository {
  final ItineraryRemoteDatasource _remote;
  final SuddenExpenseRemoteDatasource _suddenExpenseDatasource;

  ItineraryRepository(this._remote, this._suddenExpenseDatasource);

  Future<ItineraryData> getItinerary(int tripId) => _remote.getItinerary(tripId);

  Future<ActivityModel> createActivity({
    required int tripId,
    required int tripDayId,
    required String title,
    String? description,
    required String category,
    int? estimatedCost,
  }) =>
      _remote.createActivity(
        tripId: tripId,
        tripDayId: tripDayId,
        title: title,
        description: description,
        category: category,
        estimatedCost: estimatedCost,
      );

  Future<void> deleteActivity(int tripId, int activityId) =>
      _remote.deleteActivity(tripId, activityId);

  Future<({ActivityModel activity, BudgetSummaryModel budget})> completeActivity({
    required int tripId,
    required int activityId,
    required int actualCost,
  }) =>
      _remote.completeActivity(
        tripId: tripId,
        activityId: activityId,
        actualCost: actualCost,
      );

  // Sudden Expenses Methods
  Future<List<SuddenExpenseModel>> getSuddenExpenses(int tripId) {
    return _suddenExpenseDatasource.getSuddenExpenses(tripId);
  }

  Future<SuddenExpenseModel> addSuddenExpense({
    required int tripId,
    required String name,
    int? categoryId,
    required double amount,
    String? description,
  }) {
    return _suddenExpenseDatasource.addSuddenExpense(
      tripId: tripId,
      name: name,
      categoryId: categoryId,
      amount: amount,
      description: description,
    );
  }

  Future<void> deleteSuddenExpense(int tripId, int expenseId) {
    return _suddenExpenseDatasource.deleteSuddenExpense(tripId, expenseId);
  }

  Future<List<ExpenseCategory>> getExpenseCategories() {
    return _suddenExpenseDatasource.getCategories();
  }

  Future<ExpenseCategory> createCustomCategory({
    required String name,
    String icon = 'category',
    String? description,
  }) {
    return _suddenExpenseDatasource.createCustomCategory(
      name: name,
      icon: icon,
      description: description,
    );
  }

  // Trip method for budget calculation
  Future<TripModel> getTrip(int tripId) async {
    // This will be implemented via the trip datasource
    // For now, return a basic trip model
    throw UnimplementedError('Use TripRepository to get trip details');
  }
}
