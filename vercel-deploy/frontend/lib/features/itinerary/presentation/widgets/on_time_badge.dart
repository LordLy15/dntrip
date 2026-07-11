import 'package:flutter/material.dart';
import '../../data/models/activity_model.dart';

class OnTimeBadge extends StatelessWidget {
  final ActivityModel activity;

  const OnTimeBadge({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.isSkipped) {
      return _buildBadge('Dilompati', Colors.grey, Colors.grey[300]!);
    }

    if (!activity.isStarted && !activity.isCompleted) {
      return _buildBadge('-', Colors.grey, Colors.grey[300]!);
    }

    if (!activity.isCompleted) {
      return _buildBadge('Dimulai', Colors.blue, Colors.blue[50]!);
    }

    if (activity.startedOnTime) {
      return _buildBadge('On Time', const Color(0xFF2E7D32), const Color(0xFFE8F5E9));
    }

    final delayMinutes = activity.startDelayMinutes;
    final delayText = delayMinutes >= 60
        ? 'Terlambat ${(delayMinutes / 60).toStringAsFixed(0)} jam'
        : 'Terlambat $delayMinutes mnt';

    return _buildBadge(delayText, const Color(0xFFC62828), const Color(0xFFFFEBEE));
  }

  Widget _buildBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
