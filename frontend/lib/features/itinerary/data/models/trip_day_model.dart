import 'package:freezed_annotation/freezed_annotation.dart';
import 'activity_model.dart';

part 'trip_day_model.freezed.dart';
part 'trip_day_model.g.dart';

@freezed
class TripDayModel with _$TripDayModel {
  const factory TripDayModel({
    required int id,
    @JsonKey(name: 'day_number') int? dayNumber,
    String? date,
    String? notes,
    @Default([]) List<ActivityModel> activities,
  }) = _TripDayModel;

  factory TripDayModel.fromJson(Map<String, dynamic> json) =>
      _$TripDayModelFromJson(json);
}
