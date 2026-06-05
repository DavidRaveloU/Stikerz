import 'package:flutter_test/flutter_test.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/video_prefetcher.dart';

void main() {
  test('VideoPrefetcher waits until buffered reaches target', () async {
    double val = 0.0;
    double getter() => val;
    final prefetcher = VideoPrefetcher(
      getter,
      pollInterval: const Duration(milliseconds: 10),
    );

    final future = prefetcher.waitForBuffered(
      0.5,
      timeout: const Duration(seconds: 1),
    );

    // Simulate buffer progress shortly after starting
    Future.delayed(const Duration(milliseconds: 50), () {
      val = 0.6;
    });

    final res = await future;
    expect(res, isTrue);
  });

  test('VideoPrefetcher times out if buffer not reached', () async {
    double val = 0.0;
    double getter() => val;
    final prefetcher = VideoPrefetcher(
      getter,
      pollInterval: const Duration(milliseconds: 20),
    );

    final res = await prefetcher.waitForBuffered(
      0.8,
      timeout: const Duration(milliseconds: 120),
    );
    expect(res, isFalse);
  });
}
