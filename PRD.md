# DNTrip - Product Requirement Document (PRD)

## 1. Executive Summary

**DNTrip** adalah aplikasi mobile cross-platform (Android, iOS, dan Web) untuk pencatatan perjalanan bersama teman atau keluarga. Aplikasi memecahkan masalah transparansi biaya dan dokumentasi aktivitas saat bepergian.

**Target Audience:** Grup touring, backpacker, mahasiswa, dan keluarga.

**Core Value:** Memungkinkan multiple users collaborate mencatat pengeluaran dan itinerary secara terpusat.

---

## 2. Technical Stack

### Frontend
- **Framework:** Flutter 3.24+
- **State Management:** Riverpod
- **Architecture:** Clean Architecture
- **HTTP Client:** Dio
- **Local Storage:** Hive
- **Platforms:** Android, iOS, Web

### Backend
- **Framework:** Laravel 11 (PHP 8.2)
- **Authentication:** Laravel Sanctum
- **Database:** SQLite (local) / PostgreSQL (production)
- **Hosting:** Railway

### Deployment
| Service | URL | Description |
|---------|-----|-------------|
| Frontend (Web) | https://dntripp.vercel.app | Flutter Web static hosting |
| Backend (API) | https://dntrip.up.railway.app | Laravel API |
| Repository | https://github.com/LordLy15/dntrip | GitHub mono-repo |

---

## 3. Database Schema

### Users
```sql
users
├── id (PK, auto-increment)
├── name (string)
├── email (string, unique)
├── password (string, hashed)
├── avatar (string, nullable)
├── created_at (timestamp)
└── updated_at (timestamp)
```

### Trips
```sql
trips
├── id (PK, auto-increment)
├── owner_id (FK → users.id)
├── title (string)
├── destination (string)
├── description (text, nullable)
├── plan_budget (decimal, nullable)
├── start_date (date)
├── end_date (date)
├── share_code (string, unique, 6 char)
├── status (enum: planned, ongoing, completed)
├── created_at (timestamp)
└── updated_at (timestamp)
```

### Trip Members
```sql
trip_members
├── id (PK, auto-increment)
├── trip_id (FK → trips.id)
├── user_id (FK → users.id)
├── role (enum: owner, editor, viewer)
├── joined_at (timestamp)
└── PRIMARY KEY (trip_id, user_id)
```

### Trip Days
```sql
trip_days
├── id (PK, auto-increment)
├── trip_id (FK → trips.id)
├── day_number (integer)
├── date (date)
└── PRIMARY KEY (trip_id, day_number)
```

### Trip Activities
```sql
trip_activities
├── id (PK, auto-increment)
├── trip_day_id (FK → trip_days.id)
├── title (string)
├── description (text, nullable)
├── location (string, nullable)
├── completed (boolean, default: false)
├── created_at (timestamp)
└── updated_at (timestamp)
```

### Expense Categories
```sql
expense_categories
├── id (PK, auto-increment)
├── name (string)
├── icon (string, nullable)
└── created_at (timestamp)
```

### Sudden Expenses
```sql
sudden_expenses
├── id (PK, auto-increment)
├── trip_id (FK → trips.id)
├── trip_day_id (FK → trip_days.id, nullable)
├── user_id (FK → users.id, paid_by)
├── amount (decimal)
├── description (string)
├── created_at (timestamp)
└── updated_at (timestamp)
```

---

## 4. API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/register` | Register new user |
| POST | `/api/login` | Login user |
| POST | `/api/logout` | Logout user |
| GET | `/api/user` | Get current user |
| PUT | `/api/user` | Update user profile |

### Trips
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/trips` | List user's trips |
| POST | `/api/trips` | Create new trip |
| GET | `/api/trips/{id}` | Get trip details |
| PUT | `/api/trips/{id}` | Update trip |
| DELETE | `/api/trips/{id}` | Delete trip |
| POST | `/api/trips/join` | Join trip via share code |
| GET | `/api/trips/{id}/members` | List trip members |
| PUT | `/api/trips/{id}/members/{userId}/role` | Update member role |
| DELETE | `/api/trips/{id}/members/{userId}` | Remove member |

### Itinerary / Days
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/trips/{id}/days` | List trip days |
| POST | `/api/trips/{tripId}/days` | Create trip day |
| POST | `/api/trips/{tripId}/activities` | Create activity |
| PUT | `/api/trips/{tripId}/activities/{activityId}` | Update activity |
| PUT | `/api/trips/{tripId}/activities/{activityId}/complete` | Mark complete |
| DELETE | `/api/trips/{tripId}/activities/{activityId}` | Delete activity |

