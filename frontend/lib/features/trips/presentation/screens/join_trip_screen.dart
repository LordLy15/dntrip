import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/trip_providers.dart';

class JoinTripScreen extends ConsumerStatefulWidget {
  const JoinTripScreen({super.key});

  @override
  ConsumerState<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends ConsumerState<JoinTripScreen> {
  final _codeCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a 6-character code')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await ref.read(tripsNotifierProvider.notifier).joinTrip(code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Joined as ${result.role}!'), backgroundColor: Colors.green));
        context.go('/trips/${result.trip.id}');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Trip')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('Enter Trip Code', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Enter the 6-character code shared by the trip owner', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            TextField(
              controller: _codeCtrl,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: const InputDecoration(hintText: 'XXXXXX', counterText: ''),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _isLoading ? null : _join, child: _isLoading ? const CircularProgressIndicator() : const Text('Join Trip')),
            ),
          ],
        ),
      ),
    );
  }
}
