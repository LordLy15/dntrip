// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sudden_expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SuddenExpenseModelImpl _$$SuddenExpenseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SuddenExpenseModelImpl(
      id: (json['id'] as num).toInt(),
      tripId: (json['trip_id'] as num).toInt(),
      name: json['name'] as String,
      categoryId: (json['expense_category_id'] as num?)?.toInt(),
      categoryName: json['categoryName'] as String?,
      categoryIcon: json['categoryIcon'] as String?,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$SuddenExpenseModelImplToJson(
        _$SuddenExpenseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trip_id': instance.tripId,
      'name': instance.name,
      'expense_category_id': instance.categoryId,
      'categoryName': instance.categoryName,
      'categoryIcon': instance.categoryIcon,
      'amount': instance.amount,
      'description': instance.description,
      'created_at': instance.createdAt?.toIso8601String(),
    };
