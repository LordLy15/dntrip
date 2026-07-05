// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripMemberModelImpl _$$TripMemberModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TripMemberModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
    );

Map<String, dynamic> _$$TripMemberModelImplToJson(
        _$TripMemberModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
    };
