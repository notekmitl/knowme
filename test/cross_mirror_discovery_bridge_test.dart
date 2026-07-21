import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/presentation/widgets/cross_mirror_discovery_bridge.dart';

void main() {
  setUp(() {
    AppText.lang = 'th';
  });

  testWidgets('personality bridge shows exploration copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CrossMirrorDiscoveryBridge(
            target: CrossMirrorBridgeTarget.personalityMirror,
          ),
        ),
      ),
    );

    expect(
      find.text(AppText.t('cross_mirror_bridge_astrology_to_personality_body')),
      findsOneWidget,
    );
    expect(
      find.text(AppText.t('cross_mirror_bridge_astrology_to_personality_cta')),
      findsOneWidget,
    );
  });

  testWidgets('astrology bridge shows exploration copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CrossMirrorDiscoveryBridge(
            target: CrossMirrorBridgeTarget.astrologyFusion,
          ),
        ),
      ),
    );

    expect(
      find.text(AppText.t('cross_mirror_bridge_personality_to_astrology_body')),
      findsOneWidget,
    );
    expect(
      find.text(AppText.t('cross_mirror_bridge_personality_to_astrology_cta')),
      findsOneWidget,
    );
  });
}
