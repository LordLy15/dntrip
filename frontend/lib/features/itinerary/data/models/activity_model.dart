import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_model.freezed.dart';
part 'activity_model.g.dart';

@freezed
class ActivityModel with _$ActivityModel {
  const factory ActivityModel({
    required int id,
    String? title,
    String? description,
    String? category,
    @JsonKey(name: 'estimated_cost') int? estimatedCost,
    @JsonKey(name: 'actual_cost') int? actualCost,
    String? status,
    @JsonKey(name: 'is_unplanned') bool? isUnplanned,
    String? plannedStartTime,
    String? plannedEndTime,
    String? actualStartTime,
    String? actualEndTime,
  }) = _ActivityModel;

  const ActivityModel._();

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelImpl.fromJson(json);

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isSkipped => status == 'skipped';
  bool get isStarted => actualStartTime != null;

  /// Check if activity started on time
  bool get startedOnTime {
    if (actualStartTime == null || plannedStartTime == null) return true;
    // Compare timestamps - simplified logic
    return actualStartTime!.compareTo(plannedStartTime!) <= 0;
  }

  /// Check if activity ended on time
  bool get endedOnTime {
    if (actualEndTime == null || plannedEndTime == null) return true;
    return actualEndTime!.compareTo(plannedEndTime!) <= 0;
  }

  /// Calculate delay in minutes (positive = late, negative = early)
  int get startDelayMinutes {
    if (actualStartTime == null || plannedStartTime == null) return 0;
    // Simple comparison - in real app would parse datetime properly
    return 0; // Will be calculated in presentation layer
  }
}
