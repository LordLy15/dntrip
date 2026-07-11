import 'package:dntrip/features/trips/data/datasources/trip_remote_datasource.dart';
import 'package:dntrip/features/trips/data/models/trip_model.dart';
import 'package:dntrip/features/trips/data/models/trip_member_model.dart';

class TripRepository {
  final TripRemoteDatasource _remoteDatasource;

  TripRepository(this._remoteDatasource);

  Future<List<TripModel>> getTrips() => _remoteDatasource.getTrips();
  Future<TripModel> getTrip(int id) => _remoteDatasource.getTrip(id);

  Future<TripModel> createTrip({
    required String title,
    String? destination,
    String? description,
    required String startDate,
    required String endDate,
    int? planBudget,
    String? latitude,
    String? longitude,
  }) =>
      _remoteDatasource.createTrip(
        title: title,
        destination: destination,
        description: description,
        startDate: startDate,
        endDate: endDate,
        planBudget: planBudget,
        latitude: latitude,
        longitude: longitude,
      );

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
  }) =>
      _remoteDatasource.updateTrip(
        id: id,
        title: title,
        destination: destination,
        description: description,
        startDate: startDate,
        endDate: endDate,
        status: status,
        planBudget: planBudget,
        latitude: latitude,
        longitude: longitude,
      );

  Future<void> deleteTrip(int id) => _remoteDatasource.deleteTrip(id);
  Future<({TripModel trip, String role})> joinTrip(String shareCode) =>
      _remoteDatasource.joinTrip(shareCode);
  Future<List<TripMemberModel>> getMembers(int tripId) =>
      _remoteDatasource.getMembers(tripId);
  Future<void> updateMemberRole(int tripId, int userId, String role) =>
      _remoteDatasource.updateMemberRole(tripId, userId, role);
  Future<void> removeMember(int tripId, int userId) =>
      _remoteDatasource.removeMember(tripId, userId);
}
