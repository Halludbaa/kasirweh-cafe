# Kasirweh Cafe

**Kasirweh Cafe** (`simple_coffee_shop`) adalah aplikasi kasir (POS) sederhana berbasis [Flutter](https://flutter.dev) untuk keperluan bisnis kecil/mikro seperti kafe dan UMKM. Seluruh data disimpan secara lokal di perangkat (SQLite) sehingga aplikasi berjalan offline-first tanpa perlu server atau akun.

## Fitur Utama

- **Halaman PIN** - akses aplikasi dilindungi PIN 6 digit (default: `000000`).
- **Halaman Utama** - grafik pemasukan 7 hari terakhir (fl_chart), nama toko di bagian atas (default `"TOKO ANDA"`), dan Quick Access ke Catalog, Invoice list, Edit catalog, dan Settings.
- **Katalog Produk** - produk dengan gambar, kategori, dan harga; dapat ditambah/diubah/dihapus.
- **Aktif/Nonaktif Produk** - produk nonaktif hilang dari POS tetapi tetap tersimpan di master & riwayat (soft delete via `is_active`).
- **Checkout** - daftar barang pesanan dengan dua metode pembayaran: Tunai (hitung kembalian otomatis) dan QRIS statis (QR dummy).
- **Konfirmasi Pembayaran** - menampilkan metode pembayaran, tombol Batal & Selesaikan; invoice tersimpan dalam satu transaksi SQLite.
- **Cetak Struk/Invoice** - cetak via printer termal Bluetooth (`print_bluetooth_thermal`). Jika tidak ada printer/perangkat terhubung, proses cetak dilewati tanpa error.
- **Riwayat Invoice** - daftar transaksi beserta detailnya, lengkap dengan snapshot nama & harga produk saat transaksi terjadi.
- **Edit Catalog** - daftar produk dengan tombol edit, toggle aktif/nonaktif, dan hapus via geser ke kiri (flutter_slidable).
- **Pengaturan Toko** - ubah nama toko yang tampil di header aplikasi dan struk.
- **Seed Awal** - saat pertama kali dijalankan, database diisi kategori (Kopi, Non-Kopi, Makanan) dan produk dummy agar POS langsung bisa dicoba.

## Preview

![example 1](./doc-1.png)![example 2](./doc-2.png)![example 3](./doc-3.png)

## Teknologi & Dependensi

| Paket | Kegunaan |
|---|---|
| [get](https://pub.dev/packages/get) | Manajemen state, dependency injection, dan routing (GetX) |
| [sqflite](https://pub.dev/packages/sqflite) + [path](https://pub.dev/packages/path) | Database lokal SQLite |
| [intl](https://pub.dev/packages/intl) | Format Rupiah & tanggal (lokal `id_ID`) |
| [fl_chart](https://pub.dev/packages/fl_chart) | Grafik pemasukan harian di halaman utama |
| [flutter_slidable](https://pub.dev/packages/flutter_slidable) | Aksi hapus dengan geser pada daftar katalog |
| [qr_flutter](https://pub.dev/packages/qr_flutter) | Render QRIS statis saat checkout |
| [print_bluetooth_thermal](https://pub.dev/packages/print_bluetooth_thermal) | Cetak struk via printer termal Bluetooth |
| [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi) (dev) | Menjalankan tes SQLite di desktop/CI |

Platform yang didukung scaffolding: Android, iOS, dan Web.

## Struktur Proyek

```
lib/
|-- main.dart                     # Bootstrap: init DB + registrasi repository global (permanent)
|-- app/
|   |-- app.dart                  # Konfigurasi GetMaterialApp (tema, rute awal)
|   |-- routes/
|   |   |-- app_pages.dart        # Definisi halaman + binding controller
|   |   '-- app_routes.dart       # Nama-nama rute
|   '-- theme/app_theme.dart      # Tema aplikasi
|-- core/
|   |-- constants/app_constants.dart  # Default (nama toko, PIN, gambar produk)
|   '-- utils/formatters.dart         # Format Rupiah, tanggal/waktu
|-- data/
|   |-- local/db_helper.dart      # Skema SQLite + seed awal
|   |-- models/                   # CartItem, Category, Product, Order, OrderItem
|   |-- repositories/             # Category, Product, Order, Settings
|   '-- services/print_service.dart  # Cetak struk (aman tanpa printer)
'-- modules/
    |-- pin/                      # Halaman PIN
    |-- home/                     # Dashboard: grafik + quick access
    |-- catalog/                  # Katalog POS, edit catalog, form produk
    |-- checkout/                 # Keranjang + pilih metode bayar (tunai/QRIS)
    |-- payment/                  # Konfirmasi pembayaran + simpan invoice + print
    |-- invoices/                 # Daftar & detail invoice
    |-- settings/                 # Ubah nama toko
    '-- shared/                   # ProductImage helper + session controllers
```

### Skema Database (SQLite)

```
settings      (key, value)                                  # nama toko, PIN
categories    (id, name, sort_order, created_at)
products      (id, category_id, name, price, image_path,
               is_active, created_at, updated_at)
orders        (id, invoice_no, total, paid, change_amount,
               payment_method ['cash'|'qris'], created_at)
order_items   (id, order_id, product_id, product_name,
               unit_price, qty, line_total)                 # snapshot produk
```

Harga disimpan sebagai INTEGER rupiah utuh. Checkout (`orders` + seluruh `order_items`) dilakukan dalam satu transaksi.

## Menjalankan Aplikasi

### Prasyarat

- Flutter SDK >= 3.x (Dart SDK `^3.9.2`) - lihat [instalasi Flutter](https://docs.flutter.dev/get-started/install)
- Android Studio / Xcode (untuk build platform masing-masing), atau browser untuk mode web

### Langkah

```bash
# 1. Ambil dependensi
flutter pub get

# 2. Jalankan di perangkat/emulator terpilih
flutter run

# Atau spesifik per platform:
flutter run -d chrome     # web
flutter run -d android    # Android
```

PIN default saat pertama kali membuka aplikasi: `000000`.

### Menjalankan Tes

```bash
flutter test
```

Tes (`test/kasir_flow_test.dart`) memverifikasi alur end-to-end menggunakan SQLite FFI: seed database, pengaturan nama toko & PIN, CRUD produk, hingga checkout yang menyimpan invoice.

### Build Release

```bash
flutter build apk        # Android
flutter build ios        # iOS (perlu macOS + signing)
flutter build web        # Web
```

## Catatan Penting

- **Cetak struk bersifat opsional**: jika tidak ada printer Bluetooth yang terhubung (atau izin belum diberikan), aplikasi tetap berjalan normal - pencetakan cukup dilewati.
- **QRIS yang ditampilkan adalah QR dummy** untuk demo pembayaran statis, bukan integrasi payment gateway sungguhan.
- **Hapus produk tidak permanen** pada alur POS: produk dinonaktifkan (`is_active = 0`) agar riwayat/struk lama tetap konsisten; riwayat hanya menampilkan snapshot produk saat transaksi.
- **Keranjang belanja berada di memori** (controller); aplikasi yang ditutup sebelum bayar akan mengosongkan keranjang.
- **Gambar produk V1** menggunakan aset dummy di `assets/images/products/`; kolom `image_path` sudah disiapkan untuk mendukung file lokal di versi berikutnya.

## Lisensi

Proyek pribadi untuk keperluan UMKM - belum menentukan lisensi resmi.
