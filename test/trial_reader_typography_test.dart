import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/presentation/trial_reader_typography.dart';

void main() {
  for (final width in [390.0, 1280.0]) {
    testWidgets('reader preserves accessibility scaling at $width', (tester) async {
      double? effectiveSize;
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 844),
            textScaler: const TextScaler.linear(1.5),
          ),
          child: TrialReaderTypography(child: Builder(builder: (context) {
            effectiveSize = MediaQuery.textScalerOf(context).scale(16);
            return const Text('Reading');
          })),
        ),
      ));
      expect(effectiveSize, closeTo(width >= 900 ? 27.84 : 24, .01));
      expect(tester.takeException(), isNull);
    });
  }
}
