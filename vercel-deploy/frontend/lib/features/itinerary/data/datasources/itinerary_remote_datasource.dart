import 'package:dntrip/core/api/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:dntrip/features/itinerary/data/models/itinerary_data.dart';
import 'package:dntrip/features/itinerary/data/models/activity_model.dart';
import 'package:dntrip/features/itinerary/data/models/trip_day_model.dart';
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

  Future<TripDayModel> createDay({required int tripId, required String date}) async {
    try {
      final response = await _apiClient.post(
        '/trips/$tripId/days',
        data: {'date': date},
      );

      debugPrint('createDay response: $response');
      debugPrint('createDay response keys: ${response.keys.toList()}');

      // Check for errors in response
      if (response.containsKey('errors')) {
        final errors = response['errors'];
        debugPrint('Server errors: $errors');
        throw Exception('Validation error: $errors');
      }

      // Check status
      if (response['status'] == 'error') {
        throw Exception(response['message'] ?? 'Unknown error from server');
      }

      final responseData = response['data'];
      debugPrint('createDay data: $responseData');

      if (responseData == null) {
        throw Exception('Server returned null data');
      }

      // Handle nested day object
      Map<String, dynamic> dayData;
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('day')) {
          dayData = responseData['day'] as Map<String, dynamic>;
        } else {
          // Response is directly the day object
          dayData = responseData;
        }
      } else {
        throw Exception('Invalid response format from server: ${responseData.runtimeType}');
      }

      debugPrint('Parsed dayData: $dayData');
      debugPrint('day_number value: ${dayData['day_number']} (type: ${dayData['day_number']?.runtimeType})');

      // Validate required fields
      if (dayData['day_number'] == null) {
        throw Exception('day_number is null in server response');
      }
      if (dayData['id'] == null) {
        throw Exception('id is null in server response');
      }

      return TripDayModel.fromJson(dayData);
    } catch (e) {
      debugPrint('createDay error: $e');
      rethrow;
    }
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

  Future<void> skipActivity(int tripId, int activityId) async {
    await _apiClient.post(
      '/trips/$tripId/activities/$activityId',
      data: {'status': 'skipped'},
    );
  }
}
