import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/budget_summary_model.dart';
import '../../domain/itinerary_providers.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/day_card.dart';
import '../widgets/sudden_expense_sheet.dart';
import 'activity_complete_sheet.dart';

class ItineraryScreen extends ConsumerStatefulWidget {
  final int tripId;

  const ItineraryScreen({super.key, required this.tripId});

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isInitialLoading = true);
    await ref.read(itineraryNotifierProvider.notifier).loadItinerary(widget.tripId);
    if (mounted) {
      setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _refresh() async {
    await ref.read(itineraryNotifierProvider.notifier).loadItinerary(widget.tripId);
  }

  void _showCompleteSheet(int activityId) {
    final data = ref.read(itineraryNotifierProvider);
    if (data == null) return;

    ActivityModel? activity;
    for (final day in data.days) {
      for (final a in day.activities) {
        if (a.id == activityId) {
          activity = a;
          break;
        }
      }
      if (activity != null) break;
    }

    if (activity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity tidak ditemukan')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => ActivityCompleteSheet(
        activity: activity!,
        onComplete: (cost) {
          ref.read(itineraryNotifierProvider.notifier).completeActivity(
            activityId: activityId,
            actualCost: cost,
          );
        },
      ),
    );
  }

  void _showSuddenExpenseSheet() {
    final data = ref.read(itineraryNotifierProvider);
    if (data == null) return;

    // Hitung budget dari data yang sudah ada
    double totalActual = 0;
    for (final day in data.days) {
      for (final a in day.activities) {
        if (a.isCompleted) {
          totalActual += a.actualCost ?? 0;
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SuddenExpenseSheet(
        tripId: widget.tripId,
        planBudget: 0,
        currentTotal: totalActual,
      ),
    );
  }

  void _navigateToAddActivity(int tripDayId) {
    context.push('/trips/${widget.tripId}/activities/new?dayId=$tripDayId');
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(itineraryNotifierProvider);

    // Initial loading
    if (_isInitialLoading || data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Itinerary')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat itinerary...'),
            ],
          ),
        ),
      );
    }

    // Hitung statistik dari data lokal
    int totalActivities = 0;
    int onTimeActivities = 0;
    double totalEstimated = 0;
    double totalActual = 0;

    for (final day in data.days) {
      for (final a in day.activities) {
        if (!a.isUnplanned) {
          totalActivities++;
          totalEstimated += a.estimatedCost;
          if (a.isCompleted) {
            totalActual += a.actualCost ?? 0;
            if (a.startedOnTime) {
              onTimeActivities++;
            }
          }
        }
      }
    }

    final remainingBudget = totalEstimated - totalActual;
    final percentage = totalEstimated > 0
        ? (totalActual / totalEstimated * 100).clamp(0.0, 200.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Itinerary')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            // Summary Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Ringkasan Trip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem('Estimasi', 'Rp ${_formatCurrency(totalEstimated)}'),
                      _buildStatItem('Realita', 'Rp ${_formatCurrency(totalActual)}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (percentage / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.white30,
                      valueColor: AlwaysStoppedAnimation(
                        percentage > 100 ? Colors.red : Colors.green,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(0)}% dari estimasi',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        remainingBudget >= 0
                            ? 'Sisa: Rp ${_formatCurrency(remainingBudget)}'
                            : 'Lebih: Rp ${_formatCurrency(remainingBudget.abs())}',
                        style: TextStyle(
                          color: remainingBudget >= 0 ? Colors.green.shade100 : Colors.red.shade200,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (totalActivities > 0) ...[
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white30),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '$onTimeActivities/$totalActivities Aktivitas On Time',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 50,
                          child: LinearProgressIndicator(
                            value: totalActivities > 0 ? onTimeActivities / totalActivities : 0,
                            backgroundColor: Colors.white30,
                            valueColor: const AlwaysStoppedAnimation(Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Days
            if (data.days.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada itinerary',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tekan tombol + di bawah untuk menambah hari perjalanan',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...data.days.map(
                (day) => _buildDayCard(day),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSuddenExpenseSheet,
        icon: const Icon(Icons.flash_on),
        label: const Text('Pengeluaran Mendadak'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDayCard(day) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            '${day.dayNumber}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          'Hari ${day.dayNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(day.date ?? 'Tanggal tidak tersedia'),
        initiallyExpanded: true,
        children: [
          if (day.activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Belum ada kegiatan di hari ini'),
            )
          else
            ...day.activities.map<Widget>(
              (a) => ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: a.isCompleted ? Colors.green : Colors.grey.shade300,
                  child: Icon(
                    a.isCompleted ? Icons.check : Icons.schedule,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                title: Text(a.title ?? 'Tanpa judul'),
                subtitle: Text('Rp ${_formatCurrency(a.estimatedCost)}'),
                trailing: a.isCompleted
                    ? Text(
                        'Rp ${_formatCurrency(a.actualCost ?? 0)}',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
                onTap: a.isCompleted ? null : () => _showCompleteSheet(a.id),
              ),
            ),
          ListTile(
            leading: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.add, size: 16, color: Colors.white),
            ),
            title: const Text('Tambah Kegiatan', style: TextStyle(color: Colors.blue)),
            onTap: () => _navigateToAddActivity(day.id),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return amount.toStringAsFixed(0);
  }
}
