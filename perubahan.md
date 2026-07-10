# Product Requirements Document (PRD): Redesign Halaman Itinerary & Pemindahan Ringkasan ke Dashboard
**Judul Fitur:** Redesign Halaman Itinerary & Pemindahan Ringkasan ke Dashboard
**Target Komponen:** `ItineraryScreen`, `TopAppBar`, `DailyItineraryList`, `BudgetSummaryCard`
## 1. Tujuan Perubahan (Overview)
Menyederhanakan halaman *Itinerary* dengan menghilangkan *card* besar yang tidak perlu (Share & Member) dan mengubahnya menjadi ikon pada Top Bar. Memindahkan fitur "Ringkasan Trip" ke halaman Dashboard terpisah. Halaman *Itinerary* saat ini harus difokuskan murni pada dua hal utama: 
1. **Tracking Budget Aktual vs Plan**
2. **Detail Kegiatan Harian (Progress & Pengeluaran)**

## 2. Spesifikasi UI/UX (Daftar Perubahan)

### Menghapus Elemen Lama
- [ ] Hapus komponen Card "Share Code" yang memakan tempat.
- [ ] Hapus komponen Card List "Members".
- [ ] Hapus komponen "Ringkasan Trip" (Progress bar biru memanjang).

### Pembaruan Top App Bar
- [ ] Tambahkan *IconButton* `Share` (Ikon *share-nodes*) di pojok kanan atas.
- [ ] Tambahkan *IconButton* `Members` (Ikon *user-group*) di sebelah ikon Share.

### Penambahan Quick Action Icons
Di bawah Top Bar, sejajar kanan, buat dua tombol *Floating* kecil atau *Icon Button* berlatar belakang warna solid:
- [ ] **Tombol 1:** Ikon *Chart Pie* (Warna Ungu/Indigo) -> Aksi: Navigasi/Push route ke halaman `DashboardScreen`.
- [ ] **Tombol 2:** Ikon *Lightning/Bolt* (Warna Oranye) -> Aksi: Membuka *modal* atau *bottom sheet* "Pengeluaran Mendadak".

### Penambahan Budget Summary Card (Ungu)
Tampilkan *Card* Ringkasan Budget tepat di atas daftar hari (mirip dengan desain Dashboard sebelumnya). Card ini wajib memuat data berikut:
- [ ] Nominal Plan Budget.
- [ ] Nominal Estimasi.
- [ ] Nominal Realita (Total pengeluaran aktual).
- [ ] *Progress Bar* visual untuk penggunaan budget.
- [ ] *Badge* Sisa Budget (Warna Hijau).

### Modifikasi Daily Itinerary List (Hari 1, Hari 2, dst)
- [ ] **Header Hari:** Tampilkan informasi "Progress Kegiatan" (misal: 1/3 Selesai) dan "Total Pengeluaran Hari Ini" di bagian header *accordion* atau *card* hari tersebut.
- [ ] **Item Kegiatan:** Setiap *list item* kegiatan harus menampilkan:
  - Ikon Status (Selesai/Belum Selesai).
  - Nama Kegiatan.
  - Kategori atau Waktu pelaksanaan.
  - **Nominal Pengeluaran** spesifik untuk kegiatan tersebut.

## 3. State & Data Requirements (Kebutuhan Data Frontend)
Komponen *Itinerary* harus menerima atau mengambil *state* berikut dari *global store* atau *response* API:

