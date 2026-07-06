# Spec: Sudden Expenses & Budget Tracking dengan On Time/Late Status

## 1. Tujuan
Implementasi fitur:
- **Sudden Expenses** (Pengeluaran Mendadak)
- **Budget Status** dengan 5 kondisi (Underbudget, On Budget, Budget Surplus, Budget Defisit, Off-Budget)
- **On Time / Late Status** untuk aktivitas
- **Custom Expense Categories**

---

## 2. Detail Fitur

### 2.1 Sudden Expenses (Pengeluaran Mendadak)

#### UI Components
- **FAB Button** di halaman Trip Detail: `+` atau ikon `bolt` (lightning)
- **Bottom Sheet** saat FAB ditekan berisi form:
  - `Nama Pengeluaran` - TextField (required)
  - `Kategori` - Dropdown dari ExpenseCategory + "Tambah Kategori Baru"
  - `Nominal` - NumberField dengan format currency (required)
  - `Keterangan` - TextField multiline (optional)
- **Save Button** dan **Cancel Button**

#### Behavior
- Saat disimpan, langsung menambah `totalRealitaBudget` trip
- Otomatis ter-label **Off-Budget**
- Jika Total > Plan Budget → muncul warning dialog

#### Backend API
```
POST /api/trips/{trip_id}/sudden-expenses
{
  "name": "string",
  "category_id": "int|null",
  "custom_category_name": "string|null",
  "amount": "decimal",
  "description": "string|null"
}
```

---

### 2.2 Budget Status - 5 Kondisi

#### Logika Threshold (Margin 5%)
| Status | Condition | Warna | Label di UI |
|--------|-----------|-------|------------|
| **On Budget** | 0.95P ≤ T ≤ 1.05P | `#4CAF50` (Green) | "On Budget" |
| **Underbudget** | T < 0.95P | `#2196F3` (Blue) | "Underbudget" |
| **Budget Defisit** | T > 1.05P | `#FF9800` (Orange) | "Budget Defisit" |
| **Budget Surplus** | T < P (aktif) / Selesai | `#2E7D32` (Dark Green) | "Sisa Anggaran" (aktif) → "Budget Surplus" (selesai) |
| **Off-Budget** | Dari sudden_expenses | `#9E9E9E` (Grey) | "Off-Budget" |

#### Keterangan Variabel
- **P** = Plan Budget (anggaran rencana)
- **T** = Total Pengeluaran Aktual (Realita Budget + Sudden Expenses)

#### UI Components
- **Budget Summary Card** di Trip Detail:
  - Plan Budget (dengan label "Rencana")
  - Realita Budget (dengan label "Realita")
  - Sisa/Potensi Surplus atau Defisit (dengan nominal)
  - Badge Status Budget (warna sesuai kondisi)
- **Progress Indicator** - Visual bar dari Plan Budget

---

### 2.3 On Time / Late Status

