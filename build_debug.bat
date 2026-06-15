@echo off
REM Build script para compilar APK en debug mode con Test IDs de AdMob
REM Uso: build_debug.bat

echo.
echo 🔨 Compilando Stikerz en mode DEBUG con Test IDs...
echo.

flutter build apk --debug

if %ERRORLEVEL% equ 0 (
  echo.
  echo ✅ APK de debug compilado exitosamente!
  echo 📍 Ubicacion: build\app\outputs\flutter-apk\app-debug.apk
  echo ℹ️  Usando Test IDs de Google (sin riesgo de ban)
  echo.
) else (
  echo.
  echo ❌ Error durante la compilacion. Revisa los logs arriba.
  exit /b 1
)
