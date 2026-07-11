import 'package:flutter/material.dart';
import '../../data/models/budget_summary_model.dart';

class BudgetStatusBadge extends StatelessWidget {
  final BudgetSummaryModel budget;
  final bool showAmount;

  const BudgetStatusBadge({
    super.key,
    required this.budget,
    this.showAmount = true,
  });

  @override
  Widget build(BuildContext context) {
    final status = budget.budgetStatus;
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 16, color: config.textColor),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (showAmount) ...[
            const SizedBox(width: 8),
            Text(
              _formatCurrency(status == BudgetStatus.deficit
                  ? budget.deficitAmount
                  : budget.remainingBudget),
              style: TextStyle(
                color: config.textColor,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.onBudget:
        return _StatusConfig(
          label: 'On Budget',
          icon: Icons.check_circle,
          backgroundColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2E7D32),
        );
      case BudgetStatus.underbudget:
        return _StatusConfig(
          label: 'Underbudget',
          icon: Icons.trending_down,
          backgroundColor: const Color(0xFFE3F2FD),
          textColor: const Color(0xFF1565C0),
        );
      case BudgetStatus.deficit:
        return _StatusConfig(
          label: 'Budget Defisit',
          icon: Icons.warning,
          backgroundColor: const Color(0xFFFFF3E0),
          textColor: const Color(0xFFE65100),
        );
      case BudgetStatus.surplus:
        return _StatusConfig(
          label: 'Budget Surplus',
          icon: Icons.savings,
          backgroundColor: const Color(0xFFC8E6C9),
          textColor: const Color(0xFF1B5E20),
        );
      case BudgetStatus.offBudget:
        return _StatusConfig(
          label: 'Off-Budget',
          icon: Icons.info_outline,
          backgroundColor: const Color(0xFFEEEEEE),
          textColor: const Color(0xFF616161),
        );
    }
  }

  String _formatCurrency(double amount) {
    final absAmount = amount.abs();
    final formatted = absAmount >= 1000000
        ? 'Rp ${(absAmount / 1000000).toStringAsFixed(1)}jt'
        : 'Rp ${absAmount.toStringAsFixed(0)}';
    return amount < 0 ? '-$formatted' : formatted;
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  _StatusConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });
}
