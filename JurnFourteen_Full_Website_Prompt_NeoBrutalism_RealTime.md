# JurnFourteen Management System — Full Website Specification

## 1. Gambaran Umum

Buat sebuah website full-stack untuk ekstrakurikuler sekolah **JurnFourteen (Jurnalistik)**.

Website ini adalah sistem administrasi internal JurnFourteen yang digunakan untuk:

- Manajemen akun anggota
- Data anggota
- Pendaftaran anggota baru
- Broadcast/informasi kegiatan
- Konfirmasi kehadiran
- Pengajuan izin
- Pengajuan sakit
- Verifikasi kehadiran oleh sekretaris/pengurus
- Riwayat absensi
- Rekap kegiatan
- Export Excel
- Export PDF
- Notifikasi otomatis Telegram
- Pengumuman
- Dashboard statistik
- Activity log
- Halaman publik pengenalan JurnFourteen (tanpa login) — lihat Bagian 76
- Broadcast publik untuk event/pengumuman umum, terpisah dari broadcast internal anggota — lihat Bagian 7

Website harus benar-benar berfungsi sebagai aplikasi, bukan hanya desain/mockup frontend.

Bahasa seluruh interface: **Bahasa Indonesia**.

Brand: **JurnFourteen**  
Jenis organisasi: **Ekstrakurikuler Jurnalistik Sekolah**  
Tagline: **"Jurnalistik sekolah dalam satu sistem."**

---

# 2. Prinsip Utama Sistem

Alur utama sistem:

```text
ADMIN MEMBUAT KEGIATAN
        ↓
BROADCAST / INFORMASI MUNCUL
        ↓
ANGGOTA LOGIN
        ↓
ANGGOTA MEMILIH:
HADIR / IZIN / SAKIT
        ↓
DATA TERSIMPAN DI DATABASE
        ↓
STATUS: MENUNGGU VERIFIKASI
        ↓
SEKRETARIS/PENGURUS MEMERIKSA
        ↓
TERIMA / TOLAK
        ↓
STATUS FINAL
        ↓
MASUK REKAP KEHADIRAN
        ↓
EXPORT EXCEL / PDF
        ↓
OPSIONAL KIRIM REKAP KE TELEGRAM
```

Hal yang sangat penting:

**Anggota hanya memberikan respon kehadiran. Sekretaris/pengurus tetap menjadi pihak yang memverifikasi dan menentukan status final.**

Jika anggota memilih "Saya Hadir", jangan langsung dianggap hadir final.

Status awal:

`Menunggu Verifikasi`

Setelah sekretaris menerima:

`Hadir`

---

# 3. Role / Hak Akses

Buat sistem role-based access control.

## SUPER ADMIN

Akses penuh:

- Semua data anggota
- Semua akun
- Semua kegiatan
- Semua absensi
- Semua pengajuan
- Broadcast
- Pengumuman
- Laporan
- Export
- Pengaturan Telegram
- Pengaturan sistem
- Activity log

## ADMIN (KETUA UMUM / WAKIL KETUA)

Role ini dipakai oleh Ketua Umum dan Wakil Ketua JurnFourteen. Dapat:

- Mengelola anggota
- Membuat kegiatan
- Membuat broadcast
- Melihat absensi
- Memverifikasi kehadiran
- Memproses izin
- Memproses sakit
- Melihat laporan
- Export data

## PEMBINA

Pembina adalah guru pendamping ekstrakurikuler. Akses default:

- Melihat seluruh data anggota (read-only)
- Melihat seluruh kegiatan dan broadcast
- Melihat seluruh rekap dan statistik kehadiran
- Melihat activity log
- Export Excel/PDF

Pembina secara default **tidak** dapat:

- Mengubah pengaturan sistem
- Mengubah pengaturan Telegram
- Menghapus akun anggota

*(Catatan untuk AI pembuat website: batasan di atas adalah default yang disarankan dan boleh disesuaikan jika kebijakan sekolah berbeda, misalnya jika Pembina juga ingin ikut memverifikasi kehadiran sebagai approval kedua.)*

## SEKRETARIS

Fokus pada administrasi:

- Melihat data anggota
- Membuat/mengelola kegiatan
- Melihat respon kehadiran
- Memverifikasi hadir
- Memverifikasi izin
- Memverifikasi sakit
- Melihat rekap
- Export Excel
- Export PDF
- Mengirim rekap ke Telegram

## ANGGOTA

Hanya dapat:

- Login
- Melihat profil sendiri
- Mengubah data pribadi yang diizinkan
- Mengganti password
- Melihat broadcast
- Melihat kegiatan
- Konfirmasi hadir
- Mengajukan izin
- Mengajukan sakit
- Melihat status pengajuan
- Melihat riwayat kehadiran sendiri
- Melihat pengumuman

Anggota tidak boleh melihat data anggota lain.

Anggota tidak boleh mengakses halaman admin.

## Jabatan vs Role Akses (penting)

Pisahkan dua konsep berbeda dalam sistem:

- **Jabatan** — gelar struktural organisasi JurnFourteen, contoh: Pembina, Ketua Umum, Wakil Ketua, Sekretaris, Bendahara, Koordinator Liputan, Koordinator Desain/Multimedia, Anggota.
- **Role Akses** — level hak akses teknis di sistem: Super Admin, Admin, Sekretaris, Anggota.

Setiap akun memiliki kedua field ini secara terpisah. Saat Super Admin membuat/mengedit akun, sistem menyarankan Role Akses berdasarkan Jabatan yang dipilih, tapi Super Admin tetap bisa mengubahnya secara manual.

Mapping default yang disarankan:

```text
Pembina            → Role Akses: Pembina
Ketua Umum         → Role Akses: Admin
Wakil Ketua        → Role Akses: Admin
Sekretaris         → Role Akses: Sekretaris
Bendahara          → Role Akses: Anggota
Koordinator lain   → Role Akses: Anggota
Anggota biasa      → Role Akses: Anggota
```

Halaman **Data Anggota** di dashboard wajib menampilkan kolom Jabatan untuk setiap anggota, sehingga Super Admin dapat melihat dalam satu daftar siapa saja pengurus beserta jabatannya masing-masing, dan mengubah Role Akses dari daftar yang sama.

---

# 4. Sistem Login dan Akun Anggota

Setiap anggota harus mempunyai akun sendiri.

Admin dapat membuat akun secara manual.

Data akun:

- Nama lengkap
- Username
- Password
- NIS/NISN
- Kelas
- Nomor HP
- Foto profil
- Jabatan
- Status anggota
- Tanggal bergabung
- Bio singkat (opsional, untuk ditampilkan di halaman publik)
- Link Linktree/sosial media (opsional, berupa URL yang bisa diklik, dibuka di tab baru)
- Tampilkan di halaman publik? (Ya/Tidak) — toggle privasi, default **Tidak**. Lihat Bagian 76 untuk detail.

Opsi Jabatan (dapat disesuaikan pengurus):

```text
Pembina
Ketua Umum
Wakil Ketua
Sekretaris
Bendahara
Koordinator Liputan
Koordinator Desain/Multimedia
Anggota
```

Status akun:

- Aktif
- Nonaktif
- Menunggu verifikasi

Password:

- Harus di-hash
- Jangan pernah menyimpan password plaintext
- Anggota disarankan mengganti password saat pertama kali login

Admin dapat:

- Membuat akun
- Mengedit akun
- Menonaktifkan akun
- Mengaktifkan akun
- Reset password
- Melihat detail anggota

---

# 5. Pendaftaran Anggota Baru

Buat halaman:

`/register`

Judul:

**Daftar Anggota JurnFourteen**

Form:

- Nama lengkap
- NIS/NISN
- Kelas
- Nomor HP
- Username
- Password
- Konfirmasi password
- Alasan ingin bergabung
- Foto

Setelah submit:

Status:

`Menunggu Verifikasi`

Data masuk database.

Bot Telegram otomatis mengirim notifikasi ke grup pengurus/sekretaris.

Contoh:

```text
🆕 PENDAFTARAN ANGGOTA BARU

Nama:
M. Walid

Kelas:
12-2

No. HP:
xxxxxxxx

Alasan:
Tertarik dengan jurnalistik.

Status:
🟡 Menunggu verifikasi

Silakan buka dashboard JurnFourteen untuk memproses pendaftaran.
```

Admin dapat:

`TERIMA`

atau

`TOLAK`

Jika diterima:

- Akun menjadi aktif
- Anggota dapat login
- Tanggal bergabung dicatat

Jika ditolak:

- Status pendaftaran menjadi ditolak
- Akun tidak dapat digunakan

---

# 6. Dashboard Anggota

Setelah login, anggota melihat dashboard pribadi.

Contoh:

```text
Halo, Walid 👋

Anggota JurnFourteen
Kelas 12-2
```

Statistik:

- Hadir
- Izin
- Sakit
- Alfa
- Persentase kehadiran

Menu:

- Dashboard
- Profil Saya
- Kegiatan
- Absensi
- Ajukan Izin
- Ajukan Sakit
- Riwayat Kehadiran
- Pengumuman
- Logout

Jika ada kegiatan aktif, tampilkan card besar:

```text
📢 RAPAT JURNFOURTEEN

Hari ini
15:30 WITA
Ruang Jurnalistik

Apakah kamu akan hadir?

[ SAYA HADIR ]
[ SAYA IZIN ]
[ SAYA SAKIT ]
```

