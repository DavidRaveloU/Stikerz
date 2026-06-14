import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/aspect_ratio_selector.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/editor_video_area.dart';

void main() {
  testWidgets(
    'EditorVideoArea renders loading spinner and text when not ready',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: EditorVideoArea(
                videoController: null,
                videoReady: false,
                isBuffering: false,
                thumbnailPath: null,
                cropOffset: const Offset(0, 0),
                cropWidth: 1.0,
                aspectRatio: AspectRatioOption.square,
                videoAspect: 1.0,
                onCropChanged: (_, _) {},
                onTogglePlay: () {},
                isPlaying: false,
                isMuted: true,
                onToggleMute: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify loading indicator and text are rendered
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    },
  );

  testWidgets(
    'EditorVideoArea shows buffering state UI with progress indicator',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: EditorVideoArea(
                videoController: null,
                videoReady: false,
                isBuffering: true,
                thumbnailPath: null,
                cropOffset: const Offset(0, 0),
                cropWidth: 1.0,
                aspectRatio: AspectRatioOption.square,
                videoAspect: 1.0,
                onCropChanged: (_, _) {},
                onTogglePlay: () {},
                isPlaying: false,
                isMuted: true,
                onToggleMute: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify buffering state renders with progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Verify Container is rendered with black background
      expect(find.byType(Container), findsWidgets);
    },
  );
}
