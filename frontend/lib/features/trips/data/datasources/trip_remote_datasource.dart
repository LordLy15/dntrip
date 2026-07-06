import '../../../../core/api/api_client.dart';
import '../models/trip_model.dart';
import '../models/trip_member_model.dart';

class TripRemoteDatasource {
  final ApiClient _apiClient;

  TripRemoteDatasource(this._apiClient);

  Future<List<TripModel>> getTrips() async {
    final response = await _apiClient.get('/trips');
    final data = response['data'] as Map<String, dynamic>?;
    final tripsData = data?['trips'] as List?;

    if (tripsData == null) {
      return [];
    }

    return tripsData
        .map((e) => e as Map<String, dynamic>)
        .map((e) => TripModel.fromJson(e))
        .toList();
  }

  Future<TripModel> getTrip(int id) async {
    final response = await _apiClient.get('/trips/$id');
    final data = response['data'] as Map<String, dynamic>?;
    final tripData = data?['trip'] as Map<String, dynamic>?;

    if (tripData == null) {
      throw Exception('Trip not found');
    }

    return TripModel.fromJson(tripData);
  }

  Future<TripModel> createTrip({
    required String title,
    String? destination,
    String? description,
    required String startDate,
    required String endDate,
    int? planBudget,
    String? latitude,
    String? longitude,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'destination': destination,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
    };

    if (planBudget != null) data['plan_budget'] = planBudget;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;

    final response = await _apiClient.post('/trips', data: data);

    final responseData = response['data'] as Map<String, dynamic>?;
    final tripData = responseData?['trip'] as Map<String, dynamic>?;

    if (tripData == null) {
      throw Exception('Failed to create trip');
    }

    return TripModel.fromJson(tripData);
  }

  Future<TripModel> updateTrip({
    required int id,
    String? title,
    String? destination,
    String? description,
    String? startDate,
    String? endDate,
    String? status,
    int? planBudget,
    String? latitude,
    String? longitude,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (destination != null) data['destination'] = destination;
    if (description != null) data['description'] = description;
    if (startDate != null) data['start_date'] = startDate;
    if (endDate != null) data['end_date'] = endDate;
    if (status != null) data['status'] = status;
    if (planBudget != null) data['plan_budget'] = planBudget;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;

    final response = await _apiClient.put('/trips/$id', data: data);
    final responseData = response['data'] as Map<String, dynamic>?;
    final tripData = responseData?['trip'] as Map<String, dynamic>?;

    if (tripData == null) {
      throw Exception('Failed to update trip');
    }

    return TripModel.fromJson(tripData);
  }

  Future<void> deleteTrip(int id) async {
    await _apiClient.post('/trips/$id', data: {'_method': 'DELETE'});
  }

  Future<({TripModel trip, String role})> joinTrip(String shareCode) async {
    final response = await _apiClient.post('/trips/join', data: {
      'share_code': shareCode,
    });

    final data = response['data'] as Map<String, dynamic>?;
    final tripData = data?['trip'] as Map<String, dynamic>?;
    final role = data?['role'] as String?;

    if (tripData == null || role == null) {
      throw Exception('Failed to join trip');
    }

    return (
      trip: TripModel.fromJson(tripData),
      role: role,
    );
  }

  Future<List<TripMemberModel>> getMembers(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/members');
    final data = response['data'] as Map<String, dynamic>?;
    final membersData = data?['members'] as List?;

    if (membersData == null) {
      return [];
    }

    return membersData
        .map((e) => e as Map<String, dynamic>)
        .map((e) => TripMemberModel.fromJson(e))
        .toList();
  }

  Future<void> updateMemberRole(int tripId, int userId, String role) async {
    await _apiClient.post('/trips/$tripId/members/$userId/role', data: {
      'role': role,
    });
  }

  Future<void> removeMember(int tripId, int userId) async {
    await _apiClient.post('/trips/$tripId/members/$userId', data: {
      '_method': 'DELETE',
    });
  }
}
