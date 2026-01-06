# InvoBharat 🇮🇳

[![Windows Build](https://github.com/SV-stark/InvoBharat/actions/workflows/windows_build.yml/badge.svg)](https://github.com/SV-stark/InvoBharat/actions/workflows/windows_build.yml)
![License](https://img.shields.io/github/license/SV-stark/InvoBharat)
![Version](https://img.shields.io/badge/version-1.0.0-blue)

**InvoBharat** is a fast, offline-first invoice generator tailored for the Indian market. Built with Flutter, it empowers freelancers and small businesses to create professional, GST-compliant invoices in seconds—customized to their needs and ready to share as PDFs.

---

## 🚀 Features

- **GST Compliant**: Automated tax calculations (CGST, SGST, IGST) specialized for Indian billing standards.
- **Offline First**: No internet required. Your data stays local on your device for maximum privacy.
- **PDF Generation**: Instantly generate high-quality PDF invoices ready for printing or sharing.
- **Cross-Platform**: Optimized for Windows Desktop, with future updates planned for Android.
- **Modern UI**: Clean, intuitive interface built with Google's Material Design 3.

## 📥 Download

Get the latest nightly build for **Windows**:

[![Download Windows Installer](https://img.shields.io/badge/Download-Windows_Installer-blue?style=for-the-badge&logo=windows)](https://github.com/SV-stark/InvoBharat/releases/tag/nightly)

> **Note**: This is a nightly release. It contains the absolute latest features but may be experimental.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Riverpod](https://riverpod.dev)
- **PDF Engine**: `pdf` & `printing` packages
- **Typography**: Google Fonts

## 👨‍💻 Development Setup

To build InvoBharat locally, ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

1.  **Clone the repository**
    ```bash
    git clone https://github.com/SV-stark/InvoBharat.git
    cd InvoBharat
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the app**
    ```bash
    # For Windows
    flutter run -d windows
    ```

## 🤝 Contributing

Contributions are welcome! If you find a bug or have a feature request, please [open an issue](https://github.com/SV-stark/InvoBharat/issues).

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ in India.