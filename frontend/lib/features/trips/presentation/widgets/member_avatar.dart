import 'package:flutter/material.dart';

class MemberAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;

  const MemberAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
