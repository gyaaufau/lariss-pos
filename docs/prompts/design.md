# Design Guidelines — Aplikasi POS Kasir Simpel

## 1. Design Direction

Aplikasi POS ini menggunakan desain yang sederhana, bersih, dan fokus pada kecepatan transaksi.

Karakter desain:

- Minimal
- Clean
- Mudah dibaca
- Tidak ramai
- Cocok untuk kasir non-teknis
- Fokus pada fungsi utama
- Sedikit warna, maksimal dual tone

Tujuan utama desain adalah membuat user bisa melakukan transaksi dengan cepat tanpa terdistraksi elemen visual yang berlebihan.

---

## 2. Visual Style

### Style Utama

- Modern minimal
- Rounded corner
- Soft shadow
- Banyak whitespace
- Komponen besar dan mudah ditekan
- Hierarki visual jelas

### Mood

- Tenang
- Profesional
- Ramah untuk UMKM
- Ringan dan tidak intimidating

---

## 3. Color Palette

Gunakan warna yang sederhana dan konsisten.

### Primary Tone

- Primary: `#2563EB`
- Primary Dark: `#1E40AF`
- Primary Light: `#DBEAFE`

### Neutral Tone

- Background: `#F8FAFC`
- Surface: `#FFFFFF`
- Border: `#E2E8F0`
- Text Primary: `#0F172A`
- Text Secondary: `#64748B`
- Disabled: `#CBD5E1`

### Status Color

Gunakan warna status seperlunya saja.

- Success: `#16A34A`
- Warning: `#F59E0B`
- Danger: `#DC2626`

### Color Rule

- Jangan gunakan terlalu banyak warna.
- Primary hanya untuk tombol utama, active tab, dan highlight penting.
- Warning hanya untuk stok menipis.
- Danger hanya untuk stok habis atau aksi delete.
- Background harus tetap netral.

---

## 4. Typography

Gunakan font yang mudah dibaca dan clean.

Rekomendasi:

- Inter
- SF Pro
- Plus Jakarta Sans
- Poppins

### Type Scale

- Display / Page Title: 24sp / bold
- Section Title: 18sp / semibold
- Card Title: 16sp / semibold
- Body Text: 14sp / regular
- Caption: 12sp / regular
- Button Text: 14sp / semibold

### Text Rule

- Jangan terlalu banyak bold.
- Gunakan bold hanya untuk angka penting, total, nama produk, dan title.
- Hindari paragraf panjang di UI.

---

## 5. Layout System

### Spacing

Gunakan spacing konsisten:

- 4
- 8
- 12
- 16
- 20
- 24
- 32

### Padding

- Screen horizontal padding: 16
- Card padding: 16
- Button padding vertical: 14–16
- Bottom navigation height: 64–72

### Radius

- Small radius: 8
- Medium radius: 12
- Large radius: 16
- Extra large radius: 24

### Shadow

Gunakan shadow halus, jangan terlalu tebal.

Contoh:

- Card shadow ringan
- Bottom sheet shadow ringan
- Jangan pakai shadow berlebihan di semua elemen

---

## 6. Main Navigation Design

Aplikasi memiliki 4 tab utama:

1. Home
2. History
3. Trend
4. Profile

### Bottom Navigation

Style:

- Simple bottom navigation
- Icon + label
- Active state menggunakan primary color
- Inactive state menggunakan neutral gray
- Background putih
- Border top tipis

Tabs:

- Home: icon home / store
- History: icon receipt / history
- Trend: icon chart
- Profile: icon user / settings

---

## 7. Screen Design

## 7.1 Home Screen

Home adalah halaman paling penting karena digunakan untuk transaksi.

### Layout

Struktur:

1. Header
2. Search bar
3. Category filter
4. Product list/grid
5. Cart summary sticky bottom

### Header

Isi:

- Nama toko
- Tanggal hari ini
- Optional: small low stock warning badge

Style:

- Simple
- Tidak terlalu tinggi
- Fokus ke greeting / store name

Example copy:

- `KasirLite`
- `Hari ini`
- `3 produk stok menipis`

### Search Bar

Style:

- Rounded
- Background putih
- Border tipis
- Icon search
- Placeholder: `Cari produk...`

### Category Filter

Style:

- Horizontal chip
- Active chip menggunakan primary color
- Inactive chip putih dengan border

Example:

- Semua
- Makanan
- Minuman
- Snack

### Product Card

Informasi yang tampil:

- Nama produk
- Harga
- Stok
- Badge low stock jika stok menipis
- Badge out of stock jika stok habis

Style:

