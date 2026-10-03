import '../adapters/lens_theme_output.dart';
import '../application/three_tradition_consensus.dart';

enum ThirdMeaningRelation { same, near, conflict, unrelated, missing }

class ThreeTraditionAlignedMeaning {
  const ThreeTraditionAlignedMeaning({
    required this.title,
    required this.reading,
    required this.sources,
    required this.relation,
  });

  final String title;
  final String reading;
  final Map<String, LensThemeOutput> sources;
  final ThirdMeaningRelation relation;
}

/// Makes a public life-area reading only from registered, adequately supported
/// observations. The near and conflict pairs below are deliberately narrow:
/// a common signal family alone cannot turn a third lens into agreement.
abstract final class ThreeTraditionMeaningAlignment {
  static const _near = {
    'independent': {'leadership'},
    'leadership': {'independent'},
  };

  // Expression and privacy may coexist in a person, but they do not support
  // one unqualified prediction about how that person discloses feelings.
  static const _conflict = {
    'expressive': {'reserved'},
    'reserved': {'expressive'},
  };

  static ThirdMeaningRelation relation(String anchor, String? third) {
    if (third == null || third.isEmpty) return ThirdMeaningRelation.missing;
    if (anchor == third) return ThirdMeaningRelation.same;
    if (_conflict[anchor]?.contains(third) ?? false) {
      return ThirdMeaningRelation.conflict;
    }
    if (_near[anchor]?.contains(third) ?? false) {
      return ThirdMeaningRelation.near;
    }
    return ThirdMeaningRelation.unrelated;
  }

  static ThreeTraditionAlignedMeaning? select(ThreeTraditionReading reading) {
    for (final anchor in ['independent', 'expressive']) {
      final matching = <String, LensThemeOutput>{};
      for (final lens in ThreeTraditionConsensus.lensOrder) {
        final found = _supported(reading.byLens[lens], anchor);
        if (found != null) matching[lens] = found;
      }
      if (matching.length < 2) continue;

      // An opposed, adequately supported observation in any lens makes an
      // unqualified synthesis unsafe, even when another observation in that
      // same lens matches the anchor.
      if (ThreeTraditionConsensus.lensOrder.any((lens) =>
          (reading.byLens[lens] ?? const <LensThemeOutput>[])
              .where(_hasEvidenceAtAgreementThreshold)
              .any((item) =>
                  relation(anchor, item.themeId) ==
                  ThirdMeaningRelation.conflict))) {
        continue;
      }

      if (matching.length == 3) {
        return _result(anchor, ThirdMeaningRelation.same, matching);
      }
      final thirdLens = ThreeTraditionConsensus.lensOrder.singleWhere(
        (lens) => !matching.containsKey(lens),
      );
      final third = (reading.byLens[thirdLens] ?? const <LensThemeOutput>[])
          .where(_hasEvidenceAtAgreementThreshold)
          .toList();
      if (third.any(
        (item) =>
            relation(anchor, item.themeId) == ThirdMeaningRelation.conflict,
      )) {
        continue;
      }
      LensThemeOutput? near;
      for (final item in third) {
        if (relation(anchor, item.themeId) == ThirdMeaningRelation.near) {
          near = item;
          break;
        }
      }
      if (near == null) continue;
      matching[thirdLens] = near;
      return _result(anchor, ThirdMeaningRelation.near, matching);
    }
    return null;
  }

  static LensThemeOutput? _supported(
    List<LensThemeOutput>? observations,
    String theme,
  ) {
    for (final item in observations ?? const <LensThemeOutput>[]) {
      if (item.themeId == theme && _hasEvidenceAtAgreementThreshold(item)) {
        return item;
      }
    }
    return null;
  }

  static bool _hasEvidenceAtAgreementThreshold(LensThemeOutput item) =>
      item.confidence >= ThreeTraditionConsensus.minimumAgreementConfidence &&
      item.evidence.any((fact) => fact.trim().isNotEmpty);

  static ThreeTraditionAlignedMeaning _result(
    String anchor,
    ThirdMeaningRelation relation,
    Map<String, LensThemeOutput> sources,
  ) {
    if (anchor == 'independent') {
      return ThreeTraditionAlignedMeaning(
        title: 'ทิศทางและการตัดสินใจ',
        reading: relation == ThirdMeaningRelation.near
            ? 'การตัดสินใจมีแนวโน้มชัดขึ้นเมื่อคุณกำหนดทางที่อยากเดินเอง '
                  'แล้วจัดบทบาทและขอบเขตความรับผิดชอบให้คนที่เกี่ยวข้องตามทัน '
                  'สองศาสตร์ให้หลักฐานเรื่องการเลือกทางด้วยตนเอง '
                  'อีกศาสตร์ให้มุมการกำหนดทิศทางที่ใกล้เคียงกัน '
                  'นี่เป็นการอ่านประกอบกัน ไม่ใช่คำยืนยันว่าทั้งสามศาสตร์กล่าวตรงกันทุกประการ'
            : 'การตัดสินใจมีแนวโน้มชัดขึ้นเมื่อคุณมีพื้นที่เลือกทางสำคัญด้วยตนเอง '
                  'และรับผิดชอบผลของทางที่เลือก หลักฐานทั้งสามศาสตร์รองรับ'
                  'มุมการกำหนดทิศทางด้วยตนเอง โดยไม่ได้ระบุเหตุการณ์หรือช่วงเวลา',
        sources: Map.unmodifiable(sources),
        relation: relation,
      );
    }
    return ThreeTraditionAlignedMeaning(
      title: 'การสื่อสารและการแสดงออก',
      reading:
          'การสื่อสารเรื่องสำคัญมีแนวโน้มชัดขึ้นเมื่อคุณบอกความคิดหรือ'
          'ความรู้สึกให้คนฟังเข้าใจตรงกัน และเปิดพื้นที่ฟังคำตอบกลับ '
          'หลักฐานทั้งสามศาสตร์รองรับมุมการแสดงออกนี้ '
          'แต่ไม่ได้ระบุเหตุการณ์หรือช่วงเวลา',
      sources: Map.unmodifiable(sources),
      relation: relation,
    );
  }
}
