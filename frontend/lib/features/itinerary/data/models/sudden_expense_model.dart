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
