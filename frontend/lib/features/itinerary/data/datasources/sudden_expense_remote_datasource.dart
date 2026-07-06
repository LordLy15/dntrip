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
