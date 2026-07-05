import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    final tripsState = ref.watch(tripsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_link),
            onPressed: () => context.push('/join'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(tripsNotifierProvider.notifier).loadTrips(),
        child: _buildBody(tripsState),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/trips/new'),
        child: const Icon(Icons.add),
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
              Text('No trips yet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600])),
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
