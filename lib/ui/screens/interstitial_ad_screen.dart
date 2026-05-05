import 'dart:async';

import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';
import 'package:whaticker/core/services/ads_service.dart';

/// Pantalla para mostrar un anuncio interstitial después de generar un sticker
/// 
/// **Características:**
/// - Muestra el ad de Google
/// - Requiere esperar 5 segundos antes de poder cerrar (X button)
/// - Skip está disponible desde el inicio (regla AdMob: skip opcional pero disponible)
/// - Cierra automáticamente al finalizar o al clickear X
/// - Callback onDismissed cuando se cierra
/// 
/// **Políticas AdMob cumplidas:**
/// - El ad NO se cierra automáticamente inmediatamente
/// - El usuario PUEDE hacer skip desde el inicio
/// - No hay clics fraudulentos
/// - Se respetan los tiempos y callbacks
class InterstitialAdScreen extends StatefulWidget {
  final VoidCallback? onDismissed;

  const InterstitialAdScreen({super.key, this.onDismissed});

  @override
  State<InterstitialAdScreen> createState() => _InterstitialAdScreenState();
}

class _InterstitialAdScreenState extends State<InterstitialAdScreen> {
  static const int _requiredWaitSeconds = 5;
  late int _remainingSeconds;
  Timer? _timer;
  bool get _canClose => _remainingSeconds <= 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _requiredWaitSeconds;
    _startCountdown();
    // Mostrar el ad de Google (si está disponible)
    _showAd();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds -= 1;
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _showAd() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await AdsService().showInterstitialAd(
        onDismissed: _handleAdDismissed,
      );
    }
  }

  void _handleAdDismissed() {
    debugPrint('Ad dismissed by user or auto-closed');
    // El ad ya se cerró por sí solo, no necesitamos hacer nada extra aquí
  }

  void _close() {
    if (!_canClose) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.l10n.onboardingFinishButton} ($_remainingSeconds s)'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
      return;
    }
    _timer?.cancel();
    widget.onDismissed?.call();
    Navigator.of(context).pop();
  }

  void _skip() {
    _timer?.cancel();
    widget.onDismissed?.call();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canClose,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_canClose) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Espera $_remainingSeconds segundos'),
              duration: const Duration(milliseconds: 1500),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              // Contenido principal (la zona de anuncios se superpone aquí)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.videogame_asset,
                      size: 80,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Anuncio publicitario',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Esperando a que se cargue...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Botón de cerrar (X) arriba a la derecha (respecting safe insets)
              Builder(builder: (ctx) {
                final topInset = MediaQuery.of(ctx).viewPadding.top;
                return Positioned(
                  top: topInset + 8,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _close,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close,
                            color: _canClose ? AppColors.accent : AppColors.border,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              // Contador de tiempo esperado (lado derecho)
              if (!_canClose)
                Builder(builder: (ctx) {
                  final topInset = MediaQuery.of(ctx).viewPadding.top;
                  return Positioned(
                    top: topInset + 72,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_remainingSeconds s',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              // Botón Skip abajo (respetando safe inset)
              Builder(builder: (ctx) {
                final bottomInset = MediaQuery.of(ctx).viewPadding.bottom;
                return Positioned(
                  bottom: bottomInset + 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: OutlinedButton(
                      onPressed: _skip,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.accent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'SALTAR',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
