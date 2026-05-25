# 🔨 Build Scripts para Stikerz

Scripts para compilar APK sin tener que escribir las IDs de AdMob cada vez.

## 📝 Archivos

- `build_release.sh` / `build_release.bat` - Compila en **Release** (producción) con IDs reales
- `build_debug.sh` / `build_debug.bat` - Compila en **Debug** (testing) con Test IDs de Google

## 🚀 Uso

### Windows (Command Prompt / PowerShell)

**Release (producción):**

```cmd
build_release.bat
```

**Debug (testing):**

```cmd
build_debug.bat
```

### macOS / Linux (Terminal)

**Release (producción):**

```bash
./build_release.sh
```

**Debug (testing):**

```bash
./build_debug.sh
```

> ⚠️ En Linux/macOS, primero haz ejecutable el script:
>
> ```bash
> chmod +x build_*.sh
> ```

## 📊 Diferencias

| Modo        | IDs                 | Riesgo                      | Uso                             |
| ----------- | ------------------- | --------------------------- | ------------------------------- |
| **Release** | Reales (producción) | ❌ Ninguno si son correctas | Para Play Store, builds finales |
| **Debug**   | Test de Google      | ✅ 0 riesgo                 | Testing local, validación       |

## ✅ IDs Configuradas

- **Banner:** `ca-app-pub-4826279350222741/4948167391`
- **Interstitial:** `ca-app-pub-4826279350222741/1401691127`

## 🎯 Flujo de compilación

1. **Local testing:** Ejecuta `build_debug.bat` → genera `app-debug.apk`
2. **Release final:** Ejecuta `build_release.bat` → genera `app-release.apk`
3. **Play Store:** Sube el `app-release.apk`

## 🔄 GitHub Actions

El workflow automático en `.github/workflows/build_apk.yml` también usa estos mismos IDs vía Secrets cuando se hace push a `main` o se crea un tag `v*`.

---

**¡Listo! Solo ejecuta el script y deja que compile.** 🎉
