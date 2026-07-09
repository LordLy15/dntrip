# Design Spec: Dashboard Trip dengan Progress & Pie Chart

**Date:** 2026-07-09  
**Status:** Approved  
**Author:** Claude Opus 4.8

---

## 1. Overview

Menambahkan fitur dashboard trip yang komprehensif dengan:
- **Progress tracking** saat checkbox dicentang (animasi + snackbar)
- **Pie Chart** untuk breakdown pengeluaran per kategori
- **Ringkasan Budget** otomatis (Plan vs Estimasi vs Realita)
- **Navigation** via icon di AppBar

---

## 2. Screens & Navigation

### Navigation Structure
```
ItineraryScreen (AppBar)
├── [←] Back Button
├── "Itinerary" (title)
├── [📊 Chart Icon] → ItineraryDashboardScreen
└── [⚡ Flash Icon] → SuddenExpenseSheet
```

### Screens
1. **ItineraryScreen** - Halaman utama itinerary (existing)
2. **ItineraryDashboardScreen** - Dashboard dengan Pie Chart dan ringkasan

---

## 3. Functionality Specification

### 3.1 Progress Animation saat Checkbox

**Trigger:** User mencentang checkbox aktivitas (via `ActivityCompleteSheet`)

**Behavior:**
1. Tampilkan animasi checkmark di card aktivitas
2. Update progress bar di card dengan animasi
3. Tampilkan Snackbar dengan statistik:
   - "✓ [Nama Aktivitas] selesai"
   - "Progress: X/Y kegiatan (Z%)"
   - Plan Budget vs Realita

**Implementation:**
- `ActivityCompleteSheet` → tambahkan animasi `AnimatedCheckmark`
- `ItineraryScreen` → update state dan tampilkan snackbar

### 3.2 Dashboard dengan Pie Chart

**Route:** `/trips/:id/dashboard?budget={planBudget}`

**Components:**

#### A. Budget Summary Card
```
┌─────────────────────────────────────┐
│ 💰 Ringkasan Budget                 │
│─────────────────────────────────────│
│ Plan Budget:    Rp 5.000.000       │
│ Estimasi:       Rp 4.500.000       │
│ Realita:        Rp 2.750.000       │
│                                     │
│ [████████████░░░░░░] 55% terpakai  │
│ [Sisa: Rp 2.250.000]               │
└─────────────────────────────────────┘
```

#### B. Pie Chart Card
```
┌─────────────────────────────────────┐
│ 📊 Pengeluaran per Kategori         │
│─────────────────────────────────────│
│                                     │
│      [PIE CHART]     Konsumsi 35%  │
│       Rp 2.7jt      Transport 25%   │
│                      Hotel 25%      │
│                      Atraksi 15%    │
│                                     │
└─────────────────────────────────────┘
```

#### C. Progress Activities Card
```
┌─────────────────────────────────────┐
│ 📋 Progress Kegiatan                │
│─────────────────────────────────────│
│        [CIRCULAR]                   │
│         62%        ✓ Selesai: 5    │
│         5/8        ⏳ Pending: 2    │
│                     ✕ Batal: 1      │
└─────────────────────────────────────┘
```

### 3.3 Data Calculation

```dart
// Total calculations
totalEstimated = Σ(activities.map((a) => a.estimatedCost))
totalActual = Σ(activities.where((a) => a.isCompleted).map((a) => a.actualCost))
totalSudden = Σ(suddenExpenses.map((e) => e.amount))

// Category breakdown
categorySpending = Σ(expenses groupBy category)

// Progress
completedCount = activities.where((a) => a.isCompleted).length
pendingCount = activities.where((a) => a.isPending).length
skippedCount = activities.where((a) => a.isSkipped).length
```

### 3.4 Auto-Update Behavior

- **Trigger:** Setiap aktivitas di-`complete` atau di-`skip`
- **Action:** Refresh dashboard dan itinerary state
- **Manual:** Pull-to-refresh tersedia

---

## 4. UI/UX Specification

### 4.1 Color Palette

