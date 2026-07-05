import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_model.freezed.dart';
part 'activity_model.g.dart';

@freezed
class ActivityModel with _$ActivityModel {
  const factory ActivityModel({
    required int id,
    required String title,
    String? description,
    required String category,
    required int estimatedCost,
    int? actualCost,
    required String status,
    required bool isUnplanned,
  }) = _ActivityModel;

  const ActivityModel._();

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelImpl.fromJson(json);

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isSkipped => status == 'skipped';
}
