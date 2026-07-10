# Troubleshooting Guide: Flutter Web (Vercel) & Laravel 11 API (Railway)

## 📌 Deskripsi Masalah
Aplikasi Flutter Web yang di-deploy di Vercel (`https://dntrip-lilac.vercel.app`) menampilkan error **"No Internet Connection"** (atau `XMLHttpRequest error`) saat mencoba melakukan request ke backend Laravel 11 di Railway (`https://dntrip-production.up.railway.app/api`). 

Berdasarkan inspeksi pada browser (Network tab), akar masalahnya bukanlah koneksi internet yang terputus, melainkan kombinasi dari **CORS Error** dan status **429 Too Many Requests** pada request *Preflight* (OPTIONS).

---

## 🔍 Analisis Akar Masalah (Root Cause)
1. **Preflight Request Gagal:** Saat Flutter Web mengirim POST request (misal: `/login`) beda domain, browser mengirim request `OPTIONS` terlebih dahulu. 
2. **Rate Limiting (429):** Backend Laravel memblokir request tersebut karena dianggap terlalu banyak (*rate limit* / throttle), sehingga merespons dengan status `429 Too Many Requests`.
3. **CORS Ditolak:** Karena request `OPTIONS` gagal mendapatkan response dengan header CORS yang valid, browser langsung memblokir request utama (XHR/Fetch) karena melanggar kebijakan keamanan (*Cross-Origin Resource Sharing*).
4. **Error Handling Flutter:** Flutter menerjemahkan pemblokiran oleh browser ini sebagai kegagalan jaringan umum, sehingga memunculkan pesan "No Internet Connection".

---

## 🛠️ Action Plan: Backend (Laravel 11 di Railway)

Karena backend terbukti berjalan normal (halaman welcome Laravel muncul), perbaikan berfokus pada perizinan asal request (CORS).

### Langkah 1: Publikasi Konfigurasi CORS
Pada Laravel 11, file `cors.php` disembunyikan secara default. Jalankan perintah ini di terminal proyek lokal Anda:
```bash
php artisan config:publish cors
```

### Langkah 2: Sesuaikan `config/cors.php`
Buka file `config/cors.php` yang baru saja dibuat, dan ubah konfigurasinya untuk secara eksplisit mengizinkan origin dari Vercel:
```php
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    
    'allowed_methods' => ['*'],
    
    // Ganti ini dengan URL Vercel aplikasi Anda
    'allowed_origins' => ['https://dntrip-lilac.vercel.app'], 
    
    'allowed_origins_patterns' => [],
    
    'allowed_headers' => ['*'],
    
    'exposed_headers' => [],
    
    'max_age' => 0,
    
    'supports_credentials' => true, // Wajib true jika menggunakan otentikasi
];
```

### Langkah 3: Deploy Ulang ke Railway
Setelah file disimpan:
1. Lakukan `git add .`, `git commit -m "Fix CORS configuration"`, lalu `git push`.
2. Tunggu proses *build* dan *deploy* di Railway selesai.

---

## 💻 Action Plan: Frontend (Flutter di Vercel)

### Langkah 1: Pastikan Base URL Akurat
Pastikan variabel Base URL di kode Flutter (atau file `.env` Vercel) diarahkan secara spesifik ke path `/api` milik Railway.
* **Salah:** `https://dntrip-production.up.railway.app/`
* **Benar:** `https://dntrip-production.up.railway.app/api`

Contoh endpoint untuk login harus menjadi: `https://dntrip-production.up.railway.app/api/login`

### Langkah 2: Tambahkan Header HTTP Standar
Pada fungsi HTTP request di Flutter (misalnya menggunakan package `http` atau `dio`), pastikan Anda selalu mengirimkan header ini agar Laravel merespons dengan format JSON yang benar saat terjadi error validasi:
```dart
headers: {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
}
```

---

## 🧪 Skenario Pengujian (Testing)

1. **Tes Backend Secara Terisolasi (Postman):**
   * Buka Postman / Insomnia / Thunder Client.
   * Lakukan request `POST` ke `https://dntrip-production.up.railway.app/api/login` dengan body/payload yang sesuai.
   * Pastikan response yang dikembalikan adalah JSON (sukses atau pesan error validasi), **bukan** halaman HTML atau error 500/404.

2. **Tes End-to-End (Browser):**
   * Buka aplikasi Vercel Anda (`https://dntrip-lilac.vercel.app`) di browser (Gunakan mode Incognito untuk menghindari cache).
   * Buka **Developer Tools (F12)** -> Tab **Network**.
   * Lakukan aksi Login.
   * Periksa apakah request `OPTIONS` sekarang berhasil (status 204/200) dan request `POST` berjalan dengan normal.