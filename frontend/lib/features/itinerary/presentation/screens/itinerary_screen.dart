import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/itinerary_providers.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/day_card.dart';
import 'activity_complete_sheet.dart';

class ItineraryScreen extends ConsumerStatefulWidget {
  final int tripId;

  const ItineraryScreen({super.key, required this.tripId});

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(itineraryNotifierProvider.notifier).loadItinerary(widget.tripId),
    );
  }

  void _showCompleteSheet(int activityId) {
    final data = ref.read(itineraryNotifierProvider);
    if (data == null) return;

    final activity = data.days
        .expand((d) => d.activities)
        .firstWhere((a) => a.id == activityId, orElse: () => throw Exception('Activity not found'));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ActivityCompleteSheet(
        activity: activity,
        onComplete: (cost) {
          ref.read(itineraryNotifierProvider.notifier).completeActivity(
            activityId: activityId,
            actualCost: cost,
          );
        },
      ),
    );
  }

  void _navigateToAddActivity(int tripDayId, day) {
    context.push('/trips/${widget.tripId}/activities/new?dayId=$tripDayId');
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(itineraryNotifierProvider);

    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Itinerary')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Itinerary')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(itineraryNotifierProvider.notifier).loadItinerary(widget.tripId),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: BudgetSummaryCard(budget: data.budgetSummary),
            ),
            ...data.days.map(
              (day) => DayCard(
                day: day,
                onActivityTap: _showCompleteSheet,
                onAddActivity: () => _navigateToAddActivity(day.id, day),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