#### Badge Display
| Status | Chip Style | Contoh Text |
|--------|------------|-------------|
| **On Time** | Green background (#E8F5E9), Green text (#2E7D32) | "On Time" |
| **Late** | Red/Orange background (#FFEBEE), Red text (#C62828) | "Terlambat 15 mnt" |
| **Not Started** | Grey background, Grey text | "-" |
| **Skipped** | Grey background, Grey text | "Dilompati" |

#### Timeline UI
- Vertical timeline dengan node circles
- Line color berdasarkan status:
  - Green line = On Time
  - Red/Yellow line = Late (affects next activities)
- Node fill based on completion status

#### Dashboard Summary
- Ringkasan di header Trip Detail:
  - Text: "Performa Waktu: X/Y Aktivitas On Time"
  - Mini progress bar

#### Activity Actions
- **Start Button** → Record `actual_start_time`, compare with `planned_start_time`
- **Complete Button** → Record `actual_end_time`, compare with `planned_end_time`
- After completion: Badge status + Checkmark icon

---

### 2.4 Custom Expense Categories

#### Default Categories (7)
1. **Akomodasi** - `hotel` icon
2. **Transportasi** - `directions_car` icon
3. **Konsumsi** - `restaurant` icon
4. **Atraksi & Hiburan** - `attractions` icon
5. **Itinerary** - `schedule` icon
6. **Komunikasi & Dokumen** - `phone` icon
7. **Lainnya** - `more_horiz` icon

#### Custom Category Flow
- Dropdown dengan opsi "Tambah Kategori Baru..."
- Jika dipilih → TextField untuk nama kategori baru
- Kategori baru disimpan dengan `isCustom: true`
- Available untuk semua expense (planned & sudden)

---

## 3. Data Models

### 3.1 Backend Models

```php
// sudden_expenses table
Schema::create('sudden_expenses', function (Blueprint $table) {
    $table->id();
    $table->foreignId('trip_id')->constrained('trips')->onDelete('cascade');
    $table->string('name');
    $table->foreignId('expense_category_id')->nullable()->constrained('expense_categories');
    $table->decimal('amount', 12, 2);
    $table->text('description')->nullable();
    $table->timestamps();
});

// expense_categories table
Schema::create('expense_categories', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('slug')->unique();
    $table->string('icon');
    $table->string('description')->nullable();
    $table->boolean('is_custom')->default(false);
    $table->timestamps();
});
```

### 3.2 Frontend Models

```dart
// SuddenExpenseModel
@freezed
class SuddenExpenseModel with _$SuddenExpenseModel {
  const factory SuddenExpenseModel({
    required int id,
    required int tripId,
    required String name,
    int? categoryId,
    String? categoryName,
    required double amount,
    String? description,
    required DateTime createdAt,
  }) = _SuddenExpenseModel;
}

// Extended BudgetSummaryModel
@freezed
class BudgetSummaryModel with _$BudgetSummaryModel {
  const factory BudgetSummaryModel({
    int? planBudget,
    int? totalRealitaBudget,  // dari activities
    int? totalSuddenExpenses, // dari sudden_expenses
    int? variance,
    String? budgetStatus,      // 'on_budget', 'underbudget', 'deficit', 'surplus', 'off_budget'
    int? statusAmount,         // nominal surplus/defisit
    bool? isOverbudget,
  }) = _BudgetSummaryModel;
}
```

---

## 4. API Endpoints

### 4.1 Sudden Expenses
```
POST   /api/trips/{trip_id}/sudden-expenses
GET    /api/trips/{trip_id}/sudden-expenses
DELETE /api/trips/{trip_id}/sudden-expenses/{id}
```

### 4.2 Expense Categories
```
GET    /api/expense-categories
POST   /api/expense-categories  (for custom)
```

### 4.3 Trip with Budget
```
GET /api/trips/{id}  // Include budget calculations
```

---

## 5. Implementation Files

### Backend (PHP/Laravel)
1. `app/Models/SuddenExpense.php`
2. `app/Models/ExpenseCategory.php`
3. `app/Http/Controllers/SuddenExpenseController.php`
4. `app/Http/Controllers/ExpenseCategoryController.php`
5. `database/migrations/2026_07_06_xxxxxx_create_sudden_expenses_table.php`
6. `database/migrations/2026_07_06_xxxxxx_create_expense_categories_table.php`
7. `database/seeders/ExpenseCategorySeeder.php`
8. `routes/api.php` - update routes

### Frontend (Flutter)
1. `lib/features/itinerary/data/models/sudden_expense_model.dart`
2. `lib/features/itinerary/data/datasources/sudden_expense_remote_datasource.dart`
3. `lib/features/itinerary/data/itinerary_repository.dart` (extend)
4. `lib/features/itinerary/domain/itinerary_providers.dart` (extend)
5. `lib/features/itinerary/presentation/widgets/sudden_expense_sheet.dart`
6. `lib/features/itinerary/presentation/widgets/budget_status_badge.dart`
7. `lib/features/itinerary/presentation/widgets/on_time_badge.dart`
8. `lib/features/itinerary/presentation/widgets/activity_tile.dart` (update)
9. `lib/features/itinerary/presentation/screens/itinerary_screen.dart` (update)
10. `lib/features/itinerary/presentation/widgets/budget_summary_card.dart` (update)

---

## 6. Acceptance Criteria

- [ ] User bisa menambah sudden expense via FAB di trip detail
- [ ] Sudden expense muncul dengan label "Off-Budget"
- [ ] Budget status berubah sesuai threshold 5%
- [ ] Label "Sisa Anggaran" tampil saat trip aktif
- [ ] Label "Budget Surplus" tampil saat trip selesai
- [ ] Activity badge显示 "On Time" atau "Terlambat X mnt"
- [ ] Timeline vertikal dengan warna node sesuai status
- [ ] Dashboard summary menampilkan "X/Y Aktivitas On Time"
- [ ] User bisa tambah custom expense category
- [ ] Over-budget warning muncul saat expense exceeds plan

---

## 7. Priority

1. **Phase 1**: Sudden Expenses + Backend models
2. **Phase 2**: Budget Status calculation + UI badges
3. **Phase 3**: On Time/Late + Timeline + Summary
4. **Phase 4**: Custom Categories
