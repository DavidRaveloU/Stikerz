# Whaticker

**Create animated WhatsApp sticker packs from your favorite videos.**

Whaticker lets you capture short-form videos from TikTok, Instagram, or your device gallery, transform them into animated stickers, organize them into packs, and export them to WhatsApp. Quick, intuitive, and ready to use.

---

## Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/5cb1f189-6770-49be-b994-9b7fd221b444" width="30%" style="margin: 0 8px;" />
  <img src="https://github.com/user-attachments/assets/c85ddde4-5d51-4ea9-a7d9-8bdaef592614" width="30%" style="margin: 0 8px;" />
  <img src="https://github.com/user-attachments/assets/df1204e8-1fa5-4e01-9db5-5342b61dc6a7" width="30%" style="margin: 0 8px;" />
</p>


---

## Highlights

- Import videos from TikTok, Instagram, or your phone gallery.
- Customize video crop, timing, and effects before generating stickers.
- Organize stickers into themed packs.
- Export complete packs to WhatsApp with just one tap.
- Available in multiple languages with automatic detection.
- Works offline after initial setup.

---

## Core Features

### Sticker Packs

- Create and manage multiple sticker packs.
- Add, remove, rename, and preview stickers.
- Store packs locally on your device.
- Track pack status and completeness.

### Sticker Generation

- Import videos from TikTok, Instagram, or your gallery.
- Adjust crop and timing before generating.
- Convert video clips into smooth, shareable stickers.
- Handle edge cases with smart retry strategies.

### WhatsApp Export

- Validate pack requirements before export (cover + at least 3 stickers).
- Package and send sticker packs directly to WhatsApp.
- Real-time feedback during the export process.

### Languages

- English, Spanish, and Portuguese.
- Automatic detection based on device settings.
- All labels, dialogs, and messages localized.

---

## Tech Stack

- **Flutter / Dart** for the application.
- **Riverpod** for state management.
- **GoRouter** for navigation.
- **Media processing** for sticker generation.

---

## Getting Started

### Prerequisites

- Flutter SDK ([install](https://flutter.dev/docs/get-started/install))
- Android SDK (API level 21+)
- Dart 3.0+

### Clone & Setup

```bash
git clone https://github.com/DavidRaveloU/Stikerz.git
cd stikerz
```

### Configure Local Environment

Two local configuration files are required (both gitignored):

#### 1. `android/local.properties` — Android SDK paths

```bash
cp android/local.properties.template android/local.properties
```

Edit `android/local.properties` with your local paths:
```properties
sdk.dir=C:\\Users\\[YOUR_USERNAME]\\AppData\\Local\\Android\\sdk
flutter.sdk=C:\\[YOUR_FLUTTER_PATH]
```

**Find your paths:**
- `sdk.dir`: Run `flutter doctor -v` and check the Android SDK path
- `flutter.sdk`: Run `which flutter` (macOS/Linux) or `where flutter` (Windows)

#### 2. `.env` — AdMob Configuration

```bash
cp .env.template .env
```

The file is pre-configured with **test AdMob IDs** (safe for development). Skip editing unless using production IDs.

### Run

```bash
flutter pub get
flutter run
```

---

## Development

- **Analyze:** `flutter analyze`
- **Test:** `flutter test`
- **Build:** See [BUILD_SCRIPTS.md](BUILD_SCRIPTS.md) for platform-specific instructions
- **Localization:** See [I18N_GUIDE.md](I18N_GUIDE.md) for adding translations
- **Golden Tests:** See [docs/GOLDENS.md](docs/GOLDENS.md) for UI regression testing



