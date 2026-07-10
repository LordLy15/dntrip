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
import '../../features/itinerary/presentation/screens/itinerary_dashboard_screen.dart';
import '../../features/itinerary/presentation/screens/activity_form_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
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
      GoRoute(path: '/home', builder: (_, __) => const TripsListScreen()),
      GoRoute(path: '/trips', builder: (_, __) => const TripsListScreen()),
      GoRoute(path: '/trips/new', builder: (_, __) => const TripFormScreen()),
      GoRoute(path: '/trips/:id', builder: (_, state) => TripDetailScreen(tripId: int.parse(state.pathParameters['id']!))),
      GoRoute(path: '/trips/:id/edit', builder: (_, state) => TripFormScreen(tripId: int.parse(state.pathParameters['id']!))),
      GoRoute(path: '/join', builder: (_, __) => const JoinTripScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(
        path: '/trips/:id/itinerary',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final budgetStr = state.uri.queryParameters['budget'];
          final budget = budgetStr != null ? int.tryParse(budgetStr) ?? 0 : 0;
          final title = state.uri.queryParameters['title'];
          final shareCode = state.uri.queryParameters['shareCode'];
          return ItineraryScreen(
            tripId: id,
            planBudget: budget,
            tripTitle: title,
            shareCode: shareCode,
          );
        },
      ),
      GoRoute(
        path: '/trips/:id/dashboard',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final budgetStr = state.uri.queryParameters['budget'];
          final budget = budgetStr != null ? int.tryParse(budgetStr) ?? 0 : 0;
          return ItineraryDashboardScreen(tripId: id, planBudget: budget.toDouble());
        },
      ),
      GoRoute(
        path: '/trips/:id/activities/new',
        builder: (context, state) {
          final dayId = int.parse(state.uri.queryParameters['dayId']!);
          final day = TripDayModel(id: dayId, dayNumber: 0, date: '');
          return ActivityFormScreen(tripDayId: dayId, day: day);
        },
      ),
    ],
  );
}
