# whaticker

Flutter app (Dart). Entry point: `lib/main.dart`.

## Commands

```bash
flutter analyze    # lint + static analysis
flutter test      # run widget tests
flutter run      # run debug build
```

## Key dependencies

- `media_kit` / `media_kit_video` - video playback (requires `MediaKit.ensureInitialized()` in main)
- `ffmpeg_kit_flutter_new` - video processing
- `photo_manager` / `image_picker` - media selection
- `isar` + `isar_generator` - local DB (requires `dart run build_runner build` after model changes)

## Architecture

```
lib/
├── main.dart           # App entry, MediaKit init
├── ui/screens/        # Screen widgets
├── ui/components/     # Reusable widgets
├── data/             # Models, repositories
├── utils/            # Services (WhatsApp, TikTok, sticker generation)
└── models/           # Deprecated?
```

## Adaptive Layout

Uses `lib/utils/adaptive_layout.dart` with `largeScreenMinWidth = 600dp` breakpoint.

- HomeScreen: switches between GridView (tablet) and ListView (phone), constrained to 600dp max on large screens
- PackDetailScreen: adjusts sticker grid columns (5 phone, 6 tablet)
- VideoPickerScreen: responsive grid via builder
- All bottom sheets use `useSafeArea: true` or `viewInsets` padding for keyboard

## Testing

Tests in `test/widget_test.dart`. Default flutter_test setup uses `WidgetTester`.

## Gotchas

- `MediaKit.ensureInitialized()` must be called before `runApp()`
- Isar models require code generation: add `.g.dart` files via `build_runner`
- Android minSdkVersion may need bumping for some native libs