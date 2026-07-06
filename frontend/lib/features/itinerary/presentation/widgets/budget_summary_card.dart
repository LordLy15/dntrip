import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/budget_summary_model.dart';
import 'budget_status_badge.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetSummaryModel budget;
  final bool isCompleted;

  const BudgetSummaryCard({
    super.key,
    required this.budget,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
    final planBudget = budget.planBudget ?? 0;
    final totalActual = budget.totalActual ?? 0;
    final totalSudden = budget.totalSuddenExpenses ?? 0;

    final percentage = planBudget > 0
        ? (totalActual / planBudget * 100).clamp(0.0, 200.0)
        : 0.0;

    // Determine surplus/deficit label
    String statusLabel;
    if (isCompleted) {
      statusLabel = budget.remainingBudget > 0 ? 'Budget Surplus' : 'Budget Defisit';
    } else {
      statusLabel = budget.remainingBudget > 0 ? 'Sisa Anggaran' : 'Melebihi Budget';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ringkasan Budget',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                BudgetStatusBadge(budget: budget, showAmount: false),
              ],
            ),
            const SizedBox(height: 16),

            // Plan vs Actual
            Row(
              children: [
                Expanded(
                  child: _BudgetItem(
                    label: 'Rencana',
                    amount: planBudget,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BudgetItem(
                    label: 'Realita',
                    amount: totalActual,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                  _getProgressColor(percentage),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toStringAsFixed(1)}% dari rencana',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),

            // Budget breakdown
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dari Aktivitas:', style: TextStyle(fontSize: 13)),
                      Text(
                        currency.format(budget.totalActualActivities ?? 0),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Pengeluaran Mendadak:', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Off-Budget',
                              style: TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        currency.format(totalSudden),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: budget.remainingBudget >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        currency.format(budget.remainingBudget.abs()),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: budget.remainingBudget >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage <= 105) return Colors.green;
    if (percentage <= 120) return Colors.orange;
    return Colors.red;
  }
}

class _BudgetItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _BudgetItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          currency.format(amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
