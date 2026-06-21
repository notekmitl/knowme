import 'package:knowme/features/exploration_overview/domain/discovery_item.dart';

import '../domain/home_screen_contract.dart';

/// Friendly Home MVP copy — exploration tone, no funnel wording.
abstract final class HomeMvpCopy {
  static String journeyHeadline(HomeUserStateMode mode) {
    return switch (mode) {
      HomeUserStateMode.emptyUser => 'เริ่มสำรวจตัวเอง',
      HomeUserStateMode.partialUser => 'เส้นทางของคุณกำลังค่อย ๆ ชัดขึ้น',
      HomeUserStateMode.advancedUser => 'ภาพรวมการสำรวจของคุณ',
    };
  }

  static String journeyBody(HomeUserStateMode mode) {
    return switch (mode) {
      HomeUserStateMode.emptyUser =>
        'คุณสามารถเริ่มจากมุมที่สนใจได้ตามใจ — ไม่จำเป็นต้องทำทุกอย่างในครั้งเดียว',
      HomeUserStateMode.partialUser =>
        'บางมุมเริ่มสะท้อนชัดขึ้นแล้ว และยังมีพื้นที่ให้สำรวจต่อได้อย่างอิสระ',
      HomeUserStateMode.advancedUser =>
        'หลายมุมของคุณพร้อมให้มองและสะท้อนในแบบของคุณเอง',
    };
  }

  static String journeyHint(HomeUserStateMode mode) {
    return switch (mode) {
      HomeUserStateMode.emptyUser =>
        'เลือกมุมที่อยากรู้จักก่อนได้ตามใจ',
      HomeUserStateMode.partialUser =>
        'คุณอาจอยากกลับมาดูมุมที่เปิดอยู่เมื่อพร้อม',
      HomeUserStateMode.advancedUser =>
        'ภาพรวมนี้สะท้อนสิ่งที่คุณมีอยู่แล้ว',
    };
  }

  static String reflectionsEmptyHint() {
    return 'เมื่อมีมิเรอร์พร้อม มุมสะท้อนจะปรากฏที่นี่';
  }

  static String exploreEmptyHint() {
    return 'เมื่อมีมุมที่เปิดสำรวจได้ รายการจะปรากฏที่นี่';
  }

  static String availabilityLabel(DiscoveryAvailability availability) {
    return switch (availability) {
      DiscoveryAvailability.locked => 'ยังไม่เปิด',
      DiscoveryAvailability.available => 'เปิดสำรวจ',
      DiscoveryAvailability.completed => 'สำรวจแล้ว',
    };
  }

  static String surfaceStateLabel(HomeSectionSurfaceState state) {
    return switch (state) {
      HomeSectionSurfaceState.hidden => '',
      HomeSectionSurfaceState.empty => 'กำลังเริ่ม',
      HomeSectionSurfaceState.partial => 'บางส่วน',
      HomeSectionSurfaceState.ready => 'พร้อม',
    };
  }
}
