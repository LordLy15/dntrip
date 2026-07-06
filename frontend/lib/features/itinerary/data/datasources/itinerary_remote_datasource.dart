import 'package:dntrip/core/api/api_client.dart';
import 'package:dntrip/features/itinerary/data/models/itinerary_data.dart';
import 'package:dntrip/features/itinerary/data/models/activity_model.dart';
import 'package:dntrip/features/itinerary/data/models/budget_summary_model.dart';

class ItineraryRemoteDatasource {
  final ApiClient _apiClient;

  ItineraryRemoteDatasource(this._apiClient);

  Future<ItineraryData> getItinerary(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/days');
    final data = response['data'] as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Invalid response from server');
    }

    return ItineraryData.fromJson(data);
  }

  Future<ActivityModel> createActivity({
    required int tripId,
    required int tripDayId,
    required String title,
    String? description,
    required String category,
    int? estimatedCost,
  }) async {
    final data = <String, dynamic>{
      'trip_day_id': tripDayId,
      'title': title,
      'category': category,
      'estimated_cost': estimatedCost ?? 0,
    };
    if (description != null) data['description'] = description;

    final response = await _apiClient.post('/trips/$tripId/activities', data: data);
    final responseData = response['data'] as Map<String, dynamic>?;
    final activityData = responseData?['activity'] as Map<String, dynamic>?;

    if (activityData == null) {
      throw Exception('Failed to create activity');
    }

    return ActivityModel.fromJson(activityData);
  }

  Future<({ActivityModel activity, BudgetSummaryModel budget})> completeActivity({
    required int tripId,
    required int activityId,
    required int actualCost,
  }) async {
    final response = await _apiClient.post(
      '/trips/$tripId/activities/$activityId/complete',
      data: {'actual_cost': actualCost},
    );

    final data = response['data'] as Map<String, dynamic>?;
    final activityData = data?['activity'] as Map<String, dynamic>?;
    final budgetData = data?['budget_summary'] as Map<String, dynamic>?;

    if (activityData == null || budgetData == null) {
      throw Exception('Failed to complete activity');
    }

    return (
      activity: ActivityModel.fromJson(activityData),
      budget: BudgetSummaryModel.fromJson(budgetData),
    );
  }

  Future<void> deleteActivity(int tripId, int activityId) async {
    await _apiClient.post('/trips/$tripId/activities/$activityId', data: {'_method': 'DELETE'});
  }
}
