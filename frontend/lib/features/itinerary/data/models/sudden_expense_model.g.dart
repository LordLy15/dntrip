// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sudden_expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SuddenExpenseModelImpl _$$SuddenExpenseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SuddenExpenseModelImpl(
      id: (json['id'] as num).toInt(),
      tripId: (json['tripId'] as num).toInt(),
      name: json['name'] as String,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      categoryName: json['categoryName'] as String?,
      categoryIcon: json['categoryIcon'] as String?,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SuddenExpenseModelImplToJson(
        _$SuddenExpenseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'name': instance.name,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'categoryIcon': instance.categoryIcon,
      'amount': instance.amount,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
    };
