import 'package:flutter/material.dart';

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({super.key, required this.category});

  IconData get icon {
    switch (category) {
      case 'transport':
        return Icons.directions_car;
      case 'food':
        return Icons.restaurant;
      case 'accommodation':
        return Icons.hotel;
      case 'tickets':
        return Icons.confirmation_number;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary);
  }
}
