
Percakapan dengan Gemini
buat agar share code ada, dan buat fitur oin trips juga di bagian dashboard samping pengaturan dan juga buatkan fitur plan budget dan realita budget, plan budget dibuat ketika membuat trip, dan realita budget ketika activity di trip mau di selesaikan harus menginput pengeluaran, dan buatkan juga pengeluaran mendadak, dan untuk trip akan ada tambahan ingin menambahkan lokasi atau tidak, lokasi itu berupa langtitude dan longtitude, dan ketika mau diselesaikan activity dan trip nya akan terlihat waktunya on time atau lewat ketika mau di mulai.



buatkan prd nya untuk fitur tambahan,

Berikut adalah rancangan Product Requirements Document (PRD) untuk pengembangan fitur tambahan pada aplikasi manajemen trip Anda. Dokumen ini disusun untuk memberikan panduan jelas dari sisi interaksi pengguna (UX/UI) maupun kesiapan logika sistem.

Product Requirements Document (PRD): Fitur Tambahan Manajemen Trip
1. Tujuan Utama
Memperluas kapabilitas aplikasi dengan menambahkan fitur kolaborasi tim (bergabung ke trip via kode), pelacakan finansial yang komprehensif (rencana vs. realita), penandaan lokasi (koordinat), dan sistem pemantauan kedisiplinan waktu eksekusi aktivitas.

2. Detail Kebutuhan Fitur (Feature Requirements)
A. Kolaborasi: Share Code & Join Trip
Memungkinkan pengguna untuk mengundang atau bergabung ke dalam sebuah trip tanpa harus memasukkan data secara manual berulang kali.

Nama Fitur	Kebutuhan & Perilaku Sistem	Kriteria Penerimaan (Acceptance Criteria)
Share Code	Sistem men-generate kode unik (misal: 6 digit alfanumerik) saat trip dibuat.	Kode unik muncul di halaman detail trip dengan tombol Copy to Clipboard.
Menu Join Trip	Penambahan menu baru di Sidebar Dashboard, diletakkan berdekatan dengan menu Pengaturan.	Pengguna dapat melihat dan mengklik menu "Join Trip" dari sidebar.
Form Join Trip	Modal/Halaman sederhana berisi satu kolom input teks untuk memasukkan Share Code.	Jika kode valid, pengguna ditambahkan sebagai partisipan trip. Jika tidak, muncul pesan error.
B. Manajemen Anggaran: Plan vs Realita & Pengeluaran Mendadak
Mengontrol dan melacak perbandingan antara anggaran yang direncanakan dengan pengeluaran aktual di lapangan.

Nama Fitur	Kebutuhan & Perilaku Sistem	Kriteria Penerimaan (Acceptance Criteria)
Plan Budget	Field input nominal anggaran saat pengguna pertama kali membuat/menginisiasi Trip.	Form Create Trip wajib/opsional memiliki kolom Plan Budget.
Realita Budget	Input wajib (modal/pop-up) ketika pengguna menekan tombol "Selesaikan Aktivitas".	Aktivitas tidak dapat berstatus Selesai sebelum nominal pengeluaran diisi.
Pengeluaran Mendadak	Tombol khusus di dalam detail Trip ("Tambah Pengeluaran Mendadak") untuk biaya di luar aktivitas.	Sistem mencatat biaya ini dan langsung memotong total Plan Budget / menambah total Realita Budget.
C. Penanda Lokasi (Latitude & Longitude)
Memberikan opsi untuk menyematkan titik koordinat spesifik pada sebuah trip.