---

# 7. Broadcast / Informasi Kegiatan

Ini adalah salah satu fitur utama.

Di menu admin:

`Broadcast`

Pengurus dapat membuat broadcast secara custom.

Form:

- Judul
- Isi informasi
- Tanggal
- Jam
- Lokasi
- Target penerima
- Prioritas
- Lampiran opsional
- Apakah membutuhkan konfirmasi kehadiran?
- Apakah dikirim ke Telegram?

Target:

- Semua anggota
- Kelas tertentu
- Pengurus
- Anggota tertentu

Tambahkan juga field:

- **Visibilitas**: Internal (Anggota) / Publik

## Dua Jenis Broadcast: Internal vs Publik

**Broadcast Internal**
- Hanya tampil untuk anggota yang login
- Mengikuti aturan Target di atas
- Dapat meminta konfirmasi kehadiran (lihat Bagian 8)
- Dapat dikirim ke grup Telegram internal pengurus

**Broadcast Publik**
- Tampil di halaman publik `/pengumuman` tanpa perlu login (lihat Bagian 76), misalnya untuk info event, prestasi, liputan, atau open recruitment
- Tidak memiliki opsi konfirmasi kehadiran (pengunjung publik bukan anggota terdaftar)
- Opsional dikirim ke channel Telegram publik (terpisah dari grup internal pengurus, jika sekolah punya)
- Tampil terurut dari yang terbaru

Field Visibilitas wajib dipilih saat membuat broadcast dan menentukan halaman mana yang menampilkannya. Satu broadcast hanya boleh berstatus salah satu: Internal ATAU Publik, tidak keduanya sekaligus.

Contoh:

```text
📢 RAPAT JURNFOURTEEN

Hari ini akan dilaksanakan rapat JurnFourteen.

📅 Tanggal:
16 September 2026

⏰ Jam:
15:30 WITA

📍 Tempat:
Ruang Jurnalistik

📝 Keterangan:
Membahas persiapan kegiatan dokumentasi sekolah.

Diharapkan seluruh anggota hadir tepat waktu.
```

Broadcast muncul di:

- Dashboard anggota
- Halaman informasi
- Opsional Telegram

---

# 8. Broadcast dengan Konfirmasi Kehadiran

Saat membuat broadcast, admin dapat mengaktifkan:

`Membutuhkan konfirmasi kehadiran`

Jika aktif, anggota melihat:

```text
Apakah kamu akan hadir?

[ SAYA HADIR ]
[ SAYA IZIN ]
[ SAYA SAKIT ]
```

Jika tidak aktif, broadcast hanya menjadi informasi biasa.

---

# 9. Konfirmasi "SAYA HADIR"

Jika anggota memilih:

`SAYA HADIR`

Sistem mencatat:

- Member ID
- Kegiatan ID
- Tanggal
- Waktu konfirmasi
- Status

Status awal:

`Menunggu Verifikasi`

Jangan langsung menjadi `Hadir`.

Contoh di dashboard sekretaris:

```text
M. Walid
Kelas 12-2

Konfirmasi:
Hadir

Status:
🟡 Menunggu Verifikasi

Waktu:
15:12 WITA
```

Sekretaris dapat:

`✓ TERIMA`

atau

`✕ TOLAK`

Jika diterima:

`HADIR`

Jika ditolak:

`DITOLAK / TIDAK TERKONFIRMASI`

Sediakan kolom catatan jika ditolak.

---

# 10. Pengajuan Izin

Jika anggota memilih:

`SAYA IZIN`

Tampilkan form:

- Nama — otomatis
- Kelas — otomatis
- Tanggal
- Kegiatan
- Alasan izin
- Upload bukti opsional

Tombol:

`KIRIM PENGAJUAN IZIN`

Setelah dikirim:

Status:

`Menunggu Verifikasi`

Jangan langsung menjadi `IZIN` final.

Sekretaris memeriksa.

Tombol:

- Terima Izin
- Tolak

Jika diterima:

Status final:

`IZIN`

Data otomatis masuk rekap absensi kegiatan.

Jika ditolak:

Status:

`DITOLAK`

Sertakan catatan dari pengurus jika diperlukan.

---

# 11. Pengajuan Sakit

Jika anggota memilih:

`SAYA SAKIT`

Form:

- Nama — otomatis
- Kelas — otomatis
- Tanggal
- Kegiatan
- Keterangan sakit
- Upload bukti/surat jika diperlukan

Tombol:

`KIRIM PENGAJUAN SAKIT`

Status awal:

`Menunggu Verifikasi`

Sekretaris memeriksa.

Jika diterima:

`SAKIT`

Jika ditolak:

`DITOLAK`

Data yang disetujui otomatis masuk ke rekap absensi kegiatan.

---

# 12. Notifikasi Telegram

Integrasikan Telegram Bot API.

Tujuan utama:

- Grup pengurus JurnFourteen
- Chat pribadi sekretaris jika dikonfigurasi

Gunakan environment variables:

```text
TELEGRAM_BOT_TOKEN=
TELEGRAM_GROUP_CHAT_ID=
TELEGRAM_SECRETARY_CHAT_ID=
```

Jangan pernah menaruh token Telegram di frontend.

Arsitektur:

```text
Website
   ↓
Backend
   ↓
Database
   ↓
Telegram Notification Service
   ↓
Telegram Group / Secretary
```

---

# 13. Telegram: Pendaftaran Baru

Saat anggota baru mendaftar:

```text
🆕 PENDAFTARAN ANGGOTA BARU

👤 Nama:
M. Walid

🏫 Kelas:
12-2

📱 No. HP:
xxxxxxxx

📅 Tanggal daftar:
16 September 2026

⏳ Status:
Menunggu verifikasi

Silakan cek dashboard JurnFourteen.
```

---

# 14. Telegram: Konfirmasi Hadir

Ketika anggota memilih hadir:

```text
📋 KONFIRMASI KEHADIRAN

Kegiatan:
Rapat JurnFourteen

👤 Nama:
M. Walid

🏫 Kelas:
12-2

📅 Tanggal:
16 September 2026

⏰ Waktu konfirmasi:
15:12 WITA

Status:
🟡 Menunggu verifikasi sekretaris.
```

---

# 15. Telegram: Pengajuan Izin

```text
📝 PENGAJUAN IZIN BARU

👤 Nama:
M. Walid

🏫 Kelas:
12-2

📅 Tanggal:
16 September 2026

📌 Kegiatan:
Rapat JurnFourteen

📝 Alasan:
Ada keperluan keluarga.

⏳ Status:
Menunggu verifikasi.
```

---

# 16. Telegram: Pengajuan Sakit

```text
🤒 PENGAJUAN SAKIT BARU

👤 Nama:
M. Walid

🏫 Kelas:
12-2

📅 Tanggal:
16 September 2026

📌 Kegiatan:
Rapat JurnFourteen

📝 Keterangan:
Sedang sakit.

⏳ Status:
Menunggu verifikasi.
```

---

# 17. Telegram: Hasil Verifikasi

Jika diterima:

```text
✅ VERIFIKASI KEHADIRAN

Nama:
M. Walid

Kegiatan:
Rapat JurnFourteen

Status:
HADIR

Diverifikasi oleh:
Sekretaris JurnFourteen
```

Untuk izin:

```text
✅ IZIN DISETUJUI

Nama:
M. Walid

Kegiatan:
Rapat JurnFourteen

Tanggal:
16 September 2026

Status:
IZIN
```

Untuk sakit:

```text
✅ SAKIT DISETUJUI

Nama:
M. Walid

Kegiatan:
Rapat JurnFourteen

Tanggal:
16 September 2026

Status:
SAKIT
```

Jika ditolak:

```text
❌ PENGAJUAN DITOLAK

Nama:
M. Walid

Jenis:
Izin

Kegiatan:
Rapat JurnFourteen

Catatan:
[catatan pengurus]
```

---

# 18. Dashboard Verifikasi Sekretaris

Buat halaman:

`/attendance/verification`

Tampilan harus menjadi pusat kerja sekretaris.

Contoh:

```text
RAPAT JURNFOURTEEN
16 September 2026
15:30 WITA
Ruang Jurnalistik

Total anggota: 35
Sudah mengisi: 32
Menunggu verifikasi: 8
Hadir: 20
Izin: 3
Sakit: 1
Alfa: 0
Belum mengisi: 3
```

Tabel:

| Nama | Kelas | Respon | Status | Aksi |
|---|---|---|---|---|
| Walid | 12-2 | Hadir | Menunggu | Terima/Tolak |
| Aca | 11-1 | Izin | Menunggu | Terima/Tolak |
| Rian | 12-1 | Sakit | Menunggu | Terima/Tolak |

Sediakan:

`TERIMA`

`TOLAK`

`TERIMA SEMUA YANG HADIR`

Tetap berikan verifikasi individual.

---

# 19. Status Belum Mengisi

Jika anggota belum merespons:

`BELUM MENGISI`

Jangan otomatis dianggap hadir.

Setelah kegiatan selesai, sekretaris dapat menentukan status akhir jika diperlukan:

- Hadir
- Izin
- Sakit
- Alfa

Dengan demikian sekretaris memiliki kontrol akhir terhadap data resmi.

---

# 20. Batas Waktu Absensi

