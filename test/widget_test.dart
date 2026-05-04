import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:knowme/main.dart';

void main() {
  testWidgets('App loads test', (WidgetTester tester) async {
    await tester.pumpWidget(const KnowMeApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
