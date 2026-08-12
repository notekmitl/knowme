import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

import 'life_map_plain_thai_renderer.dart';
import 'life_map_verdict_semantics.dart';
import 'period_composite_score.dart';
import 'thai_life_stage_context.dart';

/// V1.3.4 — Past life-story synthesis from structured beats + period scores.
///
/// Produces 3–4 concrete sentences. No invented life events.
abstract final class PastLifeStoryComposer {
  static String compose({
    required LifeMapVerdictSemantics semantics,
    required LifePlanetData data,
    required PeriodScores scores,
    required ThaiLifeStageBand band,
    required int periodIndex,
    required int seed,
  }) {
    final byRole = <String, String>{};
    for (final b in semantics.beats) {
      final t = LifeMapPlainThaiRenderer.stripPastSoftOpenerPublic(
        b.textTh.trim(),
      );
      if (t.isEmpty) continue;
      if (LifeMapPlainThaiRenderer.hasVagueRelationshipForm(t)) continue;
      byRole.putIfAbsent(b.role, () => t);
    }

    final theme = _themeSentence(data, scores, band, periodIndex, seed);
    final change = byRole['change'] ?? byRole['context'] ?? data.phaseEssence;
    final pressure =
        byRole['pressure'] ?? byRole['support'] ?? _pressureFallback(scores);
    final carry = byRole['lingering'] ?? byRole['response'] ?? '';

    final parts = <String>[];
    void add(String? raw) {
      var t = (raw ?? '').trim();
      if (t.isEmpty) return;
      t = LifeMapPlainThaiRenderer.stripPastSoftOpenerPublic(t);
      if (t.isEmpty) return;
      if (LifeMapVerdictCopy.violatesPrimaryBody(t)) return;
      if (LifeMapPlainThaiRenderer.hasVagueRelationshipForm(t)) return;
      if (_hasUnsupportedEvent(t)) return;
      if (parts.any((p) => LifeMapPlainThaiRenderer.sameMeaningPublic(p, t))) {
        return;
      }
      parts.add(t);
    }

    add(theme);
    add(_concreteChange(change, band));
    add(_concretePressure(pressure, scores, band));
    if (carry.isNotEmpty && parts.length < 4) {
      add(_concreteCarry(carry));
    }
    if (parts.length < 3) {
      add(_ageBandLine(band));
    }
    if (parts.length > 4) {
      return parts.take(4).join(' ');
    }
    if (parts.length == 3) {
      return '${parts[0]} ${parts[1]}\n\n${parts[2]}';
    }
    if (parts.length == 4) {
      return '${parts[0]} ${parts[1]}\n\n${parts[2]} ${parts[3]}';
    }
    return parts.join(' ');
  }

  static String _themeSentence(
    LifePlanetData data,
    PeriodScores scores,
    ThaiLifeStageBand band,
    int periodIndex,
    int seed,
  ) {
    final top = scores.topDomain;
    final focus = switch (top) {
      'career' =>
        ThaiLifeStageContext.isChildOriented(band)
            ? 'การเรียนและหน้าที่ที่ถูกคาดหวัง'
            : 'งานและหน้าที่',
      'money' => 'การสร้างความมั่นคง',
      'love' =>
        ThaiLifeStageContext.isChildOriented(band)
            ? 'ความสัมพันธ์ในบ้าน'
            : 'ความใกล้ชิดกับคนรอบตัว',
      'health' => 'พลังชีวิตและการพักผ่อน',
      'growth' => 'การเรียนรู้และการเติบโต',
      'opportunity' => 'ทางเลือกและโอกาสที่เปิดขึ้น',
      _ => data.keyword,
    };
    // Avoid meta label "ธีมหลัก" — Past UX treats it as system copy (v126).
    final openers = <String>[
      'ช่วงนี้ชีวิตต้องรับมือเรื่อง$focusภายใต้อิทธิพล${data.thaiName}',
      'ช่วงนี้หมุนรอบเรื่อง$focus ตามจังหวะ${data.phaseName}ที่ผลักให้ต้องปรับตัว',
      'ใน${data.phaseName} เรื่อง$focusเปลี่ยนชัดขึ้นและมีผลต่อชีวิตประจำวัน',
    ];
    return openers[(seed + periodIndex * 3).abs() % openers.length];
  }

  static String _concreteChange(String change, ThaiLifeStageBand band) {
    final t = change.trim();
    if (t.isEmpty) {
      return ThaiLifeStageContext.isChildOriented(band)
          ? 'สภาพแวดล้อมและการคาดหวังรอบตัวผลักให้ต้องปรับตัว'
          : 'ภาระ หน้าที่ และความรับผิดชอบมีแนวโน้มเพิ่มขึ้นตามจังหวะช่วง';
    }
    return t;
  }

  static String _concretePressure(
    String pressure,
    PeriodScores scores,
    ThaiLifeStageBand band,
  ) {
    final t = pressure.trim();
    if (t.isNotEmpty) return t;
    if (scores.pressure >= 65) {
      return ThaiLifeStageContext.isChildOriented(band)
          ? 'มีแรงกดดันจากความคาดหวังและการปรับตัวกับสภาพแวดล้อม'
          : 'ต้องรับมือกับภาระหลายด้านพร้อมกันจนต้องเลือกสิ่งสำคัญก่อน';
    }
    return 'ต้องปรับตัวเมื่อทางเลือกหรือหน้าที่ไม่ตรงกับที่คุ้นเคย';
  }

  static String _pressureFallback(PeriodScores scores) {
    if (scores.pressure >= 70) {
      return 'แรงกดดันจากหน้าที่และความรับผิดชอบสูงขึ้น';
    }
    return '';
  }

  static String _concreteCarry(String carry) {
    final t = carry.trim();
    if (t.isEmpty) return '';
    if (t.contains('ต่อมา') || t.contains('ส่ง')) return t;
    return '$t และบทเรียนนี้ยังติดตัวไปในช่วงถัดไป';
  }

  static String _ageBandLine(ThaiLifeStageBand band) {
    return switch (band) {
      ThaiLifeStageBand.earlyChildhood || ThaiLifeStageBand.schoolAge =>
        'วัยนี้การเรียนรู้และคนดูแลใกล้ตัวมีอิทธิพลต่อการเลือกทาง',
      ThaiLifeStageBand.teen =>
        'วัยนี้การหาที่ยืนและทางของตัวเองเริ่มชัดขึ้นท่ามกลางความคาดหวัง',
      ThaiLifeStageBand.youngAdult =>
        'วัยนี้มีหลายทางเลือกเรื่องงานและการตั้งหลักที่ต้องตัดสินใจ',
      ThaiLifeStageBand.workingAdult || ThaiLifeStageBand.midlife =>
        'วัยนี้ภาระหน้าที่และความมั่นคงเข้ามามีน้ำหนักต่อการตัดสินใจ',
      ThaiLifeStageBand.elder =>
        'วัยนี้จังหวะชีวิตโน้มไปที่การรักษาสมดุลและสิ่งที่สะสมมา',
    };
  }

  static bool _hasUnsupportedEvent(String text) {
    const banned = [
      'แต่งงาน',
      'เลิกรา',
      'ย้ายบ้าน',
      'สูญเสีย',
      'ล้มละลาย',
      'ได้งานใหม่',
      'พ่อแม่แยก',
      'มือที่สาม',
    ];
    return banned.any(text.contains);
  }
}
