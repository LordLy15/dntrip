// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItineraryDataImpl _$$ItineraryDataImplFromJson(Map<String, dynamic> json) =>
    _$ItineraryDataImpl(
      tripId: (json['tripId'] as num?)?.toInt(),
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => TripDayModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ItineraryDataImplToJson(_$ItineraryDataImpl instance) =>
    <String, dynamic>{
      'tripId': instance.tripId,
      'days': instance.days,
    };