Admin dapat menentukan:

```text
Waktu mulai:
15:00

Waktu berakhir:
17:00
```

Setelah waktu berakhir:

- Anggota tidak dapat mengubah respon sembarangan
- Pengurus dapat membuka/menyesuaikan akses secara manual
- Semua perubahan setelah batas waktu dicatat di activity log

Sistem dapat menampilkan countdown jika relevan.

---

# 21. Sistem Absensi

Status final:

- HADIR
- IZIN
- SAKIT
- ALFA

Hubungan dengan respon:

```text
SAYA HADIR
↓
Menunggu Verifikasi
↓
Terima
↓
HADIR
```

```text
SAYA IZIN
↓
Menunggu Verifikasi
↓
Terima
↓
IZIN
```

```text
SAYA SAKIT
↓
Menunggu Verifikasi
↓
Terima
↓
SAKIT
```

Jika tidak mengisi:

`Belum Mengisi`

Setelah kegiatan selesai, pengurus dapat menentukan `ALFA` bila memang diperlukan.

---

# 22. Riwayat Kehadiran Anggota

Setiap anggota memiliki:

`Riwayat Kehadiran Saya`

Contoh:

```text
SEPTEMBER 2026

16 Sep
Rapat Redaksi
Hadir ✓

12 Sep
Dokumentasi Sekolah
Izin ✓

8 Sep
Rapat Mingguan
Hadir ✓

3 Sep
Pelatihan
Sakit ✓
```

Anggota tidak dapat mengubah riwayat yang sudah diverifikasi.

---

# 23. Rekap Kehadiran

Setelah verifikasi selesai:

```text
REKAP KEHADIRAN
RAPAT JURNFOURTEEN

Tanggal:
16 September 2026

Waktu:
15:30 WITA

Tempat:
Ruang Jurnalistik

Total anggota:
35

Hadir:
28

Izin:
3

Sakit:
2

Alfa:
2

Persentase kehadiran:
80%
```

Tabel:

| No | Nama | NIS/NISN | Kelas | Status | Waktu Konfirmasi | Waktu Verifikasi | Verifikator | Catatan |
|---|---|---|---|---|---|---|---|---|

---

# 24. Export Excel

Sediakan tombol:

`EXPORT EXCEL`

Buat file `.xlsx`.

Isi:

Header:

```text
JURNFOURTEEN
EKSTRAKURIKULER JURNALISTIK

REKAP KEHADIRAN KEGIATAN
```

Informasi:

- Nama kegiatan
- Tanggal
- Jam
- Lokasi

Tabel:

- No
- Nama
- NIS/NISN
- Kelas
- Status
- Waktu konfirmasi
- Waktu verifikasi
- Verifikator
- Catatan

Summary:

- Total anggota
- Hadir
- Izin
- Sakit
- Alfa
- Persentase kehadiran

File harus rapi dan siap digunakan sebagai dokumen administrasi sekolah.

---

# 25. Export PDF

Sediakan tombol:

`EXPORT PDF`

Format formal.

Header:

```text
JURNFOURTEEN
EKSTRAKURIKULER JURNALISTIK

REKAP KEHADIRAN KEGIATAN
```

Informasi:

Nama kegiatan:
Tanggal:
Waktu:
Tempat:

Tabel:

```text
No | Nama | Kelas | Status | Keterangan
```

Summary:

```text
Total Anggota:
Hadir:
Izin:
Sakit:
Alfa:
```

Bagian tanda tangan:

```text
Mengetahui,

Ketua JurnFourteen          Sekretaris JurnFourteen


(________________)          (________________)
```

PDF harus rapi, formal, mudah dicetak dan dapat menjadi bukti administrasi kehadiran.

---

# 26. Kirim Rekap ke Telegram

Setelah sekretaris selesai melakukan verifikasi:

Tombol:

`KIRIM REKAP KE TELEGRAM`

Bot mengirim:

```text
✅ REKAP KEHADIRAN

Kegiatan:
Rapat JurnFourteen

Tanggal:
16 September 2026

👥 Total:
35 anggota

✅ Hadir:
28

📝 Izin:
3

🤒 Sakit:
2

❌ Alfa:
2

📊 Persentase:
80%

Rekap lengkap tersedia di dashboard JurnFourteen.
```

Jika sistem memungkinkan, file Excel/PDF juga dapat dikirim ke grup Telegram sebagai dokumen.

---

# 27. Dashboard Admin

Tampilkan card statistik:

- Total Anggota
- Hadir Hari Ini
- Izin Hari Ini
- Sakit Hari Ini
- Alfa Hari Ini
- Pendaftar Baru
- Pengajuan Menunggu
- Kegiatan Aktif

Tambahkan grafik:

- Statistik kehadiran
- Anggota per kelas
- Statistik izin/sakit/alfa
- Persentase kehadiran
- Aktivitas kegiatan

---

# 28. Data Anggota

Halaman:

`/members`

Tabel:

- No
- Foto
- Nama
- NIS/NISN
- Kelas
- Username
- Jabatan
- Status
- Tanggal Bergabung
- Aksi

Fitur:

- Search
- Filter kelas
- Filter status
- Sort
- Detail
- Edit
- Nonaktifkan
- Reset password

Detail anggota:

- Profil
- Riwayat kehadiran
- Hadir
- Izin
- Sakit
- Alfa
- Persentase kehadiran
- Riwayat kegiatan

---

# 29. Manajemen Kegiatan

Halaman:

`/activities`

Admin dapat membuat:

- Nama kegiatan
- Deskripsi
- Tanggal
- Jam mulai
- Jam selesai
- Lokasi
- Status
- Apakah membutuhkan absensi
- Waktu mulai konfirmasi
- Waktu akhir konfirmasi

Status:

- Akan datang
- Aktif
- Selesai
- Dibatalkan

Setiap kegiatan memiliki absensi sendiri.

---

# 30. Pengumuman

Buat menu:

`Pengumuman`

Admin dapat membuat:

- Judul
- Isi
- Tanggal
- Lampiran
- Target penerima
- Prioritas

Pengumuman tampil di dashboard anggota.

---

# 31. Notification Center Website

Buat ikon notifikasi 🔔.

Contoh:

```text
🔔 Pengajuan izin Anda telah disetujui.

🔔 Ada kegiatan baru.

🔔 Broadcast baru dari pengurus.

🔔 Pengajuan sakit Anda telah diproses.
```

Anggota dapat menandai notifikasi sebagai sudah dibaca.

---

# 32. Activity Log

Catat aktivitas penting:

- Login
- Logout
- Membuat akun
- Mengedit anggota
- Menonaktifkan anggota
- Membuat kegiatan
- Membuat broadcast
- Konfirmasi hadir
- Pengajuan izin
- Pengajuan sakit
- Verifikasi hadir
- Menyetujui izin
- Menyetujui sakit
- Menolak pengajuan
- Export laporan
- Mengirim laporan ke Telegram

Simpan:

- User
- Aktivitas
- Waktu
- IP jika relevan
- Detail perubahan

---

# 33. Database

Gunakan database relasional seperti PostgreSQL atau MySQL.

Minimal tabel:

```text
users
members
activities
attendance
leave_requests
announcements
broadcasts
notifications
activity_logs
telegram_logs
```

Relasi harus menggunakan foreign key yang benar.

## attendance

Minimal:

```text
id
member_id
activity_id
response
final_status
submitted_at
verified_at
verified_by
note
created_at
updated_at
```

`response`:

- hadir
- izin
- sakit

`final_status`:

- pending
- hadir
- izin
- sakit
- alfa
- rejected

## leave_requests

```text
id
member_id
activity_id
type
date
reason
proof_file
status
admin_note
created_at
updated_at
verified_by
verified_at
```

`type`:

- izin
- sakit

`status`:

- pending
- approved
- rejected

---

# 34. Telegram Notification Service

Pisahkan service Telegram dari logic utama.

Contoh fungsi:

```text
sendNewMemberNotification()
sendAttendanceNotification()
sendLeaveNotification()
sendSickNotification()
sendApprovalNotification()
sendRejectionNotification()
sendBroadcastNotification()
sendAttendanceSummary()
sendFileToTelegram()
```

Jika Telegram gagal:

- Data utama tetap tersimpan
- Jangan membatalkan transaksi database hanya karena Telegram gagal
- Simpan error di `telegram_logs`
- Tampilkan status pengiriman kepada admin

Contoh:

```text
Database:
SUCCESS

Telegram:
FAILED

Error:
Telegram API timeout
```

---

# 35. Keamanan

Wajib:

- Password hashing
- Secure authentication
- Role-based access control
- Authorization pada setiap endpoint
- Validasi input
- SQL injection protection
- XSS protection
- CSRF protection jika relevan
- Rate limiting login
- Secure session/cookie
- Validasi upload
- Batasi ukuran file
- Validasi MIME type dan extension
- Telegram token hanya di environment variable
- Database credentials hanya di environment variable
- Jangan expose secret di frontend
- Jangan expose data anggota lain kepada anggota biasa

---

# 36. Upload File

Untuk bukti izin/sakit:

Izinkan format yang sesuai, misalnya:

- JPG
- JPEG
- PNG
- PDF

Tetapkan batas ukuran.

Jangan mempercayai extension saja.

Validasi:

- MIME type
- Ukuran file
- Extension
- Nama file
- Lokasi penyimpanan

