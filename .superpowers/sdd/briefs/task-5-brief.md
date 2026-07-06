# Task 5: Frontend - Data Sources & Repository

## Overview
Create the sudden expense remote datasource and update the itinerary repository.

## Context from Previous Tasks
- Task 2: Backend models (SuddenExpense, ExpenseCategory) are available
- Task 4: Frontend models (SuddenExpenseModel, updated BudgetSummaryModel) are available

## Files to Create/Modify

### 1. Create: `frontend/lib/features/itinerary/data/datasources/sudden_expense_remote_datasource.dart`

```dart
import 'package:dio/dio.dart';
import '../models/sudden_expense_model.dart';
import '../models/expense_category_model.dart';

class SuddenExpenseRemoteDatasource {
  final Dio _dio;

  SuddenExpenseRemoteDatasource(this._dio);

  Future<List<SuddenExpenseModel>> getSuddenExpenses(int tripId) async {
    final response = await _dio.get('/trips/$tripId/sudden-expenses');
    final data = response.data['data'] as List;
    return data.map((json) => SuddenExpenseModel.fromJson(json)).toList();
  }

  Future<SuddenExpenseModel> addSuddenExpense({
    required int tripId,
    required String name,
    int? categoryId,
    required double amount,
    String? description,
  }) async {
    final response = await _dio.post('/trips/$tripId/sudden-expenses', data: {
      'name': name,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
    });
    return SuddenExpenseModel.fromJson(response.data['data']);
  }

  Future<void> deleteSuddenExpense(int tripId, int expenseId) async {
    await _dio.delete('/trips/$tripId/sudden-expenses/$expenseId');
  }

  Future<List<ExpenseCategory>> getCategories() async {
    final response = await _dio.get('/expense-categories');
    final data = response.data['data'] as List;
    return data.map((json) => ExpenseCategory.fromJson(json)).toList();
  }

  Future<ExpenseCategory> createCustomCategory({
    required String name,
    String icon = 'category',
    String? description,
  }) async {
    final response = await _dio.post('/expense-categories', data: {
      'name': name,
      'icon': icon,
      'description': description,
    });
    return ExpenseCategory.fromJson(response.data['data']);
  }
}
```

### 2. Modify: `frontend/lib/features/itinerary/data/itinerary_repository.dart`

Add these methods to ItineraryRepository class:

```dart
final SuddenExpenseRemoteDatasource _suddenExpenseDatasource;

SuddenExpenseRemoteDatasource get suddenExpenses => _suddenExpenseDatasource;

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
```

Also add these imports:
```dart
import '../data/models/sudden_expense_model.dart';
import '../data/models/expense_category_model.dart';
import '../data/datasources/sudden_expense_remote_datasource.dart';
```

## Acceptance Criteria

- [ ] SuddenExpenseRemoteDatasource created with all methods
- [ ] ItineraryRepository extended with sudden expense methods
- [ ] Code compiles without errors

## Notes

- Read existing itinerary_repository.dart to understand how to add the datasource properly
- The datasource needs to be initialized in the repository constructor
