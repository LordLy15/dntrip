# DNTrip

Trip Sharing & Expense Tracking Application

## Tech Stack

- **Backend:** Laravel 11 with PHP 8.2+
- **Frontend:** Flutter with Riverpod, Freezed, GoRouter
- **Database:** MySQL

## Features

- User Authentication (Register/Login)
- Trip Management (Create, Edit, Delete)
- Share Trip with unique code
- Join Trip with share code
- Itinerary & Budget Tracking
- Activity Management

## Project Structure

```
DNTrip/
├── backend/          # Laravel API
│   ├── app/         # Models, Controllers, Requests
│   ├── config/      # Laravel configuration
│   ├── database/     # Migrations, Seeders
│   ├── routes/       # API routes
│   └── ...
└── frontend/        # Flutter App
    └── lib/
        ├── core/       # API, Router, Theme
        └── features/    # Auth, Trips, Itinerary
```

## Setup Instructions

### Backend

1. Install dependencies:
   ```bash
   cd backend
   composer install
   ```

2. Copy environment file:
   ```bash
   cp .env.example .env
   ```

3. Generate application key:
   ```bash
   php artisan key:generate
   ```

4. Configure MySQL database in `.env`:
   ```
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=dntrip
   DB_USERNAME=root
   DB_PASSWORD=
   ```

5. Run migrations:
   ```bash
   php artisan migrate
   ```

6. Start server:
   ```bash
   php artisan serve
   ```

### Frontend

1. Install dependencies:
   ```bash
   cd frontend
   flutter pub get
   ```

2. Update API URL in `lib/core/constants/app_constants.dart`

3. Run app:
   ```bash
   flutter run
   ```

## API Endpoints

- `POST /api/register` - Register user
- `POST /api/login` - Login user
- `GET /api/trips` - List trips
- `POST /api/trips` - Create trip
- `GET /api/trips/{id}` - Get trip details
- `POST /api/trips/join` - Join trip with code
- `GET /api/trips/{id}/days` - Get itinerary
- `POST /api/trips/{tripId}/activities` - Create activity

## License

MIT
