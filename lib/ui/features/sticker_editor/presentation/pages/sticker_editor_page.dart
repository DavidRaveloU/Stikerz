import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/repositories/pack_repository.dart';
import 'package:whaticker/core/services/sticker_generation_service.dart';
import 'package:whaticker/ui/features/sticker_editor/presentation/widgets/aspect_ratio_selector.dart';
import 'package:whaticker/ui/features/sticker_editor/presentation/widgets/editor_controls.dart';
import 'package:whaticker/ui/features/sticker_editor/presentation/widgets/editor_timeline.dart';
import 'package:whaticker/ui/features/sticker_editor/presentation/widgets/editor_top_bar.dart';
import 'package:whaticker/ui/features/sticker_editor/presentation/widgets/editor_video_area.dart';
import 'package:whaticker/ui/features/sticker_editor/presentation/widgets/generate_confirm_dialog.dart';
import 'package:whaticker/ui/features/sticker_editor/presentation/widgets/generation_failure_modal.dart';

class StickerEditorPage extends ConsumerStatefulWidget {
  final int packId;
  final int slotIndex;
  final String sourceType;
  final String? videoPath;

  const StickerEditorPage({
    super.key,
    required this.packId,
    required this.slotIndex,
    required this.sourceType,
    this.videoPath,
  });

  @override
  ConsumerState<StickerEditorPage> createState() => _StickerEditorPageState();
}

