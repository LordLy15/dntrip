# DNTrip Epic 3: Itinerary & Activity Management + Budget Tracking - Design Specification

**Tanggal:** 2026-07-05
**Epic:** Epic 3 - Itinerary & Activity Management
**Status:** Draft

---

## 1. Overview

Epic 3 adalah implementasi sistem itinerary dan budget tracking. Fitur ini memungkinkan user untuk melihat itinerary per hari, menambahkan activities, dan melacak budget planning vs actual spending secara real-time.

### Goals
- Auto-generate trip days dari date range
- CRUD activities dengan estimated cost
- Mark activities sebagai completed dengan actual cost
- Detect unplanned activities (ditambahkan saat trip ongoing)
- Budget summary dengan variance calculation

---

## 2. Tech Stack Decisions

| Component | Choice |
|-----------|--------|
| Backend | Laravel 11 + Sanctum |
| Frontend | Flutter + Riverpod |
| Architecture | Feature-First |

---

## 3. Backend Design (Laravel)

### 3.1 Database Schema

**trip_days table:**
| Column | Type | Constraints |
|--------|------|-------------|
| id | bigint | PK, auto increment |
| trip_id | bigint | FK → trips.id |
| day_number | int | not null |
| date | date | not null |
| notes | text | nullable |
| created_at | timestamp | nullable |
| updated_at | timestamp | nullable |

**trip_activities table:**
| Column | Type | Constraints |
|--------|------|-------------|
| id | bigint | PK, auto increment |
| trip_day_id | bigint | FK → trip_days.id |
| trip_id | bigint | FK → trips.id |
| title | varchar(255) | not null |
| description | text | nullable |
| category | enum | transport, food, accommodation, tickets, shopping, others |
| estimated_cost | decimal(12,2) | default 0 |
| actual_cost | decimal(12,2) | nullable |
| status | enum | pending, completed, skipped |
| is_unplanned | boolean | default false |
| created_at | timestamp | nullable |
| updated_at | timestamp | nullable |

### 3.2 API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/trips/{id}/days` | Yes | List trip days dengan activities |
| POST | `/api/trips/{id}/activities` | Yes | Create activity |
| PUT | `/api/trips/{id}/activities/{actId}` | Yes | Update activity |
| DELETE | `/api/trips/{id}/activities/{actId}` | Yes | Delete activity |
| PUT | `/api/trips/{id}/activities/{actId}/complete` | Yes | Mark completed with actual cost |

### 3.3 Request/Response Specifications

#### GET /api/trips/{id}/days

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "trip_id": 1,
    "budget_summary": {
      "total_estimated": 1500000,
      "total_actual": 1700000,
      "variance": 200000,
      "is_overbudget": true
    },
    "days": [
      {
        "id": 1,
        "day_number": 1,
        "date": "2026-08-01",
        "notes": "Hari pertama",
        "activities": [
          {
            "id": 101,
            "title": "Tiket Masuk Museum",
            "category": "tickets",
            "estimated_cost": 50000,
            "actual_cost": 75000,
            "status": "completed",
            "is_unplanned": false
          },
          {
            "id": 102,
            "title": "Beli Kopi Dadakan",
            "category": "food",
            "estimated_cost": 0,
            "actual_cost": 35000,
            "status": "completed",
            "is_unplanned": true
          }
        ]
      }
    ]
  }
}
```

#### POST /api/trips/{id}/activities

**Request:**
```json
{
  "trip_day_id": 1,
  "title": "Makan Siang",
  "description": "Makan siang di restaurant lokal",
  "category": "food",
  "estimated_cost": 100000
}
```

**Response (201):**
```json
{
  "status": "success",
  "data": {
    "activity": {
      "id": 103,
      "title": "Makan Siang",
      "category": "food",
      "estimated_cost": 100000,
      "actual_cost": null,
      "status": "pending",
      "is_unplanned": false
    }
  },
  "message": "Activity created successfully"
}
```

#### PUT /api/trips/{id}/activities/{actId}/complete

**Request:**
```json
{
  "actual_cost": 120000
}
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "activity": {...},
    "budget_summary": {
      "total_estimated": 1600000,
      "total_actual": 1820000,
      "variance": 220000,
      "is_overbudget": true
    }
  },
  "message": "Activity marked as completed"
}
```

### 3.4 Business Logic

**Auto-generate days on trip create:**
- Triggered when trip is created
- Generate days from start_date to end_date inclusive
- Day 1 = start_date, Day 2 = start_date + 1, etc.

**Unplanned activity detection:**
- When activity created, check: `now() >= trip_day.date`
- If true → set `is_unplanned = true`
- Unplanned activities:
  - Don't count toward `total_estimated`
  - Still count toward `total_actual` when completed

**Budget calculations:**
- `total_estimated` = SUM(estimated_cost) WHERE is_unplanned = false
- `total_actual` = SUM(actual_cost) WHERE status = completed
- `variance` = total_actual - total_estimated
- `is_overbudget` = variance > 0

---

## 4. Frontend Design (Flutter)

### 4.1 Project Structure

```
frontend/lib/features/itinerary/
├── data/
│   ├── models/
│   │   ├── trip_day_model.dart
│   │   ├── activity_model.dart
│   │   └── budget_summary_model.dart
│   ├── datasources/
│   │   └── itinerary_remote_datasource.dart
│   └── itinerary_repository.dart
├── domain/
│   └── itinerary_providers.dart
└── presentation/
    ├── screens/
    │   ├── itinerary_screen.dart
    │   ├── activity_form_screen.dart
    │   └── activity_complete_sheet.dart
    └── widgets/
        ├── day_card.dart
        ├── activity_tile.dart
        ├── budget_summary_card.dart
        ├── category_badge.dart
        └── unplanned_badge.dart