### Expenses
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/expense-categories` | List categories |
| POST | `/api/expense-categories` | Create category |
| GET | `/api/trips/{trip}/sudden-expenses` | List expenses |
| POST | `/api/trips/{trip}/sudden-expenses` | Create expense |
| DELETE | `/api/trips/{trip}/sudden-expenses/{expense}` | Delete expense |

---

## 5. Features

### Epic 1: User Authentication
- [x] Register with email & password
- [x] Login with email & password
- [x] Logout
- [x] View/Edit profile
- [x] Token-based auth (Sanctum)

### Epic 2: Trip Management
- [x] Create trip (title, destination, dates, budget)
- [x] Auto-generate days from dates
- [x] Auto-generate share code
- [x] Edit trip details
- [x] Delete trip (owner only)
- [x] View trip status (planned/ongoing/completed)

### Epic 3: Collaboration
- [x] Share trip via 6-char code
- [x] Join trip via share code
- [x] View members list
- [x] Role management (owner/editor/viewer)

### Epic 4: Itinerary / Daily Activities
- [x] View trip days (auto-generated)
- [x] Add activities to days
- [x] Edit activities
- [x] Mark activities as complete
- [x] Delete activities

### Epic 5: Expense Tracking
- [x] Add sudden expenses
- [x] View expenses list
- [x] Delete expenses
- [x] Track who paid

---

## 6. User Flows

### Registration
1. User opens app
2. Taps "Register"
3. Fills name, email, password
4. Submits form
5. Redirects to home (auto-login)

### Create Trip
1. User taps "+" button
2. Fills trip details (title, destination, dates)
3. Submits form
4. Trip created with auto-generated days
5. Redirects to trip detail

### Join Trip
1. User taps "Join Trip"
2. Enters 6-char share code
3. Submits
4. Redirects to joined trip

---

## 7. Role Permissions

| Action | Owner | Editor | Viewer |
|--------|-------|--------|--------|
| View trip | ✅ | ✅ | ✅ |
| Edit trip details | ✅ | ✅ | ❌ |
| Delete trip | ✅ | ❌ | ❌ |
| Add activities | ✅ | ✅ | ❌ |
| Edit activities | ✅ | ✅ | ❌ |
| Add expenses | ✅ | ✅ | ❌ |
| Remove members | ✅ | ❌ | ❌ |
| Change member role | ✅ | ❌ | ❌ |

---

## 8. CORS Configuration

Frontend dan backend berbeda origin, perlu CORS:

```
Frontend: https://dntripp.vercel.app
Backend:  https://dntrip.up.railway.app/api
```

CORS headers yang diperlukan:
```
Access-Control-Allow-Origin: https://dntripp.vercel.app
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization, Accept
Access-Control-Allow-Credentials: true
```

---

## 9. Development Status

### Completed
- [x] Backend API setup (Laravel 11)
- [x] Authentication (Sanctum)
- [x] Trip CRUD
- [x] Trip days auto-generation
- [x] Activities CRUD
- [x] Expenses tracking
- [x] Role management
- [x] Frontend Flutter (core features)
- [x] Web deployment (Vercel)
- [x] Backend deployment (Railway)

### In Progress
- [ ] CI/CD setup
- [ ] Database migration to PostgreSQL

### TODO
- [ ] Unit tests
- [ ] Push notifications
- [ ] Expense summary/charts
- [ ] Photo uploads
- [ ] Offline mode

---

## 10. Deployment URLs

| Environment | Frontend | Backend |
|------------|----------|---------|
| Production | https://dntripp.vercel.app | https://dntrip.up.railway.app |
| Local | localhost:3000 | localhost:8000 |

---

*Last Updated: July 11, 2026*
