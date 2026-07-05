import 'package:freezed_annotation/freezed_annotation.dart';
import 'trip_day_model.dart';
import 'budget_summary_model.dart';

part 'itinerary_data.freezed.dart';
part 'itinerary_data.g.dart';

@freezed
class ItineraryData with _$ItineraryData {
  const factory ItineraryData({
    required int tripId,
    required BudgetSummaryModel budgetSummary,
    @Default([]) List<TripDayModel> days,
  }) = _ItineraryData;

  factory ItineraryData.fromJson(Map<String, dynamic> json) =>
      _$ItineraryDataFromJson(json);
}