Jangan membuat file upload dapat menjalankan script.

---

# 37. UI / UX

Desain:

- Modern
- Profesional
- Minimalis
- Bersih
- Responsive
- Mobile-first
- Cepat
- Nyaman digunakan di HP
- Cocok untuk pelajar
- Tidak terlalu banyak animasi

Desktop:

- Sidebar
- Topbar
- Dashboard cards

Mobile:

- Hamburger menu atau bottom navigation
- Card yang mudah disentuh
- Table responsive
- Tombol besar dan jelas

Status menggunakan badge:

- Hadir
- Izin
- Sakit
- Alfa
- Menunggu
- Disetujui
- Ditolak
- Aktif
- Nonaktif
- Belum Mengisi

Gunakan:

- Modal
- Confirmation dialog
- Toast
- Loading state
- Empty state
- Error state

Contoh:

```text
Apakah Anda yakin ingin menerima kehadiran ini?

[ Batal ]
[ Terima ]
```

---

# 38. Landing Page

Halaman `/`.

Hero:

```text
JurnFourteen

Jurnalistik sekolah dalam satu sistem.
```

Tombol:

`LOGIN ANGGOTA`

`DAFTAR ANGGOTA BARU`

Section:

- Tentang JurnFourteen
- Kegiatan
- Informasi
- Kontak

Desain harus memiliki identitas JurnFourteen, bukan template generik.

---

# 39. Struktur Halaman

Gunakan struktur:

```text
/
Landing Page

/login
Login

/register
Pendaftaran anggota

/dashboard
Dashboard sesuai role

/members
Data anggota

/members/:id
Detail anggota

/activities
Kegiatan

/activities/:id
Detail kegiatan

/attendance
Absensi

/attendance/verification
Verifikasi kehadiran

/attendance/:activityId
Detail absensi kegiatan

/leave
Pengajuan izin/sakit

/announcements
Pengumuman

/broadcasts
Broadcast

/reports
Laporan

/notifications
Notifikasi

/settings
Pengaturan

/admin
Dashboard admin

/logs
Activity log
```

---

# 40. API

Buat API yang terstruktur.

Contoh:

```text
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/change-password

GET /api/members
POST /api/members
GET /api/members/:id
PUT /api/members/:id
DELETE /api/members/:id

GET /api/activities
POST /api/activities
GET /api/activities/:id
PUT /api/activities/:id

POST /api/attendance/respond
GET /api/attendance/activity/:id
PUT /api/attendance/:id/verify

POST /api/leave
GET /api/leave
PUT /api/leave/:id/approve
PUT /api/leave/:id/reject

GET /api/broadcasts
POST /api/broadcasts
PUT /api/broadcasts/:id
DELETE /api/broadcasts/:id

GET /api/reports/attendance
GET /api/reports/attendance/excel
GET /api/reports/attendance/pdf

POST /api/telegram/send-summary
```

Sesuaikan endpoint dengan framework yang dipilih.

---

# 41. Validasi Bisnis yang Wajib

## Absensi

- Satu anggota hanya dapat memiliki satu respon untuk satu kegiatan.
- Anggota dapat mengubah respon selama periode yang diizinkan.
- Setelah diverifikasi, anggota tidak boleh mengubah status final.
- Admin dapat melakukan override.
- Semua override masuk activity log.

## Izin/Sakit

- Pengajuan harus terkait dengan kegiatan jika kegiatan membutuhkan absensi.
- Status awal selalu pending.
- Hanya admin/pengurus yang berwenang dapat menyetujui.
- Pengajuan yang sudah disetujui tidak boleh berubah tanpa permission.
- Jika ditolak, alasan penolakan dapat disimpan.

## Alfa

Jangan otomatis membuat semua yang tidak merespons menjadi alfa sebelum kegiatan selesai.

Pengurus harus memiliki kontrol untuk menetapkan alfa.

---

# 42. Bulk Verification

Karena sekretaris akan banyak melakukan verifikasi, buat fitur:

`TERIMA SEMUA YANG HADIR`

Contoh:

20 anggota mengisi `Saya Hadir`.

Sekretaris dapat mengecek daftar tersebut lalu menekan:

`Terima Semua Yang Hadir`

Sistem mengubah semua yang dipilih menjadi:

`Hadir`

Tetap sediakan checkbox individual untuk memilih sebagian.

Contoh:

```text
☑ Walid       Hadir
☑ Aca         Hadir
☐ Rian        Hadir
☑ Sinta       Hadir

[ TERIMA YANG DIPILIH ]
```

---

# 43. Filter Verifikasi

Di halaman verifikasi sediakan filter:

- Semua
- Menunggu
- Hadir
- Izin
- Sakit
- Ditolak
- Belum Mengisi

Filter kelas:

- Semua kelas
- 10-1
- 10-2
- 11-1
- 11-2
- 12-1
- 12-2

Search berdasarkan nama.

---

# 44. Statistik Anggota

Setiap anggota memiliki statistik:

```text
Total kegiatan:
20

Hadir:
16

Izin:
2

Sakit:
1

Alfa:
1

Persentase:
80%
```

Gunakan formula yang jelas dan konsisten.

Jangan menghitung kegiatan yang belum selesai.

---

# 45. Statistik Kegiatan

Setiap kegiatan memiliki:

```text
Total anggota
Sudah merespons
Belum merespons
Menunggu verifikasi
Hadir
Izin
Sakit
Alfa
Persentase kehadiran
```

---

# 46. Rekap Bulanan

Admin dapat memilih:

- Bulan
- Tahun
- Kelas
- Anggota

Hasil:

| Nama | Hadir | Izin | Sakit | Alfa | Persentase |
|---|---:|---:|---:|---:|---:|

Bisa export:

- Excel
- PDF

---

# 47. Rekap Per Anggota

Admin dapat memilih satu anggota dan melihat:

```text
M. Walid
12-2

September 2026

Hadir: 8
Izin: 1
Sakit: 0
Alfa: 0

Persentase:
88.9%
```

Kemudian daftar kegiatan.

---

# 48. Pengaturan Telegram

Buat halaman admin:

`Settings → Telegram`

Field:

```text
Telegram Bot Token
Telegram Group Chat ID
Telegram Secretary Chat ID
```

Tombol:

`TEST TELEGRAM`

Saat diklik, bot mengirim:

```text
✅ TEST NOTIFIKASI

Telegram JurnFourteen berhasil terhubung.
```

Jangan tampilkan token lengkap setelah tersimpan.

---

# 49. Preferensi Notifikasi

Admin dapat mengaktifkan/nonaktifkan jenis notifikasi:

```text
☑ Pendaftaran anggota baru
☑ Konfirmasi hadir
☑ Pengajuan izin
☑ Pengajuan sakit
☑ Hasil verifikasi
☑ Broadcast
☑ Rekap kegiatan
```

---

# 50. File Excel dan PDF

Gunakan library yang sesuai dengan backend/framework.

Pastikan file:

- Memiliki nama file yang jelas
- Tidak corrupt
- Memiliki format tabel yang rapi
- Menggunakan tanggal Indonesia
- Menggunakan WITA jika menampilkan waktu
- Bisa dibuka di HP dan komputer

Contoh nama:

```text
JurnFourteen_Rekap_Rapat_2026-09-16.xlsx
JurnFourteen_Rekap_Rapat_2026-09-16.pdf
```

---

# 51. Timezone

Karena sistem digunakan di Samarinda, gunakan timezone:

```text
Asia/Makassar
```

Semua waktu kegiatan dan absensi harus konsisten menggunakan WITA.

Simpan timestamp database secara aman dan tampilkan sesuai timezone aplikasi.

---

# 52. Seed Data

Buat seed data untuk testing.

Contoh:

```text
SUPER ADMIN
Username: superadmin
Password: gunakan password dummy yang aman

ADMIN
Username: admin
Password: gunakan password dummy yang aman

SEKRETARIS
Username: sekretaris
Password: gunakan password dummy yang aman

ANGGOTA
Username: anggota01
Password: gunakan password dummy yang aman
```

Jangan gunakan password tersebut untuk produksi.

Tambahkan beberapa kegiatan dan anggota dummy agar semua fitur dapat dites.

---

# 53. Testing

Buat test untuk alur penting:

## Authentication

- Login berhasil
- Login gagal
- Anggota tidak dapat membuka admin
- Admin dapat membuka dashboard admin

## Attendance

- Anggota dapat merespons
- Tidak dapat submit dua kali
- Status awal pending
- Sekretaris dapat approve
- Sekretaris dapat reject
- Status final tersimpan

## Izin

- Anggota dapat mengajukan
- Status pending
- Admin approve
- Admin reject
- Rekap berubah menjadi izin

## Sakit

- Anggota dapat mengajukan
- Status pending
- Admin approve
- Admin reject
- Rekap berubah menjadi sakit

## Telegram

- Notifikasi terkirim
- Jika Telegram gagal, database tetap menyimpan data

## Export

- Excel berhasil dibuat
- PDF berhasil dibuat
- Data sesuai dengan database

---

# 54. Error Handling

Semua operasi harus memiliki error handling.

Contoh:

Jika pengajuan gagal:

```text
Pengajuan belum berhasil dikirim.
Silakan coba lagi.
```

Jika Telegram gagal:

