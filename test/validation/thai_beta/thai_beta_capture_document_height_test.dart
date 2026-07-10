import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/web/screenshot_friendly_scroll.dart';

void main() {
  group('computeScreenshotHostHeight', () {
    test('uses measured content plus padding', () {
      final height = computeScreenshotHostHeight(
        contentHeightPx: 5000,
        topPaddingPx: 40,
        hostPaddingPx: 80,
        windowInnerHeightPx: 915,
      );
      expect(height, 5120);
    });

    test('floors at viewport for short content', () {
      final height = computeScreenshotHostHeight(
        contentHeightPx: 200,
        topPaddingPx: 0,
        hostPaddingPx: 80,
        windowInnerHeightPx: 915,
      );
      expect(height, 915);
    });

    test('does not read body or document scroll heights', () {
      final height = computeScreenshotHostHeight(
        contentHeightPx: 7000,
        topPaddingPx: 35,
        hostPaddingPx: 80,
        windowInnerHeightPx: 915,
      );
      expect(height, 7115);
      expect(height, isNot(14234));
    });
  });
}
