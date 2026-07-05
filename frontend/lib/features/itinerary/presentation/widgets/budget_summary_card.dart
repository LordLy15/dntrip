import 'package:flutter/material.dart';
import '../../data/models/budget_summary_model.dart';
import 'package:intl/intl.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetSummaryModel budget;
  final NumberFormat _currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

  BudgetSummaryCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final percentage = budget.totalEstimated > 0
        ? (budget.totalActual / budget.totalEstimated * 100).clamp(0, 200)
        : 0.0;

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
                Text(
                  'Budget Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Planned', style: Theme.of(context).textTheme.bodySmall),
                    Text(_currency.format(budget.totalEstimated)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Actual', style: Theme.of(context).textTheme.bodySmall),
                    Text(_currency.format(budget.totalActual)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                budget.isOverbudget ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            if (budget.isOverbudget)
              Text(
                'Overbudget: ${_currency.format(budget.variance)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Text('On track', style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
