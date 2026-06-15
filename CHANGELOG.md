# Changelog

All notable changes to BMS are documented here.

## [Unreleased] - Phase 3

### Added
- **Quick Sales** - no-invoice cash sale flow with automatic stock deduction and ledger entry
- **GRN (Goods Receipt Note)** - full goods receipt workflow: supplier picker, product line items, qty/cost editing, stock-in on confirm, cost price update, purchase history tab
- **Petty Cash** - daily float card, receipt photo capture (camera and gallery), approval workflow, category chips
- **POS discounts** - line-item percentage discount and bill-level discount fields
- **Sidebar grouping** - nav items organised into labelled sections (Sales, Stock, Contacts, Finance, Admin)
- **Shared filter bar** - `BmsFilterRow` and `BmsDateBar` components replace one-off date/search implementations across all screens
- **BMS logo** - SVG icon mark in sidebar header and web favicon; `flutter_svg` dependency added
- **Web favicon** - `favicon.svg` and updated `index.html` title/description
- **README** - detailed README with banner, feature list, tech stack, role permission table, and getting-started guide
- **Banner and logo assets** - `docs/banner.svg`, `docs/banner.png`, `docs/logo.png` for GitHub org branding
- **Apache 2.0 license** - `LICENSE` file added
- **GitHub templates** - PR template and issue templates (bug report, feature request, task)
- **Sales returns schema** - tables scaffolded for Phase 4 returns flow (`schema v2`)

### Fixed
- `AppBar` missing from invoices screen
- Duplicate "Add" button appearing in Quick Sales screen
- Input field sizes inconsistent across screens - `isDense` moved to `InputDecorationTheme` and all local overrides removed
- Date range picker field taller than regular text inputs - switched to `readOnly` TextField for identical height
- Sidebar nav tile text overflowing during collapse animation - replaced fixed layout with `LayoutBuilder`
- Sidebar header and user footer overflowing during animation - both now use `LayoutBuilder`
- GRN tab label text invisible (white on white) - changed to white text on blue `AppBar`
- Em dashes replaced with hyphens across all UI strings and code comments
- Box-drawing divider comments (`+--`) removed from codebase

---

## [Phase 2] - Initial feature set

### Added
- Role-based routing with guards (Admin, Manager, Cashier, Viewer)
- App theme, color palette, and text styles
- Drift (SQLite) database with UUID primary keys
- Sidebar navigation with collapsible rail
- Inventory management - product list, add/edit/delete, stock levels
- Invoice management - create invoice, line items, payment status
- Customer and supplier contact management
- Settings screen with role switcher
- Dashboard with summary cards

---

## [Phase 1] - Project bootstrap

### Added
- Flutter project with strict lint rules
- Riverpod 3.x state management setup
- Drift database scaffold
- Router with named routes
- Core constants, error types, and utility helpers
