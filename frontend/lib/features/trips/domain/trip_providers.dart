import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/datasources/trip_remote_datasource.dart';
import '../data/trip_repository.dart';
import '../data/models/trip_model.dart';
import '../data/models/trip_member_model.dart';
import '../../auth/domain/auth_providers.dart';

part 'trip_providers.g.dart';

// Base providers - reuse apiClient from auth
@riverpod
TripRemoteDatasource tripRemoteDatasource(TripRemoteDatasourceRef ref) {
  return TripRemoteDatasource(ref.watch(apiClientProvider));
}

@riverpod
TripRepository tripRepository(TripRepositoryRef ref) {
  return TripRepository(ref.watch(tripRemoteDatasourceProvider));
}

// Trip list state
sealed class TripsState {
  const TripsState();
}

class TripsLoading extends TripsState {
  const TripsLoading();
}

class TripsLoaded extends TripsState {
  final List<TripModel> trips;
  const TripsLoaded(this.trips);
}

class TripsError extends TripsState {
  final String message;
  const TripsError(this.message);
}

@riverpod
class TripsNotifier extends _$TripsNotifier {
  @override
  TripsState build() => const TripsLoading();

  Future<void> loadTrips() async {
    state = const TripsLoading();
    try {
      final trips = await ref.read(tripRepositoryProvider).getTrips();
      state = TripsLoaded(trips);
    } catch (e) {
      state = TripsError(e.toString());
    }
  }

  Future<TripModel> createTrip({
    required String title,
    String? destination,
    String? description,
    required String startDate,
    required String endDate,
  }) async {
    final trip = await ref.read(tripRepositoryProvider).createTrip(
      title: title,
      destination: destination,
      description: description,
      startDate: startDate,
      endDate: endDate,
    );
    await loadTrips();
    return trip;
  }

  Future<void> deleteTrip(int id) async {
    await ref.read(tripRepositoryProvider).deleteTrip(id);
    await loadTrips();
  }

  Future<({TripModel trip, String role})> joinTrip(String shareCode) async {
    final result = await ref.read(tripRepositoryProvider).joinTrip(shareCode);
    await loadTrips();
    return result;
  }
}

// Single trip detail state
@riverpod
class TripDetailNotifier extends _$TripDetailNotifier {
  @override
  TripModel? build() => null;

  Future<void> loadTrip(int id) async {
    state = await ref.read(tripRepositoryProvider).getTrip(id);
  }

  Future<void> updateStatus(String status) async {
    if (state == null) return;
    final updated = await ref.read(tripRepositoryProvider).updateTrip(
      id: state!.id,
      status: status,
    );
    state = updated;
  }

  Future<void> updateTrip({
    String? title,
    String? destination,
    String? description,
    String? startDate,
    String? endDate,
  }) async {
    if (state == null) return;
    final updated = await ref.read(tripRepositoryProvider).updateTrip(
      id: state!.id,
      title: title,
      destination: destination,
      description: description,
      startDate: startDate,
      endDate: endDate,
    );
    state = updated;
  }
}

// Members state
@riverpod
class MembersNotifier extends _$MembersNotifier {
  @override
  List<TripMemberModel> build() => [];

  Future<void> loadMembers(int tripId) async {
    state = await ref.read(tripRepositoryProvider).getMembers(tripId);
  }

  Future<void> updateRole(int userId, String role) async {
    final tripId = ref.read(tripDetailNotifierProvider)!.id;
    await ref.read(tripRepositoryProvider).updateMemberRole(tripId, userId, role);
    await loadMembers(tripId);
  }

  Future<void> removeMember(int userId) async {
    final tripId = ref.read(tripDetailNotifierProvider)!.id;
    await ref.read(tripRepositoryProvider).removeMember(tripId, userId);
    await loadMembers(tripId);
  }
}
