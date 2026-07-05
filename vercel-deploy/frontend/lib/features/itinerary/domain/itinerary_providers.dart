import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dntrip/features/auth/domain/auth_providers.dart';
import '../data/datasources/itinerary_remote_datasource.dart';
import '../data/itinerary_repository.dart';
import '../data/models/itinerary_data.dart';

part 'itinerary_providers.g.dart';

@riverpod
ItineraryRemoteDatasource itineraryRemoteDatasource(ItineraryRemoteDatasourceRef ref) {
  return ItineraryRemoteDatasource(ref.watch(apiClientProvider));
}

@riverpod
ItineraryRepository itineraryRepository(ItineraryRepositoryRef ref) {
  return ItineraryRepository(ref.watch(itineraryRemoteDatasourceProvider));
}

@riverpod
class ItineraryNotifier extends _$ItineraryNotifier {
  @override
  ItineraryData? build() => null;

  Future<void> loadItinerary(int tripId) async {
    state = await ref.read(itineraryRepositoryProvider).getItinerary(tripId);
  }

  Future<void> createActivity({
    required int tripDayId,
    required String title,
    String? description,
    required String category,
    int? estimatedCost,
  }) async {
    final tripId = state?.tripId;
    if (tripId == null) return;

    await ref.read(itineraryRepositoryProvider).createActivity(
      tripId: tripId,
      tripDayId: tripDayId,
      title: title,
      description: description,
      category: category,
      estimatedCost: estimatedCost,
    );

    await loadItinerary(tripId);
  }

  Future<void> completeActivity({
    required int activityId,
    required int actualCost,
  }) async {
    final tripId = state?.tripId;
    if (tripId == null) return;

    await ref.read(itineraryRepositoryProvider).completeActivity(
      tripId: tripId,
      activityId: activityId,
      actualCost: actualCost,
    );

    await loadItinerary(tripId);
  }

  Future<void> deleteActivity(int activityId) async {
    final tripId = state?.tripId;
    if (tripId == null) return;

    await ref.read(itineraryRepositoryProvider).deleteActivity(tripId, activityId);
    await loadItinerary(tripId);
  }
}
