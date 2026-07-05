import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/activity_model.dart';

class ActivityCompleteSheet extends StatefulWidget {
  final ActivityModel activity;
  final Function(int actualCost) onComplete;

  const ActivityCompleteSheet({
    super.key,
    required this.activity,
    required this.onComplete,
  });

  @override
  State<ActivityCompleteSheet> createState() => _ActivityCompleteSheetState();
}

class _ActivityCompleteSheetState extends State<ActivityCompleteSheet> {
  late final TextEditingController _costController;
  final NumberFormat _currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _costController = TextEditingController(
      text: widget.activity.estimatedCost.toString(),
    );
  }

  @override
  void dispose() {
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mark Activity Complete',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            widget.activity.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('Estimated: ${_currency.format(widget.activity.estimatedCost)}'),
          const SizedBox(height: 16),
          TextField(
            controller: _costController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Actual Cost',
              prefixText: 'Rp ',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final cost = int.tryParse(_costController.text) ?? 0;
              widget.onComplete(cost);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
