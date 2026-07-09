# Dashboard Trip Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menambahkan dashboard trip dengan Pie Chart, progress animation saat checkbox, dan ringkasan budget otomatis.

**Architecture:** Menggunakan fl_chart untuk Pie Chart, Riverpod untuk state management, dan widget-based animation untuk progress indicators. Dashboard terpisah di route `/trips/:id/dashboard` dengan navigation via icon di AppBar ItineraryScreen.

**Tech Stack:** Flutter, fl_chart ^0.69.0, Riverpod, GoRouter

## Global Constraints

- Flutter SDK dengan Riverpod state management
- Package fl_chart untuk visualisasi data
- Kontras warna sesuai spec: Text Primary #1f2937, Success #15803d
- Format currency Indonesia (Rp dengan separator titik)

---

## File Structure

### Files to Create
- None required

### Files to Modify
- `frontend/lib/features/itinerary/presentation/screens/activity_complete_sheet.dart` - Tambah animasi dan callback
- `frontend/lib/features/itinerary/presentation/screens/itinerary_screen.dart` - Update snackbar dengan statistik lengkap
- `frontend/lib/features/itinerary/presentation/screens/itinerary_dashboard_screen.dart` - Enhance dengan Pie Chart

### Files to Check (for patterns)
- `frontend/lib/features/itinerary/presentation/widgets/budget_summary_card.dart` - Existing patterns
- `frontend/lib/features/itinerary/data/itinerary_repository.dart` - Data fetching patterns

---

## Task 1: Update ActivityCompleteSheet dengan Animasi

**Files:**
- Modify: `frontend/lib/features/itinerary/presentation/screens/activity_complete_sheet.dart`

**Interfaces:**
- Consumes: `ActivityModel activity`
- Produces: `VoidCallback onComplete` dengan animasi sebelum dismiss

- [ ] **Step 1: Read current ActivityCompleteSheet implementation**

Buka file dan periksa struktur widget saat ini.

- [ ] **Step 2: Tambahkan AnimatedCheckmark widget**

