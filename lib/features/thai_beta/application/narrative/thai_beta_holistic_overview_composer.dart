/// V1.3.4 — life overview for the single "ดวงไทยของคุณ" hero card.
///
/// Uses curated natal evidence + Life Map phase/affinity signals only.
/// No planet degrees, houses, or Swiss Ephemeris. Never pastes timeline cards.
library;

import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';

import 'thai_beta_narrative_formatting.dart';

abstract final class ThaiBetaHolisticOverviewComposer {
  static const _bannedOpeners = [
    'พื้นฐานจากดวงไทยคู่กับ',
    'จังหวะช่วง',
    'ที่เน้นการเรียนรู้',
    'ที่เน้นความสุขและความสัมพันธ์',
    'พลังชีวิตกำลังทำงาน',
    'ค่อย ๆ วางโครงให้ชีวิต',
  ];

  /// Merge curated natal copy with life-map evidence into one overview card.
  static ThaiMirrorConsumerHeroState compose({
    required ThaiMirrorConsumerHeroState natalHero,
    required ThaiMirrorSignatureInsightState core,
    required ThaiMirrorLifeTimelineState? timeline,
    required bool hasBirthTime,
  }) {
    final natalParas = _uniqueParas([
      ...natalHero.summary.split('\n\n'),
      ...core.body.split('\n\n'),
    ]).where((p) => !_isAbsorbedMeta(p) && !_isBannedPhrase(p)).toList();

    final stage = timeline?.currentStage;
    final planet = _planetFromStage(stage);
    final current = _currentPeriod(timeline);
    final analysis = timeline?.currentAnalysis;

    final foundation = _foundationSentence(natalParas, natalHero.headline);
    final strengthCaution = _strengthCaution(natalParas, foundation);
    final trajectory = _trajectorySentence(planet: planet, stage: stage);
    final currentFocus = _currentFocusSentence(
      planet: planet,
      stage: stage,
      analysis: analysis,
    );

    final parts = <String>[];
    void add(String? text) {
      final t = ThaiBetaNarrativeFormatting.normalize(text ?? '');
      if (t.isEmpty) return;
      if (_isBannedPhrase(t)) return;
      if (parts.any((p) => _overlap(p, t))) return;
      if (_looksLikeTimelineDump(t, current)) return;
      parts.add(t);
    }

    add(foundation);
    add(strengthCaution);
    add(trajectory);
    add(currentFocus);

    final capped = parts.length <= 4 ? parts : parts.take(4).toList();
    final headline = _headline(
      natalHeadline: natalHero.headline,
      planet: planet,
      stage: stage,
    );

    return ThaiMirrorConsumerHeroState(
      headline: headline,
      summary: capped.join('\n\n'),
      tags: natalHero.tags,
      identityBadge: natalHero.identityBadge,
      identitySubtitle: hasBirthTime
          ? natalHero.identitySubtitle
          : 'ไม่มีเวลาเกิด — วิเคราะห์ได้เฉพาะภาพรวมจากวันเกิด '
                'ไม่ใช่ภาพละเอียดเต็มรูปแบบ',
    );
  }

  static LifePlanetData? _planetFromStage(ThaiMirrorCurrentStageState? stage) {
    if (stage == null) return null;
    final keyword = stage.keyword.trim();
    final phase = stage.phaseName.trim();
    for (final data in LifePlanets.data.values) {
      if (data.keyword == keyword || data.phaseName == phase) return data;
    }
    return null;
  }

  static ThaiMirrorLifePeriodState? _currentPeriod(
    ThaiMirrorLifeTimelineState? timeline,
  ) {
    if (timeline == null) return null;
    for (final p in timeline.periods) {
      if (p.isCurrent) return p;
    }
    return null;
  }

  static String _headline({
    required String natalHeadline,
    required LifePlanetData? planet,
    required ThaiMirrorCurrentStageState? stage,
  }) {
    if (planet != null) {
      return ThaiBetaNarrativeFormatting.normalize(
        'ตอนนี้อยู่ใน${planet.phaseName} — ${planet.phaseEssence}',
      );
    }
    final natal = ThaiBetaNarrativeFormatting.normalize(natalHeadline);
    if (_isBannedPhrase(natal) || natal.startsWith('คุณเป็นคน')) {
      final phase = stage?.phaseName.trim() ?? '';
      if (phase.isNotEmpty) {
        return ThaiBetaNarrativeFormatting.normalize('ตอนนี้อยู่ใน$phase');
      }
    }
    return natal;
  }

  static String _foundationSentence(
    List<String> natalParas,
    String natalHeadline,
  ) {
    for (final p in natalParas) {
      if (p.length >= 24 && !_isBannedPhrase(p)) return p;
    }
    final h = ThaiBetaNarrativeFormatting.normalize(natalHeadline);
    if (h.isNotEmpty && !_isBannedPhrase(h) && !h.startsWith('คุณเป็นคน')) {
      return h;
    }
    return 'จากข้อมูลดวงไทยที่มี พื้นฐานตัวตนของคุณพออ่านเป็นแนวทางชีวิตได้ '
        'โดยยังต้องเทียบกับสถานการณ์จริง';
  }

