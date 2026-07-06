import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/auth_providers.dart';
import '../../domain/trip_providers.dart';
import '../widgets/trip_card.dart';

class TripsListScreen extends ConsumerStatefulWidget {
  const TripsListScreen({super.key});

  @override
  ConsumerState<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends ConsumerState<TripsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(tripsNotifierProvider.notifier).loadTrips());
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Color _getGreetingColor() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Colors.amber.shade300;
    if (hour < 17) return Colors.orange.shade300;
    return Colors.indigo.shade300;
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    final tripsState = ref.watch(tripsNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    // Safe extraction of user name with null checks
    String userName = '';
    try {
      userName = authState.whenOrNull(
        data: (state) {
          if (state is Authenticated && (state.user.name?.isNotEmpty ?? false)) {
            return state.user.name ?? '';
          }
          return '';
        },
      ) ?? '';
    } catch (e) {
      // ignore and use empty name
      userName = '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getGreetingEmoji(),
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getGreeting(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: _getGreetingColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (userName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back, $userName 👋',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Plan your next adventure!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(tripsNotifierProvider.notifier).loadTrips(),
              child: _buildBody(tripsState),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/trips/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Trip'),
      ),
    );
  }

  Widget _buildBody(TripsState state) {
    if (state is TripsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is TripsLoaded) {
      if (state.trips.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.luggage_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No trips yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first trip!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: state.trips.length,
        itemBuilder: (context, index) => TripCard(
          trip: state.trips[index],
          onTap: () => context.push('/trips/${state.trips[index].id}'),
        ),
      );
    } else if (state is TripsError) {
      return Center(child: Text('Error: ${state.message}'));
    }
    return const SizedBox.shrink();
  }
}
