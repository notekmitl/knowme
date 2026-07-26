/// V1.3.3 — executive overview for the single "ดวงไทยของคุณ" hero card.
///
/// Synthesizes natal foundation + life trajectory + current focus/challenge
/// from approved evidence. Never copies Past/Current/Future card bodies
/// verbatim, and never invents unsupported life events.
library;

import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';

import 'thai_beta_narrative_formatting.dart';

abstract final class ThaiBetaHolisticOverviewComposer {
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
    ]).where((p) => !_isAbsorbedMeta(p)).toList();

    final foundation = natalParas.isEmpty ? '' : natalParas.first;
    final foundationExtra = natalParas.length > 1 ? natalParas[1] : '';

    final stage = timeline?.currentStage;
    final current = _currentPeriod(timeline);
    final analysis = timeline?.currentAnalysis;

    final trajectory = _trajectorySentence(stage: stage, analysis: analysis);
    final currentFocus = _currentFocusSentence(current: current, stage: stage);
    final challenge = _challengeSentence(current: current, analysis: analysis);

    final parts = <String>[];
    void add(String? text) {
      final t = ThaiBetaNarrativeFormatting.normalize(text ?? '');
      if (t.isEmpty) return;
      if (parts.any((p) => _overlap(p, t))) return;
      // Do not paste full timeline card bodies into the hero.
      if (_looksLikeTimelineDump(t, current)) return;
      parts.add(t);
    }

    add(foundation);
    add(trajectory);
    add(currentFocus);
    add(challenge);
    // One extra natal nuance only when life evidence is sparse.
    if (parts.length < 3) {
      add(foundationExtra);
    }

    // Soft cap: executive summary, not a concatenated report.
    final capped = parts.length <= 4 ? parts : parts.take(4).toList();

    final headline = _headline(
      natalHeadline: natalHero.headline,
      stage: stage,
      hasLifeEvidence: trajectory.isNotEmpty || currentFocus.isNotEmpty,
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
    required ThaiMirrorCurrentStageState? stage,
    required bool hasLifeEvidence,
  }) {
    final natal = ThaiBetaNarrativeFormatting.normalize(natalHeadline);
    if (!hasLifeEvidence || stage == null) {
      return natal;
    }
    final phase = stage.phaseName.trim();
    final keyword = stage.keyword.trim();
    if (phase.isEmpty && keyword.isEmpty) return natal;

    // Overview headline: identity + life rhythm — not personality-only.
    if (keyword.isNotEmpty && phase.isNotEmpty) {
      return ThaiBetaNarrativeFormatting.normalize(
        'พื้นฐานจากดวงไทยคู่กับจังหวะ$phaseที่เน้น$keyword',
      );
    }
    if (keyword.isNotEmpty) {
      return ThaiBetaNarrativeFormatting.normalize(
        'พื้นฐานจากดวงไทยและจังหวะชีวิตที่เน้น$keyword',
      );
    }
    return ThaiBetaNarrativeFormatting.normalize(
      'พื้นฐานจากดวงไทยและจังหวะ$phaseในชีวิตตอนนี้',
    );
  }

  static String _trajectorySentence({
    required ThaiMirrorCurrentStageState? stage,
    required ThaiMirrorCurrentAnalysisState? analysis,
  }) {
    if (stage == null) return '';
    final phase = stage.phaseName.trim();
    final keyword = stage.keyword.trim();
    final dominant = analysis?.dominantInfluences.trim() ?? '';

    if (dominant.isNotEmpty &&
        !dominant.contains('ข้อมูลไม่เพียงพอ') &&
        dominant.length < 120) {
      // Reframe analysis line as life-rhythm overview (not a card dump).
      return ThaiBetaNarrativeFormatting.normalize(
        'เส้นทางชีวิตเดินเป็นช่วงตามดาวเสวยอายุ — $dominant',
      );
    }
    if (phase.isNotEmpty && keyword.isNotEmpty) {
      return ThaiBetaNarrativeFormatting.normalize(
        'เส้นทางชีวิตเดินเป็นช่วงตามดาวเสวยอายุ '
        'และตอนนี้อยู่ใน$phaseที่เน้น$keyword',
      );
    }
    if (keyword.isNotEmpty) {
      return ThaiBetaNarrativeFormatting.normalize(
        'เส้นทางชีวิตเดินเป็นช่วงตามดาวเสวยอายุ '
        'และจังหวะปัจจุบันเน้น$keyword',
      );
    }
    return '';
  }

  static String _currentFocusSentence({
    required ThaiMirrorLifePeriodState? current,
    required ThaiMirrorCurrentStageState? stage,
  }) {
    final keyword = (stage?.keyword ?? current?.keyword ?? '').trim();
    final phase = (stage?.phaseName ?? current?.phaseName ?? '').trim();
    final planet = (stage?.planetLine ?? current?.planetLine ?? '').trim();

    // Overview-level synthesis from approved period labels — not card body paste.
    if (keyword.isNotEmpty && phase.isNotEmpty) {
      return ThaiBetaNarrativeFormatting.normalize(
        'ช่วงชีวิตตอนนี้อยู่ใน$phase '
        'และเรื่องสำคัญหมุนรอบ$keyword',
      );
    }
    if (keyword.isNotEmpty && planet.isNotEmpty) {
      return ThaiBetaNarrativeFormatting.normalize(
        'ช่วงชีวิตตอนนี้$planet '
        'ทำให้เรื่อง$keyword เด่นขึ้น',
      );
    }
    if (keyword.isNotEmpty) {
      return ThaiBetaNarrativeFormatting.normalize(
        'ช่วงชีวิตตอนนี้เรื่องสำคัญหมุนรอบ$keyword',
      );
    }
    return '';
  }

  static String _challengeSentence({
    required ThaiMirrorLifePeriodState? current,
    required ThaiMirrorCurrentAnalysisState? analysis,
  }) {
    // Prefer current-analysis reasons (distinct composer from period cards).
    final reason = analysis?.reasons.isNotEmpty == true
        ? analysis!.reasons.first.trim()
        : '';
    if (reason.isNotEmpty &&
        reason.length < 110 &&
        !reason.contains('ข้อมูลไม่เพียงพอ')) {
      var body = reason;
      // Avoid "ช่วงนี้คือช่วงนี้…" stutter from analysis copy.
      body = body.replaceFirst(RegExp(r'^ช่วงนี้'), '').trimLeft();
      if (body.isEmpty) return '';
      return ThaiBetaNarrativeFormatting.normalize(
        'จุดที่ควรใส่ใจในช่วงนี้คือ$body',
      );
    }

    // Fall back to a short pressure cue without pasting the full harder slot.
    final harder = _firstSentence(current?.harder ?? '');
    if (harder.isEmpty) return '';
    final reframed = _stripCurrentLead(harder).trim();
    if (reframed.isEmpty || reframed.length > 90) return '';
    return ThaiBetaNarrativeFormatting.normalize(
      'จุดท้าทายที่ควรดูแลคือ$reframed',
    );
  }

  static String _firstSentence(String text) {
    final t = text.trim();
    if (t.isEmpty) return '';
    final cut = t.split(RegExp(r'(?<=[.!?。])\s+|\n+'));
    return cut.first.trim();
  }

  static String _stripCurrentLead(String text) {
    var t = text.trim();
    for (final lead in ['ตอนนี้', 'ขณะนี้', 'ช่วงชีวิตตอนนี้']) {
      if (t.startsWith(lead)) {
        t = t.substring(lead.length).trimLeft();
      }
    }
    return t;
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
