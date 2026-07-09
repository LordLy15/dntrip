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
  final int? planBudget;

  const ItineraryScreen({super.key, required this.tripId, this.planBudget});

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  @override
  void initState() {
    super.initState();
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
          // Show enhanced progress snackbar after completion
          _showProgressSnackbar(
            activityTitle: activity!.title ?? 'Kegiatan',
            isCompleted: true,
          );
        },
      ),
    );
  }

  Future<void> _skipActivity(int activityId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Kegiatan?'),
        content: const Text('Kegiatan ini akan ditandai sebagai dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(itineraryNotifierProvider.notifier).skipActivity(activityId);
      if (mounted) {
        _showProgressSnackbar(
          activityTitle: null,
          isCompleted: false,
          isSkipped: true,
        );
      }
    }
  }

  void _showProgressSnackbar({
    String? activityTitle,
    required bool isCompleted,
    bool isSkipped = false,
  }) {
    final data = ref.read(itineraryNotifierProvider);
    if (data == null) return;

    // Calculate current stats
    double totalActual = 0;
    int completedCount = 0;
    int totalCount = 0;

    for (final day in data.days) {
      for (final a in day.activities) {
        totalCount++;
        if (a.isCompleted) {
          completedCount++;
          totalActual += (a.actualCost ?? 0).toDouble();
        }
      }
    }

    final planBudget = (widget.planBudget ?? 0).toDouble();
    final remainingFromPlan = planBudget - totalActual;
    final percentage = totalCount > 0
        ? (completedCount / totalCount * 100).toStringAsFixed(0)
        : '0';

    final bgColor = isSkipped ? Colors.orange.shade600 : Colors.green.shade600;
    final icon = isSkipped ? Icons.cancel : Icons.check_circle;

    String title;
    if (isSkipped) {
      title = 'Kegiatan dibatalkan';
    } else {
      title = activityTitle != null
          ? '"$activityTitle" selesai'
          : 'Kegiatan selesai';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$completedCount/$totalCount ($percentage%)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (planBudget > 0) ...[
                  Text(
                    'Plan: Rp ${_formatCurrencyFull(planBudget)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
            if (planBudget > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Realita: ',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Rp ${_formatCurrencyFull(totalActual)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    ' • Sisa: ',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    remainingFromPlan >= 0
                        ? 'Rp ${_formatCurrencyFull(remainingFromPlan)}'
                        : '-Rp ${_formatCurrencyFull(remainingFromPlan.abs())}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: remainingFromPlan >= 0 ? Colors.green.shade200 : Colors.red.shade200,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatCurrencyFull(double amount) {
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    final length = str.length;
    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  Future<void> _showAddDayDialog() async {
    final data = ref.read(itineraryNotifierProvider);
    if (data == null) return;

    final lastDay = data.days.isEmpty ? 0 : data.days.map((d) => d.dayNumber ?? 0).reduce((a, b) => a > b ? a : b);
    final nextDayNumber = lastDay + 1;

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
              Navigator.pop(ctx, {'date': dateController.text});
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
    if (date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal tidak boleh kosong')),
      );
      return;
    }

    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(date)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format tanggal tidak valid. Gunakan YYYY-MM-DD')),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 16),
              Text('Menambahkan hari...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );

      final repo = ref.read(itineraryRepositoryProvider);
      await repo.createDay(tripId: widget.tripId, date: date);
      await ref.read(itineraryNotifierProvider.notifier).loadItinerary(widget.tripId);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hari berhasil ditambahkan!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('Error adding day: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah hari: $e'), backgroundColor: Colors.red),
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
          totalActual += (a.actualCost ?? 0).toDouble();
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SuddenExpenseSheet(
        tripId: widget.tripId,
        planBudget: (widget.planBudget ?? 0).toDouble(),
        currentTotal: totalActual,
        days: data.days,
      ),
    );
  }

  void _navigateToAddActivity(int tripDayId) {
    context.push('/trips/${widget.tripId}/activities/new?dayId=$tripDayId');
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(itineraryNotifierProvider);

    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Itinerary')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Calculate statistics
    double totalEstimated = 0;
    double totalActual = 0;
    int completedCount = 0;
    int cancelledCount = 0;
    int totalCount = 0;

    for (final day in data.days) {
      for (final a in day.activities) {
        totalCount++;
        if (a.isCompleted) {
          completedCount++;
          totalEstimated += (a.estimatedCost ?? 0).toDouble();
          totalActual += (a.actualCost ?? 0).toDouble();
        } else if (a.isSkipped) {
          cancelledCount++;
          totalEstimated += (a.estimatedCost ?? 0).toDouble();
        } else {
          totalEstimated += (a.estimatedCost ?? 0).toDouble();
        }
      }
    }

    final planBudget = (widget.planBudget ?? 0).toDouble();
    final remainingFromPlan = planBudget - totalActual;
    final percentage = totalEstimated > 0
        ? (totalActual / totalEstimated * 100).clamp(0.0, 200.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () => context.push('/trips/${widget.tripId}/dashboard?budget=${widget.planBudget ?? 0}'),
            tooltip: 'Dashboard',
            color: Theme.of(context).colorScheme.primary,
          ),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ringkasan Trip',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '$completedCount/$totalCount kegiatan selesai • $cancelledCount dibatalkan',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Plan Budget vs Actual
                  if (planBudget > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem('Plan Budget', 'Rp ${_formatCurrency(planBudget)}'),
                        _buildStatItem('Realita', 'Rp ${_formatCurrency(totalActual)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      remainingFromPlan >= 0
                          ? 'Sisa budget: Rp ${_formatCurrency(remainingFromPlan)}'
                          : 'Lebih dari budget: Rp ${_formatCurrency(remainingFromPlan.abs())}',
                      style: TextStyle(
                        color: remainingFromPlan >= 0 ? Colors.green.shade100 : Colors.red.shade200,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Progress
                  if (!data.days.isEmpty && totalCount > 0) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (completedCount / totalCount).clamp(0.0, 1.0),
                        backgroundColor: Colors.white30,
                        valueColor: AlwaysStoppedAnimation(Colors.green),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${completedCount}/$totalCount kegiatan selesai (${((completedCount / totalCount) * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                      Text('Belum ada itinerary', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
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
              leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.calendar_today, color: Colors.white)),
              title: const Text('Tambah Hari'),
              subtitle: const Text('Tambahkan hari perjalanan baru'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddDayDialog();
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.flash_on, color: Colors.white)),
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
    double dayEstimated = 0;
    double dayActual = 0;
    int completedInDay = 0;
    int totalInDay = day.activities.length;

    for (final a in day.activities) {
      if (a.isCompleted) {
        completedInDay++;
        dayActual += (a.actualCost ?? 0).toDouble();
      }
      dayEstimated += (a.estimatedCost ?? 0).toDouble();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: completedInDay == totalInDay && totalInDay > 0 ? Colors.green : Theme.of(context).colorScheme.primary,
          child: completedInDay == totalInDay && totalInDay > 0
              ? const Icon(Icons.check, color: Colors.white)
              : Text('${day.dayNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text('Hari ${day.dayNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day.date ?? 'Tanggal tidak tersedia'),
            if (totalInDay > 0)
              Text(
                '$completedInDay/$totalInDay selesai • Rp ${_formatCurrency(dayActual)}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        initiallyExpanded: true,
        children: [
          if (day.activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Belum ada kegiatan di hari ini'),
            )
          else
            ...day.activities.map<Widget>((a) => _buildActivityTile(a)),
          ListTile(
            leading: const CircleAvatar(radius: 16, backgroundColor: Colors.blue, child: Icon(Icons.add, size: 16, color: Colors.white)),
            title: const Text('Tambah Kegiatan', style: TextStyle(color: Colors.blue)),
            onTap: () => _navigateToAddActivity(day.id),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(ActivityModel a) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (a.isCompleted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Rp ${_formatCurrency((a.actualCost ?? 0).toDouble())}';
    } else if (a.isSkipped) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Dibatalkan';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.schedule;
      statusText = 'Rp ${_formatCurrency((a.estimatedCost ?? 0).toDouble())}';
    }

    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: statusColor,
        child: Icon(statusIcon, size: 16, color: Colors.white),
      ),
      title: Text(a.title ?? 'Tanpa judul'),
      subtitle: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
      trailing: a.isPending
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _showCompleteSheet(a.id),
                  tooltip: 'Selesai',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _skipActivity(a.id),
                  tooltip: 'Batalkan',
                ),
              ],
            )
          : null,
      onTap: a.isPending ? () => _showCompleteSheet(a.id) : null,
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