```text
Data berhasil disimpan, tetapi notifikasi Telegram gagal dikirim.
```

Jika export gagal:

```text
File belum berhasil dibuat.
Silakan coba lagi.
```

Jangan tampilkan stack trace atau secret kepada user.

---

# 55. README

Buat README lengkap yang menjelaskan:

1. Requirements
2. Instalasi
3. Setup database
4. Environment variables
5. Migration
6. Seed database
7. Menjalankan development server
8. Membuat akun admin
9. Konfigurasi Telegram Bot
10. Cara mendapatkan Telegram Chat ID
11. Cara menjalankan production
12. Deployment
13. Troubleshooting

Contoh environment:

```text
DATABASE_URL=

TELEGRAM_BOT_TOKEN=
TELEGRAM_GROUP_CHAT_ID=
TELEGRAM_SECRETARY_CHAT_ID=

AUTH_SECRET=
```

---

# 56. Arsitektur

Gunakan arsitektur yang mudah dikembangkan.

Pisahkan:

```text
Frontend
Backend/API
Authentication
Database
Telegram Service
File Storage
Export Service
```

Frontend tidak boleh mengakses database secara langsung.

Semua data melalui backend/API.

---

# 57. Prioritas Pengembangan

Prioritaskan dalam urutan:

1. Authentication
2. Database
3. Manajemen anggota
4. Kegiatan
5. Broadcast
6. Respon kehadiran
7. Pengajuan izin
8. Pengajuan sakit
9. Dashboard verifikasi sekretaris
10. Rekap
11. Excel
12. PDF
13. Telegram
14. Notification center
15. Activity log
16. UI polishing

---

# 58. Persyaratan Hasil Akhir

Saya tidak ingin hanya mendapatkan landing page atau UI mockup.

Saya ingin aplikasi full-stack yang benar-benar berfungsi.

Wajib berfungsi:

- Login
- Logout
- Role management
- Pembuatan akun anggota
- Pendaftaran anggota baru
- Verifikasi anggota baru
- Data anggota
- Kegiatan
- Broadcast
- Konfirmasi hadir
- Pengajuan izin
- Pengajuan sakit
- Verifikasi sekretaris
- Riwayat absensi
- Rekap
- Export Excel
- Export PDF
- Telegram notification
- Pengumuman
- Notification center
- Activity log

Semua tombol harus benar-benar memiliki fungsi.

Semua data harus tersimpan di database.

---

# 59. Gambaran Penggunaan Sehari-hari

Contoh penggunaan nyata:

## Sebelum rapat

Sekretaris/admin membuka website.

Membuat kegiatan:

```text
Rapat JurnFourteen
16 September 2026
15:30 WITA
Ruang Jurnalistik
```

Kemudian membuat broadcast.

Anggota mendapat informasi di dashboard.

Bot Telegram mengirim informasi ke grup.

---

## Sebelum kegiatan

Walid membuka website.

Melihat:

```text
📢 Rapat JurnFourteen

15:30 WITA
Ruang Jurnalistik

[ SAYA HADIR ]
[ SAYA IZIN ]
[ SAYA SAKIT ]
```

Walid memilih:

`SAYA HADIR`

Status:

`Menunggu Verifikasi`

Sekretaris mendapatkan notifikasi Telegram.

---

## Saat kegiatan

Sekretaris membuka:

`Verifikasi Kehadiran`

Melihat:

```text
Walid — Hadir — Menunggu
Aca — Hadir — Menunggu
Rian — Izin — Menunggu
Sinta — Sakit — Menunggu
```

Sekretaris mengecek siapa yang benar-benar hadir.

Kemudian klik:

`Terima`

Status menjadi:

`Hadir`

---

## Jika anggota tidak hadir

Misalnya Walid ternyata tidak datang.

Sekretaris klik:

`Tolak`

Status:

`Ditolak`

Sekretaris dapat menetapkan status final sesuai keadaan dan aturan organisasi.

---

## Jika anggota izin

Anggota memilih:

`SAYA IZIN`

Mengisi alasan dan bukti jika diperlukan.

Sekretaris menerima notifikasi Telegram.

Sekretaris membuka dashboard.

Memeriksa pengajuan.

Klik:

`Terima Izin`

Data otomatis masuk:

`IZIN`

---

## Setelah kegiatan

Sekretaris membuka:

`Rekap`

Melihat:

```text
Total: 35
Hadir: 28
Izin: 3
Sakit: 2
Alfa: 2
```

Kemudian:

`EXPORT EXCEL`

atau

`EXPORT PDF`

File tersebut dapat digunakan sebagai bukti administrasi kehadiran JurnFourteen.

Sekretaris juga dapat:

`KIRIM REKAP KE TELEGRAM`

---

# 60. Prinsip Akhir

Sistem harus dibuat dengan pola:

**ANGGOTA MELAPORKAN → SEKRETARIS MEMVERIFIKASI → SISTEM MEREKAP → FILE ADMINISTRASI DIBUAT**

Tujuan utama adalah mengurangi pekerjaan manual sekretaris.

Sekretaris tidak perlu lagi mengetik satu per satu:

"Walid hadir"
"Aca izin"
"Rian sakit"

Anggota mengisi sendiri melalui website.

Sekretaris cukup melakukan pengecekan dan menerima/menolak data.

Setelah selesai, sistem otomatis menghasilkan rekap yang rapi.

---

# 61. Kualitas yang Diharapkan

Bertindaklah sebagai software engineer, UI/UX designer, database architect, dan product designer profesional.

Jangan membuat solusi asal jadi.

Perhatikan:

- Scalability
- Security
- Maintainability
- Clean architecture
- Database normalization
- Responsive design
- Accessibility
- Error handling
- Validation
- User experience
- Performance

Jika ada keputusan teknis yang belum ditentukan, pilih solusi yang paling sederhana, aman, mudah dirawat, dan mudah dideploy untuk organisasi sekolah.

Jangan menghilangkan fitur inti hanya karena implementasinya lebih kompleks.

Jika suatu fitur membutuhkan konfigurasi eksternal seperti Telegram, buat sistem konfigurasi yang jelas dan dokumentasikan cara setup-nya.

Hasil akhir harus terasa seperti **aplikasi administrasi ekstrakurikuler sungguhan**, bukan template website biasa.



---

# 62. VISUAL DESIGN REVISION — NEO-BRUTALISM THEME

**PENTING: gunakan gambar referensi yang diberikan user sebagai REFERENSI VISUAL UNTUK TEMA SAJA.**

Jangan menyalin produk, tulisan, karakter, maskot, logo, ilustrasi, atau isi dari gambar referensi (termasuk aplikasi maupun brand yang dijadikan mood board).

Yang harus diambil hanya bahasa desainnya:

- Neo-Brutalism modern
- Border hitam tebal di setiap elemen (button, card, input, panel)
- Shadow keras/offset (hard shadow), bukan blur lembut
- Warna flat, solid, dan kontras tinggi
- Tipografi besar, tebal (bold), dan percaya diri
- Sudut membulat ringan (rounded, bukan tajam 90°) supaya tetap ramah dibaca, tapi border tetap tegas
- Layout berbasis blok/kartu dengan komposisi bersih
- Ikon flat dengan outline tebal, bukan gradient/3D
- Tampilan unik, playful, tetapi tetap profesional untuk organisasi sekolah
- Hindari desain yang terlihat seperti website corporate generik/template biasa

Jangan membuat website terlihat seperti toko online hanya karena referensi memiliki elemen aplikasi konsumen.

Website tetap harus merupakan **sistem administrasi JurnFourteen**.

## Gaya Visual

Gunakan prinsip:

**"Bold Neo-Brutalism School Journal / Modern Admin Dashboard"**

Bayangkan sistem administrasi sekolah yang didesain dengan ketegasan neo-brutalism: berani, jelas, dan mudah dipindai mata dalam sekejap.

Gunakan:

- Border hitam tebal (2–4px) di semua komponen utama
- Hard shadow offset (contoh: shadow 4px ke kanan-bawah, tanpa blur)
- Card dan panel berbentuk blok solid dengan warna flat
- Divider tegas
- Button dengan efek "tekan" (shadow mengecil saat diklik/hover)
- Grid layout yang rapi dan terstruktur
- Aksen bentuk geometris sederhana (lingkaran, kotak) sebagai elemen dekoratif, bukan ilustrasi rumit

Namun jangan berlebihan.

Prioritaskan readability dan usability.

## Warna

Ambil inspirasi dari gambar referensi berupa:

- Latar dasar netral (off-white/krem terang) sebagai kanvas utama
- 1 warna aksen utama yang kuat (misalnya kuning cerah) untuk elemen penting seperti CTA/button utama
- 1–2 warna aksen sekunder (misalnya pink/magenta dan ungu) untuk kategori/status/dekorasi
- Hitam pekat untuk border, teks utama, dan shadow
- Warna status tetap jelas (hijau untuk hadir, kuning untuk menunggu, merah untuk ditolak/alfa, biru untuk izin/sakit)

Jangan menggunakan terlalu banyak warna sekaligus dalam satu layar.

Buat color system yang konsisten (tetapkan sebagai design token: primary, secondary, accent, background, border, text, status-colors) supaya mudah dipakai ulang di semua halaman.

## Typography

Gunakan kombinasi:

1. Font sans-serif tebal (extra bold/black weight) untuk:
   - Judul
   - Heading
   - Label tertentu
   - Angka statistik besar di dashboard

