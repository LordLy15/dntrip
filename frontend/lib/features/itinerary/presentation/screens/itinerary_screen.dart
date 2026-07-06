import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/budget_summary_model.dart';
import '../../domain/itinerary_providers.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/day_card.dart';
import '../widgets/sudden_expense_sheet.dart';
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

    ActivityModel? activity;
    for (final day in data.days) {
      for (final a in day.activities) {
        if (a.id == activityId) {
          activity = a;
          break;
        }
      }
      if (activity != null) break;
    }

    if (activity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity not found')),
      );
      return;
    }

    final selectedActivity = activity;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ActivityCompleteSheet(
        activity: selectedActivity,
        onComplete: (cost) {
          ref.read(itineraryNotifierProvider.notifier).completeActivity(
            activityId: activityId,
            actualCost: cost,
          );
        },
      ),
    );
  }

  void _showSuddenExpenseSheet() {
    final budgetAsync = ref.read(budgetSummaryProvider(widget.tripId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          return budgetAsync.when(
            data: (budget) => SuddenExpenseSheet(
              tripId: widget.tripId,
              planBudget: budget.planBudget,
              currentTotal: budget.totalActual,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Error')),
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
    final timeStatsAsync = ref.watch(activityTimeStatsProvider(widget.tripId));

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
            // Time Stats Summary
            timeStatsAsync.when(
              data: (stats) {
                if (stats['total']! > 0) {
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Performa Waktu',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                '${stats['onTime']}/${stats['total']} Aktivitas On Time',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: LinearProgressIndicator(
                            value: stats['total']! > 0
                                ? stats['onTime']! / stats['total']!
                                : 0,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation(Colors.green),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Budget Summary Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ref.watch(budgetSummaryProvider(widget.tripId)).when(
                data: (budget) => BudgetSummaryCard(budget: budget),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (_, __) => const Card(child: Text('Error loading budget')),
              ),
            ),
            const SizedBox(height: 16),

            // Days with Activities
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSuddenExpenseSheet,
        icon: const Icon(Icons.flash_on),
        label: const Text('Mendadak'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