| Element | Color | Hex |
|---------|-------|-----|
| Primary | Indigo | #4f46e5 |
| Secondary | Purple | #7c3aed |
| Success | Green (dark) | #15803d |
| Warning | Amber | #f59e0b |
| Error | Red | #ef4444 |
| Text Primary | Dark Gray | #1f2937 |
| Text Secondary | Gray | #374151 |
| Background | White | #ffffff |
| Card Border | Light Gray | #e5e7eb |

### 4.2 Typography

| Element | Size | Weight |
|---------|------|--------|
| Card Title | 18px | 700 (Bold) |
| Section Header | 16px | 700 (Bold) |
| Body Text | 14px | 500-600 |
| Caption | 12-13px | 400-500 |
| Currency Large | 20px | 700 |
| Percentage | 22-32px | 700 |

### 4.3 Spacing

- Card padding: 20px
- Card margin: 16px horizontal, 0 vertical
- Card border-radius: 16px
- Section gap: 16px
- Element gap: 8-12px

### 4.4 Icons

| Icon | Usage |
|------|-------|
| 💰 | Budget Summary |
| 📊 | Pie Chart / Dashboard |
| ⚡ | Sudden Expense |
| 📋 | Progress Activities |
| ✓ | Completed |
| ⏳ | Pending |
| ✕ | Cancelled/Batal |

---

## 5. Technical Implementation

### 5.1 Dependencies

```yaml
# pubspec.yaml
dependencies:
  fl_chart: ^0.69.0  # For pie chart
```

### 5.2 Files to Modify

1. **ActivityCompleteSheet** (`itinerary/presentation/screens/`)
   - Tambahkan animasi checkmark
   - Tambahkan callback untuk snackbar

2. **ItineraryScreen** (`itinerary/presentation/screens/`)
   - Update snackbar dengan statistik lengkap
   - Pastikan auto-refresh

3. **ItineraryDashboardScreen** (`itinerary/presentation/screens/`)
   - Enhance dengan Pie Chart (fl_chart)
   - Perbaiki UI dengan kontras yang baik

### 5.3 Pie Chart Implementation

```dart
// Using fl_chart
PieChart(
  PieChartData(
    sections: categorySpending.entries.map((e) => 
      PieChartSectionData(
        value: e.value,
        color: _getCategoryColor(e.key),
        title: '${((e.value/total)*100).toStringAsFixed(0)}%',
        radius: 60,
      )
    ).toList(),
    centerSpaceRadius: 40,
  ),
)
```

---

## 6. Snackbar Design

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✓ ${activity.title} selesai'),
              Text(
                'Progress: $completedCount/$totalCount ($progress%)',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Realita: Rp ${formatCurrency(totalActual)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
    backgroundColor: Colors.green.shade600,
    duration: const Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
  ),
);
```

---

## 7. State Management

```dart
// ItineraryProviders
final itineraryNotifierProvider = StateNotifierProvider<ItineraryNotifier, ItineraryData?>(
  (ref) => ItineraryNotifier(ref.read(itineraryRepositoryProvider)),
);

// Methods needed:
- loadItinerary(int tripId)
- completeActivity(int activityId, int actualCost)
- skipActivity(int activityId)
```

---

## 8. Mockup Reference

Visual mockup tersedia di:
- `dashboard-mockup-v2.html` (final approved version)

---

## 9. Acceptance Criteria

- [ ] Checkbox centang menampilkan animasi checkmark
- [ ] Snackbar tampil dengan statistik progress
- [ ] Dashboard accessible (kontras teks baik)
- [ ] Pie Chart menampilkan breakdown kategori
- [ ] Ringkasan Budget akurat (Plan vs Estimasi vs Realita)
- [ ] Navigation ke dashboard via icon AppBar
- [ ] Pull-to-refresh berfungsi
- [ ] Auto-update saat aktivitas selesai/dibatalkan

---

## 10. Related Files

- `itinerary_dashboard_screen.dart` - Dashboard screen (existing)
- `itinerary_screen.dart` - Main itinerary screen
- `activity_complete_sheet.dart` - Complete activity modal
- `sudden_expense_sheet.dart` - Sudden expense modal
- `trip_providers.dart` - Trip state management
- `itinerary_providers.dart` - Itinerary state management