2. Font modern yang sangat mudah dibaca (regular/medium weight) untuk:
   - Isi teks
   - Form
   - Tabel
   - Deskripsi
   - Informasi administrasi

Jangan menggunakan font tebal/dekoratif untuk seluruh paragraf karena dapat mengurangi keterbacaan.

## UI Components

Semua komponen utama harus mengikuti tema neo-brutalism:

### Button

Contoh:

```text
[ LOGIN ]
[ SAYA HADIR ]
[ AJUKAN IZIN ]
[ AJUKAN SAKIT ]
[ TERIMA ]
[ TOLAK ]
```

Button menggunakan border hitam tebal + hard shadow offset. Saat ditekan/hover, shadow mengecil atau bergeser seolah tombol "tertekan" ke dalam.

### Card

Gunakan card bergaya neo-brutalism:

```text
┌──────────────────────────────┐
│ RAPAT JURNFOURTEEN           │
│                              │
│ 16 SEPTEMBER 2026            │
│ 15:30 WITA                   │
│ RUANG JURNALISTIK            │
│                              │
│ [ SAYA HADIR ]               │
└──────────────────────────────┘
```

(Border tebal + shadow offset di sisi kanan-bawah card.)

### Table

Tabel tetap profesional dan mudah dibaca.

Gunakan:

- Border tegas antar baris/kolom
- Header dengan latar warna aksen dan tipografi bold
- Status berbentuk badge dengan border hitam
- Hover state
- Responsive mobile layout

Jangan membuat tabel terlalu dekoratif sampai sulit dibaca.

## Dekorasi Neo-Brutalism

Boleh menggunakan dekorasi seperti:

- Bentuk geometris solid (lingkaran, kotak, segitiga) sebagai aksen latar
- Sticker/badge bersudut dengan border tebal (misalnya label "BARU", "PENTING")
- Ikon flat outline tebal bertema jurnalistik: kamera, koran, mikrofon, notebook, kamera video, komputer/editor

Dekorasi harus tetap berhubungan dengan **Jurnalistik**, bukan sekadar dekorasi generik.

Jangan menggunakan karakter, maskot, atau aset dari gambar referensi.

---

# 63. LOGO JURNFOURTEEN

WAJIB menyediakan tempat untuk memasang logo resmi ekstrakurikuler JurnFourteen.

Jangan membuat logo JurnFourteen secara permanen di dalam source code.

Buat sistem logo yang dapat diganti.

Contoh:

```text
[ LOGO JURNFOURTEEN ]

JurnFourteen
Jurnalistik Sekolah
```

Logo harus dapat ditampilkan di:

- Landing page
- Navbar
- Sidebar
- Login page
- Dashboard
- PDF
- Export/print header
- Halaman pengumuman
- Halaman laporan

## Logo Upload

Admin/Super Admin dapat mengunggah logo melalui:

`Settings → Branding`

Field:

- Logo utama
- Logo untuk PDF
- Favicon

Format yang disarankan:

- PNG
- SVG
- JPG/JPEG

Validasi ukuran dan tipe file.

Jika belum ada logo yang diupload, gunakan placeholder bertuliskan:

`JURNFOURTEEN`

dengan style neo-brutalism sederhana (border tebal + shadow offset).

Setelah user memberikan logo asli, logo tersebut harus dapat menggantikan placeholder tanpa mengubah struktur website.

## Branding Settings

Buat pengaturan:

```text
Nama Organisasi:
JurnFourteen

Nama Lengkap:
Ekstrakurikuler Jurnalistik

Tagline:
Jurnalistik sekolah dalam satu sistem.

Logo:
[ Upload Logo ]

Favicon:
[ Upload Favicon ]
```

Jika memungkinkan, admin dapat mengatur warna aksen utama tanpa merusak tema neo-brutalism.

---

# 64. JANGAN MENGGUNAKAN EMOJI SEBAGAI ELEMEN UI

Kurangi emoji seminimal mungkin.

**Prioritas utama: JANGAN menggunakan emoji sebagai ikon navigasi atau UI.**

Contoh yang TIDAK diinginkan:

```text
🏠 Dashboard
👤 Profil
📋 Absensi
📝 Izin
🤒 Sakit
📢 Broadcast
🔔 Notifikasi
```

Ganti dengan:

- SVG icon dengan outline tebal
- Icon library yang sesuai dengan tema neo-brutalism
- Ikon flat, solid, konsisten dengan warna tema

Contoh:

```text
[icon] Dashboard
[icon] Profil
[icon] Absensi
[icon] Izin
[icon] Sakit
[icon] Broadcast
[icon] Notifikasi
```

Untuk status, juga utamakan badge/warna/ikon dengan border tebal daripada emoji.

Contoh:

```text
[ HADIR ]
[ IZIN ]
[ SAKIT ]
[ ALFA ]
[ MENUNGGU ]
```

Jika emoji sama sekali tidak diperlukan, jangan gunakan emoji.

Notifikasi Telegram juga sebaiknya menggunakan format teks yang rapi dan tidak bergantung pada emoji.

Contoh:

```text
JURNFOURTEEN — PENGAJUAN IZIN BARU

Nama:
M. Walid

Kelas:
12-2

Kegiatan:
Rapat JurnFourteen

Tanggal:
16 September 2026

Alasan:
Ada keperluan keluarga.

Status:
MENUNGGU VERIFIKASI
```

---

# 65. LANDING PAGE DENGAN TEMA NEO-BRUTALISM

Landing page harus langsung menunjukkan identitas JurnFourteen.

Contoh konsep:

```text
┌─────────────────────────────────────────────┐
│ [LOGO] JURNFOURTEEN      LOGIN             │
├─────────────────────────────────────────────┤
│                                             │
│        JURNFOURTEEN                         │
│        JURNALISTIK SEKOLAH                  │
│                                             │
│        Jurnalistik sekolah                  │
│        dalam satu sistem.                   │
│                                             │
│        [ LOGIN ANGGOTA ]                    │
│        [ DAFTAR ANGGOTA BARU ]              │
│                                             │
│    [ilustrasi kamera/koran flat brutalism]  │
│                                             │
└─────────────────────────────────────────────┘
```

Buat hero section dengan blok warna solid, border tebal, dan shadow offset yang berani.

Jangan menggunakan karakter dari gambar referensi.

Gunakan ilustrasi flat neo-brutalism yang dibuat khusus untuk JurnFourteen.

---

# 66. DASHBOARD NEO-BRUTALISM

Dashboard admin dan anggota harus tetap menggunakan tema yang sama.

Contoh:

```text
JURNFOURTEEN
────────────────────────────────

DASHBOARD

TOTAL ANGGOTA
35

KEGIATAN AKTIF
2

PENGAJUAN
5

KEHADIRAN
86%

────────────────────────────────

KEGIATAN HARI INI

RAPAT REDAKSI
16 SEPTEMBER 2026
15:30 WITA
RUANG JURNALISTIK

[ LIHAT KEHADIRAN ]

────────────────────────────────
```

Gunakan panel dengan border tebal, shadow offset keras, dan blok warna solid yang terinspirasi neo-brutalism.

---

# 67. LOGIN PAGE

Login page harus memiliki identitas JurnFourteen.

Contoh:

```text
┌───────────────────────────────┐
│                               │
│       [LOGO JURNFOURTEEN]     │
│                               │
│       JURNFOURTEEN            │
│       MEMBER LOGIN            │
│                               │
│ Username                      │
│ [________________________]    │
│                               │
│ Password                      │
│ [________________________]    │
│                               │
│ [ LOGIN ]                     │
│                               │
│ Lupa password?                │
│                               │
└───────────────────────────────┘
```

Gunakan frame border tebal dan shadow offset khas neo-brutalism.

Tetap prioritaskan kemudahan login.

---

# 68. MOBILE DESIGN

Tema neo-brutalism harus tetap bagus di HP.

Jangan hanya membuat desktop lalu mengecilkannya.

Buat mobile-first.

Pada HP:

- Card menjadi satu kolom
- Navigasi menjadi bottom navigation atau hamburger
- Tabel menjadi responsive card/list
- Tombol mudah disentuh
- Form tidak terlalu kecil
- Broadcast mudah dibaca
- Konfirmasi hadir/izin/sakit terlihat jelas

Border tebal dan shadow tetap terasa meskipun layar kecil, tapi jangan sampai ketebalan border memakan ruang layar yang sempit.

---

# 69. ADMIN UI

Dashboard admin harus terlihat seperti:

**"Command center yang tegas dan jelas untuk administrasi JurnFourteen."**

Tetapi jangan sampai terlihat ramai atau sulit digunakan.

Gunakan neo-brutalism sebagai visual identity, bukan sebagai pengganti usability.

---

# 70. PRINT / PDF THEME

Export PDF juga harus membawa identitas JurnFourteen.

Gunakan:

- Logo resmi yang diupload admin
- Nama JurnFourteen
- Header bergaya neo-brutalism sederhana (border tebal, tipografi bold)
- Border tipis untuk tabel
- Layout formal
- Tabel yang mudah dibaca

Jangan membuat PDF terlalu dekoratif atau memakai shadow keras (PDF cetak tetap harus bersih dan hemat tinta).

Dokumen harus tetap cocok untuk administrasi sekolah.

---

