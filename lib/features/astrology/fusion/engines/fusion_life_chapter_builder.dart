import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_signal.dart';
import 'fusion_meaning_signal_helpers.dart';

/// Life chapter framing from fusion themes — V6.
class FusionLifeChapter {
  const FusionLifeChapter({
    required this.chapterTitle,
    required this.chapterNarrative,
  });

  final String chapterTitle;
  final String chapterNarrative;

  String get formattedBody => '$chapterTitle\n\n$chapterNarrative';
}

abstract final class FusionLifeChapterBuilder {
  static FusionLifeChapter? build(
    AstrologyFusionResult result, {
    required String centralThemeLabel,
    required int alignedLensCount,
  }) {
    if (result.signals.isEmpty && result.topThemes.isEmpty) return null;

    final profile = _resolveProfile(result);
    final chapter = _chapters[profile];
    if (chapter != null) return chapter;

    return FusionLifeChapter(
      chapterTitle: 'บทแห่ง$centralThemeLabel',
      chapterNarrative:
          'ช่วงนี้ของชีวิตอาจกำลังชวนให้คุณเรียนรู้ว่า\n\n'
          '$centralThemeLabel\n'
          'เป็นทิศทางที่หลายศาสตร์สะท้อนตรงกัน\n\n'
          'หลายศาสตร์สะท้อนว่า\n'
          'นี่คือบทเรียนสำคัญของช่วงชีวิตนี้',
    );
  }

  static String _resolveProfile(AstrologyFusionResult result) {
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.autonomy) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'independent') ||
        FusionMeaningSignalHelpers.hasTheme(result, 'driven')) {
      return 'autonomy';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.expression) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'expressive')) {
      return 'expression';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.reflection) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'analytical') ||
        FusionMeaningSignalHelpers.hasTheme(result, 'intuitive')) {
      return 'reflection';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.connection) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'supportive')) {
      return 'connection';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.growth) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'growth_focused')) {
      return 'growth';
    }
    return 'default';
  }

  static const Map<String, FusionLifeChapter> _chapters = {
    'autonomy': FusionLifeChapter(
      chapterTitle: 'เจ้าของเส้นทางของตัวเอง',
      chapterNarrative:
          'ช่วงนี้ของชีวิตอาจกำลังชวนให้คุณเรียนรู้ว่า\n\n'
          'การตัดสินใจด้วยตัวเอง\n'
          'ไม่ได้หมายความว่าต้องรู้ทุกคำตอบ\n\n'
          'แต่หมายถึงการกล้ายอมรับ\n'
          'ผลลัพธ์ของสิ่งที่เลือก\n\n'
          'หลายศาสตร์สะท้อนว่า\n'
          'นี่คือบทเรียนสำคัญของช่วงชีวิตนี้',
    ),
    'expression': FusionLifeChapter(
      chapterTitle: 'บทแห่งการเป็นตัวของตัวเอง',
      chapterNarrative:
          'ช่วงนี้ของชีวิตอาจกำลังชวนให้คุณเรียนรู้ว่า\n\n'
          'การพูดความจริง\n'
          'ไม่ได้หมายความว่าต้องทำลายความสัมพันธ์\n\n'
          'แต่หมายถึงการกล้าแสดงตัวตน\n'
          'อย่างตรงไปตรงมาและอ่อนโยน\n\n'
          'หลายศาสตร์สะท้อนว่า\n'
          'นี่คือบทเรียนสำคัญของช่วงชีวิตนี้',
    ),
    'reflection': FusionLifeChapter(
      chapterTitle: 'บทแห่งการมองภายใน',
      chapterNarrative:
          'ช่วงนี้ของชีวิตอาจกำลังชวนให้คุณเรียนรู้ว่า\n\n'
          'ความชัดเจน\n'
          'มักเกิดขึ้นหลังการหยุดทบทวน\n'
          'ไม่ใช่การรีบตัดสินใจ\n\n'
          'หลายศาสตร์สะท้อนว่า\n'
          'นี่คือบทเรียนสำคัญของช่วงชีวิตนี้',
    ),
    'connection': FusionLifeChapter(
      chapterTitle: 'บทแห่งความสัมพันธ์และตัวตน',
      chapterNarrative:
          'ช่วงนี้ของชีวิตอาจกำลังชวนให้คุณเรียนรู้ว่า\n\n'
          'การรักษาความผูกพัน\n'
          'ไม่จำเป็นต้องแลกกับการทิ้งตัวเอง\n\n'
          'หลายศาสตร์สะท้อนว่า\n'
          'นี่คือบทเรียนสำคัญของช่วงชีวิตนี้',
    ),
    'growth': FusionLifeChapter(
      chapterTitle: 'บทแห่งการเติบโต',
      chapterNarrative:
          'ช่วงนี้ของชีวิตอาจกำลังชวนให้คุณเรียนรู้ว่า\n\n'
          'การเติบโต\n'
          'มักเริ่มจากความไม่สมบูรณ์แบบ\n'
          'มากกว่าความพร้อมที่รอมานาน\n\n'
          'หลายศาสตร์สะท้อนว่า\n'
          'นี่คือบทเรียนสำคัญของช่วงชีวิตนี้',
    ),
  };
}
