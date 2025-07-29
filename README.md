# My Cafe - Aplikasi Pemesanan Kafe ☕

Aplikasi sederhana untuk memesan makanan dan minuman di kafe. Dibuat dengan Flutter dan Firebase, bisa dijalankan di Android dan Web.

Aplikasi ini memiliki 2 jenis pengguna:
- **Pelanggan**: Bisa melihat menu, memesan, dan bayar
- **Admin**: Bisa mengelola menu dan konfirmasi pesanan

---

## 👥 Kelompok 8
**Nama Anggota:**
1. Azhriler Lintang (3337230087)
2. Cahaya Jiwa Anenda (3337230086)
3. Muhammad Zidan Heiqmatyar (3337230084)

---

## Daftar Isi
1. [Apa yang bisa dilakukan?](#apa-yang-bisa-dilakukan)
2. [Cara Install & Jalankan](#cara-install--jalankan)
3. [Teknologi yang Dipakai](#teknologi-yang-dipakai)
4. [Panduan Kontribusi](#panduan-kontribusi)
5. [Database (Firestore)](#database-firestore)
6. [Struktur Kode](#struktur-kode)

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

## Apa yang bisa dilakukan?

### 👥 **Untuk Pelanggan**
- **Melihat Menu**: Ada menu populer di halaman utama + menu lengkap dari database
- **Pesan**: Pilih menu, masukkan ke keranjang, atur jumlah
- **Bayar**: Input nomor meja, upload bukti transfer, selesai!
- **Profil**: Edit nama, gender, ganti password, atau hapus akun

### 🛠️ **Untuk Admin** 
- **Kelola Menu**: Tambah, edit, atau hapus menu
- **Terima Pesanan**: Lihat pesanan baru dan tandai selesai
- **Dashboard**: Monitor pesanan masuk secara real-time

### 🔐 **Sistem Login**
- Daftar/masuk dengan email dan password
- Otomatis dibedakan antara pelanggan dan admin
- Bisa reset password lewat email

## Cara Install & Jalankan

**Yang perlu disiapkan:**
- Flutter SDK (versi 3.x.x ke atas)
- Android Studio atau VS Code

### Langkah-langkah:

1.  **Download kode:**
    ```bash
    git clone https://github.com/Azhriler7/flutter-mycafe.git
    cd flutter-mycafe/mycafe
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Jalankan aplikasi:**
    ```bash
    flutter run -d chrome    # Untuk Web
    flutter run              # Untuk Android
    ```

**Catatan:** Proyek sudah include konfigurasi Firebase, jadi bisa langsung dijalankan tanpa setup tambahan.

## Teknologi yang Dipakai

- **Flutter**: Framework untuk buat app Android & Web
- **GetX**: Untuk mengatur state/data di app
- **Firebase**: Database dan sistem login
- **Dart**: Bahasa pemrograman Flutter

### Library Utama:
```yaml
firebase_core & firebase_auth  # Sistem login
cloud_firestore               # Database real-time  
get                          # State management
intl                         # Format mata uang
```

## Panduan Kontribusi

jika ingin menambahkan fitur:

1. **Update kode terbaru:** `git checkout main` lalu `git pull origin main`
2. **Buat branch baru:** `git checkout -b feature/nama-fitur-baru`  
3. **Koding & commit:** `git add .` lalu `git commit -m "pesan commit"`
4. **Upload:** `git push -u origin feature/nama-fitur-baru`
5. **Buat Pull Request** di GitHub

**Aturan:** Jangan langsung edit di branch `main`, selalu bikin branch baru!

## Database (Firestore)

Ini adalah struktur data final antara Backend dan Frontend.

### Koleksi: `users`
* **Tujuan:** Menyimpan data profil pengguna dan role access.
* **ID Dokumen:** `UID` dari Firebase Authentication.
* **Fields:** `username` (String), `email` (String), `gender` (String), `createdAt` (Timestamp), `isAdmin` (Boolean).

### Koleksi: `menu`
* **Tujuan:** Menyimpan semua item menu yang bisa dipesan dan dikelola oleh admin.
* **ID Dokumen:** Auto-ID oleh Firestore.
* **Fields:** `namaMenu` (String), `harga` (Number), `kategori` (String), `isTersedia` (Boolean).

### Koleksi: `pesanan`
* **Tujuan:** Menyimpan data setiap pesanan yang sudah final dan di-submit.
* **ID Dokumen:** Auto-ID oleh Firestore.
* **Fields:** `userId` (String), `namaPemesan` (String), `noMeja` (String), `items` (Array of Maps), `totalHarga` (Number), `statusPesanan` (String: 'baru', 'selesai'), `waktuPesan` (Timestamp), `buktiPembayaran` (String).

---

## Contoh Isi Dokumen Firestore

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

## Struktur Kode

Kode diatur dengan pola **MVC** (Model-View-Controller):

```
lib/
├── controller/     # Logika bisnis (GetX controllers)
├── model/         # Model data 
├── view/          # Tampilan UI
│   ├── screen/    # Halaman-halaman app
│   └── widget/    # Komponen UI yang bisa dipakai ulang
└── main.dart      # File utama
```

**Yang perlu tahu:**
- **Model**: Bentuk data (user, menu, pesanan)
- **View**: Yang keliatan di layar
- **Controller**: Yang ngatur data dan logika
- **GetX**: Buat state management yang reactive (otomatis update UI kalau data berubah)