// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItineraryDataImpl _$$ItineraryDataImplFromJson(Map<String, dynamic> json) =>
    _$ItineraryDataImpl(
      tripId: (json['trip_id'] as num).toInt(),
      budgetSummary: BudgetSummaryModel.fromJson(
          json['budget_summary'] as Map<String, dynamic>),
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => TripDayModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ItineraryDataImplToJson(
        _$ItineraryDataImpl instance) =>
    <String, dynamic>{
      'trip_id': instance.tripId,
      'budget_summary': instance.budgetSummary,
      'days': instance.days,
    };
