import 'package:flutter_test/flutter_test.dart';
import 'package:stikerz/core/services/video_preparation_service.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/video_preparation_message.dart';

void main() {
  test('shows slow-connection warning after enough elapsed time', () {
    final type = resolveVideoPreparationMessageType(
      status: const VideoPreparationStatus(
        phase: VideoPreparationPhase.downloading,
        attempt: 1,
        maxAttempts: 3,
        elapsed: Duration(seconds: 18),
        progress: 0.2,
      ),
      hasError: false,
      hasRetried: false,
    );

    expect(type, VideoPreparationMessageType.verySlow);
  });

  test('shows retry message when preparation restarts', () {
    final type = resolveVideoPreparationMessageType(
      status: const VideoPreparationStatus(
        phase: VideoPreparationPhase.retrying,
        attempt: 2,
        maxAttempts: 3,
        elapsed: Duration(seconds: 1),
      ),
      hasError: false,
      hasRetried: false,
    );

    expect(type, VideoPreparationMessageType.retrying);
  });
}
