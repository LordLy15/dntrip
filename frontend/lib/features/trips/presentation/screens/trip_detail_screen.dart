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
    if (code.isEmpty || code == 'NO-CODE') return;
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Share code copied!'),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripDetailNotifierProvider);

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final shareCode = trip.shareCode ?? 'NO-CODE';
    final hasShareCode = shareCode.isNotEmpty && shareCode != 'NO-CODE';

    return Scaffold(
      appBar: AppBar(title: Text(trip.title ?? 'Trip Detail')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(tripDetailNotifierProvider.notifier).loadTrip(widget.tripId),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Info
              if (trip.destination != null && trip.destination!.isNotEmpty) ...[
                Row(children: [
                  const Icon(Icons.place, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(trip.destination!)),
                ]),
                const SizedBox(height: 12),
              ],

              if (trip.startDate != null || trip.endDate != null) ...[
                Row(children: [
                  const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('${trip.startDate ?? '?'} - ${trip.endDate ?? '?'}'),
                ]),
                const SizedBox(height: 12),
              ],

              if (trip.description != null && trip.description!.isNotEmpty) ...[
                Text(trip.description!),
                const SizedBox(height: 16),
              ],

              // Status Card
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
              const SizedBox(height: 16),

              // Share Code Card - SELALU TAMPILKAN
              Card(
                color: hasShareCode ? Colors.blue.shade50 : Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.share, size: 20, color: hasShareCode ? Colors.blue : Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          hasShareCode ? 'Share Code' : 'Share Code (akan di-generate)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasShareCode ? Colors.blue.shade200 : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              shareCode,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                letterSpacing: 4,
                                color: hasShareCode ? Colors.blue.shade700 : Colors.grey,
                              ),
                            ),
                            if (hasShareCode) ...[
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.copy, color: Colors.blue),
                                onPressed: () => _copyShareCode(shareCode),
                                tooltip: 'Copy Code',
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasShareCode
                            ? 'Bagikan kode ini untuk mengundang teman'
                            : 'Share code akan di-generate saat trip dibuat',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Itinerary Button - JELAS DAN BESAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/trips/${trip.id}/itinerary'),
                  icon: const Icon(Icons.calendar_month, size: 24),
                  label: const Text(
                    'LIHAT ITINERARY & TAMBAH KEGIATAN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tekan untuk melihat Hari 1, Hari 2, dst dan menambah kegiatan',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Members Section
              Text(
                'Members (${trip.members.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (trip.members.isEmpty)
                Text(
                  'Belum ada member',
                  style: TextStyle(color: Colors.grey.shade500),
                )
              else
                ...trip.members.map((m) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: MemberAvatar(name: m.name ?? '?', avatar: m.avatar),
                  title: Text(m.name ?? 'Unknown'),
                  subtitle: Text(m.email ?? ''),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: m.role == 'owner' ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (m.role ?? 'member').toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: m.role == 'owner' ? Colors.blue.shade700 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/trips/${trip.id}/edit'),
        icon: const Icon(Icons.edit),
        label: const Text('Edit Trip'),
      ),
    );
  }
}
