# POS Kasir Simpel — Master Document

Dokumen ini adalah entry point utama untuk memahami project ini secara menyeluruh.

Project ini tidak hanya fokus pada implementasi, tetapi juga menunjukkan proses berpikir sebagai seorang Mobile Engineer:

- Problem understanding
- System design
- UX consideration
- Technical decision
- Execution planning

---

## Cara Membaca Dokumen

Untuk memahami project ini dengan benar, baca dokumen dengan urutan berikut:

### 1. PRD (Product Requirement Document)

File: `prd.md`

Mulai dari sini.

Dokumen ini menjelaskan:

- Masalah yang ingin diselesaikan
- Target user
- Fitur utama
- Business rules
- Scope aplikasi

Tujuan:
Memahami apa yang dibangun dan kenapa

---

### 2. Design Guidelines

File: `design.md`

Setelah memahami fitur, lanjut ke design.

Dokumen ini menjelaskan:

- Arah visual (minimal, dual tone)
- UI principles
- Layout dan hierarchy
- Behavior UI di setiap screen

Tujuan:
Memahami bagaimana aplikasi digunakan oleh user

---

### 3. Technical & Skill Decisions

File: `skill.md`

Dokumen ini menjelaskan keputusan teknis.

Isi:

- Clean Architecture implementation
- State management (Cubit)
- Offline-first strategy
- Database design (Drift)
- Dependency injection
- Modular domain structure

Tujuan:
Memahami kenapa arsitektur dan teknologi dipilih

---

### 4. Sprint Plan

File: `sprint_plan.md`

Dokumen ini menjelaskan bagaimana project dibangun step-by-step.

Isi:

- Breakdown task harian
- Urutan development
- Prioritas fitur
- Delivery milestone

Tujuan:
Memahami bagaimana project dieksekusi secara real

---

## Alur Pemahaman Project

```txt
PRD → Design → Skill → Sprint Plan
