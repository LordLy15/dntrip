import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/trips/presentation/screens/trips_list_screen.dart';
import '../../features/trips/presentation/screens/trip_detail_screen.dart';
import '../../features/trips/presentation/screens/trip_form_screen.dart';
import '../../features/trips/presentation/screens/join_trip_screen.dart';
import '../../features/itinerary/presentation/screens/itinerary_screen.dart';
import '../../features/itinerary/presentation/screens/activity_form_screen.dart';
import '../../features/itinerary/domain/itinerary_providers.dart';
import '../../features/itinerary/data/models/trip_day_model.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/trips', builder: (_, __) => const TripsListScreen()),
      GoRoute(path: '/trips/new', builder: (_, __) => const TripFormScreen()),
      GoRoute(path: '/trips/:id', builder: (_, state) => TripDetailScreen(tripId: int.parse(state.pathParameters['id']!))),
      GoRoute(path: '/trips/:id/edit', builder: (_, state) => TripFormScreen(tripId: int.parse(state.pathParameters['id']!))),
      GoRoute(path: '/join', builder: (_, __) => const JoinTripScreen()),
      GoRoute(
        path: '/trips/:id/itinerary',
        builder: (context, state) => ItineraryScreen(
          tripId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/trips/:id/activities/new',
        builder: (context, state) {
          final dayId = int.parse(state.uri.queryParameters['dayId']!);
          // Create a placeholder day model - in real usage this would be passed properly
          final day = TripDayModel(id: dayId, dayNumber: 0, date: '');
          return ActivityFormScreen(tripDayId: dayId, day: day);
        },
      ),
    ],
  );
}
