# Design Prompts — Aplikasi POS Kasir Simpel

> Prompt UI design untuk setiap screen/page berdasarkan PRD.
> Setiap prompt sudah diselaraskan dengan design system di `design.md`.
> Fokus: visual design, layout, komponen, UX, dan interaksi — tanpa arsitektur kode.

---

## Design System Reference (Wajib Diterapkan di Setiap Screen)

### Color Palette

```
Primary:        #2563EB
Primary Dark:   #1E40AF
Primary Light:  #DBEAFE
Background:     #F8FAFC
Surface:        #FFFFFF
Border:         #E2E8F0
Text Primary:   #0F172A
Text Secondary: #64748B
Disabled:       #CBD5E1
Success:        #16A34A
Warning:        #F59E0B
Danger:         #DC2626
```

**Color Rules:**
- Primary hanya untuk tombol utama, active tab, dan highlight penting.
- Warning hanya untuk stok menipis.
- Danger hanya untuk stok habis atau aksi delete.
- Background harus tetap netral (#F8FAFC).
- Jangan gunakan terlalu banyak warna. Maksimal dual tone.

### Typography

```
Display / Page Title:   24sp / bold
Section Title:          18sp / semibold
Card Title:             16sp / semibold
Body Text:              14sp / regular
Caption:                12sp / regular
Button Text:            14sp / semibold
```

**Text Rules:**
- Font: Inter, SF Pro, Plus Jakarta Sans, atau Poppins.
- Bold hanya untuk angka penting, total, nama produk, dan title.
- Hindari paragraf panjang di UI.

### Spacing

```
Base units: 4, 8, 12, 16, 20, 24, 32
Screen horizontal padding: 16
Card padding: 16
Button padding vertical: 14–16
Bottom navigation height: 64–72
```

### Radius

```
Small:   8
Medium:  12
Large:   16
Extra:   24
```

### Shadow

- Shadow halus, jangan terlalu tebal.
- Card shadow ringan saja.
- Bottom sheet shadow ringan.
- Jangan pakai shadow berlebihan di semua elemen.

### Component Defaults

**Card:**
- Background: Surface (#FFFFFF)
- Radius: 16
- Padding: 16
- Border: #E2E8F0 (tipis)
- Shadow sangat ringan atau tanpa shadow

**Primary Button:**
- Background: Primary (#2563EB)
- Text: putih
- Radius: 12–16
- Height: 48–56

**Secondary Button:**
- Background: Primary Light (#DBEAFE) atau putih
- Border: Primary
- Text: Primary

**Danger Button:**
- Text: Danger (#DC2626)
- Hindari tombol merah full kecuali aksi sangat penting

**Chip Active:**
- Background: Primary
- Text: putih

**Chip Inactive:**
- Background: putih
- Border: neutral (#E2E8F0)
- Text: Text Secondary (#64748B)

**Badge Low Stock:**
- Background: soft warning
- Text: Warning (#F59E0B)

**Badge Out of Stock:**
- Background: soft danger
- Text: Danger (#DC2626)

**Badge Active:**
- Background: soft success
- Text: Success (#16A34A)

### Interaction & UX Rules

- Minimum tap target: 44×44
- Button utama: minimal height 48
- Setiap aksi penting harus punya feedback (loading, success, error)
- Loading: skeleton sederhana atau circular loading kecil
- Error message: singkat, jelas, actionable
- Checkout harus cepat
- Product search harus mudah ditemukan
- Cart summary harus selalu mudah diakses
- Total pembayaran harus sangat jelas
- Jangan sembunyikan informasi stok
- Error checkout harus langsung menjelaskan masalahnya
- Kurangi penggunaan modal yang tidak perlu

### Do & Don't

**Do:**
- Gunakan layout bersih
- Gunakan warna sedikit
- Buat tombol besar
- Buat total transaksi menonjol
- Gunakan card yang mudah discan
- Gunakan empty state yang jelas

**Don't:**
- Jangan gunakan terlalu banyak warna
- Jangan terlalu banyak animasi
- Jangan membuat card terlalu padat
- Jangan sembunyikan tombol checkout
- Jangan tampilkan grafik terlalu kompleks
- Jangan pakai istilah teknis untuk user kasir

---

## 1. Home Screen

```
Design the Home screen for a cashier POS app (KasirLite).

Context:
- This is the MAIN screen. The cashier uses it all day for transactions.
- Must be fast, clean, and distraction-free.
- Design for non-technical users.

Layout Structure:
1. Header — store name + today's date + optional low-stock warning badge
2. Search bar — rounded, white bg, border #E2E8F0, icon search, placeholder "Cari produk..."
3. Category filter — horizontal scrollable chips
4. Product grid — 2 columns
5. Cart summary — sticky bottom bar

Header:
- Store name in 18sp semibold, Text Primary (#0F172A)
- Date in 14sp regular, Text Secondary (#64748B)
- Low-stock warning: small badge with warning color if applicable (e.g. "3 produk stok menipis")
- Keep header simple and not too tall

Search Bar:
- Radius: 12
- Background: Surface (#FFFFFF)
- Border: 1px #E2E8F0
- Height: 48
- Icon search in Text Secondary

Category Chips:
- Active: Background Primary (#2563EB), text white, radius 12
- Inactive: Background white, border #E2E8F0, text Text Secondary (#64748B), radius 12
- Padding chip: horizontal 12, vertical 6
- Example: Semua, Makanan, Minuman, Snack

Product Card:
- Background: Surface (#FFFFFF)
- Radius: 16
- Padding: 12–16
- Border: 1px #E2E8F0
- Shadow: very light or none
- Large tap area

Card content:
- Product name: 16sp semibold, Text Primary
- Price: 14sp bold, Text Primary
- Stock: 12sp regular, Text Secondary
- Low stock badge: soft warning bg, warning text (if applicable)
- Out of stock badge: soft danger bg, danger text (if applicable)

Product Card States:
- Stok tersedia: card normal
- Stok menipis: warning badge visible
- Stok habis: card looks disabled (reduced opacity, muted colors), badge "Stok Habis"

Cart Summary (Sticky Bottom):
- Background: Surface (#FFFFFF)
- Shadow: soft upward shadow
- Rounded top: 20
- Content: item count + total price + Checkout button
- Total price: 18sp bold, Text Primary
- Checkout button: Primary button style (full width or prominent)

Empty State:
- Icon sederhana (receipt or box outline)
- Title: "Belum ada produk" — 18sp semibold
- Subtext: "Tambah produk untuk mulai berjualan" — 14sp regular, Text Secondary

Interactions:
- Tap product card adds to cart (brief scale animation + toast)
- Search expands with live filtering
- Category chip tap switches active state instantly
- Cart summary always visible when items exist
```

---

## 2. Cart Bottom Sheet

```
Design a cart bottom sheet for the cashier POS app.

Context:
- Opens when tapping the cart summary or dragging up.
- Shows current cart items before checkout.

Layout:
- Draggable bottom sheet with drag handle at top
- Rounded top corners: radius 24
- Backdrop overlay: subtle dark scrim

Header:
- "Keranjang (N items)" — 18sp semibold, Text Primary
- Close button (X icon) on the right

Cart Item Row:
- Product name: 14sp semibold, Text Primary
- Unit price: 12sp regular, Text Secondary
- Quantity stepper: circular + and - buttons, Primary color, min tap target 44×44
- Subtotal: 14sp semibold, Text Primary, right aligned
- Divider between items: 1px #E2E8F0

Total Section:
- "Total" label: 14sp regular, Text Secondary
- Total amount: 24sp bold, Text Primary
- Positioned above the checkout button

Checkout Button:
- Full width, pinned at bottom
- Primary button style: bg #2563EB, white text, radius 12–16, height 48–56
- Text: "Checkout"

States:
- Empty cart: illustration + "Keranjang kosong" + disabled checkout button (Disabled color #CBD5E1)
- Stock validation error: red warning text (#DC2626) below affected item

Interactions:
- Stepper buttons with haptic feedback
- Swipe item left to reveal delete action (red)
- Sheet dismisses by dragging down or tapping backdrop
- Real-time total update as quantity changes
```

---

## 3. Checkout Screen

```
Design the Checkout screen for finalizing a transaction.

Context:
- Cashier enters payment amount. App calculates change.
- Must be the FASTEST screen to use. No distractions.

Layout Structure:
1. Item list (scrollable, collapsed rows)
2. Total display
3. Payment input
4. Change display
5. Confirm button

Item List:
- Product name + qty × price + subtotal per row
- 14sp regular, Text Primary
- Divider 1px #E2E8F0

Total Display:
- "Total" label: 14sp regular, Text Secondary
- Amount: 32sp bold, Text Primary (#0F172A)
- Must be the MOST prominent element on screen

Payment Input:
- Label: "Bayar" — 14sp regular, Text Secondary
- Input field: outlined style, height 56, radius 12
- Focused border: Primary (#2563EB)
- Prefix: "Rp" in Text Secondary
- Number keyboard

Change Display:
- Label: "Kembalian" — 14sp regular, Text Secondary
- Amount: 24sp bold
- If sufficient: Success color (#16A34A)
- If insufficient: Danger color (#DC2626) + warning text "Pembayaran kurang"
- If exact: "Uang pas" label in Success color

Confirm Button:
- Full width, pinned bottom
- Primary button style: bg #2563EB, white text, radius 12–16, height 48–56
- Text: "Bayar"
- Disabled state if payment insufficient

Important States:
- Payment insufficient: button disabled, warning text visible
- Exact payment: "Uang pas" label
- Loading: button shows spinner, text hidden
- Stock changed during checkout: error banner "Stok tidak mencukupi"

Interactions:
- Real-time change calculation as user types
- Large tap target on input field
- Button activates instantly when payment >= total
```

---

## 4. Transaction Success Screen

```
Design the Transaction Success screen shown after a successful checkout.

Context:
- Confirms transaction completion to cashier and customer.
- Should feel rewarding but brief.

Layout:
- Centered content, lots of whitespace
- Background: #F8FAFC

Content (top to bottom):
1. Success icon — large checkmark in Success color (#16A34A), inside soft success circle
2. "Transaksi Berhasil" — 24sp bold, Text Primary, centered
3. Invoice number — 14sp regular, Text Secondary, centered
4. Total transaksi — 18sp bold, Text Primary, centered
5. Kembalian — 16sp semibold, Success color, centered
6. Two buttons stacked:
   - "Transaksi Baru" — Primary button style
   - "Lihat Detail" — Secondary button style

Style:
- Clean, lots of whitespace
- Focus on success confirmation
- No clutter
- Minimal animation (gentle scale-in of icon)

Interactions:
- Auto-navigate to Home after 3 seconds if no action
- Tap "Transaksi Baru" immediately returns to Home
- Tap "Lihat Detail" opens Transaction Detail screen
```

---

## 5. History Screen

```
Design the History screen for viewing past transactions.

Context:
- Cashier or owner reviews completed sales.
- Filter by date range.

Layout Structure:
1. Header: "Riwayat Transaksi" — 24sp bold
2. Date filter chips: "Hari Ini", "Minggu Ini", "Bulan Ini"
3. Transaction list (vertical)

Date Filter Chips:
- Active: bg Primary (#2563EB), text white, radius 12
- Inactive: bg white, border #E2E8F0, text Text Secondary (#64748B), radius 12
- Horizontal scrollable

Transaction Card:
- Background: Surface (#FFFFFF)
- Radius: 16
- Padding: 16
- Border: 1px #E2E8F0
- Left border accent: none (keep minimal, or very subtle)

Card content:
- Invoice number: 14sp semibold, Text Primary
- Date & time: 12sp regular, Text Secondary
- Total item count: 12sp regular, Text Secondary
- Total amount: 16sp bold, Text Primary, right aligned

Date Grouping:
- Section headers: "Hari Ini", "Kemarin", etc.
- 12sp semibold, Text Secondary
- Padding vertical: 8

Empty State:
- Icon: simple receipt outline
- Title: "Belum ada transaksi" — 18sp semibold
- Subtext: "Transaksi yang selesai akan muncul di sini" — 14sp regular, Text Secondary

Interactions:
- Tap card opens Transaction Detail
- Pull to refresh
- Date chip tap updates list with smooth transition
```

---

## 6. Transaction Detail Screen

```
Design the Transaction Detail screen for reviewing a single receipt.

Context:
- Digital receipt view. Can be used to show customer or for record.

Layout:
- Header: "Detail Transaksi" — 24sp bold, back button left
- Store info block: store name, date, invoice number — 14sp regular, Text Secondary
- Item list (receipt style)
- Divider
- Summary block
- Footer badge

Item List (receipt style):
- Product name: 14sp regular, Text Primary, left aligned
- Qty × price: 12sp regular, Text Secondary, center
- Subtotal: 14sp regular, Text Primary, right aligned
- Monospace-style alignment for easy scanning
- Divider 1px #E2E8F0 between items

Summary Block:
- Subtotal: 14sp regular, Text Secondary
- Total: 18sp bold, Text Primary
- Uang dibayar: 14sp regular, Text Secondary
- Kembalian: 16sp semibold, Success color (#16A34A)
- Right-aligned amounts

Footer:
- "Transaksi Berhasil" badge: soft success bg, success text, radius 8, padding 4×8
- Timestamp: 12sp regular, Text Secondary

Style:
- Receipt-like aesthetic, vertical layout
- Total made most prominent
- Clean vertical flow
- Background: #F8FAFC or white

Interactions:
- Tap back returns to History
- Optional: share/print icon in header (if supported)
```

---

## 7. Trend Screen

```
Design the Trend screen for sales insights and analytics.

Context:
- Owner views business performance quickly.
- Charts must be simple, not overwhelming.

Layout Structure:
1. Header: "Tren Penjualan" — 24sp bold
2. Summary cards row (horizontal scroll or 2×2 grid)
3. Daily sales chart
4. Top product section
5. Category sales section

Summary Cards:
- Background: Surface (#FFFFFF)
- Radius: 16
- Padding: 16
- Border: 1px #E2E8F0
- Shadow: none or very light

Card content:
- Label: 12sp regular, Text Secondary (e.g. "Penjualan Hari Ini")
- Value: 24sp bold, Text Primary (e.g. "Rp 1.250.000")
- Icon: simple line icon, Primary color

Cards:
- Penjualan Hari Ini
- Transaksi Hari Ini
- Produk Terlaris

Chart:
- Simple line chart or bar chart
- Primary color (#2563EB) only
- Background: white
- Grid lines: very subtle (#E2E8F0)
- No gradient fills, no multiple colors
- Jangan tampilkan grafik terlalu kompleks

Top Product Section:
- Section title: "Produk Terlaris" — 18sp semibold
- Vertical list, max 5 items
- Rank number: 14sp bold, Text Primary
- Product name: 14sp regular, Text Primary
- Quantity sold: 12sp regular, Text Secondary

Category Sales Section:
- Section title: "Penjualan per Kategori" — 18sp semibold
- Horizontal bar chart
- Single color (#2563EB) for all bars
- Category label: 12sp regular, Text Secondary
- Value: 12sp regular, Text Primary

Empty State:
- Title: "Belum ada data penjualan" — 18sp semibold
- Subtext: "Mulai transaksi untuk melihat tren" — 14sp regular, Text Secondary

Interactions:
- Date range selector in header (if applicable)
- Cards animate in gently on load
- Pull to refresh
- Tap chart area for detail (optional)
```

---

## 8. Profile Screen

```
Design the Profile screen — the management and settings hub.

Context:
- Central place for store management.
- Accessed by owner/admin.

Layout Structure:
1. Store profile card
2. Menu list grouped by sections

Store Profile Card:
- Background: Surface (#FFFFFF)
- Radius: 16
- Padding: 16
- Border: 1px #E2E8F0
- Content:
  - Small store icon (outline, Primary color)
  - Store name: 18sp semibold, Text Primary
  - Owner name: 14sp regular, Text Secondary
  - Optional phone/address: 12sp regular, Text Secondary
- Edit icon: small pencil, Text Secondary, top right

Menu Sections:
- Background: #F8FAFC (screen bg)
- Section cards: Surface (#FFFFFF), radius 16, padding 16, border #E2E8F0

Kelola Section:
- List tiles:
  - Produk — icon + label + chevron right
  - Kategori — icon + label + chevron right
  - Stok — icon + label + chevron right
- Tile style: icon (Text Secondary), label (14sp semibold, Text Primary), chevron (Text Secondary)
- Border bottom: 1px #E2E8F0 between tiles

Pengaturan Section:
- Informasi Toko
- Pengaturan Aplikasi
- Same tile style as above

Akun Section:
- Logout — 14sp semibold, Danger color (#DC2626), no chevron

Menu List Style:
- Icon left: 24×24, Text Secondary
- Label: 14sp semibold, Text Primary
- Chevron right: Text Secondary
- Tap target: full row, min 48 height
- Border bottom halus between items

Interactions:
- Tap tile navigates to respective screen
- Tap store card opens store info edit
- Logout shows confirmation dialog
```

---

## 9. Manage Product Screen

```
Design the Manage Product screen for product administration.

Context:
- Owner adds, edits, deletes, activates/deactivates products.
- Different from cashier view — this is for management.

Layout Structure:
1. Header: "Kelola Produk" — 24sp bold, back button, "+" action right
2. Search bar (same style as Home)
3. Product list (vertical)
4. FAB "+" (optional, alternative to header action)

Product List Item:
- Background: Surface (#FFFFFF)
- Radius: 16 (if card style) or full width with divider
- Padding: 16
- Border: 1px #E2E8F0 (if card style)

Item content:
- Product name: 16sp semibold, Text Primary
- Category: 12sp regular, Text Secondary (as small chip or text)
- Price: 14sp semibold, Text Primary
- Stock: 12sp regular, Text Secondary
- Status: toggle switch (active = green/success, inactive = gray)

Stock indicator:
- Normal: no special indicator
- Low stock: warning badge "Stok Menipis" — soft warning bg, warning text
- Out of stock: danger badge "Stok Habis" — soft danger bg, danger text

Actions:
- Swipe left: Edit (blue/primary) and Delete (red/danger)
- Tap row: open edit

Empty State:
- Title: "Belum ada produk" — 18sp semibold
- Subtext: "Tambah produk untuk mulai berjualan" — 14sp regular, Text Secondary
- CTA: "Tambah Produk" — Primary button style

Design Rule:
- Jangan tampilkan terlalu banyak informasi.
- Informasi utama: nama, harga, stok.
- Keep list scannable.

Interactions:
- Toggle switch changes active state with instant feedback
- Search filters in real time
- FAB pulses gently on first visit (optional)
```

---

## 10. Product Form Screen

```
Design the Product Form screen for creating or editing a product.

Context:
- Owner fills in product details.
- Must be simple and clear.

Fields (vertical scroll):
1. Nama Produk — text input
2. Kategori — dropdown / bottom sheet selector
3. Harga Jual — number input with "Rp" prefix
4. Stok Awal / Stok Saat Ini — number input
5. Minimum Stok — number input
6. Deskripsi — multiline text input (optional)
7. Status Aktif — toggle switch

Input Field Style:
- Label: 12sp regular, Text Secondary, above input
- Input: outlined style, height 48–56, radius 12
- Border: #E2E8F0, focused: Primary (#2563EB)
- Background: Surface (#FFFFFF)
- Error text: 12sp regular, Danger (#DC2626), below input

Dropdown:
- Tap opens bottom sheet with category list
- Sheet: white, radius 24 top, list tiles with divider

Toggle Switch:
- Active: Primary color track
- Inactive: Disabled (#CBD5E1) track
- Label: "Aktif" / "Nonaktif" — 14sp regular, Text Primary

Save Button:
- Pinned at bottom
- Full width
- Primary button style: bg #2563EB, white text, radius 12–16, height 48–56
- Text: "Simpan"

States:
- Pristine: all fields default
- Dirty: unsaved changes (optional dot indicator on back)
- Invalid: red error text under invalid fields
- Loading: button shows spinner
- Success: brief toast "Produk disimpan"

Form Design Rules:
- Label jelas
- Input tinggi 48–56
- Error text pendek
- Button save sticky bottom
- Jangan pakai modal yang tidak perlu

Interactions:
- Validation on blur
- Save disabled until required fields valid
- Back press with dirty state shows "Simpan perubahan?" dialog
- Keyboard done moves to next field
```

---

## 11. Manage Category Screen

```
Design the Manage Category screen for category administration.

Context:
- Owner manages product categories (CRUD).
- Simple and focused.

Layout Structure:
1. Header: "Kelola Kategori" — 24sp bold, back, "+ Tambah" right
2. Category list (vertical)

Category List Item:
- Full width row
- Padding: 16 horizontal, 12 vertical
- Border bottom: 1px #E2E8F0

Item content:
- Category name: 16sp semibold, Text Primary
- Product count: 12sp regular, Text Secondary (e.g. "12 produk")
- Menu icon (⋯) on the right, Text Secondary

Actions:
- Tap menu icon opens bottom action sheet:
  - Edit — Primary text
  - Delete — Danger text
- Tap row opens edit directly (alternative)

Add Button:
- Header "+ Tambah" or FAB "+"
- Opens form bottom sheet or new screen

Empty State:
- Title: "Belum ada kategori" — 18sp semibold
- Subtext: "Tambah kategori untuk mengelompokkan produk" — 14sp regular, Text Secondary

Interactions:
- Action sheet slides up, white, radius 24 top
- Delete shows confirmation dialog
- Add opens minimal form
```

---

## 12. Category Form (Bottom Sheet / Screen)

```
Design the Category Form for adding or editing a category.

Context:
- Quick form. Should feel lightweight.

Layout (Bottom Sheet preferred):
- Short modal bottom sheet
- Drag handle at top
- Rounded top: radius 24
- Background: white

Content:
- Title: "Tambah Kategori" / "Edit Kategori" — 18sp semibold, centered or left
- Single input field: "Nama Kategori"
- "Simpan" button: full width, Primary button style

Input Field:
- Outlined style, height 48–56, radius 12
- Auto-focused on open
- Border: #E2E8F0, focused: Primary

Button:
- Primary: bg #2563EB, white text, radius 12–16, height 48–56
- Disabled if name empty

States:
- Empty name: button disabled (Disabled color)
- Duplicate name: inline error "Nama kategori sudah ada"

Interactions:
- Enter key on keyboard submits
- Sheet dismisses on outside tap or drag down
- Success: brief toast + sheet closes
```

---

## 13. Manage Stock Screen

```
Design the Manage Stock screen for stock administration.

Context:
- Owner views stock levels and performs stock in/out/adjustment.
- Low stock items must be immediately visible.

Layout Structure:
1. Header: "Kelola Stok" — 24sp bold, back button
2. Low stock warning section (if any)
3. Search bar
4. Stock product list

Low Stock Warning Section:
- Background: soft warning (tinted #F59E0B at very low opacity)
- Text: "5 produk stok menipis" — 14sp regular, Warning (#F59E0B)
- Radius: 12
- Padding: 12
- Not too prominent — just a gentle heads-up

Stock Product List Item:
- Background: Surface (#FFFFFF)
- Radius: 16
- Padding: 16
- Border: 1px #E2E8F0

Item content:
- Product name: 16sp semibold, Text Primary
- Current stock: 24sp bold, Text Primary (most prominent)
- Minimum stock: 12sp regular, Text Secondary
- Status text: "Normal" / "Menipis" / "Habis" — 12sp, respective color

Action Buttons (small, inline):
- "+ Masuk" — small button, soft success bg, success text, radius 8
- "- Keluar" — small button, soft warning bg, warning text, radius 8
- "Sesuaikan" — small button, soft primary bg, primary text, radius 8
- Height: 32–36 (compact but tappable)

Low Stock Item Highlight:
- Left border: 3px Warning (#F59E0B) OR
- Subtle background tint
- Warning icon (small, warning color)

Empty State:
- Title: "Belum ada produk" — 18sp semibold
- Subtext: "Tambah produk untuk mengelola stok" — 14sp regular, Text Secondary

Interactions:
- Tap action button opens quantity input bottom sheet
- Quantity input: stepper (- / number / +) or direct number input
- Sheet: white, radius 24 top, save button
- Save triggers toast "Stok diperbarui"
- Low stock items filter toggle at top (optional)
```

---

## 14. Stock Movement Log Screen

```
Design the Stock Movement Log screen for auditing stock changes.

Context:
- Audit trail. Clean and scannable.

Layout Structure:
1. Header: "Riwayat Stok" — 24sp bold, back, filter icon
2. Filter chips: "Semua", "Masuk", "Keluar", "Penyesuaian"
3. Timeline list

Filter Chips:
- Active: bg Primary, text white, radius 12
- Inactive: bg white, border #E2E8F0, text Text Secondary, radius 12

Timeline Entry:
- Left: vertical line connector + colored dot
- Dot colors:
  - Masuk: Success (#16A34A)
  - Keluar: Danger (#DC2626)
  - Penyesuaian: Primary (#2563EB)
- Right content:
  - Date/time: 12sp regular, Text Secondary
  - Product name: 14sp semibold, Text Primary
  - Movement type badge: small pill, color-coded
  - Quantity: 14sp bold (green for +, red for -)
  - Stock before → after: 12sp regular, Text Secondary

Badge Style:
- Masuk: soft success bg, success text, radius 8, padding 2×6
- Keluar: soft danger bg, danger text, radius 8, padding 2×6
- Penyesuaian: soft primary bg, primary text, radius 8, padding 2×6

Date Grouping:
- Headers: "Hari Ini", "Kemarin", "Minggu Ini"
- 12sp semibold, Text Secondary

Empty State:
- Title: "Belum ada pergerakan stok" — 18sp semibold
- Subtext: "Perubahan stok akan tercatat di sini" — 14sp regular, Text Secondary

Interactions:
- Tap filter chip updates list
- Pull to refresh
- Infinite scroll for older entries
- Timeline line animates on scroll (optional, subtle)
```

---

## 15. Store Settings Screen

```
Design the Store Settings screen for editing store information.

Context:
- Owner updates store profile.

Layout:
- Header: "Informasi Toko" — 24sp bold, back, save icon right
- Form fields (vertical scroll)
- Save button pinned bottom

Fields:
1. Nama Toko — text input (required)
2. Nama Pemilik — text input (required)
3. Alamat — multiline text input (optional)
4. Nomor Telepon — text input, number keyboard (optional)

Input Style:
- Label: 12sp regular, Text Secondary
- Required labels have subtle indicator (no red asterisk, keep clean)
- Optional labels: "(Opsional)" in 12sp, Text Secondary
- Input: outlined, height 48–56, radius 12, border #E2E8F0, focused Primary

Save Button:
- Full width, pinned bottom
- Primary button style: bg #2563EB, white text, radius 12–16, height 48–56
- Text: "Simpan"

States:
- Pristine, dirty, invalid, saved
- Loading: button spinner
- Success: toast "Informasi toko disimpan"

Interactions:
- Validation on required fields
- Save disabled until valid
- Back with dirty state shows confirmation
```

---

## 16. App Settings Screen

```
Design the App Settings screen for general preferences.

Context:
- App-wide settings.

Layout Structure:
1. Header: "Pengaturan" — 24sp bold, back
2. Grouped settings list
3. Version footer

Settings Groups (section cards):
- Background: Surface (#FFFFFF)
- Radius: 16
- Padding: 16
- Border: 1px #E2E8F0
- Section header: 12sp semibold, Text Secondary, all caps, padding bottom 8

Tampilan Section:
- Dark Mode — toggle switch
- Bahasa — list tile with current value + chevron

Notifikasi Section:
- Low Stock Alert — toggle switch
- Daily Summary — toggle switch

Data Section:
- Export Data — list tile with chevron
- Backup & Restore — list tile with chevron
- Hapus Semua Data — list tile, text Danger (#DC2626), no chevron

Toggle Switch Style:
- Active: Primary (#2563EB) track
- Inactive: Disabled (#CBD5E1) track
- Label: 14sp regular, Text Primary

List Tile Style:
- Label: 14sp semibold, Text Primary
- Value (if any): 14sp regular, Text Secondary, right aligned
- Chevron: Text Secondary
- Tap target: full row, min 48 height
- Border bottom: 1px #E2E8F0 between tiles

Version Footer:
- Centered
- "Versi 1.0.0" — 12sp regular, Text Secondary
- Padding vertical: 24

States:
- Toggles animate on change
- Destructive actions show confirmation dialog

Interactions:
- Toggle haptic feedback
- Tap "Hapus Semua Data" shows strong warning dialog:
  - Title: "Hapus Semua Data?" — 18sp bold
  - Subtext: "Data tidak bisa dikembalikan" — 14sp regular
  - Buttons: "Batal" (secondary), "Hapus" (danger text)
- Tap export shows progress then share sheet
```
