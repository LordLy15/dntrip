import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/activity_model.dart';
import 'category_badge.dart';
import 'unplanned_badge.dart';

class ActivityTile extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onTap;
  final NumberFormat _currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

  ActivityTile({super.key, required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CategoryBadge(category: activity.category),
      title: Row(
        children: [
          Expanded(child: Text(activity.title)),
          if (activity.isUnplanned) const UnplannedBadge(),
        ],
      ),
      subtitle: Text(
        activity.estimatedCost > 0
            ? _currency.format(activity.estimatedCost)
            : 'No budget',
      ),
      trailing: activity.isCompleted
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
    );
  }
}
