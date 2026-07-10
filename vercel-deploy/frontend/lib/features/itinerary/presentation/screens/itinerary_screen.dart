import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/trip_day_model.dart';
import '../../domain/itinerary_providers.dart';
import '../../../trips/domain/trip_providers.dart';
import '../widgets/sudden_expense_sheet.dart';
import 'activity_complete_sheet.dart';

class ItineraryScreen extends ConsumerStatefulWidget {
  final int tripId;
  final int? planBudget;
  final String? tripTitle;
  final String? shareCode;

  const ItineraryScreen({
    super.key,
    required this.tripId,
    this.planBudget,
    this.tripTitle,
    this.shareCode,
  });

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(itineraryNotifierProvider.notifier).loadItinerary(widget.tripId);
      // Load trip details for share code and members
      ref.read(tripDetailNotifierProvider.notifier).loadTrip(widget.tripId);
    });
  }

  Future<void> _refresh() async {
    await ref.read(itineraryNotifierProvider.notifier).loadItinerary(widget.tripId);
    await ref.read(tripDetailNotifierProvider.notifier).loadTrip(widget.tripId);
  }

  void _showShareSheet() {
    final trip = ref.read(tripDetailNotifierProvider);
    final shareCode = trip?.shareCode ?? 'NO-CODE';
    final hasShareCode = shareCode.isNotEmpty && shareCode != 'NO-CODE';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasShareCode ? const Color(0xFF5b4eff).withValues(alpha: 0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.share,
                size: 48,
                color: hasShareCode ? const Color(0xFF5b4eff) : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bagikan Kode Trip',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasShareCode
                  ? 'Bagikan kode ini untuk mengundang teman'
                  : 'Share code akan di-generate saat trip dibuat',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (hasShareCode) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF5b4eff).withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5b4eff).withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      shareCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        letterSpacing: 6,
                        color: Color(0xFF5b4eff),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Color(0xFF5b4eff)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: shareCode));
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Kode berhasil disalin!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      tooltip: 'Salin Kode',
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Kode belum tersedia',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5b4eff),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showMembersSheet() {
    final trip = ref.watch(tripDetailNotifierProvider);
    final members = trip?.members ?? [];
    final owner = trip?.owner;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5b4eff).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.group, color: Color(0xFF5b4eff)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Member Trip',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5b4eff),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${members.length + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Owner
                    if (owner != null) ...[
                      _buildMemberTile(
                        name: owner.name ?? 'Owner',
                        role: 'owner',
                        isOwner: true,
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Members
                    ...members.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildMemberTile(
                        name: m.name ?? 'Unknown',
                        email: m.email,
                        role: m.role ?? 'member',
                        avatar: m.avatar,
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5b4eff),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTile({
    required String name,
    String? email,
    required String role,
    String? avatar,
    bool isOwner = false,
  }) {
    final isOwnerRole = role == 'owner';
    final color = isOwnerRole ? const Color(0xFF5b4eff) : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (email != null && email.isNotEmpty)
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isOwnerRole ? const Color(0xFF5b4eff).withValues(alpha: 0.1) : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOwnerRole ? 'Owner' : role.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isOwnerRole ? const Color(0xFF5b4eff) : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
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
        appBar: AppBar(title: Text(widget.tripTitle ?? 'Itinerary')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Calculate statistics
    double totalEstimated = 0;
    double totalActual = 0;

    for (final day in data.days) {
      for (final a in day.activities) {
        if (a.isCompleted) {
          totalEstimated += (a.estimatedCost ?? 0).toDouble();
          totalActual += (a.actualCost ?? 0).toDouble();
        } else {
          totalEstimated += (a.estimatedCost ?? 0).toDouble();
        }
      }
    }

    final planBudget = (widget.planBudget ?? 0).toDouble();
    final remainingFromPlan = planBudget - totalActual;
    final percentageUsed = planBudget > 0 ? (totalActual / planBudget * 100).clamp(0.0, 100.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tripTitle ?? 'Itinerary'),
        actions: [
          // Share Icon
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareSheet,
            tooltip: 'Bagikan Trip',
          ),
          // Members Icon
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: _showMembersSheet,
            tooltip: 'Members',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            // Quick Action Icons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Dashboard Button (Purple)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF5b4eff),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5b4eff).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.push('/trips/${widget.tripId}/dashboard?budget=${widget.planBudget ?? 0}'),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.pie_chart, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Lightning/Sudden Expense Button (Orange)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFf59e0b),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFf59e0b).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _showSuddenExpenseSheet,
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.flash_on, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Budget Summary Card (Purple Gradient)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7c3aed), Color(0xFF5b4eff)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5b4eff).withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_wallet, color: Color(0xFFfcd34d), size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Ringkasan Budget',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Budget Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBudgetLabel('Plan Budget'),
                      Text(
                        'Rp ${_formatCurrency(planBudget)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBudgetLabel('Estimasi'),
                      Text(
                        'Rp ${_formatCurrency(totalEstimated)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Realita',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp ${_formatCurrency(totalActual)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (percentageUsed / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(
                        remainingFromPlan >= 0 ? const Color(0xFF4ade80) : Colors.red.shade300,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Remaining Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${percentageUsed.toStringAsFixed(0)}% terpakai',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: remainingFromPlan >= 0 ? const Color(0xFF4ade80) : Colors.red.shade300,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (remainingFromPlan >= 0 ? const Color(0xFF4ade80) : Colors.red.shade300).withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          remainingFromPlan >= 0
                              ? 'Sisa: Rp ${_formatCurrency(remainingFromPlan)}'
                              : 'Lebih: Rp ${_formatCurrency(remainingFromPlan.abs())}',
                          style: TextStyle(
                            color: remainingFromPlan >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Days List
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
                        textAlign: TextAlign.center,
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
        backgroundColor: const Color(0xFF5b4eff),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBudgetLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 14),
    );
  }

  void _showQuickActionMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tambah',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF5b4eff).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_today, color: Color(0xFF5b4eff)),
              ),
              title: const Text('Tambah Hari'),
              subtitle: const Text('Tambahkan hari perjalanan baru'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddDayDialog();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFf59e0b).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flash_on, color: Color(0xFFf59e0b)),
              ),
              title: const Text('Pengeluaran Mendadak'),
              subtitle: const Text('Catat pengeluaran di luar rencana'),
              onTap: () {
                Navigator.pop(ctx);
                _showSuddenExpenseSheet();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(TripDayModel day) {
    double dayActual = 0;
    int completedInDay = 0;
    int totalInDay = day.activities.length;

    for (final a in day.activities) {
      if (a.isCompleted) {
        completedInDay++;
        dayActual += (a.actualCost ?? 0).toDouble();
      }
    }

    final isDayCompleted = completedInDay == totalInDay && totalInDay > 0;
    final dateFormatted = _formatDate(day.date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day Header
          InkWell(
            onTap: () {
              // Toggle expansion if needed
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: Row(
                children: [
                  // Day Circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDayCompleted
                          ? const Color(0xFF4ade80)
                          : const Color(0xFF5b4eff),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isDayCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : Text(
                              '${day.dayNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Day Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hari ${day.dayNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          dateFormatted,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDayCompleted
                              ? const Color(0xFF4ade80).withValues(alpha: 0.1)
                              : const Color(0xFF5b4eff).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$completedInDay/$totalInDay Selesai',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDayCompleted
                                ? const Color(0xFF16a34a)
                                : const Color(0xFF5b4eff),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${_formatCurrency(dayActual)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Activities List
          if (day.activities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Belum ada kegiatan di hari ini',
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
          else
            ...day.activities.map((a) => _buildActivityItem(a)),

          // Add Activity Button
          InkWell(
            onTap: () => _navigateToAddActivity(day.id),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 18, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Tambah Kegiatan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityModel a) {
    Color statusColor;
    IconData statusIcon;
    String nominal;

    if (a.isCompleted) {
      statusColor = const Color(0xFF4ade80);
      statusIcon = Icons.check_circle;
      nominal = 'Rp ${_formatCurrency((a.actualCost ?? 0).toDouble())}';
    } else if (a.isSkipped) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      nominal = 'Dibatalkan';
    } else {
      statusColor = Colors.grey[400]!;
      statusIcon = Icons.circle_outlined;
      nominal = 'Rp ${_formatCurrency((a.estimatedCost ?? 0).toDouble())}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          // Status Icon
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          // Activity Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title ?? 'Tanpa judul',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: a.isSkipped ? Colors.grey : const Color(0xFF1F2937),
                    decoration: a.isSkipped ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  a.category ?? 'Tanpa kategori',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Nominal
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                nominal,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: a.isSkipped ? Colors.grey : const Color(0xFF1F2937),
                ),
              ),
              if (a.isPending) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: Icons.check,
                      color: const Color(0xFF4ade80),
                      onTap: () => _showCompleteSheet(a.id),
                    ),
                    const SizedBox(width: 4),
                    _buildActionButton(
                      icon: Icons.close,
                      color: Colors.red,
                      onTap: () => _skipActivity(a.id),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Tanggal tidak tersedia';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 0);
    return formatter.format(amount).replaceAll(',', '.');
  }
}
