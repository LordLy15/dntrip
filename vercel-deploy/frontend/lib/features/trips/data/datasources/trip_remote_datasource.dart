import '../../../../core/api/api_client.dart';
import '../models/trip_model.dart';
import '../models/trip_member_model.dart';

class TripRemoteDatasource {
  final ApiClient _apiClient;

  TripRemoteDatasource(this._apiClient);

  Future<List<TripModel>> getTrips() async {
    final response = await _apiClient.get('/trips');
    final tripsData = response['data']['trips'] as List;
    return tripsData.map((e) => TripModel.fromJson(e)).toList();
  }

  Future<TripModel> getTrip(int id) async {
    final response = await _apiClient.get('/trips/$id');
    return TripModel.fromJson(response['data']['trip']);
  }

  Future<TripModel> createTrip({
    required String title,
    String? destination,
    String? description,
    required String startDate,
    required String endDate,
  }) async {
    final response = await _apiClient.post('/trips', data: {
      'title': title,
      'destination': destination,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
    });
    return TripModel.fromJson(response['data']['trip']);
  }

  Future<TripModel> updateTrip({
    required int id,
    String? title,
    String? destination,
    String? description,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (destination != null) data['destination'] = destination;
    if (description != null) data['description'] = description;
    if (startDate != null) data['start_date'] = startDate;
    if (endDate != null) data['end_date'] = endDate;
    if (status != null) data['status'] = status;

    final response = await _apiClient.post('/trips/$id', data: data);
    return TripModel.fromJson(response['data']['trip']);
  }

  Future<void> deleteTrip(int id) async {
    await _apiClient.post('/trips/$id', data: {'_method': 'DELETE'});
  }

  Future<({TripModel trip, String role})> joinTrip(String shareCode) async {
    final response = await _apiClient.post('/trips/join', data: {
      'share_code': shareCode,
    });
    return (
      trip: TripModel.fromJson(response['data']['trip']),
      role: response['data']['role'] as String,
    );
  }

  Future<List<TripMemberModel>> getMembers(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/members');
    final membersData = response['data']['members'] as List;
    return membersData.map((e) => TripMemberModel.fromJson(e)).toList();
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
