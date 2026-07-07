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

  /// Create from API response with nested members
  static TripModel fromApiResponse(Map<String, dynamic> json) {
    // Handle members array with nested user structure
    final membersJson = json['members'] as List?;
    final members = membersJson
        ?.map((m) => TripMemberModel.fromNestedJson(m as Map<String, dynamic>))
        .toList() ?? [];

    return TripModel(
      id: json['id'] as int,
      title: json['title'] as String?,
      destination: json['destination'] as String?,
      description: json['description'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      shareCode: json['share_code'] as String?,
      status: json['status'] as String?,
      owner: TripOwner(
        id: (json['owner'] as Map<String, dynamic>?)?['id'] as int? ?? 0,
        name: (json['owner'] as Map<String, dynamic>?)?['name'] as String?,
        avatar: (json['owner'] as Map<String, dynamic>?)?['avatar'] as String?,
      ),
      members: members,
      membersCount: members.length,
      planBudget: json['plan_budget'] as int?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
    );
  }
}

@freezed
class TripOwner with _$TripOwner {
  const factory TripOwner({
    required int id,
    String? name,
    String? avatar,
  }) = _TripOwner;

  factory TripOwner.fromJson(Map<String, dynamic> json) =>
      _$TripOwnerFromJson(json);
}
