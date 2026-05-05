# Guía de Integración de Google AdMob

## ✅ Setup completado

- [x] Dependencia `google_mobile_ads` añadida
- [x] App ID configurado vía inyección en build-time (no en código fuente)
- [x] Servicio `AdsService` creado (manejo centralizado de ads)
- [x] Providers Riverpod creados (`adsServiceProvider`, `bannerAdProvider`, `interstitialAdProvider`)
- [x] Inicialización de MobileAds en `main.dart`
- [x] Widget `BannerAdWidget` creado
- [x] Screen `InterstitialAdScreen` creada
- [x] Inyección segura vía Gradle + `--dart-define`

---

## 🔐 Seguridad: Cómo se manejan los IDs sin exponerlos

### ✅ No hay IDs reales en el código fuente
- `android/gradle.properties` está en `.gitignore`
- `ios/Runner/Info.plist` usa placeholder (se inyecta en build)
- `lib/core/config/ads_config.dart` lee valores vía `--dart-define`

### 📋 Archivos de configuración

1. **`android/gradle.properties.template`** (en el repo, como referencia)
   - Muestra qué valores necesita
   - Nunca se compila (es solo template)

2. **`android/gradle.properties`** (NO en el repo, local solamente)
   - Contiene los valores reales
   - Se crea localmente desde el template
   - Se crea en GitHub Actions desde Secrets

---

## 🚀 Cómo compilar localmente

### 1️⃣ Copia el template a tu máquina
```bash
cp android/gradle.properties.template android/gradle.properties
```

### 2️⃣ Edita y agrega tus valores reales
```bash
nano android/gradle.properties
# O abre el archivo con tu editor favorito
```

Contenido esperado:
```properties
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
kotlin.jvm.target.validation.mode=warning
ADMOB_APP_ID=ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
```

### 3️⃣ Compile el APK con tus IDs de Dart
```bash
flutter build apk --release \
  --dart-define=ADMOB_BANNER_ID=ca-app-pub-XXXXXXXX/ZZZZZZZZ \
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-XXXXXXXX/AAAAAAAA
```

### 4️⃣ El APK resultante tendrá todos tus IDs inyectados (sin quedar en archivos)
- Ubicación: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🐙 Cómo compilar en GitHub (sin exponer IDs)

### 1️⃣ Configura los Secrets en GitHub

En tu repositorio:
1. Ve a **Settings** > **Secrets and variables** > **Actions**
2. Crea 3 Secrets:
   - `ADMOB_APP_ID`: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`
   - `ADMOB_BANNER_ID`: `ca-app-pub-XXXXXXXX/ZZZZZZZZ`
   - `ADMOB_INTERSTITIAL_ID`: `ca-app-pub-XXXXXXXX/AAAAAAAA`

### 2️⃣ El workflow se ejecuta automáticamente

- En cada **push a main**: Compila el APK (disponible como artifact)
- En cada **tag v***: Compila el APK y lo sube a una Release

### 3️⃣ Descarga el APK desde GitHub

**Opción A: Como artifact (desde push a main)**
1. Ve a **Actions** > La ejecución más reciente
2. Descarga `whaticker-apk`

**Opción B: Como Release (desde tag)**
1. Ve a **Releases**
2. Descarga el APK adjunto

---

## 🎯 IDs de Ad Unit (referencia para testing)

| Ambiente | Tipo | Ad Unit ID |
|----------|------|-----------|
| **Test** | Banner | `ca-app-pub-3940256099942544/6300978111` |
| **Test** | Interstitial | `ca-app-pub-3940256099942544/1033173712` |

Para producción, usa tus IDs reales de AdMob Console.

### Cambiar tiempo de espera en InterstitialAdScreen
```dart
// En `lib/ui/screens/interstitial_ad_screen.dart`
static const int _requiredWaitSeconds = 5; // Cambiar aquí
```

### Usar IDs de producción en debug (para testing)
```dart
// En `lib/core/services/ads_service.dart`, cambiar:
static const bool _useTestIds = kDebugMode; // → false (fuerza producción)
```

⚠️ **No lo hagas a menos que sepas lo que haces. Los IDs de test previenen bans.**

---

## 📋 Próximos pasos

1. **Integra el banner** en `HomePage` y `PackDetailPage`
2. **Integra el interstitial** después de generar un sticker (busca dónde llamas a la generación)
3. **Prueba en debug** con los IDs de test
4. **Valida en release** antes de publicar en Play Store

---

## ❓ Troubleshooting

| Problema | Solución |
|----------|----------|
| Banner no aparece | Verifica `isBannerLoaded == true` |
| Interstitial no carga | Llama a `loadInterstitialAd()` con anticipación |
| "Ad no está listo" | El ad tarda unos segundos en cargar, espera o premuestra |
| App crashea al mostrar ad | Comprueba que `onDismissed` callback es válido |

---

**Listo para integrar. ¿Necesitas ayuda con alguna pantalla específica?**
