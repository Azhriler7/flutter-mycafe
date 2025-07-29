# Aplikasi Kafe Sederhana (Android & Web) ☕

Aplikasi pemesanan untuk kafe yang dibangun menggunakan Flutter dan Firebase. Proyek ini dirancang untuk platform **Android** dan **Web**.

Aplikasi ini memiliki sistem menu dinamis yang dikelola oleh admin dan alur pembayaran yang disederhanakan dengan verifikasi manual oleh staf di meja pelanggan.

---

## 👥 Kelompok 8
**Nama Anggota:**
1. Azhriler Lintang (3337230087)
2. Cahaya Jiwa Anenda (3337230086)
3. Muhammad Zidan Heiqmatyar (3337230084)

---

## Akun Uji Coba
Untuk keperluan pengujian, gunakan akun berikut:

Akun Admin
📧 admin@example.com
🔒 admin123

Akun User
📧 user@example.com
🔒 user123

---
## Daftar Isi
1.  [Daftar Halaman Aplikasi](#daftar-halaman-aplikasi)
2.  [Persiapan & Instalasi](#persiapan--instalasi)
3.  [Alur Kerja Git & Kontribusi Kode](#alur-kerja-git--kontribusi-kode)
4.  [Struktur Database (Firestore)](#struktur-database-firestore)
5.  [Arsitektur & State Management](#arsitektur--state-management)

---

## Daftar Halaman Aplikasi

Berikut adalah rincian halaman yang akan dibuat untuk masing-masing peran.

### Halaman Sisi Pelanggan (User)
1.  **Layar Autentikasi:** Mencakup halaman Login, Register, dan Lupa Password.
2.  **Dashboard Pengguna:** Halaman utama terpadu yang menampilkan daftar menu dari Firestore dan ringkasan keranjang belanja di bagian bawah.
3.  **Profil Pengguna:** Halaman untuk mengelola data pribadi, serta fitur Logout dan Hapus Akun.

### Halaman Sisi Admin
1.  **Dashboard Admin:** Halaman utama yang menampilkan daftar pesanan masuk (`pesanan` baru) secara *real-time*.
2.  **Detail Pesanan:** Halaman yang menampilkan rincian lengkap dari sebuah pesanan yang dipilih.
3.  **Manajemen Menu (CRUD):** Halaman untuk menambah, mengubah, dan menghapus item di koleksi `menu`.
4.  **Profil Admin:** Halaman sederhana untuk admin melakukan Logout.

---

## Persiapan & Instalasi

Pastikan Anda sudah menginstal Flutter SDK (versi 3.x.x atau lebih baru).

### Langkah-langkah
1.  **Clone repository ini:**
    ```bash
    git clone [https://github.com/NAMA_USER_ANDA/nama-repo-anda.git](https://github.com/NAMA_USER_ANDA/nama-repo-anda.git)
    ```
2.  **Masuk ke direktori proyek:**
    ```bash
    cd nama-repo-anda
    ```
3.  **Setup Firebase:**
    * Proyek ini menggunakan Firebase. File konfigurasi `google-services.json` **tidak disertakan** di repository.
    * Setiap anggota tim harus membuat proyek Firebase sendiri untuk development.
    * Jalankan `flutterfire configure` dan hubungkan ke proyek Firebase Anda (pilih platform **Android** dan **Web**).
    * Aktifkan layanan: **Authentication (Email/Password)** dan **Firestore Database**.

4.  **Install dependensi:**
    ```bash
    flutter pub get
    ```
5.  **Jalankan aplikasi:**
    ```bash
    flutter run -d chrome  # Untuk Web
    flutter run            # Untuk Android
    ```

### Dependensi Utama
* **`firebase_core`**, **`firebase_auth`**, **`cloud_firestore`**, **`provider`**, **`intl`**.

---

## Alur Kerja Git & Kontribusi Kode

Semua pekerjaan harus dilakukan di *branch* terpisah untuk menjaga *branch* `main` tetap stabil.

1.  **Update `main`:** `git checkout main` lalu `git pull origin main`.
2.  **Buat Branch Baru:** `git checkout -b feature/nama-fitur-baru`.
3.  **Kerjakan Kode & Commit:** `git add .` lalu `git commit -m "pesan commit"`.
4.  **Push Branch:** `git push -u origin feature/nama-fitur-baru`.
5.  **Buat Pull Request** di GitHub untuk di-review.

---

## Struktur Database (Firestore)

Ini adalah "kontrak" data final antara Backend dan Frontend.

### Koleksi: `users`
* **Tujuan:** Menyimpan data profil pengguna.
* **ID Dokumen:** `UID` dari Firebase Authentication.
* **Fields:** `username` (String), `email` (String), `gender` (String), `createdAt` (Timestamp), `isAdmin` (Boolean).

### Koleksi: `menu`
* **Tujuan:** Menyimpan **semua** item menu yang bisa dipesan dan dikelola oleh admin.
* **ID Dokumen:** Auto-ID oleh Firestore.
* **Fields:** `namaMenu` (String), `harga` (Number), `kategori` (String), `isTersedia` (Boolean).

### Koleksi: `pesanan`
* **Tujuan:** Menyimpan data setiap pesanan yang sudah final.
* **ID Dokumen:** Auto-ID oleh Firestore.
* **Fields:** `userId` (String), `namaPemesan` (String), `noMeja` (String), `items` (Array of Maps), `totalHarga` (Number), `statusPesanan` (String: 'baru', 'selesai'), `waktuPesan` (Timestamp).

---
## 📄 Contoh Isi Dokumen Firestore

Berikut adalah contoh isi dari masing-masing dokumen dalam Firestore Database yang digunakan pada aplikasi ini, sesuai dengan struktur "kontrak data" yang telah didefinisikan.

### Koleksi: `users`
```bash
username: "user",
email: "user@example.com",
gender: "Wanita",
isAdmin: false,
createdAt: "2025-07-29T07:51:11Z"
```

### Koleksi: `menu`
```bash
namaMenu: "Roti Panggang"
harga: 20000
kategori: "dessert"
isTersedia: true
```

### Koleksi: `pesanan`
```bash
items:
  - namaMenu: "Kopi Susu", jumlah: 2, harga: 20000
  - namaMenu: "Es Teh Manis", jumlah: 2, harga: 15000
  - namaMenu: "Cheese Cake", jumlah: 1, harga: 35000
  - namaMenu: "Iced Americano", jumlah: 1, harga: 22000
  - namaMenu: "Iced Latte", jumlah: 1, harga: 28000
  - namaMenu: "Cappuccino", jumlah: 1, harga: 25000
namaPemesan: "user@example.com"
noMeja: "56"
statusPesanan: "selesai"
totalHarga: 180000
userId: "6sPsPZVw0abOrsdFziuvKTgUSxj1"
waktuPesan: 2025-07-29T05:56:42Z
waktuSelesai: 2025-07-29T07:47:34Z
```

---

## Arsitektur & State Management

Proyek ini menggunakan arsitektur **MVC (Model-View-Controller)**.

* **Model:** Struktur data di dalam `lib/models/`.
* **View:** Semua kode UI di dalam `lib/views/`.
* **Controller:** Lapisan logika bisnis menggunakan paket **`provider`** sebagai solusi *state management*. Setiap *controller* akan dibuat menggunakan `ChangeNotifier`.
* **Navigasi:** Menggunakan **`Navigator`** bawaan Flutter untuk perpindahan halaman.
