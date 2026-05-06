# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Data Safety**: Automated Backup Scheduling system with user-configurable frequency and preferred time.
- **Financial Transparency**: Detailed GST breakdown (Taxable Value, CGST, SGST, IGST) in Estimate forms for both Fluent and Material UIs.

### Changed
- Refined sidebar behavior and accent color selection UI.
- Relocated "Update Channels" configuration to the About section for better discoverability.

### Fixed
- **Estimate Conversion**: Resolved critical application crash during the "Convert Estimate to Invoice" workflow.
- **Data Integrity**: Correctly marking Estimates as "Converted" in the database upon successful invoice creation.
- **Tax Logic**: Fixed GST calculation in Estimates to correctly distinguish between Inter-state and Intra-state transactions.
- Resolved various linting issues and BuildContext async gap warnings across the codebase.

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