Nama Fitur	Kebutuhan & Perilaku Sistem	Kriteria Penerimaan (Acceptance Criteria)
Opsi Lokasi Trip	Toggle atau Checkbox ("Tambahkan Lokasi") pada form pembuatan Trip.	Jika diaktifkan, muncul field Latitude dan Longitude.
Penyimpanan Koordinat	Sistem menerima input angka desimal koordinat dan menampilkannya sebagai link/map embed di detail trip.	Titik koordinat tersimpan dan dapat dirender ulang ke dalam format peta (opsional).
D. Time Tracking: Kedisiplinan Waktu (On Time / Terlambat)
Membandingkan waktu eksekusi aktual dengan waktu yang direncanakan untuk melihat tingkat keterlambatan.

Nama Fitur	Kebutuhan & Perilaku Sistem	Kriteria Penerimaan (Acceptance Criteria)
Mulai Aktivitas/Trip	Saat tombol "Mulai" ditekan, sistem mencatat timestamp aktual dan membandingkannya dengan Planned Start Time.	Sistem menampilkan label On Time atau Terlambat (X menit/jam).
Selesai Aktivitas/Trip	Saat tombol "Selesai" ditekan, sistem mencatat timestamp aktual dan membandingkannya dengan Planned End Time.	Status penyelesaian (Tepat Waktu/Lebih Cepat/Terlambat) direkam dan ditampilkan di riwayat trip.
3. Alur Pengguna (User Journey)
Skenario 1: Menyelesaikan Aktivitas (Flow Realita Budget & Time Tracking)

Pengguna membuka detail Trip dan memilih salah satu Aktivitas yang sedang berjalan.

Pengguna menekan tombol "Selesaikan Aktivitas".

Sistem mendeteksi waktu saat ini (timestamp). Jika melewati batas waktu rencana, sistem memberi flag peringatan "Terlambat".

Muncul Pop-up Modal mewajibkan pengguna mengisi form "Pengeluaran Aktual (Realita Budget)".

Pengguna memasukkan nominal (bisa Rp 0 jika gratis) dan menyimpan.

Status aktivitas berubah menjadi Selesai, waktu aktual tercatat, dan total pengeluaran trip ter-update.

Skenario 2: Menggunakan Pengeluaran Mendadak

Di tengah trip, ban kendaraan bocor. Ini tidak ada di daftar aktivitas.

Pengguna menekan tombol "Pengeluaran Mendadak" di dashboard trip.

Pengguna mengisi: Nama Pengeluaran (Tambal Ban), Nominal (Rp 20.000), dan Keterangan (opsional).

Biaya tersebut langsung ditambahkan ke kalkulasi total Realita Budget trip tersebut.

4. Dampak pada Struktur Database (Panduan Backend)
Untuk mengakomodasi fitur di atas, berikut adalah modifikasi tabel yang perlu disiapkan:

Tabel trips:

Tambah share_code (String, Unique)

Tambah plan_budget (Decimal/Integer)

Tambah latitude (Decimal/String, Nullable)

Tambah longitude (Decimal/String, Nullable)

Tambah actual_start_time & actual_end_time (Timestamp, Nullable)

Tabel trip_users (Pivot untuk Join Trip):

trip_id, user_id, role (owner/participant)

Tabel activities:

Tambah actual_cost (Decimal/Integer, default 0)

Tambah actual_start_time & actual_end_time (Timestamp, Nullable)

Tabel sudden_expenses (Tabel Baru):

id, trip_id, name, amount, created_at (Untuk mencatat pengeluaran mendadak yang tidak terikat pada tabel activities).

Rancang skema database lengkapnya?

Ya

buatkan dalam file berformat .md

Your MD file is ready.
Ikon MD
PRD_Fitur_Tambahan_Manajemen_Trip
 MD 
Buka

Dokumen PRD tersebut sudah saya format ke dalam bentuk Markdown (.md). Di dalamnya sudah mencakup detail kebutuhan fitur, alur pengguna, serta panduan skema dan relasi database untuk tabel trips, trip_users, activities, dan sudden_expenses yang dapat langsung Anda implementasikan ke dalam model dan struktur backend Anda. Silakan unduh file tersebut. Jika ada bagian logika yang ingin didiskusikan lebih lanjut, beri tahu saya.

