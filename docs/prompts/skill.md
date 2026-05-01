# Skills & Technical Decisions — POS Kasir Simpel

Dokumen ini menjelaskan skill teknis dan keputusan arsitektur yang digunakan dalam project POS Kasir Simpel.

---

## 1. Clean Architecture

Project ini menggunakan Clean Architecture dengan pemisahan yang jelas:

- Presentation Layer → features/
- Domain Layer → domain/*/domain
- Data Layer → domain/*/data

### Tujuan
- Maintainability
- Testability
- Scalability

### Implementasi
- Cubit hanya memanggil usecase
- Usecase hanya bergantung pada repository abstraction
- Repository implementation berada di data layer
- Tidak ada akses langsung dari UI ke database

---

## 2. Modular Domain Structure

Struktur domain dipisah per fitur:

- product_domain
- category_domain
- stock_domain
- transaction_domain
- trend_domain
- profile_domain

### Tujuan
- Isolasi logic
- Memudahkan scaling
- Menghindari tight coupling

### Cross Domain Rule
Domain boleh berinteraksi dengan domain lain melalui:
- repository abstraction
- usecase

---

## 3. State Management (Cubit)

Menggunakan Cubit dari flutter_bloc.

### Alasan
- Simpel dibandingkan Bloc
- Cocok untuk app skala kecil–menengah
- Lebih readable

### Penggunaan
- ProductCubit → manage produk
- CartCubit → manage cart
- CheckoutCubit → handle transaksi
- StockCubit → manage stok
- TrendCubit → analytics

---

## 4. Offline-first Strategy

Aplikasi tidak bergantung pada internet.

### Implementasi
- Database lokal menggunakan Drift (SQLite)
- Semua transaksi disimpan lokal
- Tidak ada API dependency

### Keuntungan
- Cepat
- Reliable
- Cocok untuk UMKM

---

## 5. Database Design (Drift)

Menggunakan Drift sebagai ORM SQLite.

### Kenapa Drift
- Type-safe query
- Reactive query support
- Cocok untuk Flutter

### Design Principles
- Semua harga menggunakan INTEGER
- Timestamp menggunakan millisecondsSinceEpoch
- Snapshot data di transaction_items

---

## 6. Stock Management System

Stok dipisahkan menjadi domain sendiri.

### Alasan
- Stok adalah concern penting
- Digunakan di banyak flow (product, checkout, trend)

### Implementasi
- stock_movements table
- Semua perubahan stok dicatat
- Tidak ada perubahan stok tanpa log

---

## 7. Transaction System

Checkout dibuat sebagai atomic operation.

### Flow
1. Validasi cart
2. Validasi stok
3. Simpan transaksi
4. Simpan transaction items
5. Update stok
6. Simpan stock movement
7. Clear cart

### Tujuan
- Data consistency
- Menghindari partial transaction

---

## 8. Routing (GoRouter)

Menggunakan GoRouter dengan shell route.

### Struktur
- 4 main tab:
  - Home
  - History
  - Trend
  - Profile

### Keuntungan
- Clean navigation
- Mudah handle nested route
- Scalable

---

## 9. Dependency Injection

Menggunakan service locator (get_it).

### Tujuan
- Decouple dependency
- Mudah testing
- Centralized injection

### Pattern
- Register repository
- Register usecase
- Inject ke Cubit

---

## 10. UI & UX Approach

Menggunakan design minimal dan fokus usability.

### Prinsip
- Minim warna (dual tone)
- Large tap area
- Fast interaction
- Clear hierarchy

### Tools
- ScreenUtil untuk responsive layout

---

## 11. Scalability Consideration

Project didesain untuk scalable:

- Domain modular
- Clean architecture
- Separation of concern
- Bisa ditambah:
  - cloud sync
  - multi user
  - API integration

---

## 12. Engineering Mindset

Project ini tidak hanya fokus pada fitur, tapi juga:

- Maintainability
- Code readability
- Separation of concern
- Real-world architecture

Tujuannya adalah menunjukkan kemampuan sebagai:
Mobile Engineer, bukan hanya UI Developer.
