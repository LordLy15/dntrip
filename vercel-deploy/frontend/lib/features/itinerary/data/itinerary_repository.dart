import 'package:dntrip/features/itinerary/data/datasources/itinerary_remote_datasource.dart';
import 'package:dntrip/features/itinerary/data/models/itinerary_data.dart';
import 'package:dntrip/features/itinerary/data/models/activity_model.dart';
import 'package:dntrip/features/itinerary/data/models/budget_summary_model.dart';

class ItineraryRepository {
  final ItineraryRemoteDatasource _remote;

  ItineraryRepository(this._remote);

  Future<ItineraryData> getItinerary(int tripId) => _remote.getItinerary(tripId);

  Future<ActivityModel> createActivity({
    required int tripId,
    required int tripDayId,
    required String title,
    String? description,
    required String category,
    int? estimatedCost,
  }) =>
      _remote.createActivity(
        tripId: tripId,
        tripDayId: tripDayId,
        title: title,
        description: description,
        category: category,
        estimatedCost: estimatedCost,
      );

  Future<void> deleteActivity(int tripId, int activityId) =>
      _remote.deleteActivity(tripId, activityId);

  Future<({ActivityModel activity, BudgetSummaryModel budget})> completeActivity({
    required int tripId,
    required int activityId,
    required int actualCost,
  }) =>
      _remote.completeActivity(
        tripId: tripId,
        activityId: activityId,
        actualCost: actualCost,
      );
}
