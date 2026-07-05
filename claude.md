markdown_content = """# CLAUDE.md - Project Context & Instructions for Claude

This file contains the complete Product Requirement Document (PRD) and specific technical instructions for building **DNTrip**. 
As an AI coding assistant (Claude), please read this entire document before generating code to ensure all architectural choices and features align with the project vision.

---

## 🤖 CLAUDE INSTRUCTIONS (AI ASSISTANT GUIDELINES)

When writing code for this project, please adhere to the following guidelines:

### Flutter (Frontend) Guidelines:
1. **State Management:** Use `Riverpod` for state management. Avoid using default `setState` for complex logic.
2. **Architecture:** Implement a Clean Architecture or Feature-first folder structure (e.g., `lib/features/auth`, `lib/features/trips`).
3. **UI/UX:** Use modern Material Design 3 guidelines. Build custom widgets for recurring elements like the `Add Expense BottomSheet` and the custom Numpad.
4. **Networking:** Use the `dio` package for HTTP requests. Create a centralized API client with interceptors for injecting the Bearer Token.
5. **Local Data:** Implement caching using `sqflite` or `hive` for offline read-only capabilities.

### Backend (PHP/Laravel) Guidelines:
1. **API First:** The backend acts strictly as a REST API. Return standard JSON responses (e.g., `{ "status": "success", "data": {...}, "message": "..." }`).
2. **Database Migrations:** Write complete Laravel migrations and seeders based on the SQL schema provided in the PRD below.
3. **Authentication:** Use Laravel Sanctum for API token generation and protection.
4. **Validation:** Always use FormRequests to validate incoming data (especially for amounts and share codes).
5. **Hosting Constraints:** Optimize queries and avoid heavy background jobs/WebSockets since the target hosting (InfinityFree) has strict limits.

---

## 📄 PRODUCT REQUIREMENT DOCUMENT (PRD)

### 1. Executive Summary & Product Vision
**DNTrip** adalah aplikasi mobile cross-platform (Android & iOS) yang dirancang untuk memfasilitasi pencatatan perjalanan secara komprehensif. Aplikasi ini memecahkan masalah transparansi biaya dan dokumentasi aktivitas saat bepergian bersama teman atau keluarga. Dengan fitur utama *Trip Sharing* menggunakan kode unik, DNTrip memungkinkan banyak pengguna untuk berkolaborasi mencatat pengeluaran (*expense tracking*) dan aktivitas harian (*itinerary log*) secara terpusat dan rapi.

### 2. Target Audience & Use Cases
*   **Target Audience:** Grup touring, backpacker, mahasiswa, dan keluarga.
*   **Use Cases:** Andi membuat trip "Bali 2026" dan membagikan kode `BALI26` ke Budi dan Citra. Saat Budi membayar makan malam, ia mencatatnya di DNTrip. Citra dan Andi bisa langsung melihat rincian biaya tersebut dan mengetahui berapa patungan yang harus dibayar nanti.

### 3. Detailed Feature Breakdown

**Epic 1: User Authentication & Profile**
*   **F1.1 Register & Login:** Autentikasi menggunakan Email & Password (JWT/Sanctum Token).
*   **F1.2 User Profile:** Menampilkan nama pengguna, email, dan statistik sederhana.

**Epic 2: Trip Management (Core)**
*   **F2.1 Create Trip:** Input detail berupa Nama Trip, Destinasi Utama, Deskripsi, Tanggal Mulai, dan Tanggal Selesai.
*   **F2.2 Edit/Delete Trip:** Modifikasi detail trip. Penghapusan trip oleh *Owner* akan menghapus seluruh data terkait.
*   **F2.3 Trip Status:** *Planned*, *Ongoing*, *Completed*.

**Epic 3: Itinerary & Daily Logging**
*   **F3.1 Day Generator:** Sistem otomatis membuat slot "Hari 1", "Hari 2", dst.
*   **F3.2 Activity Log:** Menambahkan teks aktivitas/lokasi yang dikunjungi.

**Epic 4: Expense Tracking & Finance**
*   **F4.1 Add Expense:** *Bottom Sheet* untuk menambah biaya (Nominal, Kategori, Deskripsi, *Paid By*).
*   **F4.2 Expense Summary:** Dashboard total pengeluaran dan Grafik/Pie Chart.

**Epic 5: Social & Collaboration**
*   **F5.1 Share Trip Code:** Generate 6-digit alphanumeric string unik.
*   **F5.2 Join Trip:** Memasukkan kode unik untuk bergabung.
*   **F5.3 Role Management:** Owner, Editor (Member), Viewer.

### 4. Database Schema Design (MySQL / Laravel Migrations Target)

```sql
-- 1. users
id, name, email, password_hash, created_at

-- 2. trips
id, owner_id (FK), title, destination, description, start_date, end_date, share_code, created_at

-- 3. trip_members
id, trip_id (FK), user_id (FK), role ('owner', 'editor', 'viewer'), joined_at

-- 4. trip_days
id, trip_id (FK), day_number, actual_date

-- 5. expenses
id, trip_id (FK), trip_day_id (FK nullable), paid_by_user_id (FK), amount, category_id, description, created_at

### 5. API Contract Design (REST API Draft)
*   ** POST /api/register **
*   ** POST /api/login **
*   ** GET /api/trips **
*   ** POST /api/trips **
*   ** GET /api/trips/{id} **
*   ** POST /api/trips/join -> { "share_code": "XYZ123" } **
*   ** POST /api/trips/{id}/expenses **
*   ** GET /api/trips/{id}/expenses **