Saya sudah memahami struktur proyek. Saya akan menanyakan beberapa hal untuk memastikan desain yang tepat.

Pertanyaan pertama: Untuk fitur Sudden Expenses (Pengeluaran Mendadak), bagaimana pengguna seharusnya menambahkannya?

<system-note> HARD-GATE active: do not write any code until the user approves the design. </system-note>

Berdasarkan rancangan Product Requirements Document (PRD) yang telah disusun, penambahan fitur Pengeluaran Mendadak (Sudden Expenses) dirancang agar sesederhana dan secepat mungkin untuk diakses saat pengguna sedang di lapangan.  
MD

Mengingat fokus Anda pada pengembangan backend dan pengalaman integrasi dengan frontend mobile, berikut adalah alur desain interaksi dan logika sistemnya:

1. Sisi Interaksi Pengguna (UI/UX)
Titik Akses: Pengguna dapat mengakses fitur ini melalui sebuah tombol khusus (misalnya berbentuk Floating Action Button atau tombol statis) yang diletakkan langsung di dalam halaman Dashboard Detail Trip.  
MD

Form Input: Ketika tombol ditekan, sistem akan memunculkan Pop-up Modal atau Bottom Sheet yang berisi tiga kolom input:

Nama Pengeluaran (Teks - Wajib diisi, misal: "Tambal Ban").  
MD

Nominal (Angka - Wajib diisi, misal: Rp 20.000).  
MD

Keterangan (Teks panjang - Opsional).  
MD

2. Logika Sistem (Backend)
Endpoint: Saat form disubmit, request dikirim ke endpoint khusus (contoh rancangan: POST /trips/{trip_id}/sudden-expenses).

Penyimpanan & Kalkulasi: Data akan disimpan ke dalam tabel baru yaitu sudden_expenses. Setelah data berhasil disimpan, sistem di sisi backend (menggunakan pola Observer atau logika Controller pada kerangka kerja seperti Laravel atau CodeIgniter) akan langsung menjumlahkan nominal ini ke total Realita Budget.  
MD
+ 1

Dampak Anggaran: Secara instan, total kalkulasi Realita Budget untuk trip tersebut bertambah, dan sisa Plan Budget akan otomatis terpotong.  
MD

Desain ini memastikan pengguna tidak perlu mengubah rencana aktivitas yang sudah ada, melainkan cukup mencatat kejadian tak terduga secara terpisah.

Apakah Anda ingin agar sistem memberikan notifikasi atau flag peringatan khusus jika penambahan "Pengeluaran Mendadak" ini membuat total Realita Budget melebihi Plan Budget?

buatkan prd nya

Berikut adalah dokumen Product Requirements Document (PRD) lengkap untuk fitur tambahan Manajemen Trip Anda, yang disusun beserta detail interaksi dan panduan struktur database:

Product Requirements Document (PRD): Fitur Tambahan Manajemen Trip
1. Tujuan Utama
Memperluas kapabilitas aplikasi manajemen trip dengan menambahkan fitur kolaborasi tim, pelacakan finansial komprehensif, penandaan lokasi berbasis koordinat, dan sistem pemantauan kedisiplinan waktu eksekusi aktivitas.

2. Detail Kebutuhan Fitur (Feature Requirements)
A. Kolaborasi: Share Code & Join Trip
Fitur ini ditujukan agar pengguna dapat bergabung ke dalam trip yang sudah dibuat oleh pengguna lain melalui kode unik, sehingga menghindari duplikasi pembuatan jadwal.

