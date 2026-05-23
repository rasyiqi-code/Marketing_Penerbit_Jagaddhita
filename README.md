# Marketing Penerbit Jagaddhita App

Marketing Penerbit Jagaddhita is a comprehensive specialized application for **Penerbit Jagaddhita Group**, designed to facilitate marketing operations, sales entries, and administrative management for **Penjualan Buku**.

## 🚀 Features

### for Marketing Agents (Users)
*   **Quick Sales Entry**: Dedicated form for **Penjualan Buku**.
*   **Book Catalog**: Browse products / packages with a dynamic UI.
*   **Link Bio**: Create and manage a professional "Digital Card" / Link in Bio to share with customers.
*   **Wallet & Withdrawals**: Track commissions, pulsa balance, and request withdrawals.
*   **Profile Management**: Manage personal details and bank account information.
*   **Dark Mode Support**: Fully responsive dark mode for comfortable usage in low light.

### for Admins
*   **Dashboard Overview**: Real-time stats on sales and user activity.
*   **Product Management**: Add, edit, and delete products in the Catalog.
*   **Transaction Management**: Verify and approve sales entries.
*   **User Management**: Manage registered agents.
*   **Withdrawal Processing**: Process payout requests.

## 🛠️ Tech Stack

*   **Framework**: Flutter (Web Optimized)
*   **Language**: Dart
*   **Backend**: Firebase (Auth, Firestore, Hosting)
*   **State Management**: Provider
*   **Design**: Custom "Outfit" Font, Dynamic Theming (Red/Blue/Dark)

## 📦 Setup & Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/crediblemark/Marketing_Penerbit_Jagaddhita.git
    cd Marketing_Penerbit_Jagaddhita
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run Locally**
    ```bash
    flutter run -d chrome --web-port=5000
    ```

## 🚀 Deployment

The application is deployed on Firebase Hosting.

**Live URL**: [https://marketing-jagaddhitamp.web.app](https://marketing-jagaddhitamp.web.app)

To deploy updates:
```bash
flutter build web --release
firebase deploy --only hosting
```

## 🔑 Google Sign-In Configuration

For Google Sign-In to work, the hosting domain requires specific configuration in Google Cloud Console:
*   **Console**: [Google Cloud Console](https://console.cloud.google.com/apis/credentials?project=marketing-jagaddhitamp)
*   **Authorized Redirect URI**: `https://marketing-jagaddhitamp.web.app/__/auth/handler`

---
© 2025 Penerbit Jagaddhita Group
