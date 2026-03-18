# 🕌 ShrineTours

A premium **Flutter** travel itinerary mobile application built with **BLoC** state management and **Clean Architecture**. Plan trips, create itineraries, manage packing lists, and explore destinations — all in one beautiful app.

---

## 📱 Features

### 🔐 Authentication
- Splash screen with stunning travel imagery
- Sign in with Email/Password or Google
- Secure session management

### 🗺️ Trip Planning
- Search and select travel destinations
- Choose traveller type (Solo, Couple, Family, Friends)
- Set travel purpose (Leisure, Birthday, Bachelorette)
- Pick travel dates with calendar
- Configure number of adults & kids
- Select trip style (Budget Friendly, Fast Travel, Relaxed, etc.)

### 📋 Itineraries
- View all saved itineraries with trip cards
- Trip details with dates, duration & weather forecast
- Day-by-day itinerary view with timeline
- Activity cards showing time, place, duration & costs
- Route map visualization
- Re-optimize route feature

### 🎒 Packing List
- Select transport modes (Airplane, Bus, Car, Train, etc.)
- Categorized packing items (Essentials, Airplane, Hotel, etc.)
- Check/uncheck items with visual progress tracking
- Quantity controls for each item
- Progress bar showing packing completion

### 👤 Profile & Settings
- Profile settings with editable user info
- Payment methods with card management (Visa, Mastercard)
- Subscription upgrade plans (Premium, Enterprise, Lifetime)
- User levels & gamification (Wanderer → Legend)
- Help & Support center
- Terms & Conditions

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles with **feature-first** folder structure:

```
lib/
├── main.dart
├── core/
│   ├── di/
│   │   └── injection.dart              # GetIt dependency injection
│   ├── router/
│   │   └── app_router.dart             # GoRouter (17 routes)
│   ├── theme/
│   │   └── app_theme.dart              # Design system
│   └── widgets/
│       ├── primary_button.dart
│       ├── custom_app_bar.dart
│       ├── custom_text_field.dart
│       └── trip_card.dart
│
└── features/
    ├── auth/
    │   └── presentation/
    │       ├── bloc/auth_bloc.dart
    │       └── screens/
    │           ├── splash_screen.dart
    │           └── sign_in_screen.dart
    │
    ├── trip_planning/
    │   └── presentation/
    │       ├── bloc/trip_planning_bloc.dart
    │       └── screens/
    │           ├── plan_trip_screen.dart
    │           ├── trip_preferences_screen.dart
    │           └── add_places_screen.dart
    │
    ├── itinerary/
    │   └── presentation/
    │       ├── bloc/itinerary_bloc.dart
    │       └── screens/
    │           ├── my_itineraries_screen.dart
    │           ├── trip_details_screen.dart
    │           └── itinerary_view_screen.dart
    │
    ├── packing/
    │   └── presentation/
    │       ├── bloc/packing_bloc.dart
    │       └── screens/
    │           ├── packing_list_screen.dart
    │           └── checking_packing_screen.dart
    │
    └── profile/
        └── presentation/
            ├── bloc/profile_bloc.dart
            └── screens/
                ├── profile_menu_screen.dart
                ├── profile_settings_screen.dart
                ├── payment_methods_screen.dart
                ├── upgrade_plan_screen.dart
                ├── user_levels_screen.dart
                ├── help_support_screen.dart
                └── terms_screen.dart
```

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform UI framework |
| **flutter_bloc** | State management (BLoC pattern) |
| **go_router** | Declarative routing |
| **get_it** | Dependency injection |
| **equatable** | Value equality for BLoC states |
| **google_fonts** | Inter typography |
| **cached_network_image** | Image caching |
| **intl** | Date/number formatting |
| **flutter_svg** | SVG asset rendering |

---

## 🎨 Design System

| Element | Value |
|---|---|
| **Primary Color** | `#E91E63` (Pink) |
| **Secondary Color** | `#1B2A4A` (Dark Navy) |
| **Font Family** | Inter (Google Fonts) |
| **Border Radius** | 12px (cards), 28px (buttons) |
| **Background** | `#FFFFFF` (White) |
| **Muted Text** | `#9E9E9E` |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>=3.2.0)
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

```bash
# Clone the repository
git clone https://github.com/KK13221/-Shrine_Tours-.git

# Navigate to project directory
cd -Shrine_Tours-

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 📸 Screens Overview

| # | Screen | Route |
|---|---|---|
| 1 | Splash | `/` |
| 2 | Sign In | `/sign-in` |
| 3 | My Itineraries | `/itineraries` |
| 4 | Plan Trip | `/plan-trip` |
| 5 | Trip Preferences | `/trip-preferences` |
| 6 | Add Places | `/add-places` |
| 7 | Trip Details | `/trip-details` |
| 8 | Itinerary View | `/itinerary-view` |
| 9 | Packing List | `/packing-list` |
| 10 | Checking Packing | `/checking-packing` |
| 11 | Profile Menu | `/profile` |
| 12 | Profile Settings | `/profile-settings` |
| 13 | Payment Methods | `/payment-methods` |
| 14 | Upgrade Plan | `/upgrade-plan` |
| 15 | User Levels | `/user-levels` |
| 16 | Help & Support | `/help-support` |
| 17 | Terms & Conditions | `/terms` |

---

## 📊 Project Stats

- **30** Dart files
- **17** screens
- **5** BLoC modules
- **4** reusable widgets
- **17** named routes
- **5** feature modules

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 👨‍💻 Author

**KK13221** — [GitHub Profile](https://github.com/KK13221)

---

> Built with ❤️ using Flutter & BLoC
