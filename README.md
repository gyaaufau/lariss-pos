# Lariss POS (Offline-First)

Mobile Point-of-Sale (POS) app for UMKM/small stores. Built with Flutter and designed for **fast cashier flow**, **offline-first reliability**, and **clean modular architecture**.

> Title in app: **Lariss POS**

## Highlights

- Offline-first (all data stored locally in SQLite)
- Clean Architecture (strict layering)
- Modular domains per feature
- State management with Cubit (`flutter_bloc`)
- Navigation with `go_router` (4-tab shell)
- Local database with Drift (type-safe)
- Dependency injection via `get_it`

## Features (MVP)

- **Products**: CRUD, price, active/inactive, current stock, minimum stock
- **Categories**: CRUD, product filtering
- **Cart & Checkout**:
  - Add/remove/update quantity
  - Stock validation
  - Payment input, change calculation
  - Save transaction, auto stock update
- **Stock**:
  - Stock in/out/adjustment
  - Stock movement logging
  - Low-stock detection
- **History**:
  - Transaction list
  - Transaction detail
  - Date filtering (as implemented)
- **Trend**:
  - Total sales / total transactions
  - Daily sales summary
  - Best selling products / category sales (as implemented)
- **Profile & Settings**: store profile and basic settings pages

## Main Navigation

The app uses a 4-tab shell:

1. **Home** (products + cart)
2. **History** (transactions)
3. **Trend** (analytics)
4. **Profile** (store / management)

### Routes

Defined in `lib/core/router/app_router.dart`:

- `/home`
  - `/home/checkout`
  - `/home/checkout/success`
- `/history`
- `/trend`
- `/profile`
  - `/profile/categories`
  - `/profile/products`
  - `/profile/stock`

## Tech Stack

- **Flutter** (Dart SDK constraint: `^3.11.4`)
- **State management**: `flutter_bloc` (Cubit)
- **Routing**: `go_router`
- **DI / Service Locator**: `get_it`
- **Local DB**: `drift` + `sqlite3_flutter_libs`
- **Functional helpers**: `fpdart`
- **Responsive UI**: `flutter_screenutil`
- **Codegen**: `build_runner`, `drift_dev`

## Architecture

This project follows strict Clean Architecture with a modular domain structure.

### Layering rule

`presentation → usecase → repository → datasource → database`

Rules:

- UI/Cubit only calls **usecases**
- Usecases depend only on **repository abstractions**
- Repository implementations live in **data** layer
- No direct UI access to database

### Folder structure (high level)

- `lib/core/`
  - `database/` (Drift database)
  - `di/` (service locator)
  - `router/` (GoRouter)
  - `theme/`
- `lib/domain/*_domain/`
  - `domain/` (entities, usecases, repository contracts)
  - `data/` (repository implementations, datasources, Drift integration)
- `lib/features/*/`
  - `presentation/` only (pages, cubits, widgets)

## Database Schema (summary)

The local SQLite schema is designed for POS needs:

- `categories`
- `products`
- `stock_movements`
- `transactions`
- `transaction_items`
- `store_profile`
- `app_settings`

For the detailed schema definition and rationale, see `docs/prompts/prd.md`.

## Getting Started

### Prerequisites

- Flutter SDK installed
- An iOS/Android simulator or a physical device

### Install dependencies

```bash
flutter pub get
```

### Run code generation (Drift)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run the app

```bash
flutter run
```

## Useful Commands

- Analyze:

```bash
flutter analyze
```

- Run tests:

```bash
flutter test
```

- Regenerate code (watch mode):

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Documentation

Project docs live under `docs/prompts/`:

- `docs/prompts/master.md` — entry point (how to read the docs)
- `docs/prompts/prd.md` — requirements + features + DB schema
- `docs/prompts/design.md` — design system & UI guidelines
- `docs/prompts/skill.md` — architecture & technical decisions
- `docs/prompts/sprint_plan.md` — development plan

## Notes

- This project is **offline-first** and does not require any backend.
- All amounts are stored as **INTEGER** (e.g., cents or smallest currency unit), aligned with the PRD.

## License

Specify a license if you plan to open-source this project (e.g., MIT). If this is a private/portfolio project, you can keep this section as-is or remove it.
