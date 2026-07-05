import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/trip_providers.dart';

class TripFormScreen extends ConsumerStatefulWidget {
  final int? tripId;
  const TripFormScreen({super.key, this.tripId});

  @override
  ConsumerState<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends ConsumerState<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool get _isEdit => widget.tripId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      Future.microtask(() async {
        await ref.read(tripDetailNotifierProvider.notifier).loadTrip(widget.tripId!);
        final trip = ref.read(tripDetailNotifierProvider);
        if (trip != null) {
          _titleCtrl.text = trip.title;
          _destCtrl.text = trip.destination ?? '';
          _descCtrl.text = trip.description ?? '';
          if (trip.startDate != null) _startDate = DateTime.tryParse(trip.startDate!);
          if (trip.endDate != null) _endDate = DateTime.tryParse(trip.endDate!);
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _destCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) _endDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select dates')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final notifier = ref.read(tripsNotifierProvider.notifier);
      if (_isEdit) {
        await ref.read(tripDetailNotifierProvider.notifier).updateTrip(
          title: _titleCtrl.text,
          destination: _destCtrl.text.isEmpty ? null : _destCtrl.text,
          description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
          startDate: _startDate!.toIso8601String().split('T')[0],
          endDate: _endDate!.toIso8601String().split('T')[0],
        );
      } else {
        await notifier.createTrip(
          title: _titleCtrl.text,
          destination: _destCtrl.text.isEmpty ? null : _destCtrl.text,
          description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
          startDate: _startDate!.toIso8601String().split('T')[0],
          endDate: _endDate!.toIso8601String().split('T')[0],
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Trip' : 'Create Trip')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Trip Title *')),
            const SizedBox(height: 16),
            TextFormField(controller: _destCtrl, decoration: const InputDecoration(labelText: 'Destination')),
            const SizedBox(height: 16),
            TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: ListTile(
                title: const Text('Start Date *'),
                subtitle: Text(_startDate?.toIso8601String().split('T')[0] ?? 'Select'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(true),
              )),
              const SizedBox(width: 16),
              Expanded(child: ListTile(
                title: const Text('End Date *'),
                subtitle: Text(_endDate?.toIso8601String().split('T')[0] ?? 'Select'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(false),
              )),
            ]),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading ? const CircularProgressIndicator() : Text(_isEdit ? 'Save Changes' : 'Create Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
