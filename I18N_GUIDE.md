# Guía de Internacionalización (i18n) - Stikerz

## Configuración Actual

El app soporta 3 idiomas:

- **Inglés** (`en`) - Idioma por defecto
- **Español** (`es`)
- **Portugués** (`pt`)

## Auto-Detección de Locale

El app detecta automáticamente el idioma del dispositivo:

- Si el dispositivo está en **español** → usa español
- Si el dispositivo está en **portugués** → usa portugués
- Si el dispositivo está en **inglés** → usa inglés
- Si el dispositivo está en **otro idioma** → usa inglés (por defecto)

## Cómo Usar Traducciones en Widgets

### Método 1: Usando la Extension (Recomendado)

```dart
import 'package:stikerz/core/extensions/localization_extension.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.appTitle);
  }
}
```

### Método 2: Acceso Directo

```dart
import 'package:stikerz/generated_l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(l10n.appTitle);
  }
}
```

## Agregar Nuevas Traducciones

### Paso 1: Actualizar los archivos `.arb`

Edita los archivos de traducción en `lib/l10n/`:

- `lib/l10n/en.arb` - Inglés
- `lib/l10n/es.arb` - Español
- `lib/l10n/pt.arb` - Portugués

Ejemplo:

```json
{
  "newString": "My New String",
  "anotherKey": "Another translatable string"
}
```

### Paso 2: Regenerar los archivos de localización

Ejecuta en la terminal:

```bash
flutter gen-l10n
```

O simplemente guarda los cambios en el archivo `.arb` y Flutter rebuild automáticamente generará los nuevos archivos.

### Paso 3: Usar la nueva traducción en el código

```dart
Text(context.l10n.newString)
```

## Archivos Generados

Los archivos generados están en `lib/generated_l10n/` (NO editar directamente):

- `app_localizations.dart` - Clase principal
- `app_localizations_en.dart` - Implementación para inglés
- `app_localizations_es.dart` - Implementación para español
- `app_localizations_pt.dart` - Implementación para portugués

## Estructura de Traducción

Los archivos `.arb` (Application Resource Bundle) siguen este formato:

```json
{
  "@@locale": "en",
  "appTitle": "Stikerz",
  "description": "The main app title"
}
```

## Testing

Para probar diferentes idiomas, cambia el locale en el emulador/dispositivo:

- Android: Settings → Languages → Español/English/Português
- iOS: Settings → General → Language & Region → Español/English/Português

## Referencia de Strings Disponibles

### Navegación y Acciones

- `appTitle` - Título de la app
- `home`, `videoPicker`, `stickerEditor` - Secciones principales
- `yourPacks`, `myStickers` - Palabras clave de UI
- `createPack`, `editPack`, `deletePack`, `renamePack` - Acciones

### Modales y Diálogos

- `galleryLimitedAccessTitle`, `galleryLimitedAccessDesc` - Acceso a galería limitado
- `noPacksTitle`, `noPacksDesc` - Sin paquetes

### Botones

- `cancel`, `save`, `delete`, `edit`, `done`, `close` - Botones generales
- `grantAccess` - Conceder acceso
- `tryAgain` - Reintentar

### Mensajes de Estado

- `loading`, `error`, `success`, `warning` - Estados generales
- `confirming`, `copying`, `generating` - Estados de proceso
- `permissionDenied` - Permiso denegado
- `noInternet` - Sin internet

### Campos de Formulario

- `packName`, `packNameHint` - Nombre del paquete
- `author`, `authorHint` - Autor
- `emptyFieldError`, `tooLongError` - Errores de validación

### Mensajes Informativos

- `addedToPack` - Añadido al paquete
- `failedToAdd` - Fallo al añadir
- `videoNotSupported` - Video no soportado
- `copiedToClipboard` - Copiado al portapapeles
- `errorOccurred`, `unknownError` - Errores generales
