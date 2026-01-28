## 🚀 Quick Start - Testing Fitur Baru

### Demo Account
```
Email: admin@example.com
Password: admin123
Role: Admin
```

### Fitur #3: Multi-Kasir / User Roles
**Cara Test:**
1. Login dengan admin account
2. Klik **Settings** → Scroll ke bagian fitur
3. Atau navigate ke `/users` route
4. Klik tombol **+** untuk tambah kasir baru
5. Isi:
   - Nama: "Kasir 1"
   - Email: "kasir1@example.com"
   - Password: "kasir123"
   - Role: "cashier" (dropdown)
6. Klik **Tambah**
7. Logout & login dengan kasir1 account
8. Perhatikan: Role berbeda → permission berbeda

---

### Fitur #4: Notifikasi Stok Otomatis
**Status:** Siap integrasi di ProductService
**Cara Activate:**
1. Check `product.stock < product.minStock`
2. Tampilkan alert/warning di:
   - Inventory page (red badge)
   - POS page (stok warning)
   - Dashboard (low stock widget)

---

### Fitur #5: Kategori Produk
**Cara Test:**
1. Navigate ke `/categories` atau Settings
2. Klik tombol **+** untuk add kategori
3. Input:
   - Nama: "Laptop Gaming"
   - Deskripsi: "Gaming laptop dengan spesifikasi tinggi"
4. Klik **Tambah**
5. Repeat untuk kategori lain
6. Saat create product, pilih kategori

---

### Fitur #6: Metode Pembayaran Beragam
**Default Methods (Auto-Created):**
- ✅ Tunai (Cash)
- ✅ Transfer Bank
- ✅ E-Wallet
- ✅ Kartu Kredit

**Cara Test:**
1. Buka POS page
2. Tambahkan produk ke cart
3. Di checkout → Pilih metode pembayaran (dropdown)
4. Finalisasi transaksi
5. Cek di database: `transactions.payment_method_id`

---

### Fitur #7: Refund / Return Management
**Cara Test:**
1. Pastikan sudah ada transaksi
2. Di POS page → Klik tombol **"Catat Retur"**
3. Input form:
   - Alasan: "Produk rusak"
   - Qty Retur: 1
   - Jumlah Refund: 15000000 (harga jual)
   - Catatan: "Rusak saat pengiriman"
4. Klik **Simpan Retur**
5. Stok otomatis bertambah
6. Total transaksi otomatis berkurang
7. Lihat history di `/returns` page

**Expected Result:**
- ✅ Return item tersimpan di database
- ✅ Stok produk restored (+1)
- ✅ Total transaksi updated (kurangi refund)
- ✅ Muncul di return management dashboard

---

### Fitur #9: Expense Tracking
**Cara Test:**
1. Di POS page → Klik tombol **"Catat Pengeluaran"**
2. Input form:
   - Kategori: "Supplies" (dropdown)
   - Deskripsi: "Beli tinta printer"
   - Jumlah: 150000
3. Klik **Simpan**
4. Navigate ke `/expenses` page
5. Lihat:
   - Total pengeluaran
   - Breakdown per kategori
   - List semua expense dengan detail

**Expected Result:**
- ✅ Expense tersimpan dengan kategori
- ✅ Total terakumulasi otomatis
- ✅ Breakdown per kategori muncul
- ✅ created_by_user_id = kasir yang input

---

## 🔍 Testing Checklist

### Login System
- [ ] Login dengan admin account berhasil
- [ ] Login dengan kasir account berhasil
- [ ] Password salah → error message
- [ ] Route /login accessible

### User Management
- [ ] Tambah kasir baru
- [ ] List all users
- [ ] Logout → redirect ke login

### Kategori
- [ ] Create kategori
- [ ] List kategori
- [ ] Delete kategori
- [ ] Kategori muncul saat create product

### Payment Methods
- [ ] 4 default methods exist
- [ ] Pilih payment saat transaksi
- [ ] Payment method tersimpan di transaction

### Return Management
- [ ] Catat retur
- [ ] Stok restored
- [ ] Total transaksi berkurang
- [ ] Return history tampil di /returns

### Expense Tracking
- [ ] Catat expense
- [ ] Kategori terasign
- [ ] Total breakdown kerja
- [ ] List expense tampil

---

## 🎨 UI Navigation

Setelah login, kasir dapat akses:
```
Dashboard → Kasir → Inventory → Reports → Settings
                                              ↓
                                    (Settings page)
                                         ↓
                        Shows all features info
                                         ↓
                        + Logout button
```

Admin mendapat akses tambahan ke:
```
Settings → Manage Users
        → Manage Categories
        → View Expenses
        → View Returns
```

---

## ⚙️ Technical Notes

### Database Migration
- Version: 3 (updated from 2)
- Automatic migration untuk existing database
- New tables: users, categories, payment_methods, return_items, expenses
- Updated columns: transactions (payment_method_id, created_by_user_id)

### Transaction Flow
```
1. User login → session start
2. Select products → cart
3. Choose payment method
4. Input service fee (opsional)
5. Checkout → transaction created
6. Transaction recorded with:
   - payment_method_id
   - created_by_user_id
   - timestamps
```

### Return Flow
```
1. Select transaction
2. Input return details
3. System:
   - Create return_item record
   - Restore product stock
   - Update transaction total (gross & net)
```

### Expense Flow
```
1. Click "Catat Pengeluaran" button
2. Select category
3. Input amount & description
4. System:
   - Create expense record
   - Track created_by user
   - Store creation date
```

---

## 🐛 Known Issues & TODO

1. **🔒 Password Security**
   - Current: Plain text (NOT SECURE!)
   - TODO: Implement bcrypt hashing
   - Line to fix: `lib/models/user.dart` (toMap/fromMap)

2. **📢 Stock Notifications**
   - Schema ready, UI not implemented
   - TODO: Add alert widget to dashboard/inventory
   - Check: `product.stock < product.minStock`

3. **👮 Permission System**
   - Current: Role-based only (admin/cashier)
   - TODO: Granular permissions per action
   - Example: Cashier cannot access /users

4. **💾 Data Persistence**
   - No cloud backup yet
   - Local SQLite only
   - TODO: Add cloud sync option

---

Created: 28 Jan 2026
Status: ✅ Ready for Testing