```dart
class AnimatedCheckmark extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const AnimatedCheckmark({super.key, required this.onAnimationComplete});

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onAnimationComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade500,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 3: Modify build method untuk show animation overlay**

```dart
@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      // Existing content
      Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ... existing fields
          ],
        ),
      ),
      // Animated overlay when saving
      if (_isSaving)
        Positioned.fill(
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedCheckmark(
                    onAnimationComplete: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Menyimpan...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}
```

- [ ] **Step 4: Add _isSaving state variable**

```dart
class _ActivityCompleteSheetState extends State<ActivityCompleteSheet> {
  late final TextEditingController _costController;
  bool _isSaving = false;
  // ... rest of the code
}
```

- [ ] **Step 5: Modify save button to trigger animation**

```dart
ElevatedButton(
  onPressed: _isSaving
    ? null
    : () {
        setState(() => _isSaving = true);
        final cost = int.tryParse(_costController.text) ?? 0;
        widget.onComplete(cost);
        // Animation will call Navigator.pop when complete
      },
  child: _isSaving
    ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
    : const Text('Simpan'),
),
```

- [ ] **Step 6: Commit**

```bash
git add frontend/lib/features/itinerary/presentation/screens/activity_complete_sheet.dart
git commit -m "feat: Add animated checkmark to activity complete sheet"
```

---

## Task 2: Update ItineraryScreen dengan Enhanced Snackbar

**Files:**
- Modify: `frontend/lib/features/itinerary/presentation/screens/itinerary_screen.dart`

**Interfaces:**
- Consumes: `ItineraryData data`, `SuddenExpenseModel expenses`
- Produces: Enhanced snackbar dengan statistik lengkap

- [ ] **Step 1: Read current ItineraryScreen implementation**

Periksa bagian `_showCompleteSheet` dan snackbar yang ada.

- [ ] **Step 2: Add helper method _showProgressSnackbar**

```dart
void _showProgressSnackbar({
  required String activityTitle,
  required int completedCount,
  required int totalCount,
  required double totalActual,
  required double planBudget,
}) {
  final progressPercent = totalCount > 0
      ? ((completedCount / totalCount) * 100).toStringAsFixed(0)
      : '0';

  final remaining = planBudget - totalActual;
  final formatter = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✓ $activityTitle selesai',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Progress: $completedCount/$totalCount kegiatan ($progressPercent%)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
                if (planBudget > 0)
                  Text(
                    'Realita: ${formatter.format(totalActual)} • Sisa: ${formatter.format(remaining)}',
                    style: TextStyle(
                      color: remaining >= 0
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green.shade600,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ),
  );
}
```

- [ ] **Step 3: Update _showCompleteSheet to calculate and pass stats**

```dart
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

  // Calculate current stats before completion
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

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => ActivityCompleteSheet(
      activity: activity!,
      onComplete: (cost) {
        // Update state
        ref.read(itineraryNotifierProvider.notifier).completeActivity(
          activityId: activityId,
          actualCost: cost,
        );

        // Show enhanced snackbar
        final newTotalActual = totalActual + cost;
        final newCompletedCount = completedCount + 1;
        _showProgressSnackbar(
          activityTitle: activity!.title ?? 'Aktivitas',
          completedCount: newCompletedCount,
          totalCount: totalCount,
          totalActual: newTotalActual,
          planBudget: (widget.planBudget ?? 0).toDouble(),
        );
      },
    ),
  );
}
```

- [ ] **Step 4: Update _skipActivity to show snackbar**

```dart
Future<void> _skipActivity(int activityId) async {
  // ... existing confirmation dialog code ...

  if (confirmed == true) {
    final data = ref.read(itineraryNotifierProvider);
    double totalActual = 0;
    int completedCount = 0;
    int skippedCount = 0;
    int totalCount = 0;
    for (final day in data?.days ?? []) {
      for (final a in day.activities) {
        totalCount++;
        if (a.isCompleted) {
          completedCount++;
          totalActual += (a.actualCost ?? 0).toDouble();
        } else if (a.isSkipped) {
          skippedCount++;
        }
      }
    }

    await ref.read(itineraryNotifierProvider.notifier).skipActivity(activityId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.cancel, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('✓ Aktivitas dibatalkan • $completedCount/$totalCount selesai'),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/features/itinerary/presentation/screens/itinerary_screen.dart
git commit -m "feat: Add enhanced progress snackbar to itinerary screen"
```

---

## Task 3: Enhance ItineraryDashboardScreen dengan Pie Chart

**Files:**
- Modify: `frontend/lib/features/itinerary/presentation/screens/itinerary_dashboard_screen.dart`
- Check: `pubspec.yaml` for fl_chart dependency

**Interfaces:**
- Consumes: `ItineraryData`, `SuddenExpenseModel list`
- Produces: PieChart widget dengan category breakdown

- [ ] **Step 1: Check pubspec.yaml for fl_chart**

```bash
grep -n "fl_chart" frontend/pubspec.yaml
```

If not found, add:
```yaml
dependencies:
  fl_chart: ^0.69.0
```

- [ ] **Step 2: Read current ItineraryDashboardScreen**

Periksa struktur widget yang ada.

- [ ] **Step 3: Add fl_chart import**

```dart
import 'package:fl_chart/fl_chart.dart';
```

- [ ] **Step 4: Add PieChart widget method**

```dart
Widget _buildPieChartCard(BuildContext context, Map<String, double> categorySpending) {
  final total = categorySpending.values.fold(0.0, (a, b) => a + b);
  if (total == 0) return const SizedBox.shrink();

  final sortedEntries = categorySpending.entries.toList()
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
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('📊', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            const Text(
              'Pengeluaran per Kategori',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            // Pie Chart
            SizedBox(
              width: 130,
              height: 130,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 35,
                  sections: sortedEntries.map((entry) {
                    final percent = (entry.value / total) * 100;
                    return PieChartSectionData(
                      value: entry.value,
                      color: _getCategoryColor(entry.key),
                      radius: 25,
                      title: percent >= 10 ? '${percent.toStringAsFixed(0)}%' : '',
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Legend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sortedEntries.take(5).map((entry) {
                  final percent = (entry.value / total) * 100;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(entry.key),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getCategoryName(entry.key),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        Text(
                          '${percent.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
```

- [ ] **Step 5: Update build method to include PieChart card**

```dart
// In build method, replace the _buildCategoryBreakdown section with:
if (categorySpending.isNotEmpty) ...[
  const SizedBox(height: 16),
  _buildPieChartCard(context, categorySpending),
],
```

- [ ] **Step 6: Update _getCategoryName and _getCategoryColor for better contrast**

```dart
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
    'accommodation': Color(0xFF3B82F6), // Blue
    'transportation': Color(0xFFF59E0B), // Amber
    'food_and_beverage': Color(0xFF22C55E), // Green
    'food': Color(0xFF22C55E), // Green
    'attractions': Color(0xFF8B5CF6), // Purple
    'itinerary': Color(0xFF14B8A6), // Teal
    'communication': Color(0xFF6366F1), // Indigo
    'others': Color(0xFF6B7280), // Gray
  };
  return colors[slug] ?? const Color(0xFF6B7280);
}
```

- [ ] **Step 7: Commit**

```bash
git add frontend/lib/features/itinerary/presentation/screens/itinerary_dashboard_screen.dart
git add frontend/pubspec.yaml
flutter pub get
git commit -m "feat: Add Pie Chart to itinerary dashboard with fl_chart"
```

---

## Task 4: Add Navigation Icon to ItineraryScreen AppBar

**Files:**
- Modify: `frontend/lib/features/itinerary/presentation/screens/itinerary_screen.dart`

**Interfaces:**
- Consumes: `tripId`, `planBudget`
- Produces: Navigation ke `/trips/:id/dashboard`

- [ ] **Step 1: Read current AppBar section**

Periksa bagian AppBar di ItineraryScreen.

- [ ] **Step 2: Update AppBar with dashboard icon**

```dart
appBar: AppBar(
  title: const Text('Itinerary'),
  actions: [
    // Dashboard icon
    IconButton(
      icon: const Icon(Icons.pie_chart),
      onPressed: () => context.push(
        '/trips/${widget.tripId}/dashboard?budget=${widget.planBudget ?? 0}',
      ),
      tooltip: 'Dashboard',
      color: Theme.of(context).colorScheme.primary,
    ),
    // Sudden expense icon
    IconButton(
      icon: const Icon(Icons.flash_on),
      onPressed: _showSuddenExpenseSheet,
      tooltip: 'Pengeluaran Mendadak',
      color: Colors.orange,
    ),
  ],
),
```

- [ ] **Step 3: Commit**

```bash
git add frontend/lib/features/itinerary/presentation/screens/itinerary_screen.dart
git commit -m "feat: Add dashboard navigation icon to itinerary screen"
```

---

## Task 5: Final Testing and Verification

**Files:**
- Test: Manual testing on device/emulator

- [ ] **Step 1: Run flutter analyze**

```bash
cd frontend
flutter analyze
```

Expected: No errors

- [ ] **Step 2: Test complete activity flow**

1. Buka itinerary screen
2. Klik checkbox pada aktivitas
3. Lihat animasi checkmark
4. Lihat snackbar dengan statistik
5. Verifikasi progress bar terupdate

- [ ] **Step 3: Test dashboard navigation**

1. Klik icon 📊 di AppBar
2. Verifikasi Pie Chart muncul
3. Verifikasi ringkasan budget akurat

- [ ] **Step 4: Test pull-to-refresh**

1. Pull down pada dashboard
2. Verifikasi data refresh

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat: Complete dashboard trip implementation with Pie Chart

- Add animated checkmark on activity completion
- Enhanced progress snackbar with statistics
- Pie Chart breakdown by category
- Dashboard navigation from itinerary"
```

---

## Acceptance Criteria Checklist

- [ ] Checkbox centang menampilkan animasi checkmark
- [ ] Snackbar tampil dengan statistik progress (completed/total, realita, sisa budget)
- [ ] Dashboard accessible (kontras teks baik sesuai mockup v2)
- [ ] Pie Chart menampilkan breakdown kategori dengan warna yang membedakan
- [ ] Ringkasan Budget akurat (Plan vs Estimasi vs Realita)
- [ ] Navigation ke dashboard via icon 📊 di AppBar
- [ ] Pull-to-refresh berfungsi
- [ ] Auto-update saat aktivitas selesai/dibatalkan
