# DNTrip Epic 2: Trip Management + Members - Design Specification

**Tanggal:** 2026-07-04
**Epic:** Epic 2 - Trip Management & Collaboration
**Status:** Draft

---

## 1. Overview

Epic 2 adalah implementasi sistem manajemen trip dan kolaborasi multi-user. Fitur ini memungkinkan user untuk membuat, mengedit, dan mengelola trip perjalanan dengan fitur share code untuk invite member.

### Goals
- CRUD trip dengan detail lengkap
- Share code generation untuk collaboration
- Role-based member management (Owner, Editor, Viewer)
- Hybrid status management (auto + manual)

---

## 2. Tech Stack Decisions

| Component | Choice | Rationale |
|-----------|--------|-----------|
| Backend | Laravel 11 + Sanctum | REST API, token auth |
| Frontend | Flutter + Riverpod | State management |
| Architecture | Feature-First | Modular structure |

---

## 3. Backend Design (Laravel)

### 3.1 Database Schema

**trips table:**
| Column | Type | Constraints |
|--------|------|-------------|
| id | bigint | PK, auto increment |
| owner_id | bigint | FK → users.id |
| title | varchar(255) | not null |
| destination | varchar(255) | nullable |
| description | text | nullable |
| start_date | date | nullable |
| end_date | date | nullable |
| share_code | varchar(10) | unique, nullable |
| status | enum | 'planned', 'ongoing', 'completed' |
| created_at | timestamp | nullable |
| updated_at | timestamp | nullable |

**trip_members table:**
| Column | Type | Constraints |
|--------|------|-------------|
| id | bigint | PK, auto increment |
| trip_id | bigint | FK → trips.id |
| user_id | bigint | FK → users.id |
| role | enum | 'owner', 'editor', 'viewer' |
| joined_at | timestamp | nullable |

**Constraints:** Unique(trip_id, user_id)

### 3.2 API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/trips` | Yes | List user's trips (owned + joined) |
| POST | `/api/trips` | Yes | Create new trip |
| GET | `/api/trips/{id}` | Yes | Get trip detail |
| PUT | `/api/trips/{id}` | Yes | Update trip (owner/editor) |
| DELETE | `/api/trips/{id}` | Yes | Delete trip (owner only) |
| POST | `/api/trips/join` | Yes | Join trip via share code |
| GET | `/api/trips/{id}/members` | Yes | List trip members |
| PUT | `/api/trips/{id}/members/{userId}/role` | Yes | Update member role (owner only) |
| DELETE | `/api/trips/{id}/members/{userId}` | Yes | Remove member (owner only) |

### 3.3 Request/Response Specifications

#### GET /api/trips

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "trips": [
      {
        "id": 1,
        "title": "Bali 2026",
        "destination": "Bali, Indonesia",
        "start_date": "2026-08-01",
        "end_date": "2026-08-07",
        "status": "planned",
        "share_code": "BALI26",
        "owner": { "id": 1, "name": "Andi" },
        "members_count": 3
      }
    ]
  }
}
```

#### POST /api/trips

**Request:**
```json
{
  "title": "Bali 2026",
  "destination": "Bali, Indonesia",
  "description": "Trip keluarga summer",
  "start_date": "2026-08-01",
  "end_date": "2026-08-07"
}
```

**Response (201):**
```json
{
  "status": "success",
  "data": {
    "trip": {
      "id": 1,
      "title": "Bali 2026",
      "destination": "Bali, Indonesia",
      "description": "Trip keluarga summer",
      "start_date": "2026-08-01",
      "end_date": "2026-08-07",
      "share_code": "BALI26",
      "status": "planned",
      "owner": { "id": 1, "name": "Andi" },
      "members": [
        { "id": 1, "name": "Andi", "role": "owner" }
      ]
    }
  },
  "message": "Trip created successfully"
}
```

#### POST /api/trips/join

**Request:**
```json
{
  "share_code": "BALI26"
}
```

**Response (200):**
```json
{
  "status": "success",
  "data": {
    "trip": { ... },
    "role": "editor"
  },
  "message": "Joined trip successfully"
}
```

**Error (404):**
```json
{
  "status": "error",
  "message": "Trip not found with this share code"
}
```

**Error (409 - Already joined):**
```json
{
  "status": "error",
  "message": "You have already joined this trip"
}
```

### 3.4 Validation Rules

| Endpoint | Field | Rules |
|----------|-------|-------|
| create_trip | title | required, string, min:1, max:255 |
| create_trip | destination | nullable, string, max:255 |
| create_trip | description | nullable, string |
| create_trip | start_date | required, date, after_or_equal:today |
| create_trip | end_date | required, date, after_or_equal:start_date |
| join_trip | share_code | required, string, size:6, exists:trips,share_code |

### 3.5 Business Logic

**Share Code Generation:**
- Generate 6-character alphanumeric code
- Format: Uppercase letters + digits (e.g., "BALI26", "TR1P42")
- Collision check before saving

**Status Management (Hybrid):**
- Auto transition: planned → ongoing on start_date
- Auto transition: ongoing → completed on end_date
- Manual override allowed anytime
- Validation: Cannot set status to "planned" if current_date > start_date

**Role Permissions:**
| Action | Owner | Editor | Viewer |
|--------|-------|--------|--------|
| View trip | ✓ | ✓ | ✓ |
| Update trip | ✓ | ✓ | ✗ |
| Delete trip | ✓ | ✗ | ✗ |
| Manage members | ✓ | ✗ | ✗ |
| Change status | ✓ | ✓ | ✗ |

---

## 4. Frontend Design (Flutter)

### 4.1 Project Structure

```
frontend/lib/features/trips/
├── data/
│   ├── models/
│   │   ├── trip_model.dart
│   │   └── trip_member_model.dart
│   ├── datasources/
│   │   └── trip_remote_datasource.dart
│   └── trip_repository.dart
├── domain/
│   └── trip_providers.dart
└── presentation/
    ├── screens/
    │   ├── trips_list_screen.dart
    │   ├── trip_detail_screen.dart
    │   ├── trip_form_screen.dart
    │   ├── join_trip_screen.dart
    │   └── trip_members_screen.dart
    └── widgets/
        ├── trip_card.dart
        ├── status_badge.dart
        └── member_avatar.dart
