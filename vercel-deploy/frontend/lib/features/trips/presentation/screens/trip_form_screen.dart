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
  final _budgetCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  bool _isLoading = false;
  bool _addLocation = false;
  bool get _isEdit => widget.tripId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      Future.microtask(() async {
        await ref.read(tripDetailNotifierProvider.notifier).loadTrip(widget.tripId!);
        final trip = ref.read(tripDetailNotifierProvider);
        if (trip != null) {
          _titleCtrl.text = trip.title ?? '';
          _destCtrl.text = trip.destination ?? '';
          _descCtrl.text = trip.description ?? '';
          if (trip.planBudget != null) _budgetCtrl.text = trip.planBudget.toString();
          if (trip.latitude != null && trip.longitude != null) {
            _addLocation = true;
            _latCtrl.text = trip.latitude ?? '';
            _lngCtrl.text = trip.longitude ?? '';
          }
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
    _budgetCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0)) : (_endTime ?? const TimeOfDay(hour: 18, minute: 0)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _buildDateTimeString(DateTime date, TimeOfDay? time) {
    final dateStr = _formatDate(date);
    if (time != null) {
      return '$dateStr ${_formatTime(time)}';
    }
    return dateStr;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select dates')));
      return;
    }

    final planBudget = int.tryParse(_budgetCtrl.text);
    final latitude = _addLocation ? _latCtrl.text : null;
    final longitude = _addLocation ? _lngCtrl.text : null;

    setState(() => _isLoading = true);
    try {
      final notifier = ref.read(tripsNotifierProvider.notifier);
      if (_isEdit) {
        await ref.read(tripDetailNotifierProvider.notifier).updateTrip(
          title: _titleCtrl.text,
          destination: _destCtrl.text.isEmpty ? null : _destCtrl.text,
          description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
          planBudget: planBudget,
          latitude: latitude,
          longitude: longitude,
          startDate: _buildDateTimeString(_startDate!, _startTime),
          endDate: _buildDateTimeString(_endDate!, _endTime),
        );
      } else {
        await notifier.createTrip(
          title: _titleCtrl.text,
          destination: _destCtrl.text.isEmpty ? null : _destCtrl.text,
          description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
          planBudget: planBudget,
          latitude: latitude,
          longitude: longitude,
          startDate: _buildDateTimeString(_startDate!, _startTime),
          endDate: _buildDateTimeString(_endDate!, _endTime),
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
            // Basic Info Section
            Text('Basic Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Trip Title *')),
            const SizedBox(height: 12),
            TextFormField(controller: _destCtrl, decoration: const InputDecoration(labelText: 'Destination')),
            const SizedBox(height: 12),
            TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),

            const SizedBox(height: 24),

            // Budget Section
            Text('Budget Planning', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _budgetCtrl,
              decoration: const InputDecoration(
                labelText: 'Plan Budget',
                prefixText: 'Rp ',
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            // Location Section
            Text('Location (Optional)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Add Location'),
              subtitle: const Text('Add GPS coordinates to this trip'),
              value: _addLocation,
              onChanged: (value) => setState(() => _addLocation = value),
              contentPadding: EdgeInsets.zero,
            ),
            if (_addLocation) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        hintText: '-6.200000',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        hintText: '106.816666',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Example: Jakarta (-6.200000, 106.816666)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],

            const SizedBox(height: 24),

            // Date & Time Section
            Text('Schedule', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Start Date & Time', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(_startDate != null ? _formatDate(_startDate!) : 'Date'),
                  onPressed: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.access_time, size: 18),
                  label: Text(_startTime != null ? _formatTime(_startTime!) : 'Time'),
                  onPressed: () => _selectTime(true),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Text('End Date & Time', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(_endDate != null ? _formatDate(_endDate!) : 'Date'),
                  onPressed: () => _selectDate(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.access_time, size: 18),
                  label: Text(_endTime != null ? _formatTime(_endTime!) : 'Time'),
                  onPressed: () => _selectTime(false),
                ),
              ),
            ]),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading ? const CircularProgressIndicator() : Text(_isEdit ? 'Save Changes' : 'Create Trip'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
