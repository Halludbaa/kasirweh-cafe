Keputusan V1 sudah cukup jelas. Berikut rancangan yang disesuaikan — masih tanpa kode.

## Keputusan yang terkunci

| Topik | V1 |
|---|---|
| Pajak / service | Tidak ada. Total = jumlah `qty × harga`. Kolom `discount` / `tax` di `orders` **tidak perlu**. |
| Varian (S/M/L, extra) | Tidak. Satu baris = satu produk jual, misalnya “Americano” dan “Americano Ice” terpisah. |
| Gambar | Ada dari awal, **dummy dari asset** dulu. |
| Hapus produk | Tidak hapus keras. `is_active = 0` (nonaktif), hilang dari POS, tetap di master & riwayat. |
| Login | Tidak ada. Buka app langsung ke kasir. |

---

## Gambar dummy: cara kerjanya

Jangan ambil dari galeri dulu. Bundel beberapa file di project, seed database mengarah ke file itu.

```
assets/images/products/
  americano.png
  latte.png
  croissant.png
  default.png          # fallback jika path kosong/rusak
```

Di `pubspec.yaml` daftarkan folder itu. Di tabel `products`, kolom `image_path` menyimpan **kunci asset**, bukan URL:

```
image_path TEXT  -- contoh: assets/images/products/americano.png
```

Tampilan:

1. Jika `image_path` terisi dan file ada di asset → `Image.asset(...)`
2. Jika kosong atau gagal → `default.png` atau ikon kopi

Nanti (bukan V1 wajib): user pilih foto dari galeri, simpan ke penyimpanan app, isi `image_path` dengan path file. UI tetap sama jika kita bungkus satu helper `ProductImage(path)` yang membedakan:

- path diawali `assets/` → asset  
- selain itu → file lokal  

Skema DB **tidak perlu diubah** saat fitur upload ditambah.

CRUD produk V1: dropdown atau grid pilih **salah satu dummy**, bukan file picker. Cukup untuk terlihat “ada foto”, tanpa izin storage.

---

## Skema SQLite V1 (disederhanakan)

```
categories
  id, name, sort_order, created_at

products
  id
  category_id
  name
  price            -- INTEGER rupiah utuh
  image_path       -- asset dummy
  is_active        -- 1 jual, 0 tersembunyi di POS
  created_at, updated_at

orders
  id
  invoice_no
  total            -- = sum line_total
  paid
  change_amount
  payment_method   -- 'cash'
  created_at

order_items
  id
  order_id
  product_id       -- referensi lunak, bukan FK ketat
  product_name     -- snapshot
  unit_price       -- snapshot
  qty
  line_total
```

Tidak ada `subtotal` / `discount` / `tax`. Struk: daftar item + **Total** + tunai + kembalian.

Checkout tetap satu transaksi SQLite (`orders` + semua `order_items`).

---

## Perilaku nonaktif

- POS hanya `WHERE is_active = 1`
- Halaman produk menampilkan semua, dengan toggle / badge Nonaktif
- Nonaktifkan: `UPDATE ... SET is_active = 0` — baris tetap ada
- Riwayat lama tetap menampilkan `product_name` / `unit_price` dari snapshot, meski produk sudah nonaktif atau namanya berubah
- Tidak ada tombol hapus permanen di V1 (menghindari struk yatim)

---

## Alur app tanpa login

```
Splash (init DB + seed jika kosong)
  → POS (halaman utama)
```

Navigasi samping atau bawah: **Kasir · Produk · Riwayat**. Pengaturan (nama kafe) boleh belakangan; tidak memblokir V1.

Seed pertama kali: beberapa kategori (Kopi, Non-Kopi, Makanan) + produk dummy berharga + gambar asset, supaya POS langsung bisa dicoba.

Keranjang hanya di `PosController` (GetX). Hilang jika app di-kill sebelum bayar — wajar untuk V1.

---

## GetX (tidak berubah)

- Global: `DbHelper` + repository, `permanent: true` setelah DB siap  
- Per halaman: binding + controller  
- Rute bernama, tanpa middleware auth  

`PosController`: filter kategori, daftar produk aktif, `RxList` keranjang, hitung `total`, dialog tunai/kembalian, panggil `OrderRepository.create`.

---

## Yang tidak dibangun di V1

Pajak, diskon, varian, stok, meja, printer, sync cloud, PIN kasir, pilih foto dari galeri.

---

Urutan implementasi nanti tetap: fondasi GetX + DB + seed → CRUD produk (termasuk pilih gambar dummy + nonaktif) → POS + checkout tunai → riwayat.

Kalau ini sudah pas, bilang saja untuk mulai dari fondasi (dependensi, folder, rute, SQLite + seed).

Keputusan V1 sudah cukup jelas. Berikut rancangan yang disesuaikan — masih tanpa kode.

## Keputusan yang terkunci

| Topik | V1 |
|---|---|
| Pajak / service | Tidak ada. Total = jumlah `qty × harga`. Kolom `discount` / `tax` di `orders` **tidak perlu**. |
| Varian (S/M/L, extra) | Tidak. Satu baris = satu produk jual, misalnya “Americano” dan “Americano Ice” terpisah. |
| Gambar | Ada dari awal, **dummy dari asset** dulu. |
| Hapus produk | Tidak hapus keras. `is_active = 0` (nonaktif), hilang dari POS, tetap di master & riwayat. |
| Login | Tidak ada. Buka app langsung ke kasir. |