Nama Fitur	Kebutuhan & Perilaku Sistem	Kriteria Penerimaan (Acceptance Criteria)
Share Code	Sistem men-generate kode unik (misal: 6 digit alfanumerik acak) secara otomatis saat trip dibuat.	Kode unik tampil di halaman Dashboard Detail Trip dilengkapi dengan tombol Copy to Clipboard.
Menu Join Trip	Penambahan akses menu baru di Sidebar Dashboard, diletakkan berdekatan dengan menu Pengaturan.	Pengguna dapat melihat menu "Join Trip" secara jelas dan dapat diklik untuk membuka form.
Form Join Trip	Berupa Modal/Pop-up atau halaman sederhana dengan satu input teks wajib untuk memasukkan Share Code.	Jika valid, pengguna otomatis terdaftar sebagai partisipan. Jika tidak valid/kadaluarsa, sistem menampilkan pesan error.
B. Manajemen Anggaran: Plan vs Realita & Pengeluaran Mendadak
Fitur ini bertujuan membandingkan anggaran awal dengan biaya aktual yang terjadi selama perjalanan.

Nama Fitur	Kebutuhan & Perilaku Sistem	Kriteria Penerimaan (Acceptance Criteria)
Plan Budget	Field input nominal pada saat pembuatan trip baru.	Terdapat kolom input Plan Budget di dalam form Create Trip.
Realita Budget	Form validasi saat pengguna menekan tombol "Selesaikan Aktivitas".	Status aktivitas tidak dapat diubah menjadi Selesai jika form nominal pengeluaran aktual (Realita Budget) belum diisi (bisa diisi 0 jika gratis).
Pengeluaran Mendadak	Tombol khusus di Dashboard Detail Trip (misal: Floating Action Button) untuk mencatat kejadian tak terduga.	Sistem menyediakan form (Nama Pengeluaran, Nominal, Keterangan). Saat disimpan, nominal langsung menambah total Realita Budget dan memotong sisa Plan Budget.
C. Penanda Lokasi
Memungkinkan penyelenggara trip untuk menyematkan titik koordinat spesifik lokasi tujuan.

Nama Fitur	Kebutuhan & Perilaku Sistem	Kriteria Penerimaan (Acceptance Criteria)
Opsi Lokasi Trip	Terdapat Toggle/Checkbox "Tambahkan Lokasi" pada form pembuatan Trip.	Jika toggle diaktifkan, muncul dua field tambahan: Latitude dan Longitude.
Penyimpanan Koordinat	Menyimpan data desimal garis lintang dan bujur.	Sistem merender koordinat tersebut menjadi tautan yang bisa diklik atau embed peta di Dashboard Detail Trip.
D. Time Tracking: Kedisiplinan Waktu
Sistem untuk memantau seberapa akurat pelaksanaan trip dibandingkan dengan rencana waktu awal.

Nama Fitur	Kebutuhan & Perilaku Sistem	Kriteria Penerimaan (Acceptance Criteria)
Mulai Aktivitas	Sistem mengambil timestamp aktual saat tombol "Mulai" ditekan dan membandingkannya dengan rencana awal.	UI menampilkan indikator/label On Time atau Terlambat (X menit/jam).
Selesaikan Aktivitas	Sistem mengambil timestamp aktual saat tombol "Selesai" ditekan.	Sistem menyimpan durasi aktual dan status penyelesaian ke dalam riwayat perjalanan.
3. Alur Pengguna (User Journey)
Skenario 1: Bergabung dengan Trip (Join Trip)

Pengguna A (Pembuat) menyalin Share Code dari detail trip miliknya dan membagikannya ke Pengguna B.

Pengguna B membuka aplikasi, membuka Sidebar Dashboard, dan mengklik "Join Trip".

Pengguna B memasukkan Share Code ke dalam pop-up modal dan menekan Submit.

Sistem memvalidasi kode. Jika sukses, trip tersebut otomatis muncul di daftar trip Pengguna B dengan role sebagai Partisipan.

Skenario 2: Menyelesaikan Aktivitas & Input Realita Budget

Pengguna membuka detail Trip dan melihat daftar Aktivitas.

Pengguna menekan tombol "Selesaikan Aktivitas" pada aktivitas yang sedang berjalan.

