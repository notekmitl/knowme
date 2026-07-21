import 'fusion_contradiction_builder.dart';

/// Resolution layer — contradiction to wisdom — V5.
abstract final class FusionWisdomBuilder {
  static String? build(FusionContradiction? contradiction) {
    if (contradiction == null) return null;

    final resolution = _resolutionFor(contradiction);
    if (resolution == null) return null;

    return resolution;
  }

  static String? _resolutionFor(FusionContradiction contradiction) {
    final a = contradiction.poleA;
    final b = contradiction.poleB;

    if (_mentions(a, 'อิสระ') && _mentions(b, 'ความสัมพันธ์')) {
      return _bothSidesResolution(
        first: 'อิสระ',
        second: 'ความสัมพันธ์',
      );
    }

    if (_mentions(a, 'อิสระ') && _mentions(b, 'ความรู้สึก')) {
      return _bothSidesResolution(
        first: 'อิสระ',
        second: 'ความสัมพันธ์',
      );
    }

    if (_mentions(a, 'อิสระ') && _mentions(b, 'ไม่แน่นอน')) {
      return 'คุณต้องการทั้ง\n'
          'อิสระ\n'
          'และ\n'
          'ทิศทางที่ชัดเจน\n\n'
          'ความขัดแย้งนี้อาจไม่ได้มีไว้ให้เลือกด้านใดด้านหนึ่ง\n'
          'แต่อาจมีไว้เพื่อเรียนรู้ว่า\n'
          'อิสระที่แท้จริงมักมาพร้อมทิศทางที่คุณเลือกเอง';
    }

    if (_mentions(a, 'แสดงความคิด') || _mentions(a, 'แสดงตัวตน')) {
      return 'คุณต้องการทั้ง\n'
          'การแสดงตัวตนอย่างตรงไปตรงมา\n'
          'และ\n'
          'ความสัมพันธ์ที่ดี\n\n'
          'ความขัดแย้งนี้อาจไม่ได้มีไว้ให้เลือกด้านใดด้านหนึ่ง\n'
          'แต่อาจมีไว้เพื่อเรียนรู้วิธีรักษาทั้งสองด้านไว้พร้อมกัน';
    }

    if (_mentions(a, 'โครงสร้าง') || _mentions(a, 'ความชัดเจน')) {
      return 'คุณต้องการทั้ง\n'
          'ความมั่นคง\n'
          'และ\n'
          'พื้นที่ให้ตัวเองหายใจ\n\n'
          'ความขัดแย้งนี้อาจไม่ได้มีไว้ให้เลือกด้านใดด้านหนึ่ง\n'
          'แต่อาจมีไว้เพื่อเรียนรู้วิธีรักษาทั้งสองด้านไว้พร้อมกัน';
    }

    if (_mentions(a, 'ตัดสินใจ') && _mentions(b, 'ทบทวน')) {
      return 'คุณต้องการทั้ง\n'
          'ความกล้าในการตัดสินใจ\n'
          'และ\n'
          'เวลาในการทบทวน\n\n'
          'ความขัดแย้งนี้อาจไม่ได้มีไว้ให้เลือกด้านใดด้านหนึ่ง\n'
          'แต่อาจมีไว้เพื่อเรียนรู้ว่า\n'
          'การหยุดมองย้อนกลับอาจเป็นส่วนหนึ่งของการตัดสินใจที่มีน้ำหนัก';
    }

    return 'ความขัดแย้งนี้อาจไม่ได้มีไว้ให้เลือกด้านใดด้านหนึ่ง\n'
        'แต่อาจมีไว้เพื่อเรียนรู้วิธีรักษาทั้งสองด้านไว้พร้อมกัน';
  }

  static String _bothSidesResolution({
    required String first,
    required String second,
  }) {
    return 'คุณต้องการทั้ง\n'
        '$first\n'
        'และ\n'
        '$second\n\n'
        'ความขัดแย้งนี้อาจไม่ได้มีไว้ให้เลือกด้านใดด้านหนึ่ง\n'
        'แต่อาจมีไว้เพื่อเรียนรู้วิธีรักษาทั้งสองด้านไว้พร้อมกัน';
  }

  static bool _mentions(String text, String keyword) => text.contains(keyword);
}
