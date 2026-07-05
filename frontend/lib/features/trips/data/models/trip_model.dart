import 'package:freezed_annotation/freezed_annotation.dart';
import 'trip_member_model.dart';

part 'trip_model.freezed.dart';
part 'trip_model.g.dart';

@freezed
class TripModel with _$TripModel {
  const TripModel._();

  const factory TripModel({
    required int id,
    required String title,
    String? destination,
    String? description,
    String? startDate,
    String? endDate,
    required String shareCode,
    required String status,
    required UserModel owner,
    @Default([]) List<TripMemberModel> members,
    int? membersCount,
  }) = _TripModel;

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    required String name,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
