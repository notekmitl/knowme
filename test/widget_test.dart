import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:knowme/main.dart';
import 'package:knowme/presentation/providers/locale_provider.dart';

void main() {
  testWidgets('App loads test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const KnowMeApp(launchRouteName: '/beta/thai'),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
