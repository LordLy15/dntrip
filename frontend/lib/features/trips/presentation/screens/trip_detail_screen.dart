import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/trip_providers.dart';
import '../widgets/status_badge.dart';
import '../widgets/member_avatar.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final int tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(tripDetailNotifierProvider.notifier).loadTrip(widget.tripId));
  }

  void _copyShareCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share code copied!')));
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripDetailNotifierProvider);

    if (trip == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(trip.title ?? 'Untitled')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trip.destination != null) ...[
              Row(children: [const Icon(Icons.place, size: 20), const SizedBox(width: 8), Text(trip.destination!)]),
              const SizedBox(height: 12),
            ],
            if (trip.startDate != null || trip.endDate != null) ...[
              Row(children: [const Icon(Icons.calendar_today, size: 20), const SizedBox(width: 8), Text('${trip.startDate ?? '?'} - ${trip.endDate ?? '?'}')]),
              const SizedBox(height: 12),
            ],
            if (trip.description != null) ...[Text(trip.description!), const SizedBox(height: 16)],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const Text('Status: '),
                  const Spacer(),
                  StatusBadge(status: trip.status ?? 'planned'),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            if (trip.shareCode != null && trip.shareCode!.isNotEmpty)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.share, size: 20, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('Share Code:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              trip.shareCode ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: 4,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.blue),
                              onPressed: () => _copyShareCode(trip.shareCode ?? ''),
                              tooltip: 'Copy Code',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bagikan kode ini untuk mengundang teman',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Itinerary Button
            ElevatedButton.icon(
              onPressed: () => context.push('/trips/${trip.id}/itinerary'),
              icon: const Icon(Icons.calendar_month),
              label: const Text('Lihat Itinerary & Tambah Kegiatan'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 24),

            Text('Members (${trip.members.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...trip.members.map((m) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: MemberAvatar(name: m.name ?? '?'),
              title: Text(m.name ?? 'Unknown'),
              trailing: Text((m.role ?? 'member').toUpperCase()),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/trips/${trip.id}/edit'),
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
      ),
    );
  }
}