Muncul Modal Pop-up yang mewajibkan input "Pengeluaran Aktual" (Realita Budget).

Pengguna memasukkan nominal.

Sistem mengubah status aktivitas menjadi Selesai, mencatat timestamp untuk mendeteksi On Time/Terlambat, dan menjumlahkan nominal tersebut ke total pengeluaran trip.

Skenario 3: Input Pengeluaran Mendadak

Terjadi pengeluaran di luar rencana (misal: biaya parkir tak terduga).

Pengguna menekan tombol "Tambah Pengeluaran Mendadak" di dalam halaman detail trip.

Pengguna mengisi form: Nama (Parkir), Nominal (Rp 10.000), dan Keterangan (Opsional).

Data tersimpan dan sistem backend otomatis menjumlahkan Rp 10.000 ke total Realita Budget trip tanpa mengganggu daftar aktivitas.

4. Struktur Database (Panduan Backend)
Berikut adalah modifikasi Skema Data Definition Language (DDL) atau Migration yang diperlukan pada rancangan database relasional:

Tabel trips (Modifikasi)
Penambahan kolom untuk budgeting, share code, dan lokasi.

share_code (VARCHAR, Unique, Indexed) -> Di-generate otomatis oleh sistem (Observer/Model Event).

plan_budget (DECIMAL/INT, Default 0)

latitude (DECIMAL, Nullable)

longitude (DECIMAL, Nullable)

actual_start_time (TIMESTAMP, Nullable)

actual_end_time (TIMESTAMP, Nullable)

Tabel trip_users (Tabel Pivot Baru)
Untuk mengakomodasi fitur Join Trip / Share Code.

trip_id (Foreign Key -> trips.id)

user_id (Foreign Key -> users.id)

role (ENUM: 'owner', 'participant')

Tabel activities (Modifikasi)
Penambahan pencatatan anggaran riil dan waktu pelaksanaan riil per aktivitas.

actual_cost (DECIMAL/INT, Default 0) -> Terisi dari Realita Budget.

actual_start_time (TIMESTAMP, Nullable)

actual_end_time (TIMESTAMP, Nullable)

Tabel sudden_expenses (Tabel Baru)
Untuk mencatat pengeluaran mendadak yang tidak terikat pada tabel aktivitas.

id (Primary Key)

trip_id (Foreign Key -> trips.id)

name (VARCHAR) -> Nama pengeluaran mendadak.

amount (DECIMAL/INT) -> Nominal biaya.

description (TEXT, Nullable) -> Keterangan tambahan.

created_at, updated_at (Timestamps)

Apakah Anda ingin agar sistem memberikan notifikasi atau flag peringatan khusus jika penambahan "Pengeluaran Mendadak" ini membuat total Realita Budget melebihi Plan Budget?

ya

Baik, fitur peringatan (alert/flag) over-budget akan sangat membantu pengguna untuk lebih sadar terhadap kondisi keuangan trip mereka.

Berikut adalah versi pembaruan dari PRD, di mana saya telah menambahkan logika peringatan pada bagian Manajemen Anggaran dan penyesuaian pada Alur Pengguna serta respons Backend.

Product Requirements Document (PRD): Fitur Tambahan Manajemen Trip (Update)
1. Tujuan Utama
Memperluas kapabilitas aplikasi manajemen trip dengan menambahkan fitur kolaborasi tim, pelacakan finansial komprehensif (beserta sistem peringatan over-budget), penandaan lokasi berbasis koordinat, dan sistem pemantauan kedisiplinan waktu eksekusi aktivitas.

