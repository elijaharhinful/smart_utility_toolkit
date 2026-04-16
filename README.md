# NexKit — Smart Utility Toolkit

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Version-2.0.0-6C63FF?style=for-the-badge" alt="Version"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge" alt="Platform"/>
</p>

> **NexKit** is a beautifully designed, all-in-one mobile utility toolkit built with Flutter. It brings together a smart unit converter, live currency exchange, and a task manager into a single, polished experience.

---

## Features

### Smart Dashboard
- **First-time onboarding** experience with a personalised welcome flow
- **Returning user dashboard** showing top tasks, quick-access converter shortcuts, and recent conversion history at a glance

### Unit Converter
Supports **6 measurement categories** with instant, real-time conversion:

| Category     | Units Covered |
|-------------|---------------|
| 📏 Length    | Meter, Kilometer, Centimeter, Millimeter, Mile, Yard, Feet, Inch |
| ⚖️ Weight    | Kilogram, Gram, Milligram, Pound, Ounce, Ton, Stone |
| 🌡️ Temperature | Celsius, Fahrenheit, Kelvin |
| 📐 Area      | Square Meter, Square Kilometer, Square Mile, Square Foot, Hectare, Acre |
| 💨 Speed     | m/s, km/h, mph, Knots, ft/s |
| 🧪 Volume    | Liter, Milliliter, Cubic Meter, Gallon (US), Fluid Ounce, Cup, Pint |

### Currency Converter
- Live exchange rates
- Supports a wide range of global currencies

### Task Manager
- Create, edit, and complete tasks
- Priority levels and due-date support

### Settings
- **Appearance** — customise the app look and feel
- **Preferences** — configure app behaviour
- App version info, Privacy Policy & Terms of Service links

---

## Project Structure

```
lib/
├── main.dart                   # Entry point, Provider setup
├── app_router.dart             # GoRouter navigation config
├── core/
│   └── theme/
│       └── app_theme.dart      # Design tokens & Material theme
└── features/
    ├── home/                   # Splash, Dashboard (first-time & returning)
    ├── converter/              # Converter category list screen
    ├── unit_converter/         # Unit converter screen & logic
    ├── currency/               # Currency screen & CurrencyProvider
    ├── history/                # ConversionHistoryProvider
    ├── tasks/                  # Task model, screen, form & TasksProvider
    ├── settings/               # Settings screen & section widgets
    └── shell/                  # AppShell scaffold (bottom nav)
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **≥ 3.x** (Dart ≥ 3.x)
- An Android emulator / physical device **or** iOS Simulator (macOS only)
- `flutter doctor` showing no critical errors

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/smart_utility_toolkit.git
cd smart_utility_toolkit

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run
```

> **Tip:** Use `flutter run -d chrome` to test in a browser during development (some features may behave differently on web).

### Build a Release APK (Android)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```
#### Build a smaller Release APK (Android) targetted for appetize.io
```bash
flutter build apk --release --target-platform android-arm64 
#flutter build apk --release --target-platform android-x64
```

### Build for iOS (macOS only)

```bash
flutter build ios --release
```

---

## Contributing

Contributions are welcome! Please open an issue first to discuss proposed changes, then submit a pull request.

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Commit your changes: `git commit -m "feat: add your feature"`
4. Push and open a PR

---

## License

This project is open-source. See [LICENSE](LICENSE) for details.

---

<p align="center">Made using Flutter &nbsp;|&nbsp; NexKit v2.0.0</p>