- Card putih
- Rounded 16
- Padding 12–16
- Border tipis
- Tap area besar

Product card rule:

- Jika stok tersedia, card normal.
- Jika stok menipis, tampilkan warning kecil.
- Jika stok habis, card terlihat disabled.

### Cart Summary

Cart summary sticky di bawah.

Isi:

- Jumlah item
- Total harga
- Tombol Checkout

Style:

- Background putih
- Shadow halus
- Rounded top 20 jika menggunakan bottom container
- Tombol checkout full width atau prominent

---

## 7.2 Checkout Screen

Checkout digunakan untuk finalisasi transaksi.

### Layout

1. List item
2. Total
3. Input pembayaran
4. Kembalian
5. Confirm button

### Design Rule

- Total harus sangat jelas.
- Input pembayaran harus besar dan mudah diisi.
- Kembalian tampil otomatis.
- Tombol bayar hanya aktif jika pembayaran cukup.

### Important UI State

- Jika uang kurang, tampilkan warning:
  `Pembayaran kurang`
- Jika stok berubah, tampilkan error:
  `Stok tidak mencukupi`

---

## 7.3 Transaction Success Screen

Screen setelah checkout berhasil.

### Isi

- Success icon
- Text: `Transaksi Berhasil`
- Invoice number
- Total transaksi
- Kembalian
- Button:
  - `Transaksi Baru`
  - `Lihat Detail`

### Style

- Clean
- Banyak whitespace
- Fokus ke success confirmation

---

## 7.4 History Screen

History digunakan untuk melihat transaksi sebelumnya.

### Layout

1. Header
2. Date filter
3. Transaction list

### Transaction Card

Isi:

- Invoice number
- Tanggal dan jam
- Total transaksi
- Total item

Style:

- Card putih
- Rounded
- Border tipis
- Total transaksi bold

### Empty State

Jika belum ada transaksi:

- Icon receipt kosong
- Text: `Belum ada transaksi`
- Subtext: `Transaksi yang selesai akan muncul di sini`

---

## 7.5 Transaction Detail Screen

Isi:

- Invoice number
- Tanggal dan jam
- List item
- Subtotal
- Total
- Uang dibayar
- Kembalian

Design rule:

- Mirip struk digital
- Gunakan layout vertikal
- Total dibuat paling menonjol

---

## 7.6 Trend Screen

Trend digunakan untuk melihat insight penjualan.

### Layout

1. Summary cards
2. Daily sales chart
3. Top product section
4. Category sales section

### Summary Cards

Cards:

- Penjualan Hari Ini
- Transaksi Hari Ini
- Produk Terlaris

Style:

- Card putih
- Angka besar
- Label kecil

### Chart

Style chart:

- Simple line chart / bar chart
- Gunakan primary color
- Background putih
- Grid line sangat subtle
- Jangan terlalu banyak warna

### Empty State

Jika belum ada transaksi:

- Text: `Belum ada data penjualan`
- Subtext: `Mulai transaksi untuk melihat tren`

---

## 7.7 Profile Screen

Profile adalah pusat manajemen toko dan data.

### Layout

1. Store profile card
2. Menu list

### Store Profile Card

Isi:

- Nama toko
- Nama owner
- Optional phone/address

Style:

- Card putih
- Rounded
- Icon toko kecil

### Menu List

Menu:

- Manage Product
- Manage Category
- Manage Stock
- Low Stock
- Store Profile
- App Settings

Style:

- List tile
- Icon kiri
- Label
- Chevron kanan
- Border bottom halus

---

## 7.8 Manage Product Screen

### Layout

1. Header
2. Search product
3. Product list
4. Floating action button / Add button

### Product List Item

Isi:

- Nama produk
- Kategori
- Harga
- Stok
- Status aktif

Actions:

- Edit
- Delete / deactivate

Design rule:

- Jangan tampilkan terlalu banyak informasi.
- Informasi utama: nama, harga, stok.

---

## 7.9 Product Form Screen

Digunakan untuk create/edit product.

### Fields

- Nama produk
- Kategori
- Harga jual
- Stok awal / stok saat ini
- Minimum stok
- Deskripsi
- Status aktif

### Form Design

- Label jelas
- Input tinggi 48–56
- Error text pendek
- Button save sticky bottom

---

## 7.10 Manage Stock Screen

### Layout

1. Header
2. Low stock warning section
3. Stock product list

### Stock Item

Isi:

- Nama produk
- Stok saat ini
- Minimum stok
- Status: normal / low stock / out of stock

Actions:

- Tambah stok
- Kurangi stok
- Adjustment

### Low Stock Section

Style:

