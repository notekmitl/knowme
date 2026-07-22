/// Thai Beta Narrative V1.2 — Personal Relevance & Actionable Guidance.
///
/// Presentation-only helpers on top of V1.1.2 curated blocks. No new engine,
/// no generative AI, no Canon changes.
library;

import 'thai_beta_curated_narrative_block.dart';
import 'thai_beta_narrative_confidence.dart';
import 'thai_beta_narrative_domain.dart';
import 'thai_beta_narrative_formatting.dart';

/// Confidence band used for user-facing language (not a new scoring system).
enum ThaiBetaNarrativeConfidenceBand {
  high,
  medium,
  low,
}

abstract final class ThaiBetaNarrativeV12 {
  /// Max linked strength / caution cards shown in the prioritised report.
  static const int maxLinkedGuidanceCards = 3;

  static ThaiBetaNarrativeConfidenceBand bandFor({
    required bool hasBirthTime,
    required int matchLevel,
  }) {
    if (!hasBirthTime) return ThaiBetaNarrativeConfidenceBand.low;
    if (matchLevel <= 2) return ThaiBetaNarrativeConfidenceBand.high;
    if (matchLevel <= 4) return ThaiBetaNarrativeConfidenceBand.medium;
    return ThaiBetaNarrativeConfidenceBand.low;
  }

  static ThaiBetaNarrativeConfidenceBand bandFromQueryConfidence(
    double confidence,
  ) {
    if (confidence >= ThaiBetaNarrativeConfidence.withBirthTime) {
      return ThaiBetaNarrativeConfidenceBand.high;
    }
    if (confidence >= ThaiBetaNarrativeConfidence.withoutBirthTime) {
      return ThaiBetaNarrativeConfidenceBand.medium;
    }
    return ThaiBetaNarrativeConfidenceBand.low;
  }

  /// Personal Core eyebrow — overview before detail sections.
  static String personalCoreEyebrow(ThaiBetaNarrativeConfidenceBand band) {
    return switch (band) {
      ThaiBetaNarrativeConfidenceBand.high => 'แก่นที่เห็นชัดจากข้อมูลของคุณ',
      ThaiBetaNarrativeConfidenceBand.medium =>
        'แก่นที่พอเห็นได้จากข้อมูลที่มี',
      ThaiBetaNarrativeConfidenceBand.low =>
        'ภาพรวมเบื้องต้นจากข้อมูลที่มี (ยังไม่ครบ)',
    };
  }

  /// Confidence note shown as signature under the core paragraph.
  static String personalCoreSignature(ThaiBetaNarrativeConfidenceBand band) {
    return switch (band) {
      ThaiBetaNarrativeConfidenceBand.high =>
        'สรุปจากสิ่งที่เด่นและสอดคล้องกัน — ใช้สังเกตตัวเอง ไม่ใช่คำฟันธง',
      ThaiBetaNarrativeConfidenceBand.medium =>
        'ยังเป็นแนวโน้มจากข้อมูลที่มี — ยืนยันกับชีวิตจริงก่อนตัดสินใจใหญ่',
      ThaiBetaNarrativeConfidenceBand.low =>
        'ข้อมูลเวลายังไม่ครบ จึงจำกัดความเฉพาะเจาะจง และไม่สรุปแรงจูงใจลึก',
    };
  }

