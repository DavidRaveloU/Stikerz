# Flujo de Desarrollo y Release

Este documento describe el flujo de trabajo para desarrollo, pruebas locales y releases a producción.

## Rama `development` (Desarrollo local)

La rama `development` es tu rama de trabajo principal. Aquí haces todo el desarrollo y las pruebas.

### Flujo diario

```bash
# 1. Asegúrate de estar en development
git checkout development

# 2. Crea un feature branch si lo deseas
git checkout -b feature/my-feature

# 3. Trabaja normalmente, haz commits
git add .
git commit -m "feat: implementar nueva funcionalidad"

# 4. Push a tu rama de feature (o directamente a development)
git push origin feature/my-feature
# Luego abre un PR en GitHub o simplemente:
git checkout development
git merge feature/my-feature
git push origin development
```

### Pruebas locales en `development`

#### Debug en tu dispositivo (F5 en VS Code)

```bash
# Asegúrate de estar en development
git checkout development

# Conecta tu teléfono y presiona F5 en VS Code
# O desde terminal:
flutter run
```

#### Build APK Release local (sin tocar main)

Para generar un APK release **localmente** con IDs de test de Google (sin exponer IDs reales):

```bash
# 1. Crea android/gradle.properties con IDs de test (está gitignored, no se comitea)
cat > android/gradle.properties <<EOF
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
kotlin.jvm.target.validation.mode=warning
ADMOB_APP_ID=ca-app-pub-3940256099942544~3347511713
EOF

# 2. Build APK release con IDs de test via --dart-define
flutter build apk --release \
  --dart-define=ADMOB_BANNER_ID=ca-app-pub-3940256099942544/6300978111 \
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-3940256099942544/1033173712

# 3. Salida: build/app/outputs/flutter-apk/app-release.apk
```

**Instalar en tu dispositivo:**
```bash
# Opción A: si el dispositivo está conectado vía ADB
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Opción B: transferir por Bluetooth o USB y instalar manualmente en el dispositivo
```

---

## Rama `main` (Producción)

La rama `main` siempre contiene código listo para producción. Solo se actualiza mediante merge desde `development` cuando estés 100% seguro.

### Actualizar `main` desde `development`

Cuando hayas probado exhaustivamente en `development` y quieras lanzar una actualización a la app en GitHub:

```bash
# 1. Asegúrate de que development está pusheada y lista
git checkout development
git push origin development

# 2. Merge development → main
git checkout main
git pull origin main
git merge development

# 3. Push a main
git push origin main
```

**Alternativa (recomendado en GitHub):** Abre un Pull Request de `development` → `main` y apruébala / mergeala en GitHub.

---

## Release a Producción (GitHub Actions)

Una vez que `main` esté actualizada con los cambios de `development`, genera el APK y crea la Release en GitHub.

### Disparar manualmente el workflow

1. Ve a **GitHub → Actions → "Build and Release APK"**
2. Haz clic en **"Run workflow"**
3. Deja `target_branch` en **`main`** (default)
4. Haz clic en **"Run workflow"**

El workflow automáticamente:
- Usa tus GitHub Secrets (IDs de AdMob reales)
- Construye el APK con IDs de producción
- Sube el APK como artifact
- Si quieres crear un Release, empuja un tag `v1.x.x` y el workflow lo subirá automáticamente

### Ejemplo: Crear un Release con tag

```bash
# En la rama main, después de hacer merge
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin v1.1.0

# El workflow automáticamente detectará el tag y creará la Release en GitHub
```

---

## Flujo completo: De desarrollo a producción

### Paso a paso

1. **Desarrolla en `development`**
   ```bash
   git checkout development
   # ... edita código, commititea, pushea
   ```

2. **Prueba localmente (debug y release)**
   ```bash
   flutter run  # debug en dispositivo conectado
   # ... prueba exhaustiva
   
   # Cuando necesites un release local
   cat > android/gradle.properties <<EOF
   org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
   android.useAndroidX=true
   kotlin.jvm.target.validation.mode=warning
   ADMOB_APP_ID=ca-app-pub-3940256099942544~3347511713
   EOF
   
   flutter build apk --release \
     --dart-define=ADMOB_BANNER_ID=ca-app-pub-3940256099942544/6300978111 \
     --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-3940256099942544/1033173712
   ```

3. **Merge a `main` cuando estés listo**
   ```bash
   git checkout main
   git pull origin main
   git merge development
   git push origin main
   ```

4. **Dispara el workflow en GitHub**
   - Ve a Actions → Build and Release APK → Run workflow
   - Confirma que `target_branch=main`
   - Ejecuta

5. **Descarga el APK o crea una Release**
   - El APK estará en **Artifacts** del workflow run
   - Para crear una Release en GitHub, empuja un tag:
     ```bash
     git tag -a v1.1.0 -m "Release v1.1.0"
     git push origin v1.1.0
     ```

---

## Notas importantes

- **`android/gradle.properties` está gitignored**: no se comitea. Créalo localmente cuando necesites hacer un build local.
- **IDs de test vs. producción**:
  - Test IDs (hardcodeados en scripts): se usan para pruebas locales en `development`.
  - IDs reales: almacenados en GitHub Secrets, inyectados por el workflow cuando haces merge a `main` y disparas el build.
- **GitHub Secrets**: nunca commitees IDs reales; siempre están en Secrets.
- **Tags**: si creas un tag `v*` en `main`, el workflow automáticamente crea un Release en GitHub con el APK.

---

## Protección de ramas (opcional)

Para evitar pushes directos a `main`, configura **Branch Protection**:
- Ve a GitHub → Settings → Branches → Add rule
- Rama: `main`
- Activa "Require a pull request before merging"
- Haz que todos los merges pasen por PR desde `development`

