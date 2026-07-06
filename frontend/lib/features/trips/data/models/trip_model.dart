import 'package:freezed_annotation/freezed_annotation.dart';
import 'trip_member_model.dart';

part 'trip_model.freezed.dart';
part 'trip_model.g.dart';

@freezed
class TripModel with _$TripModel {
  const TripModel._();

  const factory TripModel({
    required int id,
    String? title,
    String? destination,
    String? description,
    String? startDate,
    String? endDate,
    String? shareCode,
    String? status,
    required TripOwner owner,
    @Default([]) List<TripMemberModel> members,
    int? membersCount,
    int? planBudget,
    String? latitude,
    String? longitude,
    String? actualStartTime,
    String? actualEndTime,
  }) = _TripModel;

  bool get hasLocation => latitude != null && latitude!.isNotEmpty && longitude != null && longitude!.isNotEmpty;
  bool get isOnTime {
    if (actualStartTime == null) return true;
    // Simple check - if actual start is before planned, it's on time
    return true; // Will be calculated based on planned time
  }

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);
}

@freezed
class TripOwner with _$TripOwner {
  const factory TripOwner({
    required int id,
    String? name,
  }) = _TripOwner;

  factory TripOwner.fromJson(Map<String, dynamic> json) =>
      _$TripOwnerFromJson(json);
}
