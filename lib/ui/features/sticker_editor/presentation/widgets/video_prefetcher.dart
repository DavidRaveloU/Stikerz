import 'dart:async';

typedef BufferedFractionGetter = double Function();

/// Lightweight prefetcher that waits until an externally-provided
/// buffered fraction reaches the requested threshold.
///
/// This is intentionally simple: it polls the provided getter periodically
/// and completes when the buffered fraction >= targetFraction, or when
/// the timeout elapses.
class VideoPrefetcher {
  final BufferedFractionGetter _getter;
  final Duration pollInterval;

  VideoPrefetcher(
    this._getter, {
    this.pollInterval = const Duration(milliseconds: 200),
  });

  /// Waits until [targetFraction] (0.0-1.0) is buffered or [timeout]
  /// elapses. Returns true if buffered in time, false on timeout.
  Future<bool> waitForBuffered(
    double targetFraction, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      final val = _getter();
      if (val >= targetFraction) return true;
      await Future.delayed(pollInterval);
    }
    return false;
  }
}
