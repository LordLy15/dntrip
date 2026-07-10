import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/trip_day_model.dart';
import '../../domain/itinerary_providers.dart';

class ItineraryDashboardScreen extends ConsumerStatefulWidget {
  final int tripId;
  final double planBudget;

  const ItineraryDashboardScreen({
    super.key,
    required this.tripId,
    required this.planBudget,
  });

  @override
  ConsumerState<ItineraryDashboardScreen> createState() => _ItineraryDashboardScreenState();
}

class _ItineraryDashboardScreenState extends ConsumerState<ItineraryDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(itineraryNotifierProvider.notifier).loadItinerary(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(itineraryNotifierProvider);
    final suddenExpenses = ref.watch(suddenExpensesProvider(widget.tripId));

    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard Trip')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Calculate statistics
    double totalEstimated = 0;
    double totalActual = 0;
    double totalSudden = 0;
    int completedCount = 0;
    int skippedCount = 0;
    int pendingCount = 0;
    int totalCount = 0;
    Map<String, double> categorySpending = {};

    for (final day in data.days) {
      for (final a in day.activities) {
        totalCount++;
        final cost = (a.estimatedCost ?? 0).toDouble();
        if (a.isCompleted) {
          completedCount++;
          totalActual += (a.actualCost ?? cost);
          totalEstimated += cost;
          categorySpending[a.category ?? 'others'] =
              (categorySpending[a.category ?? 'others'] ?? 0) + (a.actualCost ?? cost);
        } else if (a.isSkipped) {
          skippedCount++;
          totalEstimated += cost;
        } else {
          pendingCount++;
          totalEstimated += cost;
        }
      }
    }

    suddenExpenses.whenData((expenses) {
      for (final e in expenses) {
        totalSudden += e.amount;
        categorySpending[e.categoryName ?? 'others'] =
            (categorySpending[e.categoryName ?? 'others'] ?? 0) + e.amount;
      }
    });

    final planBudget = widget.planBudget;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Trip'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(itineraryNotifierProvider.notifier).loadItinerary(widget.tripId);
          ref.invalidate(suddenExpensesProvider(widget.tripId));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Main Budget Card
            _buildBudgetCard(
              context,
              planBudget: planBudget,
              actualSpent: totalActual + totalSudden,
              estimated: totalEstimated,
            ),
            const SizedBox(height: 20),

            // Progress Section
            _buildProgressSection(
              context,
              completedCount: completedCount,
              pendingCount: pendingCount,
              skippedCount: skippedCount,
              totalCount: totalCount,
            ),
            const SizedBox(height: 20),

            // Category Breakdown
            if (categorySpending.isNotEmpty) ...[
              _buildPieChartCard(context, categorySpending),
              const SizedBox(height: 20),
              _buildCategoryBreakdown(context, categorySpending),
              const SizedBox(height: 20),
            ],

            // Day-by-day Progress
            _buildDayProgress(context, data.days),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context, {
    required double planBudget,
    required double actualSpent,
    required double estimated,
  }) {
    final remaining = planBudget - actualSpent;
    final percentUsed = planBudget > 0 ? (actualSpent / planBudget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = actualSpent > planBudget;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverBudget
              ? [Colors.red.shade400, Colors.red.shade600]
              : [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOverBudget ? Colors.red : Theme.of(context).colorScheme.primary).withValues(alpha: 0.3),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Ringkasan Budget',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Plan Budget
          _buildBudgetRow('Plan Budget', planBudget, Colors.white70),
          const SizedBox(height: 8),

          // Actual Spent
          _buildBudgetRow('Realita', actualSpent, Colors.white),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentUsed,
              backgroundColor: Colors.white30,
              valueColor: AlwaysStoppedAnimation(
                isOverBudget ? Colors.red.shade200 : Colors.green.shade200,
              ),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),

          // Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(percentUsed * 100).toStringAsFixed(1)}% terpakai',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: remaining >= 0 ? Colors.green.shade200 : Colors.red.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  remaining >= 0
                      ? 'Sisa: ${_formatCurrency(remaining)}'
                      : 'Lebih: ${_formatCurrency(remaining.abs())}',
                  style: TextStyle(
                    color: remaining >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 14)),
        Text(
          'Rp ${_formatCurrency(amount)}',
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProgressSection(
    BuildContext context, {
    required int completedCount,
    required int pendingCount,
    required int skippedCount,
    required int totalCount,
  }) {
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Progress Kegiatan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Circular Progress
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        completedCount == totalCount && totalCount > 0
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completedCount/$totalCount',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                'Selesai',
                completedCount,
                Colors.green,
                Icons.check_circle,
              ),
              _buildLegendItem(
                'Pending',
                pendingCount,
                Colors.orange,
                Icons.schedule,
              ),
              _buildLegendItem(
                'Batal',
                skippedCount,
                Colors.red,
                Icons.cancel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, Map<String, double> spending) {
    final sortedEntries = spending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pie_chart_outline, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pengeluaran per Kategori',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortedEntries.take(5).map((entry) => _buildCategoryBar(
                context,
                category: _getCategoryName(entry.key),
                amount: entry.value,
                color: _getCategoryColor(entry.key),
                maxAmount: sortedEntries.first.value,
              )),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(BuildContext context, Map<String, double> spending) {
    final totalAmount = spending.values.fold(0.0, (sum, value) => sum + value);
    final sortedEntries = spending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = <PieChartSectionData>[];
    final legends = <Widget>[];

    for (final entry in sortedEntries) {
      final percentage = totalAmount > 0 ? (entry.value / totalAmount * 100) : 0.0;
      final color = _getCategoryColor(entry.key);

      sections.add(PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));

      legends.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getCategoryName(entry.key),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            Text(
              'Rp ${_formatCurrency(entry.value)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.donut_large, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Grafik Pengeluaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...legends,
        ],
      ),
    );
  }

  Widget _buildCategoryBar(
    BuildContext context, {
    required String category,
    required double amount,
    required Color color,
    required double maxAmount,
  }) {
    final percent = maxAmount > 0 ? amount / maxAmount : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(category),
                ],
              ),
              Text(
                'Rp ${_formatCurrency(amount)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayProgress(BuildContext context, List<TripDayModel> days) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_month, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              const Text(
                'Progress per Hari',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...days.take(7).map((day) {
            int completed = 0;
            int total = day.activities.length;
            for (final a in day.activities) {
              if (a.isCompleted) completed++;
            }
            final percent = total > 0 ? completed / total : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      'Hari ${day.dayNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          completed == total && total > 0
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '$completed/$total',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getCategoryName(String slug) {
    const names = {
      'accommodation': 'Akomodasi',
      'transportation': 'Transportasi',
      'food_and_beverage': 'Konsumsi',
      'food': 'Konsumsi',
      'attractions': 'Atraksi',
      'itinerary': 'Itinerary',
      'communication': 'Komunikasi',
      'others': 'Lainnya',
    };
    return names[slug] ?? slug;
  }

  Color _getCategoryColor(String slug) {
    const colors = {
      'accommodation': Color(0xFF3B82F6),      // Blue
      'transportation': Color(0xFFF59E0B),      // Amber
      'food_and_beverage': Color(0xFF22C55E),  // Green
      'food': Color(0xFF22C55E),               // Green
      'attractions': Color(0xFF8B5CF6),        // Purple
      'itinerary': Color(0xFF14B8A6),           // Teal
      'communication': Color(0xFF6366F1),       // Indigo
      'others': Color(0xFF6B7280),             // Gray
    };
    return colors[slug] ?? const Color(0xFF6B7280);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 0);
    return formatter.format(amount).replaceAll(',', '.');
  }
}
