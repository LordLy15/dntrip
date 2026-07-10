import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/activity_model.dart';
import 'category_badge.dart';
import 'unplanned_badge.dart';
import 'on_time_badge.dart';

class ActivityTile extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onTap;
  final bool showOnTimeBadge;
  final NumberFormat _currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

  ActivityTile({
    super.key,
    required this.activity,
    required this.onTap,
    this.showOnTimeBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CategoryBadge(category: activity.category ?? 'others'),
      title: Row(
        children: [
          Expanded(child: Text(activity.title ?? 'Untitled')),
          if (activity.isUnplanned == true) const UnplannedBadge(),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (activity.estimatedCost ?? 0) > 0
                ? _currency.format(activity.estimatedCost)
                : 'No budget',
          ),
          if (activity.isCompleted && showOnTimeBadge)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: OnTimeBadge(activity: activity),
            ),
        ],
      ),
      trailing: activity.isCompleted
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showOnTimeBadge && activity.startedOnTime)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20)
                else if (showOnTimeBadge)
                  const Icon(Icons.warning, color: Colors.orange, size: 20)
                else
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right),
              ],
            )
          : const Icon(Icons.circle_outlined, color: Colors.grey),
    );
  }
}