2. Detail Kebutuhan Fitur (Feature Requirements)
A. Kolaborasi: Share Code & Join Trip
Nama Fitur	Kebutuhan & Perilaku Sistem	Kriteria Penerimaan (Acceptance Criteria)
Share Code	Sistem men-generate kode unik (misal: 6 digit alfanumerik) saat trip dibuat.	Kode unik tampil di halaman detail trip dilengkapi tombol Copy to Clipboard.
Menu Join Trip	Penambahan akses menu baru di Sidebar Dashboard, diletakkan berdekatan dengan menu Pengaturan.	Pengguna dapat melihat menu "Join Trip" secara jelas dan dapat diklik.
Form Join Trip	Halaman/Modal sederhana dengan satu input teks wajib untuk memasukkan Share Code.	Jika valid, pengguna terdaftar sebagai partisipan. Jika tidak, sistem menampilkan pesan error.
B. Manajemen Anggaran: Plan vs Realita & Pengeluaran Mendadak (Updated)
Nama Fitur	Kebutuhan & Perilaku Sistem	Kriteria Penerimaan (Acceptance Criteria)
Plan Budget	Field input nominal pada saat pembuatan trip baru.	Terdapat kolom input Plan Budget di dalam form Create Trip.
Realita Budget	Form validasi saat pengguna menekan tombol "Selesaikan Aktivitas".	Status aktivitas tidak dapat diubah menjadi Selesai sebelum nominal diisi.
Pengeluaran Mendadak	Tombol khusus di Dashboard Detail Trip untuk mencatat kejadian tak terduga.	Sistem menyediakan form (Nama, Nominal, Keterangan). Saat disimpan, nominal menambah total Realita Budget.
Over-Budget Alert ✨	Sistem mendeteksi secara real-time jika total Realita Budget (Aktivitas + Mendadak) > Plan Budget.	Muncul warning banner (misal: warna merah) di Dashboard Trip dan pop-up alert peringatan saat pengguna mensubmit pengeluaran yang memicu over-budget.
C. Penanda Lokasi (Latitude & Longitude)
Nama Fitur	Kebutuhan & Perilaku Sistem	Kriteria Penerimaan (Acceptance Criteria)
Opsi Lokasi Trip	Toggle/Checkbox "Tambahkan Lokasi" pada form pembuatan Trip.	Jika diaktifkan, muncul field Latitude dan Longitude.
Penyimpanan Koordinat	Menyimpan data desimal garis lintang dan bujur.	Sistem merender koordinat menjadi tautan atau embed peta di detail trip.
D. Time Tracking: Kedisiplinan Waktu
Nama Fitur	Kebutuhan & Perilaku Sistem	Kriteria Penerimaan (Acceptance Criteria)
Mulai Aktivitas	Sistem membandingkan timestamp aktual dengan rencana awal.	UI menampilkan indikator/label On Time atau Terlambat (X menit/jam).
Selesaikan Aktivitas	Sistem mencatat timestamp selesai.	Sistem menyimpan durasi aktual dan status penyelesaian di riwayat perjalanan.
3. Alur Pengguna (User Journey)
Skenario: Input Pengeluaran Mendadak yang Memicu Over-Budget

Pengguna memiliki Plan Budget Rp 500.000. Saat ini total Realita Budget sudah mencapai Rp 450.000 (sisa Rp 50.000).

Terjadi pengeluaran tak terduga. Pengguna menekan tombol "Tambah Pengeluaran Mendadak".

Pengguna mengisi: Nama (Beli Jas Hujan), Nominal (Rp 75.000).

Saat pengguna menekan Simpan, sistem mendeteksi bahwa total baru (Rp 525.000) akan melebihi Plan Budget (Rp 500.000).

UI di mobile menampilkan Dialog Alert: "Perhatian: Pengeluaran ini membuat total biaya trip Anda melebihi rencana anggaran sebesar Rp 25.000. Lanjutkan?"

Jika pengguna memilih "Lanjutkan", data tersimpan.

Halaman Dashboard Detail Trip kini menampilkan banner/flag peringatan berwarna merah yang mengindikasikan status Over-Budget.

