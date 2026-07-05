import 'package:flutter/material.dart';
import '../../data/models/trip_day_model.dart';
import 'activity_tile.dart';

class DayCard extends StatelessWidget {
  final TripDayModel day;
  final Function(int activityId) onActivityTap;
  final VoidCallback onAddActivity;

  const DayCard({
    super.key,
    required this.day,
    required this.onActivityTap,
    required this.onAddActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          'Day ${day.dayNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(day.date),
        initiallyExpanded: true,
        children: [
          if (day.notes != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(day.notes!, style: Theme.of(context).textTheme.bodySmall),
            ),
          ...day.activities.map(
            (a) => ActivityTile(
              activity: a,
              onTap: () => onActivityTap(a.id),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add, color: Colors.green),
            title: const Text(
              'Add Activity',
              style: TextStyle(color: Colors.green),
            ),
            onTap: onAddActivity,
          ),
        ],
      ),
    );
  }
}