```

### 4.2 Data Models

```dart
@freezed
class TripModel with _$TripModel {
  const factory TripModel({
    required int id,
    required String title,
    String? destination,
    String? description,
    String? startDate,
    String? endDate,
    required String shareCode,
    required String status, // planned, ongoing, completed
    required UserModel owner,
    @Default([]) List<TripMemberModel> members,
    int? membersCount,
  }) = _TripModel;

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);
}

@freezed
class TripMemberModel with _$TripMemberModel {
  const factory TripMemberModel({
    required int id,
    required String name,
    String? email,
    required String role, // owner, editor, viewer
  }) = _TripMemberModel;

  factory TripMemberModel.fromJson(Map<String, dynamic> json) =>
      _$TripMemberModelFromJson(json);
}
```

### 4.3 Screen Specifications

**TripsListScreen:**
- List all user's trips (owned + joined)
- Each trip shows: title, destination, dates, status badge, member count
- FAB for creating new trip
- Pull-to-refresh

**TripDetailScreen:**
- Full trip information display
- Share code with copy functionality
- Members list preview
- Edit button (if owner/editor)
- Delete button (if owner)
- Status dropdown (if owner/editor)

**TripFormScreen:**
- Form fields: title, destination, description, start_date, end_date
- Auto-generated share code display
- Create and Edit modes
- Form validation with inline errors

**JoinTripScreen:**
- Share code input field
- Join button
- QR scanner option (future)

**TripMembersScreen:**
- List all members with roles
- Role dropdown for owner to change
- Remove member button (owner only)
- Current user indicator

### 4.4 Widget Components

```dart
// StatusBadge colors
StatusBadge: planned → Colors.blue
             ongoing → Colors.green
             completed → Colors.grey

// TripCard layout
TripCard:
  - Leading: Destination icon or image
  - Title: Trip title
  - Subtitle: Dates
  - Trailing: StatusBadge + member count
  - onTap → navigate to detail
```

### 4.5 Navigation Routes

```
/trips              → TripsListScreen
/trips/new          → TripFormScreen (create)
/trips/:id          → TripDetailScreen
/trips/:id/edit     → TripFormScreen (edit)
/trips/:id/members  → TripMembersScreen
/join               → JoinTripScreen
```

---

## 5. Implementation Checklist

### Backend
- [ ] Create TripController
- [ ] Create TripMemberController
- [ ] Create TripRequest (validation)
- [ ] Create JoinTripRequest (validation)
- [ ] Update Trip model with relationships
- [ ] Create Trip migration
- [ ] Create TripMember migration
- [ ] Add routes
- [ ] Test all endpoints

### Frontend
- [ ] Create TripModel with freezed
- [ ] Create TripMemberModel
- [ ] Create TripRemoteDatasource
- [ ] Create TripRepository
- [ ] Create TripProviders
- [ ] Create TripsListScreen
- [ ] Create TripDetailScreen
- [ ] Create TripFormScreen
- [ ] Create JoinTripScreen
- [ ] Create TripMembersScreen
- [ ] Create widgets (TripCard, StatusBadge, MemberAvatar)
- [ ] Update AppRouter with new routes
- [ ] Test auth flow integration

---

## 6. Dependencies

No new dependencies required. Using existing:
- dio for HTTP
- freezed for models
- riverpod for state
- go_router for navigation

---

## 7. Notes & Considerations

### Security
- Share codes are case-insensitive on input
- Only owner can delete trip
- Only owner can manage members
- Editors and viewers cannot modify trip

### Future Enhancements (Out of Scope)
- QR code generation for share
- Push notifications for member updates
- Trip templates
- Export trip summary

---

*Design specification v1.0 - 2026-07-04*
