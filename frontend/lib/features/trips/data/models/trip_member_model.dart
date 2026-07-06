import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_member_model.freezed.dart';
part 'trip_member_model.g.dart';

@freezed
class TripMemberModel with _$TripMemberModel {
  const TripMemberModel._();

  const factory TripMemberModel({
    required int id,
    String? name,
    String? email,
    String? role,
  }) = _TripMemberModel;

  factory TripMemberModel.fromJson(Map<String, dynamic> json) =>
      _$TripMemberModelFromJson(json);

  bool get isOwner => role == 'owner';
  bool get isEditor => role == 'owner' || role == 'editor';
}
