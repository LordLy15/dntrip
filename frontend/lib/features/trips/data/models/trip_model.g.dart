// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripModelImpl _$$TripModelImplFromJson(Map<String, dynamic> json) =>
    _$TripModelImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String?,
      destination: json['destination'] as String?,
      description: json['description'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      shareCode: json['shareCode'] as String?,
      status: json['status'] as String?,
      owner: TripOwner.fromJson(json['owner'] as Map<String, dynamic>),
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => TripMemberModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      membersCount: (json['membersCount'] as num?)?.toInt(),
      planBudget: (json['planBudget'] as num?)?.toInt(),
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      actualStartTime: json['actualStartTime'] as String?,
      actualEndTime: json['actualEndTime'] as String?,
    );

Map<String, dynamic> _$$TripModelImplToJson(_$TripModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'destination': instance.destination,
      'description': instance.description,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'shareCode': instance.shareCode,
      'status': instance.status,
      'owner': instance.owner,
      'members': instance.members,
      'membersCount': instance.membersCount,
      'planBudget': instance.planBudget,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'actualStartTime': instance.actualStartTime,
      'actualEndTime': instance.actualEndTime,
    };

_$TripOwnerImpl _$$TripOwnerImplFromJson(Map<String, dynamic> json) =>
    _$TripOwnerImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$TripOwnerImplToJson(_$TripOwnerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
