import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/ui/features/sticker_editor/presentation/widgets/editor_timeline.dart';

void main() {
  testWidgets('EditorTimeline draws buffered overlay when bufferedFraction provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: EditorTimeline(
              startPoint: 0.0,
              duration: 5.0,
              playheadPosition: 0.1,
              videoDurationSecs: 10.0,
              bufferedFraction: 0.3,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final finder = find.byWidgetPredicate((w) {
      if (w is Container && w.color != null) {
        return w.color == AppColors.accent.withValues(alpha: 0.08);
      }
      return false;
    });

    expect(finder, findsOneWidget);
  });
}
