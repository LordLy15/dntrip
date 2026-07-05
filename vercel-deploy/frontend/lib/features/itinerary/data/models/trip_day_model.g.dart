// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_day_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripDayModelImpl _$$TripDayModelImplFromJson(Map<String, dynamic> json) =>
    _$TripDayModelImpl(
      id: (json['id'] as num).toInt(),
      dayNumber: (json['day_number'] as num).toInt(),
      date: json['date'] as String,
      notes: json['notes'] as String?,
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TripDayModelImplToJson(
        _$TripDayModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day_number': instance.dayNumber,
      'date': instance.date,
      'notes': instance.notes,
      'activities': instance.activities,
    };
