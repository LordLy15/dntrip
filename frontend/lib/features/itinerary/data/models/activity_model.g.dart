// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityModelImpl _$$ActivityModelImplFromJson(Map<String, dynamic> json) =>
    _$ActivityModelImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      estimatedCost: (json['estimated_cost'] as num?)?.toInt() ?? 0,
      actualCost: (json['actual_cost'] as num?)?.toInt(),
      status: json['status'] as String,
      isUnplanned: json['is_unplanned'] as bool? ?? false,
    );

Map<String, dynamic> _$$ActivityModelImplToJson(
        _$ActivityModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'estimated_cost': instance.estimatedCost,
      'actual_cost': instance.actualCost,
      'status': instance.status,
      'is_unplanned': instance.isUnplanned,
    };