4. Struktur Database & Logika API (Panduan Backend)
Struktur tabel (trips, trip_users, activities, sudden_expenses) tetap sama seperti rancangan sebelumnya. Namun, ada penambahan logika pada respons API (Controller):

API Response Logic (is_overbudget):
Anda tidak perlu menambahkan kolom is_overbudget di database karena ini adalah data dinamis (derived data). Di sisi backend (misalnya pada fungsi Resource/Transformer yang mengirim data trip ke frontend), tambahkan logika kalkulasi otomatis:

JSON
// Contoh struktur JSON balikan dari Backend ke Mobile/Frontend
{
  "trip_id": 1,
  "plan_budget": 500000,
  "total_realita_budget": 525000,
  "is_overbudget": true,
  "overbudget_amount": 25000
}
Dengan begitu, frontend (Android/Mobile) hanya perlu membaca boolean is_overbudget untuk memunculkan banner merah atau flag peringatan.

buatkan dalam bentuk .md

Your MD file is ready.
Ikon MD
PRD_Fitur_Tambahan_Manajemen_Trip_Update
 MD 
Buka

Saya telah membuat ulang dokumen PRD tersebut dengan menyertakan pembaruan fitur Over-Budget Alert dan menyimpannya dalam format Markdown. Silakan merujuk pada file "PRD_Fitur_Tambahan_Manajemen_Trip_Update.md" untuk melihat keseluruhan struktur desain beserta panduan backend-nya.




Gemini adalah AI dan dapat melakukan kesalahan.

# Product Requirements Document (PRD): Fitur Tambahan Manajemen Trip (Update)

## 1. Tujuan Utama
Memperluas kapabilitas aplikasi manajemen trip dengan menambahkan fitur kolaborasi tim, pelacakan finansial komprehensif (beserta sistem peringatan *over-budget*), penandaan lokasi berbasis koordinat, dan sistem pemantauan kedisiplinan waktu eksekusi aktivitas.

---

## 2. Detail Kebutuhan Fitur (Feature Requirements)

### A. Kolaborasi: Share Code & Join Trip
| Nama Fitur | Kebutuhan & Perilaku Sistem | Kriteria Penerimaan (Acceptance Criteria) |
| :--- | :--- | :--- |
| **Share Code** | Sistem men-*generate* kode unik (misal: 6 digit alfanumerik) saat trip dibuat. | Kode unik tampil di halaman detail trip dilengkapi tombol *Copy to Clipboard*. |
| **Menu Join Trip** | Penambahan akses menu baru di *Sidebar Dashboard*, diletakkan berdekatan dengan menu *Pengaturan*. | Pengguna dapat melihat menu "Join Trip" secara jelas dan dapat diklik. |
| **Form Join Trip** | Halaman/Modal sederhana dengan satu input teks wajib untuk memasukkan *Share Code*. | Jika valid, pengguna terdaftar sebagai partisipan. Jika tidak, sistem menampilkan pesan *error*. |

### B. Manajemen Anggaran: Plan vs Realita & Pengeluaran Mendadak (Updated)
| Nama Fitur | Kebutuhan & Perilaku Sistem | Kriteria Penerimaan (Acceptance Criteria) |
| :--- | :--- | :--- |
| **Plan Budget** | *Field* input nominal pada saat pembuatan trip baru. | Terdapat kolom input *Plan Budget* di dalam form *Create Trip*. |
| **Realita Budget** | Form validasi saat pengguna menekan tombol "Selesaikan Aktivitas". | Status aktivitas tidak dapat diubah menjadi *Selesai* sebelum nominal diisi. |
| **Pengeluaran Mendadak** | Tombol khusus di *Dashboard Detail Trip* untuk mencatat kejadian tak terduga. | Sistem menyediakan form (Nama, Nominal, Keterangan). Saat disimpan, nominal menambah total *Realita Budget*. |
| **Over-Budget Alert** ✨ | Sistem mendeteksi secara *real-time* jika total *Realita Budget* (Aktivitas + Mendadak) > *Plan Budget*. | Muncul *warning banner* (misal: warna merah) di *Dashboard Trip* dan *pop-up alert* peringatan saat pengguna mensubmit pengeluaran yang memicu *over-budget*. |

