import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String _formatDateDisplay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'No date set';
    try {
      // Try parsing with time first
      if (dateStr.contains(' ')) {
        final parts = dateStr.split(' ');
        final date = DateTime.parse(parts[0]);
        final time = parts[1];
        final dayName = DateFormat('EEEE').format(date);
        return '$dayName, ${DateFormat('MMM d, yyyy').format(date)} - $time';
      }
      // Just date
      final date = DateTime.parse(dateStr);
      final dayName = DateFormat('EEEE').format(date);
      return '$dayName, ${DateFormat('MMM d, yyyy').format(date)}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            '${day.dayNumber}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          'Day ${day.dayNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_formatDateDisplay(day.date)),
        initiallyExpanded: true,
        children: [
          if (day.notes != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(day.notes!, style: Theme.of(context).textTheme.bodySmall),
            ),
          if (day.activities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No activities yet',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ...day.activities.map(
            (a) => ActivityTile(
              activity: a,
              onTap: () => onActivityTap(a.id),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Colors.green),
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
