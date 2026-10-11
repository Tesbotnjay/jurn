# Panduan Penggunaan & Integrasi JurnFourteen App

## 1. Database Supabase Migration
Eksekusi SQL migration baru di Supabase SQL Editor:
- File: `D:\absensi jurn\jurnfourteen\supabase\migrations\002_division_tasks_and_drive.sql`
- Berisi skema untuk:
  1. Fitur Penugasan Divisi (`assignments`) + RLS & Realtime.
  2. Berbagi Link Google Drive antar Divisi (`drive_links`) + RLS & Realtime.
  3. Kolom `divisi` dan `is_koor` di tabel `members`.

## 2. Website Next.js (`jurnfourteen`)
Website tetap berfungsi 100% normal dengan Supabase backend yang sama. Tampilan sudah Responsive Web Design (RWD).

## 3. Aplikasi Android Flutter (`jurnfourteen_app`)
Lokasi: `D:\absensi jurn\jurnfourteen_app`

### Fitur yang Sudah Dibuat:
1. **Real-time Sync & Absensi**:
   - Terhubung langsung ke Supabase (`waptqzihambwhsqgtuzl.supabase.co`).
   - Melakukan presensi Hadir/Izin/Alpa secara real-time yang langsung tercermin di Website.
2. **Penugasan Anggota oleh Koor (Setiap Divisi)**:
   - Koor (Dokumentasi, Media, Berita, Korespondensi, Umum) bisa centang anggota divisinya.
   - Wajib melampirkan Judul Tugas & Deskripsi Instruksi agar anggota paham pekerjaannya.
   - Anggota melihat daftar tugas yang diberikan kepadanya beserta instruksinya.
3. **Berbagi Link Google Drive Lintas Divisi**:
   - Koor Dokumentasi / Koor lainnya bisa menaruh link Google Drive langsung di aplikasi (menggantikan kirim link via WA).
   - Koor Media & Koor Berita dapat langsung mengakses link tersebut untuk kebutuhan edit media & pembuatan caption.
4. **Ringan & Notifikasi Real-time**:
   - Menggunakan Flutter Material 3 Dark Theme yang sangat ringan dan responsif.
   - Menggunakan `supabase_flutter` Realtime Client + Local Notifications.

### Cara Build APK Android:
Buka terminal dan jalankan:
```bash
cd "D:\absensi jurn\jurnfourteen_app"
flutter build apk --release
```
File APK akan berada di `build/app/outputs/flutter-apk/app-release.apk`.