class _StickerEditorPageState extends ConsumerState<StickerEditorPage>
    with TickerProviderStateMixin {
  late final Player _player;
  late final VideoController _videoController;

  bool _videoReady = false;
  bool _isPlaying = false;
  bool _isGenerating = false;
  String _generationStatus = '';
  double? _generationProgress;

  // Estados locales del editor
  AspectRatioOption _aspectRatio = AspectRatioOption.square;
  double _startPoint = 0.0;
  double _duration = 5.0;
  double _playheadPosition = 0.0;
  double _videoDurationSecs = 1.0;
  Offset _cropOffset = const Offset(0.08, 0.10);
  double _cropWidth = 0.76;
  double _videoAspect = 1.0;

  late AnimationController _playheadCtrl;

  @override
  void initState() {
    super.initState();

    _player = Player();
    _videoController = VideoController(_player);

    _playheadCtrl =
        AnimationController(
            vsync: this,
            duration: Duration(seconds: _duration.round()),
          )
          ..addListener(() {
            if (!_isGenerating) {
              setState(() {
                _playheadPosition =
                    _startPoint +
                    _playheadCtrl.value * (_duration / _videoDurationSecs);
              });
            }
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && _isPlaying) {
              _restartLoopPreviewFromStart();
            }
          });

    _initVideo();
  }

  Future<void> _initVideo() async {
    final path = widget.videoPath;
    try {
      if (path == null || path.trim().isEmpty) {
        throw const FormatException('Ruta de video vacía');
      }

      // Configuración especial para TikTok e Instagram (streams HTTP)
      if (path.startsWith('http')) {
        final nativePlayer = _player.platform as NativePlayer;
        await nativePlayer.setProperty('hwdec', 'mediacodec');
        await nativePlayer.setProperty('hwdec-codecs', 'all');
        await nativePlayer.setProperty('cache', 'yes');
        await nativePlayer.setProperty('cache-secs', '15');
      }

      await _player.open(Media(path), play: false);

      // Esperamos duración + primer frame visible
      bool videoInitialized = false;

      // Duración
      _player.stream.duration.first.then((dur) {
        if (!mounted || videoInitialized) return;
        setState(() {
          _videoDurationSecs = dur.inMilliseconds > 0
              ? dur.inMilliseconds / 1000.0
              : 1.0;
          _syncDurationToWindow();
        });
      });

      // Video params (aspect ratio)
      _player.stream.videoParams.listen((params) {
        if (!mounted) return;
        final resolved = _resolveAspectFromParams(params);
        if (resolved != null && resolved > 0) {
          setState(() => _videoAspect = resolved);
        }
      });

      // Loop
      _player.stream.completed.listen((_) {
        if (_isPlaying && mounted) {
          _restartLoopPreviewFromStart();
        }
      });

      // Espera inteligente: máximo 8 segundos para marcar como listo
      try {
        await Future.any([
          _player.stream.videoParams.firstWhere(
            (p) => (p.w ?? p.dw) != null && (p.h ?? p.dh) != null,
          ),
          _player.stream.duration.firstWhere((d) => d.inMilliseconds > 500),
        ]).timeout(const Duration(seconds: 8));
      } catch (_) {
        debugPrint('Timeout esperando inicialización del video (Instagram)');
      }

      if (!mounted) return;
      setState(() => _videoReady = true);

      await _player.play();
      if (!mounted) return;
      setState(() => _isPlaying = true);
      _playheadCtrl.forward(from: 0);
    } catch (e) {
      debugPrint('Error inicializando editor de video: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo abrir el video: $e')));
      Navigator.pop(context);
    }
  }

  Future<void> _restartLoopPreviewFromStart() async {
    final ms = (_startPoint * _videoDurationSecs * 1000).round();
    await _player.seek(Duration(milliseconds: ms));

    if (!mounted) return;
    setState(() => _playheadPosition = _startPoint);

    _playheadCtrl.stop();
    if (_isPlaying) {
      await _player.play();
      _playheadCtrl.forward(from: 0);
    }
  }

  double? _resolveAspectFromParams(VideoParams params) {
    final baseW = params.dw ?? params.w;
    final baseH = params.dh ?? params.h;
    if (baseW == null || baseH == null || baseW <= 0 || baseH <= 0) {
      return null;
    }
    return baseW / baseH;
  }

  void _syncDurationToWindow() {
    final maxDur = _maxDurationForCurrentStart;
    if (_duration > maxDur) _duration = maxDur;
    _playheadCtrl.duration = Duration(milliseconds: (_duration * 1000).round());
  }

  double get _maxDurationForCurrentStart {
    final remaining = _videoDurationSecs - (_startPoint * _videoDurationSecs);
    return math.min(5.0, remaining.clamp(0.1, 5.0));
  }

  void _togglePlay() async {
    setState(() => _isPlaying = !_isPlaying);

    if (_isPlaying) {
      await _player.play();
      _playheadCtrl.forward();
    } else {
      await _player.pause();
      _playheadCtrl.stop();
    }
  }

  void _setAspectRatio(AspectRatioOption ratio) {
    setState(() {
      _aspectRatio = ratio;
      final n = _normalizeCrop(_cropOffset, _cropWidth, ratio);
      _cropOffset = n.$1;
      _cropWidth = n.$2;
    });
  }

  (Offset, double) _normalizeCrop(
    Offset rawOffset,
    double rawWidth,
    AspectRatioOption ratio,
  ) {
    final safeAspect = _videoAspect > 0 ? _videoAspect : 1.0;
    double safeWidth = rawWidth.clamp(0.15, 1.0);
    double safeHeight = (safeWidth * safeAspect) / ratio.ratio;

    if (safeHeight > 1.0) {
      safeHeight = 1.0;
      safeWidth = (safeHeight * ratio.ratio / safeAspect).clamp(0.15, 1.0);
    }

    final maxDx = (1.0 - safeWidth).clamp(0.0, 1.0);
    final maxDy = (1.0 - safeHeight).clamp(0.0, 1.0);

    final safeOffset = Offset(
      rawOffset.dx.clamp(0.0, maxDx),
      rawOffset.dy.clamp(0.0, maxDy),
    );

    return (safeOffset, safeWidth);
  }

  void _updateCrop(Offset offset, double width) {
    final n = _normalizeCrop(offset, width, _aspectRatio);
    setState(() {
      _cropOffset = n.$1;
      _cropWidth = n.$2;
    });
  }

  void _showGenerateConfirm() {
    showDialog(
      context: context,
      builder: (_) => GenerateConfirmDialog(
        aspectRatio: _aspectRatio,
        startSecs: _startPoint * _videoDurationSecs,
        durationSecs: _duration,
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          Navigator.pop(context);
          _generateSticker();
        },
      ),
    );
  }

  Future<void> _generateSticker() async {
    // Pausar el video mientras se genera
    if (_isPlaying) {
      await _player.pause();
      _playheadCtrl.stop();
      setState(() => _isPlaying = false);
    }

    setState(() {
      _isGenerating = true;
      _generationStatus = 'Preparando...';
      _generationProgress = 0.0;
    });

    try {
      final result = await StickerGenerationService.generate(
        StickerGenerationRequest(
          inputPath: widget.videoPath!,
          packId: widget.packId,
          slotIndex: widget.slotIndex,
          startSec: _startPoint * _videoDurationSecs,
          durationSec: _duration,
          cropX: _cropOffset.dx,
          cropY: _cropOffset.dy,
          cropWidth: _cropWidth,
          cropHeight: (_cropWidth * _videoAspect) / _aspectRatio.ratio,
          requiresInternet: widget.sourceType == 'tiktok',
          aspectRatioLabel: _aspectRatio.label,
        ),
        strategy: 'none',
        onStatus: (status, progress) {
          if (!mounted) return;
          setState(() {
            _generationStatus = status;
            _generationProgress = progress;
          });
        },
      );

      if (result.success && result.path != null) {
        await PackRepository.instance.addSticker(
          packId: widget.packId,
          slotIndex: widget.slotIndex,
          webpPath: result.path!,
          sourceType: widget.sourceType,
        );

        if (!mounted) return;
        Navigator.pop(context, 'generated');
      } else {
        if (!mounted) return;
        _showFailureModal(retry: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showFailureModal(retry: false);
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generationStatus = '';
          _generationProgress = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _playheadCtrl.dispose();
    super.dispose();
  }

  void _showFailureModal({bool retry = false}) {
    showDialog(
      context: context,
      builder: (_) => GenerationFailureModal(
        canRetry: retry,
        onRetryWithBlur: () => _retryWith(StickerStrategy.lightBlur),
        onRetryWithReduceFps: () => _retryWith(StickerStrategy.reduceFps),
        onRetryWithBlurAndReduceFps: () =>
            _retryWith(StickerStrategy.blurAndReduceFps),
        onRetryWithTransparency: () =>
            _retryWith(StickerStrategy.increaseTransparency),
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _retryWith(StickerStrategy strategy) {
    Navigator.pop(context); // cierra el modal de error
    Future.delayed(const Duration(milliseconds: 300), () {
      _generateStickerWithStrategy(strategy);
    });
  }

  // Nuevo método auxiliar
  Future<void> _generateStickerWithStrategy(StickerStrategy strategy) async {
    setState(() {
      _isGenerating = true;
      _generationStatus = 'Intentando con estrategia...';
      _generationProgress = 0.0;
    });

    try {
      final result = await StickerGenerationService.generate(
        StickerGenerationRequest(
          inputPath: widget.videoPath!,
          packId: widget.packId,
          slotIndex: widget.slotIndex,
          startSec: _startPoint * _videoDurationSecs,
          durationSec: _duration,
          cropX: _cropOffset.dx,
          cropY: _cropOffset.dy,
          cropWidth: _cropWidth,
          cropHeight: (_cropWidth * _videoAspect) / _aspectRatio.ratio,
          requiresInternet: widget.sourceType == 'tiktok',
          aspectRatioLabel: _aspectRatio.label,
        ),
        strategy: strategy.name,
        onStatus: (status, progress) {
          if (!mounted) return;
          setState(() {
            _generationStatus = status;
            _generationProgress = progress;
          });
        },
      );

      if (result.success && result.path != null) {
        await PackRepository.instance.addSticker(
          packId: widget.packId,
          slotIndex: widget.slotIndex,
          webpPath: result.path!,
          sourceType: widget.sourceType,
        );

        if (!mounted) return;
        Navigator.pop(context, 'generated');
      } else {
        if (!mounted) return;
        _showFailureModal(retry: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showFailureModal(retry: false);
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generationStatus = '';
          _generationProgress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            EditorTopBar(
              selectedAspect: _aspectRatio,
              onAspectChanged: _setAspectRatio,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: EditorVideoArea(
                videoController: _videoController,
                videoReady: _videoReady,
                cropOffset: _cropOffset,
                cropWidth: _cropWidth,
                aspectRatio: _aspectRatio,
                videoAspect: _videoAspect,
                onCropChanged: _updateCrop,
                onTogglePlay: _togglePlay,
                isPlaying: _isPlaying,
              ),
            ),
            EditorTimeline(
              startPoint: _startPoint,
              duration: _duration,
              playheadPosition: _playheadPosition,
              videoDurationSecs: _videoDurationSecs,
            ),
            EditorControls(
              startPoint: _startPoint,
              duration: _duration,
              videoDurationSecs: _videoDurationSecs,
              isGenerating: _isGenerating,
              generationStatus: _generationStatus,
              generationProgress: _generationProgress,
              aspectRatio: _aspectRatio,
              onAspectChanged: _setAspectRatio,
              onStartPointChanged: (v) {
                setState(() {
                  _startPoint = v;
                  _syncDurationToWindow();
                  _playheadPosition = _startPoint;
                });
                _restartLoopPreviewFromStart();
              },
              onDurationChanged: (v) {
                setState(() {
                  _duration = v.clamp(0.1, _maxDurationForCurrentStart);
                  _playheadCtrl.duration = Duration(
                    milliseconds: (_duration * 1000).round(),
                  );
                  _playheadPosition = _startPoint;
                });
                _restartLoopPreviewFromStart();
              },
              onGenerate: _showGenerateConfirm,
            ),
          ],
        ),
      ),
    );
  }
}
