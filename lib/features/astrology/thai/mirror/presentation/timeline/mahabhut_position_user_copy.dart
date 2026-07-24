import 'package:knowme/features/astrology/thai/content/models/content_status.dart';
import 'package:knowme/features/astrology/thai/content/registry/thai_content_registry.dart';
import 'package:knowme/features/astrology/thai/core/life_period/mahabhut_planet_position_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_life_period_rise_fall_metadata.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_ontology_runtime_mapping.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_mahabhut_khumsap_runtime_key.dart';

/// Presentation-only Mahabhut explanations for Life Map cards.
///
/// Derives 1–2 Thai sentences from approved content registry mappings and
/// (for Khumsap only) Canon ontology alias + p17 rise-set membership.
/// Never invents placement tables or mutates Frozen Canon.
abstract final class MahabhutPositionUserCopy {
  /// Returns user copy when evidence-backed explanation is available; else null.
  static String? explain(MahabhutPlanetPosition position) {
    if (!position.known) return null;
    final thai = position.thaiName?.trim();
    final canonId = position.canonId?.trim();
    if (thai == null || thai.isEmpty || canonId == null || canonId.isEmpty) {
      return null;
    }

    if (canonId == ThaiMahabhutKhumsapRuntimeKey.canonEntityId) {
      return _khumsapExplanation(thai);
    }

    final contentKey =
        ThaiCanonOntologyRuntimeMapping.contentKeyForMahabhutPosition(canonId);
    if (contentKey == null || contentKey.isEmpty) return null;

    final section = ThaiContentRegistry.resolve(contentKey);
    if (section == null) return null;
    if (section.contentStatus != ContentStatus.approved) return null;

    final summary = _replaceLegacyNames(section.summary, thai);
    final nature = _replaceLegacyNames(section.coreNature, thai);
    final summaryLead = _firstSentences(summary, 1);
    final natureLead = _firstSentences(nature, 1);
    if (summaryLead.isEmpty) return null;

    if (natureLead.isEmpty || natureLead == summaryLead) {
      return _clipToTwoSentences(
        '$summaryLead '
        'พลังตำแหน่งนี้จึงสะท้อนต่อบรรยากาศของช่วงชีวิตผ่านแนวโน้มภายใน '
        'มากกว่าการฟันธงเหตุการณ์ภายนอก',
      );
    }

    return _clipToTwoSentences('$summaryLead $natureLead');
  }

  /// True when every period is known and each has an explainable user copy.
  static bool reportReadyToShow(Iterable<MahabhutPlanetPosition> positions) {
    final list = positions.toList(growable: false);
    if (list.isEmpty) return false;
    for (final pos in list) {
      if (!pos.known) return false;
      final copy = explain(pos);
      if (copy == null || copy.trim().isEmpty) return false;
    }
    return true;
  }

  static String _khumsapExplanation(String thaiName) {
    // Evidence: Canon ontology alias + p17 rise-set (structural), not book prose.
    final isRise = ThaiLifePeriodRiseFallP17Rules.risePositionIds.contains(
      ThaiMahabhutKhumsapRuntimeKey.canonEntityId,
    );
    final atmosphere = isRise
        ? 'ตามกฎโครงสร้าง Canon จัดอยู่ในกลุ่มจังหวะเกื้อหนุน '
              'ทำให้บรรยากาศของช่วงชีวิตมักเอื้อต่อการเก็บฐานและเตรียมความพร้อม '
              'มากกว่าการพังทลาย'
        : 'สะท้อนบรรยากาศของช่วงชีวิตตามหลักฐานโครงสร้างตำแหน่งที่มีอยู่';
    return '$thaiNameเป็นตำแหน่งมหาภูตที่ยืนยันได้จาก Canon '
        'โดยชื่อชี้ถึงคลังหรือฐานที่สะสมไว้ $atmosphere';
  }

  static String _replaceLegacyNames(String source, String thaiName) {
    return source
        .replaceAll('พยาธิ', thaiName)
        .replaceAll('ราชิยะ', thaiName)
        .replaceAll('ทายะ', thaiName);
  }

  static String _firstSentences(String text, int count) {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return '';
    final parts = cleaned.split(RegExp(r'(?<=[.!?…])\s+'));
    final take = parts.take(count).join(' ').trim();
    return take;
  }

  static String _clipToTwoSentences(String text) {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final parts = cleaned.split(RegExp(r'(?<=[.!?…])\s+'));
    if (parts.length <= 2) return cleaned;
    return parts.take(2).join(' ').trim();
  }
}
