import 'package:flutter/material.dart';
import '../../data/models/trip_model.dart';
import 'status_badge.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback? onTap;

  const TripCard({super.key, required this.trip, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.place, color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(trip.title ?? 'Untitled', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  StatusBadge(status: trip.status ?? 'planned'),
                ],
              ),
              const SizedBox(height: 8),
              if (trip.destination != null)
                Row(
                  children: [
                    const SizedBox(width: 28),
                    Text(trip.destination!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  ],
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 28),
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(_formatDateRange(trip.startDate, trip.endDate), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                  const Spacer(),
                  Icon(Icons.people, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${trip.membersCount ?? trip.members.length}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateRange(String? start, String? end) {
    if (start == null && end == null) return 'No dates set';
    if (start != null && end != null) return '${_formatDate(start)} - ${_formatDate(end)}';
    return start ?? end ?? '';
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    if (parts.length != 3) return date;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = int.tryParse(parts[1]) ?? 1;
    final day = parts[2];
    return '${months[month - 1]} $day';
  }
}