```typescript
interface ItineraryState {
  tripDetails: {
    title: string;
    shareCode: string;
    membersCount: number;
  };
  budgetSummary: {
    planBudget: number;
    estimasi: number;
    realita: number; // Total pengeluaran aktual
    sisaBudget: number;
    persentaseTerpakai: number;
  };
  dailyItineraries: Array<{
    dayNumber: number;
    date: string;
    totalPengeluaranHariIni: number;
    kegiatanSelesai: number;
    totalKegiatan: number;
    activities: Array<{
      id: string;
      title: string;
      waktu: string;
      kategori: string;
      nominalPengeluaran: number;
      isCompleted: boolean;
    }>;
  }>;
}

## 4. Instruksi Interaksi (Behavior)
- Klik ikon Share: Buka Bottom Sheet atau Dialog berisi Share Code & opsi salin teks ke clipboard.
- Klik ikon Members: Buka Bottom Sheet atau halaman daftar member.
- Klik ikon Dashboard (Ungu): Arahkan pengguna ke halaman yang berisi visualisasi data (chart donat).
- Checkbox/Icon Check pada kegiatan harian: Saat di-klik, panggil fungsi toggleActivityStatus(activityId). Aksi ini harus secara reaktif memperbarui angka "Realita Budget", "Sisa Budget", dan "Progress Hari" tanpa perlu memuat ulang seluruh halaman.

## 5. Panduan Styling & Aksesibilitas
- Gunakan palet warna yang konsisten: Ungu (Budget Card) #5b4eff / #7c3aed, Oranye (Mendadak) #f59e0b.
- Gunakan shadow-sm pada card harian untuk memberikan dimensi agar tidak terlihat datar.

- Penting: Pastikan rasio kontras teks terjaga dengan baik (gunakan teks putih murni di atas card ungu, dan teks gelap tegas di atas latar belakang terang/putih).

contoh untuk mockup nya seperti code html ini implementasikan ke dalam project saya :
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mockup Itinerary Baru</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f3f4f6;
            display: flex;
            justify-content: center;
        }
        .mobile-container {
            width: 100%;
            max-width: 480px;
            background-color: #f8fafc;
            min-height: 100vh;
            position: relative;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>

<div class="mobile-container pb-24">
    <!-- TOP APP BAR -->
    <header class="bg-white px-4 py-4 flex items-center justify-between sticky top-0 z-10 shadow-sm">
        <div class="flex items-center gap-4">
            <button class="text-gray-700 hover:text-black">
                <i class="fas fa-arrow-left text-lg"></i>
            </button>
            <h1 class="text-lg font-semibold text-gray-800">Itinerary Bali</h1>
        </div>
        <div class="flex items-center gap-5">
            <!-- Share Icon -->
            <button class="text-gray-600 hover:text-blue-600 transition">
                <i class="fas fa-share-nodes text-lg"></i>
            </button>
            <!-- Member Icon -->
            <button class="text-gray-600 hover:text-blue-600 transition">
                <i class="fas fa-user-group text-lg"></i>
            </button>
        </div>
    </header>

    <main class="p-4 space-y-5">
        
        <!-- QUICK ACTIONS (Hanya Icon sesuai permintaan) -->
        <div class="flex justify-end gap-3">
            <!-- Tombol Dashboard -->
            <button class="bg-[#5b4eff] text-white p-3 rounded-xl shadow-md hover:bg-blue-700 transition">
                <i class="fas fa-chart-pie text-xl"></i>
            </button>
            <!-- Tombol Mendadak -->
            <button class="bg-[#f59e0b] text-white p-3 rounded-xl shadow-md hover:bg-yellow-600 transition">
                <i class="fas fa-bolt text-xl"></i>
            </button>
        </div>

        <!-- BUDGET SUMMARY CARD (Menggantikan Ringkasan Trip lama) -->
        <div class="bg-gradient-to-br from-[#7c3aed] to-[#5b4eff] rounded-2xl p-5 text-white shadow-lg relative overflow-hidden">
            <div class="flex items-center gap-3 mb-4">
                <div class="bg-white/20 p-2 rounded-lg">
                    <i class="fas fa-sack-dollar text-yellow-300"></i>
                </div>
                <h2 class="font-semibold text-lg">Ringkasan Budget</h2>
            </div>

            <div class="space-y-2 text-sm mb-4">
                <div class="flex justify-between items-center opacity-90">
                    <span>Plan Budget</span>
                    <span class="font-semibold">Rp 5.000.000</span>
                </div>
                <div class="flex justify-between items-center opacity-90">
                    <span>Estimasi</span>
                    <span>Rp 4.500.000</span>
                </div>
                <div class="flex justify-between items-center text-lg font-bold mt-2">
                    <span>Realita</span>
                    <span>Rp 2.750.000</span>
                </div>
            </div>

            <!-- Progress Bar -->
            <div class="w-full bg-white/20 rounded-full h-2 mb-2">
                <div class="bg-green-400 h-2 rounded-full" style="width: 55%"></div>
            </div>
            
            <div class="flex justify-between items-center text-xs">
                <span>55% terpakai</span>
                <span class="bg-green-500 text-white px-3 py-1 rounded-full font-semibold shadow-sm">
                    Sisa: Rp 2.250.000
                </span>
            </div>
        </div>

        <!-- ITINERARY PER HARI -->
        <div class="space-y-4">
            
            <!-- HARI 1 -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <!-- Header Hari -->
                <div class="px-4 py-3 flex justify-between items-center bg-gray-50 border-b border-gray-100 cursor-pointer">
                    <div class="flex items-center gap-3">
                        <div class="bg-blue-600 text-white w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm">
                            1
                        </div>
                        <div>
                            <h3 class="font-bold text-gray-800 text-sm">Hari 1</h3>
                            <p class="text-xs text-gray-500">09 Jul 2026</p>
                        </div>
                    </div>
                    <div class="text-right flex flex-col items-end">
                        <span class="text-xs font-semibold text-blue-600 bg-blue-50 px-2 py-1 rounded-md mb-1">
                            1/2 Selesai
                        </span>
                        <span class="text-xs font-bold text-gray-700">Rp 1.050.000</span>
                    </div>
                </div>

                <!-- List Kegiatan Hari 1 -->
                <div class="p-4 space-y-4">
                    <!-- Item 1 (Selesai) -->
                    <div class="flex items-start gap-3">
                        <div class="mt-1"><i class="fas fa-check-circle text-green-500"></i></div>
                        <div class="flex-1">
                            <h4 class="text-sm font-semibold text-gray-800">Tiket Pesawat & Bagasi</h4>
                            <p class="text-xs text-gray-500">08:00 - Flight</p>
                        </div>
                        <div class="text-right">
                            <span class="text-sm font-bold text-gray-800">Rp 1.000.000</span>
                        </div>
                    </div>
                    
                    <!-- Item 2 (Belum Selesai) -->
                    <div class="flex items-start gap-3">
                        <div class="mt-1"><i class="far fa-circle text-gray-300"></i></div>
                        <div class="flex-1">
                            <h4 class="text-sm font-semibold text-gray-800">Makan Siang Bandara</h4>
                            <p class="text-xs text-gray-500">12:30 - Konsumsi</p>
                        </div>
                        <div class="text-right">
                            <span class="text-sm font-bold text-gray-800">Rp 50.000</span>
                        </div>
                    </div>
                </div>
                
                <!-- Tambah Kegiatan Button -->
                <button class="w-full py-3 text-sm font-semibold text-blue-600 bg-blue-50 hover:bg-blue-100 transition flex items-center justify-center gap-2 border-t border-gray-100">
                    <i class="fas fa-plus"></i> Tambah Kegiatan
                </button>
            </div>

            <!-- HARI 2 -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <!-- Header Hari -->
                <div class="px-4 py-3 flex justify-between items-center bg-gray-50 border-b border-gray-100 cursor-pointer">
                    <div class="flex items-center gap-3">
                        <div class="bg-gray-400 text-white w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm">
                            2
                        </div>
                        <div>
                            <h3 class="font-bold text-gray-800 text-sm">Hari 2</h3>
                            <p class="text-xs text-gray-500">10 Jul 2026</p>
                        </div>
                    </div>
                    <div class="text-right flex flex-col items-end">
                        <span class="text-xs font-semibold text-gray-500 bg-gray-200 px-2 py-1 rounded-md mb-1">
                            0/1 Selesai
                        </span>
                        <span class="text-xs font-bold text-gray-700">Rp 0</span>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <!-- FAB Tambah Hari (Optional, jika diperlukan) -->
    <button class="absolute bottom-6 right-6 w-14 h-14 bg-blue-600 text-white rounded-full shadow-xl flex items-center justify-center hover:bg-blue-700 transition">
        <i class="fas fa-plus text-xl"></i>
    </button>
</div>

</body>
</html>