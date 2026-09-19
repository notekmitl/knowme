import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/web/web_launch_router.dart';
import 'package:knowme/features/bazi_compatibility/presentation/bazi_compatibility_owner_page.dart';
import 'package:knowme/features/bazi_compatibility/presentation/bazi_compatibility_routes.dart';

void main() {
  test('owner route resolves supported case query without auth or writes', () {
    final widget = WebLaunchRouter.resolveLaunchWidget(
      '/beta/chinese?case=lichun-unknown',
    );

    expect(widget, isA<BaziCompatibilityOwnerPage>());
    expect(BaziCompatibilityRoutes.isOwnerPath('/beta/chinese'), isTrue);
  });

  testWidgets('Li Chun Unknown fixture does not leak Year/Month values', (
    tester,
  ) async {
    final widget = WebLaunchRouter.resolveLaunchWidget(
      '/beta/chinese?case=lichun-unknown',
    );
    await tester.pumpWidget(MaterialApp(home: widget));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bazi-owner-fixture-banner')), findsOneWidget);
    expect(find.textContaining('ไม่แสดงเสาปี'), findsOneWidget);
    expect(find.textContaining('ไม่แสดงเสาเดือน'), findsOneWidget);
    expect(find.textContaining('ไม่แสดงเสาชั่วโมง'), findsWidgets);
    expect(find.textContaining('己巳'), findsNothing);
    expect(find.textContaining('戊寅'), findsNothing);
  });

  testWidgets("known owner route renders Reader V4 life timeline", (
    tester,
  ) async {
    final widget = WebLaunchRouter.resolveLaunchWidget(
      "/beta/chinese?case=known",
    );
    await tester.pumpWidget(MaterialApp(home: widget));
    await tester.pumpAndSettle();
    expect(
      find.text("โหราศาสตร์จีน · BaZi Reader V3 · Owner Testing"),
      findsOneWidget,
    );
    expect(find.text("คำทำนายดวงจีน · ปาจื้อ (BaZi)"), findsOneWidget);
    expect(find.text("เส้นทางที่ผ่านมา · ดวงจรสิบปี"), findsOneWidget);
    expect(find.text("แนวโน้ม 5 ปีข้างหน้า"), findsOneWidget);
    expect(find.text("ภาพระยะยาว · สองดวงจรถัดไป"), findsOneWidget);
    expect(find.textContaining("BaZi V1"), findsNothing);
    expect(
      find.textContaining("คำอ่านนี้ใช้สี่เสาครบ รวมเสาชั่วโมง"),
      findsNothing,
    );
    expect(find.text("ข้อมูลดวงที่ใช้ประกอบคำอ่าน"), findsNothing);
    expect(find.text("กติกาและข้อมูลสำหรับตรวจซ้ำ"), findsNothing);
    expect(find.text("ที่มาของผลคำนวณและคำอ่าน"), findsNothing);
    expect(find.text("ข้อจำกัดและคำเตือน"), findsNothing);
  });
}
