import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/trip_day_model.dart';
import '../../domain/itinerary_providers.dart';
import '../widgets/sudden_expense_sheet.dart';
import 'activity_complete_sheet.dart';

class ItineraryScreen extends ConsumerStatefulWidget {
  final int tripId;

  const ItineraryScreen({super.key, required this.tripId});

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(itineraryNotifierProvider.notifier).loadItinerary(widget.tripId);
    });
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

    if (activity == null) return;

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

  Future<void> _showAddDayDialog() async {
    final data = ref.read(itineraryNotifierProvider);
    if (data == null) return;

    // Calculate next day number
    final lastDay = data.days.isEmpty ? 0 : data.days.map((d) => d.dayNumber ?? 0).reduce((a, b) => a > b ? a : b);
    final nextDayNumber = lastDay + 1;

    // Get suggested date (tomorrow if no days, otherwise day after last)
    DateTime suggestedDate = DateTime.now().add(const Duration(days: 1));
    if (data.days.isNotEmpty) {
      try {
        final lastDateStr = data.days.last.date;
        if (lastDateStr != null) {
          final lastDate = DateTime.parse(lastDateStr);
          suggestedDate = lastDate.add(const Duration(days: 1));
        }
      } catch (_) {}
    }

    final dateController = TextEditingController(
      text: suggestedDate.toIso8601String().split('T')[0],
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah Hari $nextDayNumber'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Tanggal',
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: suggestedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  dateController.text = picked.toIso8601String().split('T')[0];
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (dateController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Pilih tanggal terlebih dahulu')),
                );
                return;
              }
              Navigator.pop(ctx, {
                'date': dateController.text,
              });
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (result != null && result['date'] != null) {
      await _addDay(result['date'] as String);
    }
  }

  Future<void> _addDay(String date) async {
    // Validate date format
    if (date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal tidak boleh kosong')),
      );
      return;
    }

    // Validate date format YYYY-MM-DD
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(date)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format tanggal tidak valid. Gunakan YYYY-MM-DD')),
      );
      return;
    }

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Menambahkan hari...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );

      final repo = ref.read(itineraryRepositoryProvider);
      final newDay = await repo.createDay(tripId: widget.tripId, date: date);
      debugPrint('Day created successfully: $newDay');

      // Refresh itinerary
      await ref.read(itineraryNotifierProvider.notifier).loadItinerary(widget.tripId);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hari berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding day: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        String errorMessage = 'Gagal menambah hari';
        if (e.toString().contains('401')) {
          errorMessage = 'Sesi telah berakhir. Silakan login kembali.';
        } else if (e.toString().contains('403')) {
          errorMessage = 'Anda tidak memiliki akses untuk menambah hari.';
        } else if (e.toString().contains('404')) {
          errorMessage = 'Trip tidak ditemukan.';
        } else if (e.toString().contains('422')) {
          errorMessage = 'Data tidak valid. Periksa format tanggal.';
        } else if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
          errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuddenExpenseSheet() {
    final data = ref.read(itineraryNotifierProvider);
    if (data == null) return;

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

    // Show loading spinner while data is null
    if (data == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Itinerary'),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_balance_wallet),
              onPressed: _showSuddenExpenseSheet,
              tooltip: 'Pengeluaran Mendadak',
            ),
          ],
        ),
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

    // Calculate statistics
    double totalEstimated = 0;
    double totalActual = 0;

    for (final day in data.days) {
      for (final a in day.activities) {
        if (!(a.isUnplanned ?? false)) {
          totalEstimated += (a.estimatedCost ?? 0).toDouble();
          if (a.isCompleted) {
            totalActual += (a.actualCost ?? 0).toDouble();
          }
        }
      }
    }

    final remainingBudget = totalEstimated - totalActual;
    final percentage = totalEstimated > 0
        ? (totalActual / totalEstimated * 100).clamp(0.0, 200.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: _showSuddenExpenseSheet,
            tooltip: 'Pengeluaran Mendadak',
            color: Colors.orange,
          ),
        ],
      ),
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
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
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
              ...data.days.map((day) => _buildDayCard(day)),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActionMenu,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showQuickActionMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.calendar_today, color: Colors.white),
              ),
              title: const Text('Tambah Hari'),
              subtitle: const Text('Tambahkan hari perjalanan baru'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddDayDialog();
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.flash_on, color: Colors.white),
              ),
              title: const Text('Pengeluaran Mendadak'),
              subtitle: const Text('Catat pengeluaran di luar rencana'),
              onTap: () {
                Navigator.pop(ctx);
                _showSuddenExpenseSheet();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
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

  Widget _buildDayCard(TripDayModel day) {
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
                subtitle: Text('Rp ${_formatCurrency((a.estimatedCost ?? 0).toDouble())}'),
                trailing: a.isCompleted
                    ? Text(
                        'Rp ${_formatCurrency((a.actualCost ?? 0).toDouble())}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