# 71. REFERENSI VISUAL

Gambar yang diberikan user (referensi gaya aplikasi neo-brutalism) hanya digunakan sebagai referensi:

- Komposisi visual
- Border hitam tebal
- Hard shadow/offset shadow
- Warna flat dan kontras tinggi
- Typography bold
- Cara menyusun card/panel/button

**Jangan menyalin:**

- Nama aplikasi, brand, atau produk dari gambar referensi
- Maskot atau karakter apa pun
- Logo
- Tulisan/copy asli dari gambar referensi
- Ilustrasi spesifik
- Layout produk secara identik
- Elemen copyright lain

Buat identitas visual baru yang khusus untuk **JurnFourteen**.

---

# 72. HASIL VISUAL YANG DIHARAPKAN

Target akhirnya:

**JurnFourteen terlihat seperti aplikasi administrasi sekolah yang dibuat dengan estetika neo-brutalism premium.**

Bukan:

- Website toko online
- Website gaming
- Template dashboard biasa
- Website corporate generik
- Website yang penuh emoji

Tetapi:

**Bold Neo-Brutalism + Modern UI + Jurnalistik Sekolah + Professional Administration System**

Gunakan neo-brutalism dengan elegan.

Neo-brutalism harus menjadi identitas visual yang tegas dan percaya diri, bukan membuat website terlihat berantakan atau terlalu ramai.

---

# 73. PRIORITAS DESAIN

Urutan prioritas:

1. Readability
2. Usability
3. Responsive
4. Professional appearance
5. JurnFourteen branding
6. Neo-Brutalism visual identity
7. Decorative elements

Jika dekorasi neo-brutalism bertabrakan dengan usability, prioritaskan usability.

---

# 74. KETENTUAN AKHIR UNTUK AI PEMBUAT WEBSITE

Sebelum menyelesaikan project, pastikan:

- Tema seluruh halaman konsisten
- Tidak ada halaman yang kembali ke template default
- Tidak menggunakan emoji sebagai ikon utama
- Semua icon menggunakan icon/SVG dengan outline tebal
- Logo JurnFourteen dapat diupload dan diganti
- Logo muncul pada dashboard dan dokumen
- Website responsive
- Tema neo-brutalism tetap terlihat di desktop dan mobile
- Warna konsisten
- Typography konsisten
- UI tetap mudah dibaca
- Tidak menyalin brand atau karakter dari gambar referensi
- Gambar referensi hanya digunakan sebagai inspirasi gaya visual

Tema final:

**JURNFOURTEEN — NEO-BRUTALISM JOURNALISM ADMINISTRATION SYSTEM**

---

# 75. REAL-TIME SYSTEM — WAJIB LIVE

**Seluruh sistem yang membutuhkan pembaruan informasi harus bekerja secara REAL-TIME/LIVE.**

Jangan mengharuskan pengguna melakukan refresh halaman untuk melihat data terbaru.

Gunakan teknologi real-time yang sesuai, misalnya WebSocket, Server-Sent Events (SSE), Supabase Realtime, Firebase Realtime/Firestore listeners, Pusher, Ably, atau solusi sejenis. Pilih satu yang stabil, aman, mudah dirawat, dan mudah di-deploy.

## Prinsip

Setiap perubahan yang berhasil tersimpan di server/database harus dapat diterima client terkait secara otomatis tanpa reload.

```text
PERUBAHAN DATA
↓
BACKEND
↓
DATABASE
↓
REAL-TIME EVENT
↓
USER TERKAIT
```

## Broadcast real-time

Ketika admin membuat dan mempublikasikan broadcast:

```text
Admin klik PUBLISH
↓
Database menyimpan
↓
Real-time event
↓
Anggota target langsung menerima broadcast
```

Broadcast harus langsung muncul pada dashboard anggota tanpa refresh.

Jika broadcast diedit, perubahan tampil secara real-time.

Jika broadcast ditarik/dihapus, tampilan anggota ikut diperbarui secara real-time.

Target broadcast tetap mengikuti permission:
- Semua anggota
- Kelas tertentu
- Pengurus
- Anggota tertentu

## Konfirmasi kehadiran real-time

Ketika anggota menekan `SAYA HADIR`, data langsung tersimpan dan dashboard sekretaris yang sedang terbuka langsung berubah.

Contoh:

```text
Sudah mengisi: 21 → 22
Menunggu verifikasi: 7 → 8
```

Sekretaris tidak perlu refresh.

## Izin dan sakit real-time

Ketika anggota mengirim pengajuan izin/sakit:

```text
Anggota
↓
Kirim pengajuan
↓
Database
↓
Real-time event
↓
Dashboard sekretaris langsung mendapat pengajuan
```

Counter pengajuan dan daftar pengajuan harus langsung berubah.

Contoh:
`Pengajuan menunggu: 4 → 5`

Tampilkan notifikasi internal seperti:
`Pengajuan izin baru dari M. Walid.`

## Hasil verifikasi real-time

Ketika sekretaris menekan `TERIMA` atau `TOLAK`, anggota yang bersangkutan langsung menerima perubahan status tanpa refresh.

Contoh:

```text
Menunggu Verifikasi
↓
Sekretaris TERIMA
↓
HADIR — TERVERIFIKASI
```

Hal yang sama berlaku untuk izin dan sakit.

## Dashboard statistik real-time

Semua statistik harus diperbarui otomatis ketika data berubah:

- Total anggota
- Sudah mengisi
- Menunggu verifikasi
- Hadir
- Izin
- Sakit
- Alfa
- Persentase kehadiran
- Pengajuan menunggu

Jangan hanya mengubah angka di frontend. Angka harus berasal dari data server/database yang terbaru.

## Status kegiatan real-time

Jika admin membuat atau mengubah kegiatan, anggota yang menjadi target langsung menerima perubahan.

Perubahan yang harus live:
- Judul
- Tanggal
- Jam
- Lokasi
- Deskripsi
- Status
- Batas waktu konfirmasi

Jika kegiatan dibatalkan, status pembatalan langsung muncul.

## Notification center real-time

Notifikasi internal harus masuk secara live:

- Broadcast baru
- Kegiatan baru
- Pengajuan disetujui
- Pengajuan ditolak
- Kehadiran diverifikasi
- Informasi penting

Badge jumlah notifikasi juga harus berubah tanpa refresh.

## Telegram real-time/immediate

Telegram Bot harus mengirim notifikasi segera setelah event berhasil diproses.

Contoh:

```text
Anggota kirim izin
↓
Backend menyimpan data
↓
Telegram notification service
↓
Bot mengirim ke grup/sekretaris
```

Tidak boleh menunggu refresh atau tindakan manual tambahan.

Gunakan queue/background job jika diperlukan agar pengiriman Telegram tidak menghambat UI.

Jika pengiriman Telegram gagal:
- Data website tetap tersimpan
- Catat error pada telegram_logs
- Tampilkan status pengiriman kepada admin
- Jangan berpura-pura bahwa pesan berhasil dikirim

## Broadcast website + Telegram

Jika admin membuat broadcast dan memilih `Kirim ke Telegram`, satu kali klik `PUBLISH` harus menghasilkan:

```text
1. Broadcast langsung muncul di website
2. Telegram Bot langsung mengirim informasi
```

## Verifikasi kehadiran real-time

Ketika sekretaris menerima satu kehadiran:

```text
Dashboard sekretaris:
Menunggu Verifikasi 8 → 7
Hadir 20 → 21

Dashboard anggota:
Menunggu Verifikasi → Hadir — Terverifikasi

Rekap:
Hadir 20 → 21
```

Semua bagian terkait harus konsisten.

## Multi-user / concurrency

Sistem harus mendukung banyak user aktif bersamaan, misalnya puluhan anggota + sekretaris + ketua + admin.

Gunakan:
- Database transaction
- Unique constraint
- Server-side validation
- Idempotency jika diperlukan
- Proper concurrency handling

Satu anggota tidak boleh memiliki dua respon final untuk kegiatan yang sama.

## Offline / reconnect

Jika koneksi real-time terputus, tampilkan indikator:

`REAL-TIME TERPUTUS`

Lakukan reconnect otomatis.

Jika koneksi kembali:

`TERHUBUNG KEMBALI`

Kemudian sinkronkan data terbaru dari server.

Jangan menampilkan data lama sebagai data terbaru.

Jika aksi belum diterima server, jangan tampilkan seolah-olah aksi sudah berhasil.

## Keamanan real-time

Real-time channel harus mengikuti permission.

Anggota hanya menerima:
- Broadcast yang memang menjadi targetnya
- Status pengajuan miliknya
- Status kehadirannya
- Notifikasi yang berhak dilihat

Data pengajuan pribadi anggota lain tidak boleh dikirim ke client anggota biasa.

Filtering harus diterapkan di server/backend/realtime authorization, bukan hanya disembunyikan dengan frontend.

## Source of truth

Database/server adalah sumber data utama.

Jangan menggunakan localStorage sebagai database absensi.

Flow:

```text
Frontend
↓
Backend
↓
Database
↓
Real-time event
↓
Client terkait
```

## Real-time audit log

Catat perubahan penting:

```text
16 Sep 2026 15:31
M. Walid
Mengirim konfirmasi hadir
Kegiatan: Rapat Redaksi
```

Kemudian:

