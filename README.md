<div align="center">
  <img src="logo.png" alt="InvoBharat Logo" width="120" height="120">

  # InvoBharat 🇮🇳

  [![Windows Build](https://github.com/SV-stark/InvoBharat/actions/workflows/windows_build.yml/badge.svg)](https://github.com/SV-stark/InvoBharat/actions/workflows/windows_build.yml)
  ![License](https://img.shields.io/github/license/SV-stark/InvoBharat)
  ![Version](https://img.shields.io/badge/version-1.1.0-blue)
</div>

**InvoBharat** is a fast, offline-first invoice generator tailored for the Indian market, optimized for **Windows** (Fluent UI) and **Linux/Android** (Material 3). It empowers freelancers and small businesses to create professional, GST-compliant invoices in seconds—customized to their needs and ready to share as PDFs.

---

## 🚀 Key Features

### 📊 Professional Dashboard & Analytics
Gain instant insights into your business performance with a powerful dashboard:
- **Real-time Financials**: Track Total Revenue, Total Invoices, and Outstanding Batches instantly.
- **Tax Breakdown**: View detailed split of **CGST**, **SGST**, and **IGST** liabilities to stay on top of tax obligations.
- **Smart Filtering**: Analyze data by **All Time**, **Current Month**, **Last Month**, or specific **Financial Quarters** (Q1-Q4).
- **Quick Actions**: One-click access to create invoices, manage clients, or export reports.

### 🧾 Intelligent Invoicing
Create GST-compliant invoices effortlessly with smart automation:
- **Auto-Tax Calculation**: Just enter the amount, and the app calculates Taxable Value, GST, and Total automatically.
- **Smart Place of Supply**: Auto-detects **Inter-state (IGST)** vs. **Intra-state (CGST+SGST)** transactions based on customer state.
- **Professional PDF Engine**: 
  - Generates high-resolution PDFs with your **Brand Logo**.
  - Supports **A4** layout with standard margins.
  - Interactive **Full-Screen Preview** with Zoom and Print capability.
- **Number to Words**: Automatically converts invoice totals into words (e.g., "Rupees One Thousand Only") as per Indian banking standards.

### 👥 Client & Inventory Management
Streamline your workflow by managing data efficiently:
- **Client Directory**: Save customer details (GSTIN, Address, Contact) once and auto-fill them in future invoices.
- **Inventory/Services**: Manage your products/services with predefined **HSN/SAC codes** and tax rates (0%, 5%, 12%, 18%, 28%).
- **Search & Select**: Quickly find clients or items while creating invoices without manual entry.

### 📈 Compliance & Exports
Stay compliant with Indian tax regulations:
- **GSTR-1 Ready**: Export your sales data into **GSTR-1 compatible CSV format** for easy filing with your Chartered Accountant (CA).
- **GSTIN Validation**: (Planned) Real-time validation of customer GST numbers.

### 🎨 Cross-Platform Adaptive UI
Experience a truly native feel on every device:
- **Windows**: Built with **Fluent UI** (Acrylic effects, Reveal focus) to look and feel like a native Windows 11 app.
- **Linux & Android**: Adapts to **Material Design 3** (Material You) with dynamic theming and responsive layouts.
- **Theme Engine**: Complete support for System, Light, and Dark modes with customizable accent colors to match your brand.

---

## 📥 Download

Get the latest nightly build for **Windows**:

[![Download Windows Installer](https://img.shields.io/badge/Download-Windows_Installer-blue?style=for-the-badge&logo=windows)](https://github.com/SV-stark/InvoBharat/releases/tag/nightly)
[![Download Linux AppImage](https://img.shields.io/badge/Download-Linux_AppImage-orange?style=for-the-badge&logo=linux)](https://github.com/SV-stark/InvoBharat/releases/tag/nightly)

> **Note**: This is a nightly release. It contains the absolute latest features but may be experimental.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **UI Library**: 
  - **Windows**: [fluent_ui](https://pub.dev/packages/fluent_ui) (Native Feel)
  - **Linux/Android**: Material Design 3
- **State Management**: [Riverpod](https://riverpod.dev)
- **PDF Engine**: `pdf` & `printing` packages
- **Typography**: Google Fonts (Noto Sans)

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

    # For Linux
    flutter run -d linux
    ```

    > **Note for Linux Users**: Ensure you have the necessary prerequisites installed:
    > ```bash
    > sudo apt-get update
    > sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev
    > ```

4.  **Run Tests**
    ```bash
    flutter test
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

<div align="center">
 Made with ❤️ in India.
</div> 