# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

_No changes yet._

## [1.2.0] - 2026-10-20

### Changed
- Dependency refresh: upgraded `fluent_ui` 4.16.1 → 4.17.0, `go_router` 18.0.2 → 18.1.0, `material_ui` 1.6.0 → 1.7.0, `sqlite3` 3.7.0 → 3.7.1, `file_saver` 0.6.0 → 0.7.0, `freezed` 4.0.2 → 4.0.3, `json_serializable` 6.14.1 → 6.15.1, `shared_preferences_android`/`shared_preferences_foundation`, and other transitive updates.
- Migrated Excel export from `excel` to `excel_plus` (drop-in, performance-focused fork), enabling `archive` 3.6.1 → 4.5.2 and `image` 4.3.0 → 4.12.0.
- Migrated CSV handling from `csv` to `csv_plus` (the CSV engine used by `excel_plus`); removed the `csv` dependency.
- `backup_service.dart`: updated zip-directory parsing for `archive` 4.x (`ZipDirectory` instance + `InputMemoryStream`).

### Fixed
- Fixed compile errors introduced by `fluent_ui` 4.17.0: `ThemeMode` now resolves to `material_ui`'s in Fluent screens (aliased Flutter `ThemeMode`), renamed `ScaffoldPage.scrollable`'s `bottomBar` parameter to `footer`, and replaced the removed `CircleAvatar` with Flutter's `CircleAvatar`.
- Resolved `file_saver` 0.7.0 API usage (returns `String` instead of `Uri?`).

## [1.1.0] - 2026-10-13

> **Beta release.** Feature-complete for offline GST invoicing. Test coverage is
> still growing, so feedback on edge cases is welcome.

### Added
- **Recurring Invoices**: Define recurring invoice profiles and auto-generate invoices from them, with a dedicated Fluent and Material UI.
- **Payment History**: Payment tracking per invoice with a payment dialog capturing amount, transaction ID and remarks.
- **Audit Report Screen**: Action-level audit trail of changes made to invoices and clients.
- **Receivables Aging Report**: Aging analysis with chart visualisation.
- **Client Ledger**: Statement-style running-balance ledger per client, with printable/PDF export.
- **Excel Export**: Workbook export alongside the existing CSV export.
- **GSTR-3B Service**: GSTR-3B summary generation in addition to GSTR-1.
- **E-Invoice JSON Export**: GST-compliant e-invoice JSON export, plus E-Way Bill number capture on invoices.
- **GSTR-1 Import**: Bulk JSON import for historic GSTR-1 data.
- **Item Templates**: Reusable item/service catalogue with HSN codes.
- **Multi-Profile Switching**: In-session business profile switching via the profile switcher sheet.
- **Data Safety**: Automated Backup Scheduling system with user-configurable frequency and preferred time.
- **Financial Transparency**: Detailed GST breakdown (Taxable Value, CGST, SGST, IGST) in Estimate forms for both Fluent and Material UIs.
- **UX**: Skeleton loading states, empty states, and a global error view.

### Changed
- Refined sidebar behavior and accent color selection UI.
- Relocated "Update Channels" configuration to the About section for better discoverability.
- Dependency refresh: `file_picker` 13.1.0, `data_table_2` 3.0.0 (with the Material → `material_ui` migration), `sqlite3` 3.7.0, `drift` 2.35.2 and other transitive updates.

### Fixed
- **Estimate Conversion**: Resolved critical application crash during the "Convert Estimate to Invoice" workflow.
- **Data Integrity**: Correctly marking Estimates as "Converted" in the database upon successful invoice creation.
- **Tax Logic**: Fixed GST calculation in Estimates to correctly distinguish between Inter-state and Intra-state transactions.
- Resolved various linting issues and BuildContext async gap warnings across the codebase.

### Known Limitations
- Auto-update is Windows-only; Linux users should update manually from GitHub Releases.
- Test coverage is currently partial, concentrated on financial calculations, GST utilities and core screens.

### Security
- Release builds suppress stack traces; the diagnostics screen is disabled in production builds.


## [1.0.0] - 2026-05-06

### Added
- **Financial Management**: Multi-bank management system and custom Financial Year (FY) picker.
- **GSTR Services**: GSTR-1 JSON bulk import for historic data and GSTR-1 summary enhancements.
- **Invoicing**: Single-Window Invoice entry, Credit/Debit Note support, and Invoice uniqueness checks.
- **Templates & Branding**: Stamp and Digital Signature support, brand logo integration, and Spectral font integration.
- **Profiles**: Multi-business profile support.
- **Updates & Builds**: In-app update system (stable/nightly channels) and Inno Setup installer generation.
- **Platform Support**: Linux support with AppImage workflow and nightly Windows build workflow.
- **Data Management**: CSV backup/restore and database caching for improved performance.
- **Validation**: GSTIN validation logic and financial precision handling.
- **Initial Features**: Phase 2 Dynamic Templates, Persistence, and initial project scaffolding.

### Changed
- **Licensing**: Switched to AGPLv3 and enhanced user data security measures.
- **Architecture**: Migrated state management to Riverpod Notifier and updated database to `drift_flutter`.
- **UI/UX**: Comprehensive overhaul using Fluent UI for a modern Windows-native experience.
- **Documentation**: Updated README with professional documentation and license sections.

### Fixed
- **UI Layouts**: Resolved layout overflows in `FluentInvoiceWizard` and sidebar inconsistencies.
- **State Management**: Fixed reactive state issues in client selection and dashboard filters.
- **Stability**: Resolved critical data loss during migrations and financial precision errors.
- **CI/CD**: Fixed workflow issues related to iOS/Android icon generation and build runner conflicts.
- **PDF Generation**: Corrected type mismatches and rendering bugs in invoice previews.

### Security
- Enforced secure user data handling and finalized transition to AGPLv3.

---
*Project started on 2026-01-06.*