```text
16 Sep 2026 15:45
Sekretaris
Memverifikasi M. Walid
Status: Hadir
```

## Acceptance test real-time

Sebelum dianggap selesai, uji:

### Test 1 — Broadcast
Browser A = Admin  
Browser B = Anggota

Admin membuat broadcast.

Hasil yang wajib:
Broadcast muncul di Browser B tanpa refresh.

### Test 2 — Kehadiran
Browser A = Anggota  
Browser B = Sekretaris

Anggota klik `SAYA HADIR`.

Hasil:
Browser B langsung menampilkan respon tersebut sebagai `Menunggu Verifikasi`.

### Test 3 — Verifikasi
Sekretaris klik `TERIMA`.

Hasil:
Browser anggota langsung berubah menjadi `HADIR — TERVERIFIKASI`.

### Test 4 — Izin
Anggota mengirim izin.

Hasil:
Dashboard sekretaris langsung mendapat pengajuan dan Telegram langsung menerima notifikasi.

### Test 5 — Sakit
Anggota mengirim sakit.

Hasil:
Dashboard sekretaris langsung mendapat pengajuan dan Telegram langsung menerima notifikasi.

### Test 6 — Statistik
Beberapa anggota mengirim respon hampir bersamaan.

Hasil:
Counter diperbarui real-time dan tetap konsisten dengan database.

### Test 7 — Reconnect
Putuskan koneksi sementara lalu sambungkan kembali.

Hasil:
Sistem otomatis reconnect dan melakukan sinkronisasi data terbaru.

## Target UX

Pada koneksi normal, perubahan harus terasa hampir instan, idealnya dalam hitungan detik atau lebih cepat.

Jangan menggunakan polling lambat 30–60 detik jika teknologi realtime tersedia.

**Jangan membuat fitur palsu yang terlihat live tetapi sebenarnya membutuhkan refresh.**

Fitur berikut WAJIB benar-benar live:
- Broadcast
- Pengumuman
- Kegiatan
- Konfirmasi hadir
- Pengajuan izin
- Pengajuan sakit
- Verifikasi sekretaris
- Statistik dashboard
- Notification center
- Status kegiatan
- Status pengajuan
- Status kehadiran
- Update rekap
- Notifikasi Telegram

Jika teknologi/framework memiliki realtime bawaan, gunakan.

Dokumentasikan seluruh konfigurasi realtime dan Telegram di README.

---

# 76. HALAMAN PUBLIK — LANDING PAGE PENGENALAN JURNFOURTEEN

Selain sistem internal (login-only), buat halaman publik yang dapat diakses siapa saja **tanpa login**, berfungsi sebagai halaman pengenalan resmi JurnFourteen.

## Rute publik (tanpa login)

```text
/            → Landing page utama
/tentang     → Tentang JurnFourteen (sejarah, visi & misi)
/anggota     → Direktori anggota/struktur organisasi publik
/pengumuman  → Broadcast/pengumuman publik (event, prestasi, dsb)
/register    → Pendaftaran anggota baru (tetap ada seperti Bagian 5)
```

## Isi Landing Page

1. **Hero section** — nama JurnFourteen, tagline "Jurnalistik sekolah dalam satu sistem.", banner bertema neo-brutalism, tombol CTA "Gabung Jadi Anggota" (menuju `/register`) dan "Lihat Kegiatan Kami"
2. **Tentang Kami** — deskripsi singkat ekstrakurikuler, sejarah singkat, visi & misi
3. **Foto Bersama** — satu foto grup utama, dapat diunggah dan diganti oleh Super Admin
4. **Struktur Organisasi / Anggota** — lihat detail di bawah
5. **Pengumuman / Event Publik** — daftar broadcast publik terbaru (Bagian 7)
6. **Kata Sambutan Pembina** (opsional) — kutipan singkat dari Pembina
7. **Footer** — kontak resmi JurnFourteen, link Linktree/sosial media resmi, copyright

## Direktori Anggota Publik

Tampilkan kartu untuk setiap anggota yang telah mengizinkan datanya ditampilkan publik (lihat toggle privasi di Bagian 4):

- Foto profil
- Nama
- Jabatan
- Kelas (opsional, dapat disembunyikan per anggota)
- Bio singkat (opsional)
- Link Linktree/sosial media anggota (jika diisi) — tampil sebagai tombol/ikon yang bisa diklik dan membuka tab baru

Urutkan kartu berdasarkan hierarki jabatan (Pembina → Ketua Umum → Wakil Ketua → Sekretaris → Bendahara → Koordinator → Anggota), bukan alfabet, supaya struktur organisasi terlihat jelas.

## Privasi & Data yang Ditampilkan

Karena ini halaman publik, wajib diperhatikan:

- **Jangan pernah** menampilkan NIS/NISN, nomor HP, atau data pribadi sensitif lain di halaman publik.
- Foto & nama seorang anggota hanya tampil jika toggle "Tampilkan di halaman publik" pada Bagian 4 aktif. Default: nonaktif.
- Sediakan halaman admin untuk mengelola siapa saja yang tampil di direktori publik, termasuk aksi bulk toggle untuk banyak anggota sekaligus.
- Sebagian besar anggota kemungkinan pelajar di bawah umur — persetujuan orang tua/wali sebelum foto & nama anak ditampilkan publik adalah kebijakan sekolah yang perlu diputuskan pengurus, di luar sistem. Sistem hanya perlu menyediakan toggle privasi ini agar kebijakan tersebut bisa dijalankan.

## SEO & Share Preview

- Tambahkan meta title, meta description, dan Open Graph image (foto bersama/logo) supaya saat link JurnFourteen dibagikan (WhatsApp, bio Instagram, dsb) muncul preview yang menarik.
- Landing page tetap mengikuti tema neo-brutalism di Bagian 62–74, dengan prioritas tetap readability & professional appearance sesuai Bagian 73.

---

# 77. TECH STACK — SKEMA "FULL FREE"

Seluruh sistem harus bisa dibangun dan dijalankan **tanpa biaya**, menggunakan kombinasi layanan yang punya free tier cukup untuk skala ekskul sekolah (puluhan anggota aktif bersamaan):

```text
Framework      : Next.js (frontend + backend/API dalam satu project)
Database       : PostgreSQL via Supabase (free tier)
Auth           : Supabase Auth, atau auth custom dengan password hashing
Realtime       : Supabase Realtime (built-in, free tier)
File Storage   : Supabase Storage (foto profil, foto bersama, bukti izin/sakit)
Hosting        : Vercel (Hobby/free plan)
Notifikasi     : Telegram Bot API (gratis)
Export Excel   : Library ExcelJS / SheetJS (gratis)
Export PDF     : Library PDFKit / pdf-lib / Puppeteer (gratis)
```

Alasan pemilihan:

- Supabase menyediakan Database + Auth + Realtime + Storage dalam **satu layanan gratis**, sehingga requirement real-time di Bagian 75 dapat terpenuhi tanpa perlu mengelola server WebSocket sendiri.
- Next.js + Vercel adalah kombinasi yang stabil, mudah di-deploy gratis, dan cocok untuk beban puluhan hingga ratusan pengguna.

## Batasan free tier yang perlu diketahui

Supabase free tier (per project, dapat berubah — cek dokumentasi resmi sebelum deploy):
- Database sekitar 500MB
- Storage sekitar 1GB
- Project otomatis pause jika tidak ada aktivitas dalam beberapa hari, dan perlu dibangunkan kembali secara manual

Vercel free tier:
- Cukup untuk trafik ekskul sekolah, namun tetap ada batas bandwidth bulanan

Domain:
- Secara default memakai subdomain gratis (contoh: `jurnfourteen.vercel.app`)
- Domain custom (misalnya `.sch.id`) berbayar, kecuali sekolah sudah memiliki domain sendiri

*(Catatan untuk AI pembuat website: jika kebutuhan kelak melebihi batas free tier, sistem harus tetap bisa di-upgrade ke tier berbayar tanpa migrasi besar-besaran. Jangan gunakan teknologi yang mengunci ketat ke satu penyedia.)*

---

# 78. SARAN TAMBAHAN (OPSIONAL)

Beberapa ide tambahan yang bisa dipertimbangkan, tidak wajib dikerjakan:

1. **Galeri Kegiatan/Dokumentasi** — halaman publik berisi foto-foto kegiatan/liputan JurnFourteen dari waktu ke waktu, baik untuk showcase dan rekrutmen.
2. **Bagan Struktur Organisasi** — selain kartu anggota, tampilkan juga org chart sederhana bertema neo-brutalism di halaman `/anggota` atau `/tentang`.
3. **Banner Rekrutmen** — banner "Pendaftaran anggota baru dibuka!" yang bisa diaktifkan/nonaktifkan Super Admin, muncul di landing page saat periode pendaftaran dibuka.
4. **Label kategori broadcast publik** — bedakan visual antara pengumuman biasa dan event penting, misalnya label "Prestasi", "Kegiatan", "Rekrutmen" di halaman `/pengumuman`.
5. **Kompresi otomatis foto yang diupload** — foto profil dan foto bersama otomatis di-resize/dikompres saat upload, supaya kuota storage gratis tidak cepat habis.
6. **Kontak publik tidak memakai nomor pribadi** — untuk kontak di footer/halaman publik, gunakan Linktree/Instagram resmi JurnFourteen, bukan nomor HP pribadi anggota.
