import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_store.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_completion_page.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_landing_page.dart';
import 'package:knowme/features/astrology/fusion/presentation/trial_visual_design.dart';
import 'package:knowme/features/thai_beta/presentation/widgets/thai_beta_progress_bar.dart';

void main() {
  testWidgets('Landing screen sets expectations and shows the start CTA', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ThaiBetaLandingPage()));
    await tester.pump();

    // CTA lives in the bottom bar (always visible); the info tiles scroll.
    expect(find.text('เริ่มการวิเคราะห์'), findsOneWidget);
    expect(find.text('จุดประสงค์'), findsOneWidget);
    expect(find.text('ใช้เวลาโดยประมาณ'), findsOneWidget);
  });

  testWidgets('anonymous trial does not read research participants', (
    tester,
  ) async {
    final store = _TrackingStore();
    await tester.pumpWidget(
      MaterialApp(
        home: ThaiBetaLandingPage(store: store, anonymousTrial: true),
      ),
    );
    await tester.pump();

    expect(store.readCount, 0);
    expect(find.text('เริ่มดูดวงรวม'), findsOneWidget);
    expect(find.byType(TrialArtworkBanner), findsOneWidget);
    expect(find.text('สามศาสตร์ · พื้นดวงเดียว'), findsOneWidget);
    expect(find.text('การเข้าร่วมงานวิจัย'), findsNothing);
    expect(find.textContaining('โดยไม่บันทึกลงบัญชี'), findsOneWidget);
  });

  for (final size in [
    const Size(1920, 911),
    const Size(1280, 800),
    const Size(390, 844),
  ]) {
    testWidgets('trial landing has one reachable CTA at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(home: ThaiBetaLandingPage(anonymousTrial: true)),
      );
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(
        scaffold.bottomNavigationBar,
        size.width >= 800 ? isNull : isNotNull,
      );
      expect(find.text('เริ่มดูดวงรวม'), findsOneWidget);
      expect(find.byType(TrialArtworkBanner), findsOneWidget);
      expect(tester.takeException(), isNull);

      if (size.width >= 800) {
        final logoLeft = tester.getTopLeft(find.text('KnowMe')).dx;
        final imageLeft = tester.getTopLeft(find.byType(TrialArtworkBanner)).dx;
        expect((logoLeft - imageLeft).abs(), lessThan(3));
        expect(
          tester.getTopLeft(find.byType(FilledButton).first).dx,
          greaterThan(size.width / 2),
        );
        expect(
          tester.getBottomRight(find.byType(FilledButton).first).dy,
          lessThan(size.height),
        );
      }
    });
  }

  testWidgets('trial desktop landing scrolls on a short screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 450);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(home: ThaiBetaLandingPage(anonymousTrial: true)),
    );
    await tester.pump();
    final cta = find.text('เริ่มดูดวงรวม');
    expect(cta, findsOneWidget);
    await tester.ensureVisible(cta);
    await tester.pump();
    expect(tester.getBottomRight(cta).dy, lessThan(450));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Completion screen shows thanks + reference id + restart', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ThaiBetaCompletionPage(researchId: 'TH-00000042'),
      ),
    );
    await tester.pump();

    expect(find.text('ขอบคุณที่ร่วมงานวิจัย!'), findsOneWidget);
    expect(find.text('TH-00000042'), findsOneWidget);
    expect(find.text('เริ่มการวิเคราะห์ใหม่'), findsOneWidget);
  });

  testWidgets('Progress bar renders all four step labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ThaiBetaProgressBar(current: ThaiBetaStep.read)),
      ),
    );
    await tester.pump();

    expect(find.text('กรอกข้อมูล'), findsOneWidget);
    expect(find.text('ตรวจสอบข้อมูล'), findsOneWidget);
    expect(find.text('อ่านผล'), findsOneWidget);
    expect(find.text('ส่งความคิดเห็น'), findsOneWidget);
  });
}

class _TrackingStore extends ThaiBetaStore {
  int readCount = 0;

  @override
  Future<int?> participantCount() async {
    readCount++;
    return 0;
  }
}
