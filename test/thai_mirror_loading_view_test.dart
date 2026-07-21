import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_loading_view.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7E57C2)),
          useMaterial3: true,
        ),
        home: Scaffold(body: child),
      );

  group('ThaiMirrorLoadingView', () {
    for (final size in const [
      Size(390, 844),
      Size(768, 1024),
      Size(1440, 900),
    ]) {
      testWidgets('renders without overflow at ${size.width.toInt()}px',
          (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(host(const ThaiMirrorLoadingView()));
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.text(ThaiMirrorLoadingView.titleTh), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('shows deep analysis subtitle when flagged', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(host(const ThaiMirrorLoadingView(deepAnalysis: true)));
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        find.textContaining('กำลังวิเคราะห์เชิงลึก'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
