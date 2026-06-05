import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/services/video_preparation_service.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/pages/sticker_editor_page.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/video_preparation_message.dart';

class VideoPreparationPage extends StatefulWidget {
  final int packId;
  final int slotIndex;
  final String sourceType;
  final String videoPath;

  const VideoPreparationPage({
    super.key,
    required this.packId,
    required this.slotIndex,
    required this.sourceType,
    required this.videoPath,
  });

  @override
  State<VideoPreparationPage> createState() => _VideoPreparationPageState();
}

class _VideoPreparationPageState extends State<VideoPreparationPage> {
  double? _progress;
  VideoPreparationStatus? _status;
  String? _errorMessage;
  bool _retrying = false;
  bool _hasRetried = false;
  late final Stopwatch _stopwatch;
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _errorMessage == null) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _prepareVideo();
    });
  }

  Future<void> _prepareVideo() async {
    try {
      final preparedPath = await VideoPreparationService.prepareVideoSource(
        widget.videoPath,
        onStatus: (status) {
          if (!mounted) return;
          setState(() {
            _status = status;
            if (status.phase == VideoPreparationPhase.retrying) {
              _hasRetried = true;
            }
            _retrying = status.phase == VideoPreparationPhase.retrying;
            _progress = status.progress ?? _progress;
          });
        },
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => StickerEditorPage(
            packId: widget.packId,
            slotIndex: widget.slotIndex,
            sourceType: widget.sourceType,
            videoPath: preparedPath,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyPreparationError(error);
        _retrying = false;
      });
    }
  }

  String _friendlyPreparationError(Object error) {
    if (error is VideoPreparationException &&
        error.code == 'network_interrupted') {
      return context.l10n.externalServiceTimeout;
    }

    if (error is VideoPreparationException && error.code == 'download_failed') {
      return context.l10n.externalServiceDown;
    }

    return context.l10n.externalServiceDown;
  }

  @override
  void dispose() {
    _ticker.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = buildVideoPreparationMessage(
      context: context,
      status: _status?.copyWithElapsed(
        Duration(seconds: _stopwatch.elapsed.inSeconds),
      ),
      hasError: _errorMessage != null,
      hasRetried: _hasRetried,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: context.responsiveSize(42, tabletSize: 48),
                  height: context.responsiveSize(42, tabletSize: 48),
                  child: _errorMessage != null
                      ? Icon(
                          Icons.wifi_off_rounded,
                          size: context.responsiveSize(42, tabletSize: 48),
                          color: AppColors.textMuted,
                        )
                      : CircularProgressIndicator(
                          value: _progress,
                          color: AppColors.accent,
                          strokeWidth: 3.5,
                        ),
                ),
                SizedBox(height: context.responsiveSize(20, tabletSize: 24)),
                Text(
                  message.title,
                  textAlign: TextAlign.center,
                  style: context.responsiveTextStyle(
                    mobileSize: 18,
                    tabletSize: 20,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: context.responsiveSize(8, tabletSize: 10)),
                Text(
                  _errorMessage ?? message.subtitle,
                  textAlign: TextAlign.center,
                  style: context.responsiveTextStyle(
                    mobileSize: 13,
                    tabletSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                if (_retrying) ...[
                  SizedBox(height: context.responsiveSize(12, tabletSize: 14)),
                  Text(
                    context.l10n.loadingVideo,
                    textAlign: TextAlign.center,
                    style: context.responsiveTextStyle(
                      mobileSize: 12,
                      tabletSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on VideoPreparationStatus {
  VideoPreparationStatus copyWithElapsed(Duration elapsed) {
    return VideoPreparationStatus(
      phase: phase,
      attempt: attempt,
      maxAttempts: maxAttempts,
      elapsed: elapsed,
      progress: progress,
      totalBytes: totalBytes,
    );
  }
}