---

## Gambar dummy: cara kerjanya

Jangan ambil dari galeri dulu. Bundel beberapa file di project, seed database mengarah ke file itu.

```
assets/images/products/
  americano.png
  latte.png
  croissant.png
  default.png          # fallback jika path kosong/rusak
```

Di `pubspec.yaml` daftarkan folder itu. Di tabel `products`, kolom `image_path` menyimpan **kunci asset**, bukan URL:

```
image_path TEXT  -- contoh: assets/images/products/americano.png
```

Tampilan:

1. Jika `image_path` terisi dan file ada di asset → `Image.asset(...)`
2. Jika kosong atau gagal → `default.png` atau ikon kopi

Nanti (bukan V1 wajib): user pilih foto dari galeri, simpan ke penyimpanan app, isi `image_path` dengan path file. UI tetap sama jika kita bungkus satu helper `ProductImage(path)` yang membedakan:

- path diawali `assets/` → asset  
- selain itu → file lokal  

Skema DB **tidak perlu diubah** saat fitur upload ditambah.

CRUD produk V1: dropdown atau grid pilih **salah satu dummy**, bukan file picker. Cukup untuk terlihat “ada foto”, tanpa izin storage.

---

## Skema SQLite V1 (disederhanakan)

```
categories
  id, name, sort_order, created_at

products
  id
  category_id
  name
  price            -- INTEGER rupiah utuh
  image_path       -- asset dummy
  is_active        -- 1 jual, 0 tersembunyi di POS
  created_at, updated_at

orders
  id
  invoice_no
  total            -- = sum line_total
  paid
  change_amount
  payment_method   -- 'cash'
  created_at

order_items
  id
  order_id
  product_id       -- referensi lunak, bukan FK ketat
  product_name     -- snapshot
  unit_price       -- snapshot
  qty
  line_total
```

Tidak ada `subtotal` / `discount` / `tax`. Struk: daftar item + **Total** + tunai + kembalian.

Checkout tetap satu transaksi SQLite (`orders` + semua `order_items`).

---

## Perilaku nonaktif

- POS hanya `WHERE is_active = 1`
- Halaman produk menampilkan semua, dengan toggle / badge Nonaktif
- Nonaktifkan: `UPDATE ... SET is_active = 0` — baris tetap ada
- Riwayat lama tetap menampilkan `product_name` / `unit_price` dari snapshot, meski produk sudah nonaktif atau namanya berubah
- Tidak ada tombol hapus permanen di V1 (menghindari struk yatim)

---

## Alur app tanpa login

```
Splash (init DB + seed jika kosong)
  → POS (halaman utama)
```

Navigasi samping atau bawah: **Kasir · Produk · Riwayat**. Pengaturan (nama kafe) boleh belakangan; tidak memblokir V1.

Seed pertama kali: beberapa kategori (Kopi, Non-Kopi, Makanan) + produk dummy berharga + gambar asset, supaya POS langsung bisa dicoba.

Keranjang hanya di `PosController` (GetX). Hilang jika app di-kill sebelum bayar — wajar untuk V1.

---

## GetX (tidak berubah)

- Global: `DbHelper` + repository, `permanent: true` setelah DB siap  
- Per halaman: binding + controller  
- Rute bernama, tanpa middleware auth  

`PosController`: filter kategori, daftar produk aktif, `RxList` keranjang, hitung `total`, dialog tunai/kembalian, panggil `OrderRepository.create`.

---

## Yang tidak dibangun di V1

Pajak, diskon, varian, stok, meja, printer, sync cloud, PIN kasir, pilih foto dari galeri.

---

Urutan implementasi nanti tetap: fondasi GetX + DB + seed → CRUD produk (termasuk pilih gambar dummy + nonaktif) → POS + checkout tunai → riwayat.

Kalau ini sudah pas, bilang saja untuk mulai dari fondasi (dependensi, folder, rute, SQLite + seed).

ada beberpa yang saya ingin rubah dibagian login, Saat pertama kali membuka pengguna perlu memasukan pin 6 digit default 000 000.

Tambahkan fitur print invoice, pastikan tidak membuat error ketika tidak ada perangkat yang terhubung.
Jika statusnya tidak ada printer atau perangkat (Abaikan saja).

Bagi aplikasi menjadi beberapa bagian.
- Halaman PIN
- Halaman Utama: Grafik Pemasukan, Qucik Access (Catalog, Invoice list, Edit catalog, Settings)) Bagian atas tunjukan nama toko default "TOKO ANDA"
- Halaman Checkout (Pembayaran QRIS dan Tunai, menunjukan barang-barang yang di pesan)
- Halaman konfirmasi pembayaran. (Tampilkan metode pembayaran (tunai/qris), dan 2 tombol batal dan selesaikan pembayaran). -> proses print jika printer tersedia abaikan jika tidak ada
- Halaman Edit Catalog (Gunakan list dengan tombol edit (pencil), tombol toggle aktif/nonaktif, geser ke kiri untuk memunculkan tombol hapus).
- Halaman Settings (Ubah nama toko)

Pastikan semunya berjalan