- Background warning soft
- Text warning jelas
- Tidak terlalu mencolok

Example:
`5 produk stok menipis`

---

## 8. Component Guidelines

## 8.1 Buttons

### Primary Button

Digunakan untuk aksi utama.

Example:

- Checkout
- Simpan
- Bayar

Style:

- Background primary
- Text putih
- Rounded 12–16
- Height 48–56

### Secondary Button

Digunakan untuk aksi alternatif.

Style:

- Background primary light atau putih
- Border primary
- Text primary

### Danger Button

Digunakan untuk delete/deactivate.

Style:

- Text danger
- Hindari tombol merah full kecuali aksi sangat penting

---

## 8.2 Cards

Default card:

- Background putih
- Radius 16
- Padding 16
- Border `#E2E8F0`
- Shadow sangat ringan atau tanpa shadow

---

## 8.3 Chips

Digunakan untuk kategori/filter.

Active:

- Background primary
- Text putih

Inactive:

- Background putih
- Border neutral
- Text secondary

---

## 8.4 Badges

Digunakan untuk status stok.

Low stock:

- Background soft warning
- Text warning

Out of stock:

- Background soft danger
- Text danger

Active:

- Background soft success
- Text success

---

## 8.5 Empty State

Gunakan empty state untuk halaman kosong.

Struktur:

- Icon sederhana
- Title
- Subtext
- Optional button

Example:

- Belum ada produk
- Belum ada transaksi
- Belum ada data penjualan

---

## 9. Interaction Guidelines

### Tap Target

- Minimum tap target: 44x44
- Button utama: minimal height 48

### Feedback

Setiap aksi penting harus punya feedback:

- Loading saat menyimpan
- Success message setelah berhasil
- Error message jika gagal

### Loading State

Gunakan:

- Skeleton sederhana
- Circular loading kecil
- Jangan membuat UI terlalu ramai

### Error State

Error message harus:

- Singkat
- Jelas
- Actionable

Example:

- `Stok tidak mencukupi`
- `Pembayaran kurang`
- `Nama produk wajib diisi`

---

## 10. Responsive Rule with ScreenUtil

Gunakan ScreenUtil untuk ukuran responsif.

Rules:

- Font menggunakan `.sp`
- Width/height menggunakan `.w` dan `.h`
- Radius menggunakan `.r`
- Padding menggunakan `.w` / `.h`

Example guideline:

- Screen padding: `16.w`
- Card radius: `16.r`
- Button height: `52.h`
- Title font: `24.sp`
- Body font: `14.sp`

---

## 11. Accessibility

- Kontras warna harus jelas.
- Font jangan terlalu kecil.
- Tombol harus mudah ditekan.
- Jangan mengandalkan warna saja untuk status.
- Status stok harus tetap punya text label.
- Gunakan icon + label jika perlu.

---

## 12. UX Rules for POS

Karena ini aplikasi kasir:

- Checkout harus cepat.
- Product search harus mudah ditemukan.
- Cart summary harus selalu mudah diakses.
- Total pembayaran harus sangat jelas.
- Jangan sembunyikan informasi stok.
- Error checkout harus langsung menjelaskan masalahnya.
- Kurangi penggunaan modal yang tidak perlu.

---

## 13. Design Do & Don't

### Do

- Gunakan layout bersih.
- Gunakan warna sedikit.
- Buat tombol besar.
- Buat total transaksi menonjol.
- Gunakan card yang mudah discan.
- Gunakan empty state yang jelas.

### Don't

- Jangan gunakan terlalu banyak warna.
- Jangan terlalu banyak animasi.
- Jangan membuat card terlalu padat.
- Jangan sembunyikan tombol checkout.
- Jangan tampilkan grafik terlalu kompleks.
- Jangan pakai istilah teknis untuk user kasir.

---

## 14. Suggested Visual Identity

Nama sementara: KasirLite

Tone visual:

- Blue + Neutral
- Clean
- Fast
- Reliable

Alternatif dual tone:

- Blue + Slate
- Green + Slate
- Indigo + Gray

Untuk MVP, gunakan:

- Primary Blue
- Neutral Slate

---

## 15. Screen Priority

Prioritas desain MVP:

1. Home
2. Checkout
3. Manage Product
4. Manage Stock
5. History
6. Trend
7. Profile
8. Settings

---

## 16. Final Design Principle

Aplikasi ini tidak perlu terlihat mewah. Yang penting:

- Cepat
- Jelas
- Konsisten
- Mudah dipakai
- Tidak bikin user mikir terlalu lama

Desain harus mendukung workflow kasir, bukan sekadar terlihat cantik.