### C. Penanda Lokasi (Latitude & Longitude)
| Nama Fitur | Kebutuhan & Perilaku Sistem | Kriteria Penerimaan (Acceptance Criteria) |
| :--- | :--- | :--- |
| **Opsi Lokasi Trip** | *Toggle/Checkbox* "Tambahkan Lokasi" pada form pembuatan Trip. | Jika diaktifkan, muncul field *Latitude* dan *Longitude*. |
| **Penyimpanan Koordinat** | Menyimpan data desimal garis lintang dan bujur. | Sistem merender koordinat menjadi tautan atau *embed* peta di detail trip. |

### D. Time Tracking: Kedisiplinan Waktu
| Nama Fitur | Kebutuhan & Perilaku Sistem | Kriteria Penerimaan (Acceptance Criteria) |
| :--- | :--- | :--- |
| **Mulai Aktivitas** | Sistem membandingkan *timestamp* aktual dengan rencana awal. | UI menampilkan indikator/label **On Time** atau **Terlambat (X menit/jam)**. |
| **Selesaikan Aktivitas** | Sistem mencatat *timestamp* selesai. | Sistem menyimpan durasi aktual dan status penyelesaian di riwayat perjalanan. |

---

## 3. Alur Pengguna (User Journey)

**Skenario: Input Pengeluaran Mendadak yang Memicu Over-Budget**
1. Pengguna memiliki *Plan Budget* Rp 500.000. Saat ini total *Realita Budget* sudah mencapai Rp 450.000 (sisa Rp 50.000).
2. Terjadi pengeluaran tak terduga. Pengguna menekan tombol **"Tambah Pengeluaran Mendadak"**.
3. Pengguna mengisi: Nama (Beli Jas Hujan), Nominal (Rp 75.000).
4. Saat pengguna menekan **Simpan**, sistem mendeteksi bahwa total baru (Rp 525.000) akan melebihi *Plan Budget* (Rp 500.000).
5. UI di *mobile* menampilkan *Dialog Alert*: *"Perhatian: Pengeluaran ini membuat total biaya trip Anda melebihi rencana anggaran sebesar Rp 25.000. Lanjutkan?"*
6. Jika pengguna memilih "Lanjutkan", data tersimpan.
7. Halaman *Dashboard Detail Trip* kini menampilkan *banner/flag* peringatan berwarna merah yang mengindikasikan status **Over-Budget**.

---

## 4. Struktur Database & Logika API (Panduan Backend)

Struktur tabel (`trips`, `trip_users`, `activities`, `sudden_expenses`) tetap sama seperti rancangan sebelumnya. Namun, ada penambahan logika pada respons API (*Controller*):

*   **API Response Logic (`is_overbudget`):**
    Anda tidak perlu menambahkan kolom `is_overbudget` di *database* karena ini adalah data dinamis (derived data). Di sisi *backend* (misalnya pada fungsi *Resource/Transformer* yang mengirim data trip ke *frontend*), tambahkan logika kalkulasi otomatis:
    
    ```json
    // Contoh struktur JSON balikan dari Backend ke Mobile/Frontend
    {
      "trip_id": 1,
      "plan_budget": 500000,
      "total_realita_budget": 525000,
      "is_overbudget": true,
      "overbudget_amount": 25000
    }
    ```
    Dengan begitu, *frontend* (Android/Mobile) hanya perlu membaca *boolean* `is_overbudget` untuk memunculkan *banner* merah atau *flag* peringatan.
PRD_Fitur_Tambahan_Manajemen_Trip_Update.md
Menampilkan PRD_Fitur_Tambahan_Manajemen_Trip_Update.md.