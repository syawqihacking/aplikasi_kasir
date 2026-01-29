# Fitur Baru: Diskon dan Kategorisasi Produk

## 1. Fitur Diskon (Discount)

### Deskripsi
Fitur diskon memungkinkan Anda memberikan diskon dalam bentuk persentase untuk setiap item yang dijual. Diskon akan mengurangi harga jual dan otomatis mengurangi laba bersih transaksi.

### Implementasi Teknis

#### Model yang Diubah
- **TransactionItem** (`lib/models/transaction_item.dart`)
  - Tambah field: `discountPercent: double` (default 0.0)
  - Tambah getter: `discountAmount` - menghitung nominal diskon
  - Tambah getter: `finalPrice` - harga setelah diskon
  - Update getter: `profit` - menghitung profit berdasarkan harga setelah diskon

- **CartItem** (baru - `lib/models/cart_item.dart`)
  - Model untuk mengelola item di keranjang belanja
  - Fields: `product`, `quantity`, `discountPercent`
  - Getter: `discountAmount`, `finalPrice`, `subtotal`, `profit`

#### Database
- Database version diupdate dari 3 menjadi 4
- Migration: Tambah kolom `discount_percent REAL DEFAULT 0.0` di tabel `transaction_items`

#### UI & Dialog
- **CartItemDialog** (baru - `lib/widgets/cart_item_dialog.dart`)
  - Dialog untuk input diskon per item
  - Preview real-time untuk diskon nominal dan harga akhir
  - Navigasi dari tombol "Tambah Diskon" / "Ubah Diskon" di keranjang

#### POS Page
- Ubah struktur cart dari `Map<Product, int>` menjadi `List<CartItem>`
- Tambah tombol "Tambah Diskon" / "Ubah Diskon" di setiap item keranjang
- Update kalkulasi `totalGross` dan `totalNet` untuk memperhitungkan diskon
- Display diskon dalam format amber highlight di cart item

#### Transaction Service
- Update `createTransaction()` untuk menerima `List<CartItem>` sebagai parameter
- Simpan `discount_percent` setiap item saat transaksi disimpan
- Legacy method `createTransactionLegacy()` untuk backward compatibility

### Cara Menggunakan
1. Tambahkan produk ke keranjang belanja di POS
2. Klik tombol "➕ Tambah Diskon" pada item yang ingin didiskon
3. Masukkan persentase diskon (0-100%)
4. Lihat preview diskon nominal dan harga akhir
5. Klik "Simpan"
6. Diskon akan otomatis mengurangi total bayar dan laba bersih

---

## 2. Fitur Kategorisasi Produk

### Deskripsi
Fitur ini memungkinkan pengelompokan produk berdasarkan kategori dan sorting otomatis. Produk akan ditampilkan terkelompok per kategori di halaman inventori.

### Implementasi Teknis

#### Model
- **Product** sudah memiliki field `category: String`
- Tidak perlu perubahan model

#### Inventory Page
- State tambahan: `String? selectedCategory` untuk filter kategori aktif
- Method baru: `categories` getter - ekstrak unique categories dan sort
- Update `filteredProducts` getter:
  - Filter berdasarkan search query
  - Filter berdasarkan kategori terpilih
  - Sort otomatis: kategori terlebih dahulu, kemudian nama produk

#### UI Changes
- Tambah dropdown filter kategori di header sebelum search bar
- Tambah kolom "🏷️ Kategori" di tabel produk (setelah kolom Nama Produk)
- Kategori ditampilkan dengan styling badge biru

#### Product Management
- ProductFormDialog sudah mendukung input kategori
- Kategori dapat diedit saat membuat atau mengubah produk

### Cara Menggunakan
1. Buka halaman Inventori
2. Lihat dropdown "Semua Kategori" di bagian filter
3. Pilih kategori yang ingin dilihat
4. Produk akan otomatis difilter dan disort sesuai kategori
5. Kombinasi dengan search untuk hasil lebih spesifik

### Contoh Kategori
- Elektronik
- Peralatan Rumah Tangga
- Fashion
- Makanan & Minuman
- Kosmetik
- dll.

---

## 3. Perubahan Database

### Migration dari v3 ke v4
```sql
ALTER TABLE transaction_items ADD COLUMN discount_percent REAL DEFAULT 0.0
```

---

## 4. File-File Baru

1. `lib/models/cart_item.dart` - Model CartItem
2. `lib/widgets/cart_item_dialog.dart` - Dialog untuk input diskon

---

## 5. File-File yang Dimodifikasi

1. `lib/pages/pos_page.dart` - Integrasi diskon dan CartItem
2. `lib/pages/inventory_page.dart` - Tambah kategori filter dan sorting
3. `lib/models/transaction_item.dart` - Tambah field diskon
4. `lib/models/cart_item.dart` - Baru
5. `lib/services/transaction_service.dart` - Support CartItem dan diskon
6. `lib/services/database_service.dart` - Migrate to v4

---

## 6. Testing Checklist

- [ ] Tambah produk dengan berbagai kategori
- [ ] Filter inventory berdasarkan kategori
- [ ] Sorting produk otomatis per kategori
- [ ] Tambah item ke keranjang di POS
- [ ] Berikan diskon pada item
- [ ] Verifikasi perhitungan harga dan profit dengan diskon
- [ ] Checkout transaksi dengan diskon
- [ ] Verifikasi data transaksi tersimpan dengan benar

---

## 7. Catatan Penting

- Diskon hanya berlaku per-item, tidak ada diskon total transaksi (untuk sekarang)
- Diskon maksimal tidak ada limitasi (bisa 0-100% atau lebih)
- Kategori bersifat text, bukan tabel terpisah (untuk fleksibilitas)
- Migration otomatis saat aplikasi di-launch untuk existing database