```

### 4.2 Data Models

```dart
@freezed
class BudgetSummaryModel with _$BudgetSummaryModel {
  const factory BudgetSummaryModel({
    required int totalEstimated,
    required int totalActual,
    required int variance,
    required bool isOverbudget,
  }) = _BudgetSummaryModel;

  factory BudgetSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetSummaryModelFromJson(json);
}

@freezed
class ActivityModel with _$ActivityModel {
  const factory ActivityModel({
    required int id,
    required String title,
    String? description,
    required String category,
    required int estimatedCost,
    int? actualCost,
    required String status,
    required bool isUnplanned,
  }) = _ActivityModel;

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);
}

@freezed
class TripDayModel with _$TripDayModel {
  const factory TripDayModel({
    required int id,
    required int dayNumber,
    required String date,
    String? notes,
    @Default([]) List<ActivityModel> activities,
  }) = _TripDayModel;

  factory TripDayModel.fromJson(Map<String, dynamic> json) =>
      _$TripDayModelFromJson(json);
}

@freezed
class ItineraryData with _$ItineraryData {
  const factory ItineraryData({
    required int tripId,
    required BudgetSummaryModel budgetSummary,
    @Default([]) List<TripDayModel> days,
  }) = _ItineraryData;

  factory ItineraryData.fromJson(Map<String, dynamic> json) =>
      _$ItineraryDataFromJson(json);
}
```

### 4.3 UI Components

**Budget Summary Card:**
```
┌─────────────────────────────────────┐
│ 💰 Budget Summary                    │
├─────────────────────────────────────┤
│ Planned:     Rp 1.500.000          │
│ Actual:      Rp 1.700.000           │
│                                     │
│ [██████████████░░░░░░] 113%        │
│ Overbudget: Rp 200.000              │
└─────────────────────────────────────┘
```

**Day Card:**
```
┌─────────────────────────────────────┐
│ Day 1 - Aug 1, 2026                │
│ Hari pertama di Bali                 │
├─────────────────────────────────────┤
│ 🍽️ Makan Siang        Rp 100.000   │
│ ✓                                 │
│ 🎟️ Tiket Museum      Rp 50.000    │
│ ✓                                 │
│ ☕ Kopi Dadakan ⚠️    Rp 35.000   │
│ ✓                                 │
├─────────────────────────────────────┤
│ [+ Tambah Activity]                 │
└─────────────────────────────────────┘
```

**Activity Complete Bottom Sheet:**
```
┌─────────────────────────────────────┐
│         Mark Activity Complete       │
├─────────────────────────────────────┤
│                                     │
│ Makan Siang                         │
│                                     │
│ Estimated: Rp 100.000              │
│                                     │
│ Actual Cost:                        │
│ ┌───────────────────────────────┐   │
│ │ 120000                       │   │
│ └───────────────────────────────┘   │
│                                     │
│ ┌───────────────────────────────┐   │
│ │       Simpan                  │   │
│ └───────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

## 5. Categories Enum

```dart
enum ActivityCategory {
  transport('Transport', Icons.directions_car),
  food('Food', Icons.restaurant),
  accommodation('Stay', Icons.hotel),
  tickets('Tickets', Icons.confirmation_number),
  shopping('Shopping', Icons.shopping_bag),
  others('Others', Icons.more_horiz);
}
```

---

## 6. Implementation Checklist

### Backend
- [ ] Create TripDay model
- [ ] Create TripActivity model
- [ ] Create TripDay migration
- [ ] Create TripActivity migration
- [ ] Create TripActivityRequest validation
- [ ] Create ItineraryController
- [ ] Add routes
- [ ] Test endpoints

### Frontend
- [ ] Create models (BudgetSummary, Activity, TripDay, ItineraryData)
- [ ] Create ItineraryRemoteDatasource
- [ ] Create ItineraryRepository
- [ ] Create ItineraryProviders
- [ ] Create BudgetSummaryCard widget
- [ ] Create DayCard widget
- [ ] Create ActivityTile widget
- [ ] Create CategoryBadge widget
- [ ] Create UnplannedBadge widget
- [ ] Create ItineraryScreen
- [ ] Create ActivityFormScreen
- [ ] Create ActivityCompleteSheet
- [ ] Test flows

---

*Design specification v1.0 - 2026-07-05*
