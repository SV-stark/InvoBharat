# Developer Guide

Welcome to the InvoBharat development documentation. This guide is for developers who want to build the project from source or contribute features.

## 🛠️ Tech Stack

*   **Language**: Dart
*   **Framework**: [Flutter](https://flutter.dev) (Windows, Linux, Android)
*   **State Management**: [Riverpod](https://riverpod.dev)
*   **Database**: [Drift](https://drift.simonbinder.eu/) (SQLite abstraction)
*   **UI Library**: 
    *   [fluent_ui](https://pub.dev/packages/fluent_ui) (Windows/Linux)
    *   Material 3 (Android)

## ⚡ Prerequisites

To build the project, you need:
1.  **Flutter SDK**: Version 3.5.0 or higher.
2.  **C++ Build Tools**:
    *   **Windows**: Visual Studio 2022 with "Desktop development with C++".
    *   **Linux**: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`.

## 🚀 Build Instructions

### 1. Clone the Repo
```bash
git clone https://github.com/SV-stark/InvoBharat.git
cd InvoBharat
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate Code
The project uses `freezed` and `drift` for code generation. You needs to run build_runner:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run Locally
```bash
# For Windows
flutter run -d windows

# For Linux
flutter run -d linux
```

## 🏗️ Project Structure

*   `lib/data`: Database tables and repositories (Drift).
*   `lib/models`: Data models (Freezed classes).
*   `lib/providers`: Riverpod providers for state management.
*   `lib/screens`: UI Screens (Widgets).
*   `lib/widgets`: Reusable UI components.
*   `lib/utils`: Helper functions (PDF generation, Formatters).

## 🤝 Contributing

1.  **Fork** the repository.
2.  Create a feature branch (`git checkout -b feature/cool-feature`).
3.  Commit changes.
4.  Push and open a **Pull Request**.

Please ensure you run `flutter analyze` before pushing to catch any linting errors.