  static String _strengthCaution(List<String> natalParas, String foundation) {
    for (final p in natalParas) {
      if (_overlap(foundation, p)) continue;
      if (p.length < 20) continue;
      if (_isBannedPhrase(p)) continue;
      return p;
    }
    return '';
  }

  static String _trajectorySentence({
    required LifePlanetData? planet,
    required ThaiMirrorCurrentStageState? stage,
  }) {
    if (planet != null) {
      return ThaiBetaNarrativeFormatting.normalize(
        'เส้นทางชีวิตเดินเป็นช่วงตามดาวเสวยอายุ '
        'จังหวะปัจจุบันเน้น${planet.keyword}และผลของสิ่งที่สะสมมา',
      );
    }
    final keyword = stage?.keyword.trim() ?? '';
    if (keyword.isEmpty) return '';
    return ThaiBetaNarrativeFormatting.normalize(
      'เส้นทางชีวิตเดินเป็นช่วงตามดาวเสวยอายุ '
      'และจังหวะปัจจุบันเกี่ยวข้องกับ$keyword',
    );
  }

  static String _currentFocusSentence({
    required LifePlanetData? planet,
    required ThaiMirrorCurrentStageState? stage,
    required ThaiMirrorCurrentAnalysisState? analysis,
  }) {
    final reason = analysis?.reasons.isNotEmpty == true
        ? analysis!.reasons.first.trim()
        : '';
    if (reason.isNotEmpty &&
        reason.length < 110 &&
        !_isBannedPhrase(reason) &&
        !reason.contains('ข้อมูลไม่เพียงพอ')) {
      var body = reason.replaceFirst(RegExp(r'^ช่วงนี้'), '').trimLeft();
      if (body.isNotEmpty) {
        return ThaiBetaNarrativeFormatting.normalize(
          'สิ่งที่ควรใส่ใจในช่วงนี้คือ$body',
        );
      }
    }
    if (planet != null) {
      final pressure = planet.affinity.pressure;
      if (pressure >= 70) {
        return ThaiBetaNarrativeFormatting.normalize(
          'ช่วงนี้มีแรงกดดันจากหน้าที่และความเปลี่ยนแปลงสูง '
          'ควรจัดลำดับสิ่งที่รับได้ก่อนเร่งขยาย',
        );
      }
      return ThaiBetaNarrativeFormatting.normalize(
        'ช่วงนี้เหมาะกับการใช้จุดแข็งที่มีอยู่ให้เป็นรูปธรรม '
        'มากกว่าการรอจังหวะจากภายนอกอย่างเดียว',
      );
    }
    return '';
  }

  static bool _isBannedPhrase(String text) {
    return _bannedOpeners.any(text.contains);
  }

  static bool _looksLikeTimelineDump(
    String candidate,
    ThaiMirrorLifePeriodState? current,
  ) {
    if (current == null) return false;
    final key = ThaiBetaNarrativeFormatting.normalizedKey(candidate);
    if (key.length < 24) return false;
    for (final field in [
      current.summary,
      current.harder,
      current.advice,
      current.whatChanges,
      current.comparison,
      ...current.lifeDomains.map((d) => d.body),
    ]) {
      final fk = ThaiBetaNarrativeFormatting.normalizedKey(field);
      if (fk.isEmpty) continue;
      if (key == fk) return true;
      if (fk.contains(key) && key.length >= (fk.length * 0.9)) return true;
    }
    return false;
  }

  static List<String> _uniqueParas(Iterable<String> raw) {
    final out = <String>[];
    for (final p in raw) {
      final t = ThaiBetaNarrativeFormatting.normalize(p);
      if (t.isEmpty) continue;
      if (out.any((e) => _overlap(e, t))) continue;
      out.add(t);
    }
    return out;
  }

  static bool _isAbsorbedMeta(String para) {
    const meta = [
      'ใช้สังเกตตัวเอง ไม่ใช่คำฟันธง',
      'ยังเป็นแนวโน้มจากข้อมูลที่มี',
      'ยืนยันกับชีวิตจริงก่อนตัดสินใจใหญ่',
      'ข้อมูลเวลายังไม่ครบ',
      'ไม่ใช่ข้อสรุปตายตัว',
    ];
    return meta.any(para.contains) && para.length < 80;
  }

  static bool _overlap(String a, String b) {
    final ka = ThaiBetaNarrativeFormatting.normalizedKey(a);
    final kb = ThaiBetaNarrativeFormatting.normalizedKey(b);
    if (ka.isEmpty || kb.isEmpty) return false;
    if (ka == kb) return true;
    if (ka.contains(kb) || kb.contains(ka)) {
      final shorter = ka.length < kb.length ? ka : kb;
      return shorter.length >= 18;
    }
    return false;
  }
}
