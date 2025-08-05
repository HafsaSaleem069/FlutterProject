# 🍽️ Flutter Restaurant App – Food Ordering & Buffet Reservation

A full-featured restaurant food ordering and buffet/high-tea reservation app built with **Flutter** and **Firebase**. This mobile application provides both **user-facing features** and an **admin panel**, making it suitable for real-world restaurant use cases.

## ✨ Key Features

### 🧑‍🍳 Customer Side
- 🔍 Explore food menus with categories
- 🛒 Add to cart, checkout, and order food
- 📆 Reserve tables for buffets or high tea
- ❤️ Add items to wishlist
- 👤 View/edit profile
- 📜 See order receipts

### 🧑‍💼 Admin Panel
- 📦 Manage products and menus
- 👥 View customers and orders
- 📊 Admin dashboard with charts
- 🗃️ Firebase Firestore data control

---

## 🔐 Tech Stack

- **Frontend**: Flutter, Dart
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider
- **UI**: Google Fonts, FontAwesome, Cupertino Icons
- **Others**: 
  - `fluttertoast`, `image_picker`
  - `google_mobile_ads`, `fl_chart`, `intl`, `url_launcher`

---

## 📁 Project Structure

```
lib/
├── admin/                   # Admin dashboard and management pages
│   ├── admin_panel.dart         # Main admin panel
│   ├── products_page.dart       # Product management screen
│   └── widgets/                 # Admin-related UI widgets (charts, cards, etc.)

├── auth/                    # Authentication screens
│   └── login_or_Registerpage.dart

├── backend/                 # Backend logic and API-like routing
│   └── routes/
│       └── customer_route.dart

├── components/              # Reusable UI components
│   ├── my_button.dart
│   └── my_textfield.dart

├── database/                # Models and database helper files
│   ├── customer_model.dart
│   └── insertion.dart

├── screens/                 # Main app UI screens
│   ├── homepage.dart
│   ├── cart_page.dart
│   ├── checkout.dart
│   ├── reservation.dart
│   ├── profile_screen.dart
│   ├── product_screen.dart
│   └── ... (more user-facing screens)

├── themes/                  # App theming and styles
├── firebase_options.dart    # Firebase configuration (auto-generated)
└── main.dart                # App entry point
```

---

## 🛠️ Tech Stack

- **Flutter** (UI + mobile logic)
- **Firebase** (Authentication, Firestore, Storage)
- **Provider** (State management)
- **Other packages**:
  - `fluttertoast`, `image_picker`, `google_mobile_ads`, `fl_chart`, `intl`

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>= 3.7.0)
- Firebase project set up
- Android/iOS device or emulator

### Setup

```bash
git clone https://github.com/HafsaSaleem069/FlutterProject.git
cd FlutterProject
flutter pub get
flutter run