  /// Build Personal Core body from curated strength (+ optional tension context).
  ///
  /// Uses complete curated sentences only — never clause-glued labels.
  static String composePersonalCoreBody({
    required CuratedNarrativeBlock primaryStrength,
    CuratedNarrativeBlock? secondaryStrength,
    required ThaiBetaNarrativeConfidenceBand band,
    required bool hasBirthTime,
  }) {
    final parts = <String>[];
    final observable = _norm(primaryStrength.observableBehavior);
    final strength = _norm(primaryStrength.strengthText);
    if (observable.isNotEmpty) {
      parts.add(_confidenceLead(observable, band: band));
    } else if (strength.isNotEmpty) {
      parts.add(_confidenceLead(strength, band: band));
    }

    if (secondaryStrength != null) {
      final secondaryObs = _norm(secondaryStrength.observableBehavior);
      final secondaryStrengthText = _norm(secondaryStrength.strengthText);
      final secondary = secondaryObs.isNotEmpty
          ? secondaryObs
          : secondaryStrengthText;
      if (secondary.isNotEmpty &&
          ThaiBetaNarrativeFormatting.normalizedKey(secondary) !=
              ThaiBetaNarrativeFormatting.normalizedKey(parts.join())) {
        parts.add(
          'ในอีกบริบทหนึ่ง ${_stripLeadingYou(secondary)}',
        );
      }
    }

    final tension = _norm(primaryStrength.tensionText);
    if (tension.isNotEmpty && hasBirthTime) {
      parts.add(tension);
    } else if (tension.isNotEmpty && !hasBirthTime) {
      // Keep caution light when birth time is missing — no deep motive.
      parts.add(
        'ข้อที่ควรสังเกตควบคู่กันคือ ${_stripLeadingCaution(tension)}',
      );
    }

    if (parts.isEmpty) {
      return band == ThaiBetaNarrativeConfidenceBand.low
          ? 'ภาพรวมจากวันเกิดสะท้อนแนวโน้มบางด้านที่เด่นพอสังเกตได้ '
              '— ใช้เทียบกับชีวิตจริงของคุณ ไม่ใช่ข้อสรุปตายตัว'
          : 'จากข้อมูลที่มี มีลักษณะเด่นที่พอสรุปเป็นภาพรวมได้ '
              '— ใช้สังเกตตัวเอง ไม่ใช่คำฟันธง';
    }
    return parts.join('\n\n');
  }

  /// Section titles that make Strength → Risk → Action readable as a set.
  static const strengthsSectionTitle = 'จุดแข็งที่เด่นในตัวคุณ';
  static const cautionsSectionTitle = 'ข้อควรระวังเมื่อใช้จุดแข็งนี้';
  static const adviceSectionTitle = 'แนวทางสำคัญที่นำไปใช้ได้ก่อน';

  /// Whether [adviceText] conflicts with a core/strength framing.
  ///
  /// Conservative lexical guard only — curated catalog stays authoritative.
  static bool adviceConflictsWithCore({
    required String adviceText,
    required String coreBody,
  }) {
    final advice = ThaiBetaNarrativeFormatting.normalizedKey(adviceText);
    final core = ThaiBetaNarrativeFormatting.normalizedKey(coreBody);
    if (advice.isEmpty || core.isEmpty) return false;
    // Same paragraph reused as "advice" is not guidance — treat as conflict.
    if (advice == core) return true;
    const opposePairs = <(String, String)>[
      ('รีบ', 'ค่อย'),
      ('ลดการพัก', 'พัก'),
      ('ไม่ต้องคิด', 'คิดละเอียด'),
    ];
    for (final pair in opposePairs) {
      if (core.contains(pair.$1) && advice.contains(pair.$2) == false) {
        // only flag when advice pushes the opposite of a named risk in core
      }
      if (core.contains('ควรระวังคือ คุณอาจ${pair.$1}') &&
          advice.contains(pair.$1) &&
          !advice.contains('ระวัง') &&
          !advice.contains('เว้น') &&
          !advice.contains('พัก')) {
        return true;
      }
    }
    return false;
  }

