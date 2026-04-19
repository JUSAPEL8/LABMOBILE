# README — LabMob Movie App

**Project:** `labmob`  
**Fokus:** Movie App dengan API publik, cache offline, search, filter, dan loading shimmer  
**State Management:** Provider

## Deskripsi Singkat
LabMob Movie App adalah aplikasi Flutter yang menampilkan data film dari public API. Aplikasi ini dibuat untuk memenuhi tugas Mobile Development dengan fokus pada struktur kode yang rapi, offline readiness, error handling, search/filter, serta reusable widgets.

## Fitur Utama
- Mengambil data film dari public API.
- Menyimpan data terakhir ke cache agar tetap bisa dibuka saat offline.
- Search film berdasarkan judul, genre, deskripsi, dan tahun.
- Filter film berdasarkan kategori.
- Loading state dengan shimmer effect.
- Reusable widget untuk movie card, loading, empty state, dan error state.

## Tech Stack
- Flutter
- Provider
- HTTP
- SharedPreferences
- Connectivity Plus
- Shimmer

## Struktur Folder
- `models/` → model data film
- `services/` → API call dan cache
- `providers/` → state management
- `views/` → halaman UI
- `widgets/` → komponen UI yang dipakai ulang

## Alasan Menggunakan Provider
Provider dipilih karena sederhana, ringan, dan mudah dipahami. Dengan Provider, logika data bisa dipisahkan dari UI sehingga kode lebih rapi, mudah dirawat, dan lebih aman untuk penambahan fitur baru.

## Cara Menjalankan
```bash
flutter pub get
flutter run
```

## Catatan Implementasi
Jika internet tidak tersedia, aplikasi akan menampilkan data terakhir yang berhasil disimpan. Jika cache belum ada, aplikasi menampilkan pesan error yang ramah pengguna.

## API yang Digunakan
SampleAPIs Movies (endpoint kategori film).
