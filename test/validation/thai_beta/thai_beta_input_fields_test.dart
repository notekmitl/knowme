import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_province_options.dart';
import 'package:knowme/features/thai_beta/presentation/widgets/thai_beta_province_field.dart';
import 'package:knowme/features/thai_beta/presentation/widgets/thai_beta_time_picker.dart';

void main() {
  group('Province autocomplete', () {
    testWidgets('typing เชียง narrows to เชียงใหม่ / เชียงราย and selects',
        (tester) async {
      ThaiBetaProvinceOption? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThaiBetaProvinceField(
              value: null,
              onChanged: (v) => selected = v,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'เชียง');
      await tester.pumpAndSettle();

      expect(find.text('เชียงใหม่'), findsOneWidget);
      expect(find.text('เชียงราย'), findsOneWidget);
      expect(find.text('ภูเก็ต'), findsNothing);

      await tester.tap(find.text('เชียงราย'));
      await tester.pumpAndSettle();
      expect(selected?.resolverKey, 'chiang rai');
    });

    testWidgets('typing อุดร narrows to อุดรธานี', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThaiBetaProvinceField(value: null, onChanged: (_) {}),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'อุดร');
      await tester.pumpAndSettle();

      expect(find.text('อุดรธานี'), findsOneWidget);
      expect(find.text('กรุงเทพมหานคร'), findsNothing);
    });
  });

  group('Time field', () {
    testWidgets('shows hour + minute controls (no scrolling wheel)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThaiBetaTimeField(
              hour: null,
              minute: 0,
              onHourChanged: (_) {},
              onMinuteChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('thai_beta_hour_menu')), findsOneWidget);
      expect(find.byKey(const Key('thai_beta_minute_menu')), findsOneWidget);
      expect(find.text('ชั่วโมง'), findsOneWidget);
      expect(find.text('นาที'), findsOneWidget);
    });

    testWidgets('opening the hour menu reveals the 00–23 range', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThaiBetaTimeField(
              hour: null,
              minute: 0,
              onHourChanged: (_) {},
              onMinuteChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('thai_beta_hour_menu')));
      await tester.pumpAndSettle();

      // The opened menu exposes selectable hour entries across the 24h range.
      expect(find.text('00'), findsWidgets);
      expect(find.text('23'), findsWidgets);
    });
  });
}
