// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityModelImpl _$$ActivityModelImplFromJson(Map<String, dynamic> json) =>
    _$ActivityModelImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      estimatedCost: (json['estimatedCost'] as num).toInt(),
      actualCost: (json['actualCost'] as num?)?.toInt(),
      status: json['status'] as String?,
      isUnplanned: json['isUnplanned'] as bool,
      plannedStartTime: json['plannedStartTime'] as String?,
      plannedEndTime: json['plannedEndTime'] as String?,
      actualStartTime: json['actualStartTime'] as String?,
      actualEndTime: json['actualEndTime'] as String?,
    );

Map<String, dynamic> _$$ActivityModelImplToJson(_$ActivityModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'estimatedCost': instance.estimatedCost,
      'actualCost': instance.actualCost,
      'status': instance.status,
      'isUnplanned': instance.isUnplanned,
      'plannedStartTime': instance.plannedStartTime,
      'plannedEndTime': instance.plannedEndTime,
      'actualStartTime': instance.actualStartTime,
      'actualEndTime': instance.actualEndTime,
    };
