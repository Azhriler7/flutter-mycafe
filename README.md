# My Cafe ☕

Aplikasi pemesanan untuk kafe yang dibangun menggunakan Flutter dan Firebase. Proyek ini dirancang untuk platform **Android** dan **Web**.

Aplikasi ini memiliki sistem menu ganda: menu utama yang statis (disertakan dalam aset aplikasi) untuk kecepatan dan keandalan, serta menu info/promo dinamis yang dapat dikelola oleh admin. Alur pembayaran disederhanakan dengan verifikasi manual oleh staf di meja pelanggan.

---

## Daftar Isi
1.  [Alur Kerja Aplikasi](#alur-kerja-aplikasi)
2.  [Persiapan & Instalasi](#persiapan--instalasi)
3.  [Struktur Database (Firestore)](#struktur-database-firestore)
4.  [Struktur Aset Aplikasi](#struktur-aset-aplikasi)
5.  [Arsitektur & State Management](#arsitektur--state-management)

---

## Alur Kerja Aplikasi

Aplikasi ini memiliki dua peran utama: **Pelanggan** dan **Admin**.

### Alur Pelanggan
1.  **Autentikasi:** Pengguna harus mendaftar (Register) atau masuk (Login) dengan **Email/Password**. Fitur Lupa Password dan Hapus Akun tersedia di halaman profil.
2.  **Dashboard (Menu Utama):** Setelah login, pengguna melihat halaman utama yang menampilkan **Menu Utama Kafe**. Menu ini (beserta gambar, harga, dan deskripsi) diambil dari aset lokal aplikasi.
3.  **Keranjang:** Pengguna dapat menambahkan item dari Menu Utama ke keranjang belanja.
4.  **Pesan & Bayar:**
    * Setelah selesai, pengguna menekan tombol "Pesan".
    * Aplikasi akan langsung mengirim pesanan ke sistem admin.
    * Secara bersamaan, layar pengguna akan menampilkan **QRIS statis** milik kafe beserta total tagihan. Pelanggan diharapkan membayar secara mandiri menggunakan aplikasi pembayaran mereka.
5.  **Menu Lainnya:** Pengguna dapat mengakses halaman terpisah yang berisi info, pengumuman, atau promo spesial yang dikelola oleh admin.

### Alur Admin
1.  **Login Admin:** Admin masuk menggunakan akun khusus.
2.  **Lihat Pesanan Masuk:** Admin melihat daftar pesanan yang baru masuk secara *real-time*.
3.  **Proses Pesanan & Verifikasi Manual:** Staf menyiapkan pesanan, mengantarkannya ke meja, lalu meminta untuk melihat bukti pembayaran di ponsel pelanggan. **Tidak ada proses verifikasi di dalam aplikasi.**
4.  **CRUD Menu Lainnya:** Admin memiliki panel khusus untuk membuat, mengubah, atau menghapus konten di halaman "Menu Lainnya".

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
    flutter run -d chrome  // Untuk Web
    flutter run            // Untuk Android
    ```

### Dependensi Utama
Proyek ini menggunakan dependensi berikut (tercantum di `pubspec.yaml`):
* **`firebase_core`**: Inti koneksi Firebase.
* **`firebase_auth`**: Untuk sistem autentikasi.
* **`cloud_firestore`**: Untuk koneksi ke database Firestore.
* **`provider`**: Untuk state management (lapisan Controller).
* **`intl`**: Untuk format angka (mata uang) dan tanggal.

---

## Struktur Database (Firestore)

Ini adalah "kontrak" data antara Backend dan Frontend.

### Koleksi: `users`
* Menyimpan data profil pengguna. ID Dokumen adalah `UID` dari Firebase Authentication.
* **Fields:** `username` (String), `email` (String), `gender` (String), `createdAt` (Timestamp), `isAdmin` (Boolean, opsional).

### Koleksi: `pesanan`
* Menyimpan data setiap pesanan yang dibuat oleh pengguna.
* **Fields:** `userId` (String), `namaPemesan` (String), `noMeja` (String), `items` (Array of Maps), `totalHarga` (Number), `statusPesanan` (String: 'baru', 'selesai'), `waktuPesan` (Timestamp).

### Koleksi: `menu_tambahan`
* Menyimpan data dinamis yang dikelola oleh admin.
* **Fields:** `judul` (String), `detail` (String), `waktuPosting` (Timestamp).

---

## Struktur Aset Aplikasi

Gambar untuk **Menu Utama** disimpan secara lokal di dalam aplikasi.

* **Lokasi Folder:** `assets/images/menu/`
* **Deklarasi `pubspec.yaml`:**
    ```yaml
    flutter:
      assets:
        - assets/images/menu/
    ```

---

## Arsitektur & State Management

Proyek ini menggunakan arsitektur **MVC (Model-View-Controller)** untuk memisahkan tanggung jawab kode.

* **Model:** Struktur data yang didefinisikan di dalam folder `lib/models/`.
* **View:** Semua kode UI yang ada di dalam folder `lib/views/` (termasuk `screens` dan `widgets`).
* **Controller:** Lapisan logika bisnis dan manajemen data. Untuk ini, kami menggunakan paket **`provider`** sebagai solusi *state management*. Setiap *controller* (misalnya `AuthController`, `CartController`) akan dibuat menggunakan `ChangeNotifier` untuk mengelola logika dan memberi tahu UI ketika ada perubahan data.

```
lib/
├── models/
├── views/
│   ├── screens/
│   └── widgets/
└── controllers/
```