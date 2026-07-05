# Spesifikasi Penambahan Fitur: Budget & Expense Tracking
**Epic Terkait:** Epic 3 (Itinerary & Activity Management)

## 1. Ringkasan Fitur
Sistem tidak hanya mencatat jadwal kegiatan (*itinerary*), tetapi juga melacak rencana anggaran (*plan budget*) dan pengeluaran riil (*actual cost*). Fitur ini mencakup kemampuan untuk mendeteksi kegiatan yang ditambahkan secara mendadak pada hari H (*unplanned activities*) dan memberikan evaluasi *overbudget* secara *real-time*.

---

## 2. Pembaruan Skema Database (Backend - Laravel)
Penambahan kolom pada tabel yang menyimpan detail kegiatan (misal: `trip_activities`):

| Nama Kolom       | Tipe Data       | Default | Deskripsi |
| :---             | :---            | :---    | :--- |
| `estimated_cost` | Decimal/Integer | `0`     | Harga yang direncanakan di awal (*Plan Budget*). |
| `actual_cost`    | Decimal/Integer | `null`  | Harga riil saat dieksekusi. |
| `status`         | Enum            | `pending` | Pilihan: `pending`, `completed`, `skipped`. |
| `is_unplanned`   | Boolean         | `false` | `true` jika kegiatan ditambahkan pada/setelah tanggal jadwal. |

---

## 3. Logika Kalkulasi (Bisnis & UI)
Kalkulasi dilakukan di level *backend* untuk disajikan ke *frontend*, dengan rumus dasar:

*   **Total Plan Budget:** $\sum (\text{estimated\_cost})$ untuk semua kegiatan di mana `is_unplanned = false`.
*   **Total Actual Cost:** $\sum (\text{actual\_cost})$ untuk semua kegiatan dengan `status = completed`.
*   **Variance (Selisih):** $\text{Total Actual Cost} - \text{Total Plan Budget}$
    *   Jika $\text{Variance} > 0$ $\rightarrow$ **Overbudget**
    *   Jika $\text{Variance} \le 0$ $\rightarrow$ **Underbudget / On-Track**

---

## 4. Alur UI/UX (Frontend - Flutter)

### A. Tahap Planning (Sebelum Hari H)
*   Form `Create Activity` memiliki *input field* wajib: **Estimasi Biaya**.
*   Layar `Trip Details` menampilkan *card summary* berisi **Total Plan Budget**.

### B. Tahap Eksekusi (Hari H)
*   Terdapat tombol/ikon **"Tandai Selesai"** pada tiap *card* kegiatan.
*   Saat ditekan, muncul *BottomSheet* untuk konfirmasi pengeluaran:
    *   *Field* **Harga Aktual** otomatis terisi nilai `estimated_cost` (bisa diedit).
    *   Tombol "Simpan" akan mengubah status menjadi `completed` dan mencatat `actual_cost`.

### C. Kondisi Unplanned (Kegiatan Dadakan)
*   Jika *user* menambahkan kegiatan baru, sistem akan mengecek: `waktu_sekarang` $\ge$ `tanggal_kegiatan`.
*   Jika ya, kolom `is_unplanned` di-*set* menjadi `true`.
*   UI akan menampilkan *badge* khusus (misal: **Label Merah: Unplanned**) pada kegiatan tersebut.
*   Biaya kegiatan langsung menambah `Total Actual Cost` tanpa menambah `Total Plan Budget`.

### D. Evaluasi Real-time
*   Menyediakan *Progress Bar* pengeluaran di bagian atas layar *Itinerary*.
*   Warna dinamis: **Hijau** (Aman/Sesuai) dan **Merah** (Overbudget beserta nominal selisihnya).

---

## 5. Pembaruan Kontrak API (Draft)
Struktur *response* JSON dari *backend* saat me-*request* detail *itinerary*:

```json
{
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
        "date": "2026-07-10",
        "activities": [
          {
            "id": 101,
            "title": "Tiket Masuk Museum",
            "estimated_cost": 50000,
            "actual_cost": 75000,
            "status": "completed",
            "is_unplanned": false
          },
          {
            "id": 102,
            "title": "Beli Kopi Dadakan",
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