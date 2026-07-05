import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/itinerary_providers.dart';
import '../../data/models/trip_day_model.dart';

class ActivityFormScreen extends ConsumerStatefulWidget {
  final int tripDayId;
  final TripDayModel day;

  const ActivityFormScreen({
    super.key,
    required this.tripDayId,
    required this.day,
  });

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  String _category = 'others';

  final _categories = [
    ('transport', 'Transport'),
    ('food', 'Food'),
    ('accommodation', 'Accommodation'),
    ('tickets', 'Tickets'),
    ('shopping', 'Shopping'),
    ('others', 'Others'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(itineraryNotifierProvider.notifier).createActivity(
      tripDayId: widget.tripDayId,
      title: _titleCtrl.text,
      description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
      category: _category,
      estimatedCost: int.tryParse(_costCtrl.text),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Activity')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title *'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c.$1, child: Text(c.$2)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'others'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costCtrl,
              decoration: const InputDecoration(
                labelText: 'Estimated Cost',
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Add Activity'),
            ),
          ],
        ),
      ),
    );
  }
}
