# Sprint Plan — POS Kasir Simpel

Durasi: 2 minggu (14 hari)  
Fokus: Build MVP dari 0 sampai siap demo portfolio

---

## Sprint Goal

- Aplikasi POS fully working (offline)
- Clean Architecture terimplementasi
- 4 main shell berjalan
- Transaksi + stok + history + trend basic

---

## Day 1 — Project Setup

- Init project Flutter
- Setup folder structure (core, features, domain)
- Install dependencies:
  - flutter_bloc
  - get_it
  - go_router
  - drift
  - screenutil
- Setup service locator (sl)
- Setup base theme

DONE jika:
- Project run tanpa error
- Struktur folder sesuai arsitektur

---

## Day 2 — Database Setup

- Setup Drift database
- Create tables:
  - categories
  - products
  - stock_movements
  - transactions
  - transaction_items
- Generate DAO

DONE jika:
- Semua table bisa di-query basic

---

## Day 3 — Category Feature

- Entity
- Repository
- Usecases:
  - get categories
  - create category
- Cubit
- UI basic list + create

DONE jika:
- Bisa CRUD kategori

---

## Day 4 — Product Feature (Part 1)

- Entity
- Repository
- Usecases:
  - get products
  - create product

DONE jika:
- Produk bisa ditampilkan & ditambah

---

## Day 5 — Product Feature (Part 2)

- Update & delete product
- Product Cubit
- UI:
  - product list
  - product form

DONE jika:
- CRUD produk selesai

---

## Day 6 — Stock Feature

- Stock logic
- Stock movement
- Usecases:
  - update stock
  - get low stock
- UI manage stock

DONE jika:
- Stok bisa update + tercatat

---

## Day 7 — Cart

- Cart Cubit
- Add/remove/update item
- Hitung total

DONE jika:
- Cart berfungsi normal

---

## Day 8 — Checkout

- Checkout usecase
- Validasi stok
- Simpan transaksi
- Update stok
- Clear cart

DONE jika:
- Transaksi sukses end-to-end

---

## Day 9 — Checkout UI

- Checkout screen
- Payment input
- Success screen

DONE jika:
- Flow checkout usable

---

## Day 10 — History

- Transaction repository
- Usecases:
  - get history
  - get detail
- UI:
  - list
  - detail

DONE jika:
- History tampil lengkap

---

## Day 11 — Trend

- Aggregation query
- Usecases:
  - total sales
  - daily sales
- UI:
  - summary
  - chart basic

DONE jika:
- Trend tampil (basic)

---

## Day 12 — Profile & Settings

- Store profile
- Settings
- UI profile page

DONE jika:
- Profile & settings working

---

## Day 13 — Navigation

- Setup GoRouter shell
- 4 tabs:
  - Home
  - History
  - Trend
  - Profile

DONE jika:
- Navigasi stabil tanpa bug

---

## Day 14 — Polish & QA

- UI polish (spacing, typography)
- Loading state
- Error state
- Edge case:
  - stok habis
  - pembayaran kurang
- Bug fixing

DONE jika:
- App siap demo & portfolio

---

## Final Output

- App bisa transaksi
- Stok update otomatis
- Ada history
- Ada trend
- Clean architecture jelas
- UI clean & usable
