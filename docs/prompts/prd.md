# PRD — Aplikasi POS Kasir Simpel (Final Architecture)

## 1. Overview
Aplikasi POS kasir sederhana berbasis mobile untuk UMKM, fokus pada transaksi cepat, manajemen produk, kategori, stok, riwayat, dan tren penjualan.

Pendekatan:
- Offline-first
- Clean Architecture (strict)
- Feature hanya presentation layer
- Domain root memuat data + domain
- Cubit (state management)
- GoRouter (navigation)
- ScreenUtil (responsive)
- Service Locator (get_it)

---

## 2. Main Navigation (4 Shell)
- Home (produk + cart)
- History (riwayat transaksi)
- Trend (grafik)
- Profile (manage + settings)

---

## 3. Architecture Structure

### Feature (Presentation Only)
features/
  product/presentation/
  category/presentation/
  cart/presentation/
  stock/presentation/
  history/presentation/
  trend/presentation/
  profile/presentation/

### Domain Root
domain/
  product_domain/
    data/
    domain/
  category_domain/
    data/
    domain/
  cart_domain/
    data/
    domain/
  transaction_domain/
    data/
    domain/
  stock_domain/
    data/
    domain/
  trend_domain/
    data/
    domain/
  profile_domain/
    data/
    domain/

---

## 4. Dependency Flow

presentation → usecase → repository → datasource → database

Rules:
- Cubit hanya call usecase
- Usecase hanya call repository
- Repository impl di data layer
- Tidak boleh lompat layer

---

## 5. Core Features

### Product
- CRUD produk
- Harga
- Stok
- Minimum stok
- Active/inactive

### Category
- CRUD kategori
- Filter produk

### Stock
- Stock in/out
- Adjustment
- Stock movement log
- Low stock detection

### Cart & Checkout
- Add/remove item
- Quantity control
- Validasi stok
- Hitung total
- Input pembayaran
- Hitung kembalian
- Simpan transaksi
- Update stok

### History
- List transaksi
- Detail transaksi
- Filter tanggal

### Trend
- Total penjualan
- Total transaksi
- Grafik harian
- Produk terlaris
- Penjualan per kategori

### Profile
- Store info
- Manage product/category/stock
- Settings

---

## 6. Database Schema

### categories
id TEXT PRIMARY KEY
name TEXT
created_at INTEGER
updated_at INTEGER
deleted_at INTEGER

---

### products
id TEXT PRIMARY KEY
category_id TEXT
name TEXT
selling_price INTEGER
current_stock INTEGER
minimum_stock INTEGER
is_active INTEGER
created_at INTEGER
updated_at INTEGER
deleted_at INTEGER

---

### stock_movements
id TEXT PRIMARY KEY
product_id TEXT
type TEXT
quantity INTEGER
stock_before INTEGER
stock_after INTEGER
reference_id TEXT
created_at INTEGER

---

### transactions
id TEXT PRIMARY KEY
invoice_number TEXT
total_amount INTEGER
paid_amount INTEGER
change_amount INTEGER
total_item INTEGER
created_at INTEGER

---

### transaction_items
id TEXT PRIMARY KEY
transaction_id TEXT
product_id TEXT
product_name TEXT
category_name TEXT
product_price INTEGER
quantity INTEGER
subtotal INTEGER
created_at INTEGER

---

### store_profile
id TEXT PRIMARY KEY
store_name TEXT
owner_name TEXT
created_at INTEGER
updated_at INTEGER

---

### app_settings
id TEXT PRIMARY KEY
key TEXT
value TEXT
created_at INTEGER
updated_at INTEGER

---

## 7. Business Rules

- Stok tidak boleh minus
- Produk stok 0 tidak bisa dijual
- Checkout harus atomic
- Snapshot data wajib di transaction_items
- Semua perubahan stok harus dicatat

---

## 8. Success Criteria

- Bisa transaksi
- Stok otomatis update
- Riwayat aman
- Low stock terdeteksi
- Trend tampil
- Offline berjalan
- Arsitektur clean terjaga
