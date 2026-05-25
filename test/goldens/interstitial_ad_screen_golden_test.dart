import 'package:golden_test/golden_test.dart';
import 'package:stikerz/ui/screens/interstitial_ad_screen.dart';

import '../golden_test_config.dart';

void main() {
  setupGoldenTests();

  goldenTest(
    name: 'interstitial_ad_screen',
    subdirectory: 'ads',
    builder: (_) => InterstitialAdScreen(
      onDismissed: () {},
      autoStartCountdown: false,
      autoShowAd: false,
      initialRemainingSeconds: 3,
      showInterstitialAd: ({onDismissed}) async {},
    ),
  );
}