  /// Prefer advice whose semantic tags intersect the strength block tags/traits.
  static bool adviceCompatibleWithStrength({
    required CuratedNarrativeBlock advice,
    required CuratedNarrativeBlock strength,
  }) {
    if (advice.domain != null &&
        strength.domain != null &&
        advice.domain != strength.domain) {
      return false;
    }
    final strengthTags = <String>{
      ...strength.primarySemanticTags,
      ...strength.secondarySemanticTags,
      ...strength.primaryTraitIds,
      ...strength.sourceSignalIds,
    };
    if (strengthTags.isEmpty) return true;
    final adviceTags = <String>{
      ...advice.primarySemanticTags,
      ...advice.secondarySemanticTags,
      ...advice.primaryTraitIds,
      ...advice.sourceSignalIds,
      if (advice.domain != null) advice.domain!.aspectKey,
    };
    if (adviceTags.isEmpty) return true;
    return adviceTags.any(strengthTags.contains);
  }

  static String _norm(String? value) =>
      ThaiBetaNarrativeFormatting.normalize(value ?? '');

  static String _confidenceLead(
    String text, {
    required ThaiBetaNarrativeConfidenceBand band,
  }) {
    final t = text.trim();
    if (t.isEmpty) return t;
    if (band == ThaiBetaNarrativeConfidenceBand.high) return t;
    if (band == ThaiBetaNarrativeConfidenceBand.medium) {
      if (_hasTendencyLanguage(t)) return t;
      return 'แนวโน้มที่เห็นได้คือ ${_stripLeadingYou(t)}';
    }
    if (_hasTendencyLanguage(t)) return t;
    return 'จากข้อมูลที่มี คุณอาจมีแนวโน้มว่า ${_stripLeadingYou(t)}';
  }

  static bool _hasTendencyLanguage(String text) {
    return text.contains('อาจ') ||
        text.contains('แนวโน้ม') ||
        text.contains('มัก') ||
        text.contains('เหมาะสำหรับใช้สังเกต');
  }

  static String _stripLeadingYou(String text) {
    var t = text.trim();
    for (final prefix in ['คุณมัก', 'คุณอาจ', 'คุณ']) {
      if (t.startsWith(prefix)) {
        t = t.substring(prefix.length).trimLeft();
        break;
      }
    }
    return t;
  }

  static String _stripLeadingCaution(String text) {
    var t = text.trim();
    const lead = 'จุดที่ควรระวังคือ ';
    if (t.startsWith(lead)) t = t.substring(lead.length);
    return t;
  }
}

/// One linked Strength → Risk → Action triad from the same curated strength block
/// plus a compatible advice block.
class ThaiBetaLinkedGuidance {
  const ThaiBetaLinkedGuidance({
    required this.themeId,
    required this.strengthBlock,
    required this.adviceBlock,
    required this.matchLevel,
    this.domain,
  });

  final String themeId;
  final CuratedNarrativeBlock strengthBlock;
  final CuratedNarrativeBlock adviceBlock;
  final int matchLevel;
  final ThaiBetaLifeDomain? domain;

  String get strengthTitle => _titleFromBlock(strengthBlock);
  String get strengthBody => ThaiBetaNarrativeFormatting.normalize(
        strengthBlock.observableBehavior ?? strengthBlock.strengthText ?? '',
      );
  String get strengthExpanded {
    final parts = <String>[
      if ((strengthBlock.observableBehavior ?? '').trim().isNotEmpty)
        ThaiBetaNarrativeFormatting.normalize(strengthBlock.observableBehavior!),
      if ((strengthBlock.strengthText ?? '').trim().isNotEmpty)
        ThaiBetaNarrativeFormatting.normalize(strengthBlock.strengthText!),
    ];
    return parts.join('\n\n');
  }

  String get riskBody => ThaiBetaNarrativeFormatting.normalize(
        strengthBlock.tensionText ?? '',
      );

  String get actionBody => ThaiBetaNarrativeFormatting.normalize(
        adviceBlock.adviceText ?? '',
      );

  static String _titleFromBlock(CuratedNarrativeBlock block) {
    if (block.primaryTraitIds.isNotEmpty) {
      return block.primaryTraitIds.first;
    }
    if (block.primarySemanticTags.isNotEmpty) {
      return block.primarySemanticTags.first;
    }
    return block.id;
  }
}
