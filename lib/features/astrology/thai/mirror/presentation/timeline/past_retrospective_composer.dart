import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

import 'life_map_verdict_copy.dart';
import 'period_composite_score.dart';
import 'thai_life_stage_context.dart';

/// Presentation-only past Life Map narrative — life facets from existing
/// planet affinity, period scores, keyword, and phase essence only.
///
/// Does not invent Canon meanings or hardcode one event to one planet.
abstract final class PastRetrospectiveComposer {
  static String compose({
    required ThaiLifeStageBand band,
    required LifePlanetData data,
    required PeriodScores scores,
    required int seed,
    required int periodIndex,
  }) {
    final s = seed.abs() + periodIndex * 17;
    final facets = _selectFacets(
      band: band,
      data: data,
      scores: scores,
      seed: s,
    );
    final opening = _pick(_openingLines(band, data, facets), s);
    final middle = _pick(_experienceLines(band, data, facets), s ~/ 5);
    final closing = _pick(_innerEffectLines(band, data, facets), s ~/ 11);
    return _fitWordBudget(
      '$opening\n\n$middle\n\n$closing',
      band,
      data,
      facets,
      s,
    );
  }

  /// Approx Thai word mass from lightly-spaced copy.
  static int approxWordCount(String text) {
    final chars = text.replaceAll(RegExp(r'\s+'), '').runes.length;
    if (chars == 0) return 0;
    return (chars / 2.5).round();
  }

  static bool containsRetrospectivePrompt(String text) =>
      LifeMapVerdictCopy.containsBannedCoaching(text);

  static List<_PastFacet> _selectFacets({
    required ThaiLifeStageBand band,
    required LifePlanetData data,
    required PeriodScores scores,
    required int seed,
  }) {
    final ranked = <(_PastFacet, int)>[];

    void add(LifeDomain domain, int weight) {
      final narrative = ThaiLifeStageContext.narrativeDomain(domain.name, band);
      final facet = _facetForDomain(narrative, band, data);
      if (facet == null) return;
      ranked.add((facet, weight));
    }

    // Structured evidence: planet affinity ranking.
    final affinityOrder = data.affinity.supportRanked;
    for (var i = 0; i < affinityOrder.length; i++) {
      add(affinityOrder[i], 100 - i * 8);
    }
    // Period composite top/weak domains.
    add(_domainFromKey(scores.topDomain), 90);
    add(_domainFromKey(scores.weakestDomain), 70);
    // Pressure is evidence of constraint / friction when high.
    if (data.affinity.pressure >= 65) {
      final pressureFacet = _pressureFacet(band);
      ranked.add((pressureFacet, data.affinity.pressure));
    }
    // Keyword / essence cues already stored on LifePlanetData.
    for (final facet in _facetsFromKeywordAndEssence(band, data)) {
      ranked.add((facet, 88));
    }

    final byFacet = <_PastFacet, int>{};
    for (final (facet, weight) in ranked) {
      byFacet[facet] = (byFacet[facet] ?? 0) + weight;
    }
    final ordered = byFacet.entries.toList()
      ..sort((a, b) {
        final c = b.value.compareTo(a.value);
        if (c != 0) return c;
        return a.key.index.compareTo(b.key.index);
      });

    final picked = <_PastFacet>[];
    for (final e in ordered) {
      if (picked.contains(e.key)) continue;
      if (!_allowedForBand(e.key, band)) continue;
      picked.add(e.key);
      if (picked.length == 3) break;
    }
    if (picked.isEmpty) {
      picked.add(_defaultFacet(band));
    }
    // Deterministic rotation so neighbouring periods differ when ties exist.
    if (picked.length > 1 && seed.isOdd) {
      final first = picked.removeAt(0);
      picked.add(first);
    }
    return picked;
  }

  static LifeDomain _domainFromKey(String key) => switch (key) {
    'career' => LifeDomain.career,
    'money' => LifeDomain.money,
    'love' => LifeDomain.love,
    'health' => LifeDomain.health,
    'growth' => LifeDomain.growth,
    'opportunity' => LifeDomain.opportunity,
    _ => LifeDomain.growth,
  };

  static _PastFacet? _facetForDomain(
    String narrativeDomain,
    ThaiLifeStageBand band,
    LifePlanetData data,
  ) {
    switch (narrativeDomain) {
      case 'career':
        return ThaiLifeStageContext.allowsAdultCareerMoneyRomance(band)
            ? _PastFacet.workPath
            : _PastFacet.dutyAndAdaptation;
      case 'money':
        return ThaiLifeStageContext.allowsAdultCareerMoneyRomance(band)
            ? _PastFacet.moneySecurity
            : _PastFacet.homeFamily;
      case 'love':
        if (band == ThaiLifeStageBand.earlyChildhood ||
            band == ThaiLifeStageBand.schoolAge) {
          return _PastFacet.homeFamily;
        }
        if (band == ThaiLifeStageBand.teen) {
          return _PastFacet.peersBelonging;
        }
        return _PastFacet.lovePartner;
      case 'health':
        return _PastFacet.healthEnergy;
      case 'growth':
        if (band == ThaiLifeStageBand.earlyChildhood) {
          return _PastFacet.homeFamily;
        }
        if (band == ThaiLifeStageBand.schoolAge) {
          return _PastFacet.schoolLearning;
        }
        if (band == ThaiLifeStageBand.teen) {
          return _PastFacet.identityExpress;
        }
        return _PastFacet.identityExpress;
      case 'opportunity':
        return data.keyword.contains('เปลี่ยน') ||
                data.phaseEssence.contains('เปลี่ยน')
            ? _PastFacet.changeTransition
            : _PastFacet.newBeginnings;
      default:
        return null;
    }
  }

  static _PastFacet _pressureFacet(ThaiLifeStageBand band) {
    if (band == ThaiLifeStageBand.earlyChildhood ||
        band == ThaiLifeStageBand.schoolAge ||
        band == ThaiLifeStageBand.teen) {
      return _PastFacet.homeFamily;
    }
    return _PastFacet.dutyAndAdaptation;
  }

  static List<_PastFacet> _facetsFromKeywordAndEssence(
    ThaiLifeStageBand band,
    LifePlanetData data,
  ) {
    final blob = '${data.keyword} ${data.phaseEssence} ${data.phaseName}';
    final out = <_PastFacet>[];
    if (blob.contains('มั่นคง') ||
        blob.contains('รากฐาน') ||
        blob.contains('ตั้งหลัก')) {
      out.add(_PastFacet.homeFamily);
      if (ThaiLifeStageContext.allowsAdultCareerMoneyRomance(band)) {
        out.add(_PastFacet.moneySecurity);
      }
    }
    if (blob.contains('เติบโต') ||
        blob.contains('เรียนรู้') ||
        blob.contains('โอกาส')) {
      out.add(
        band == ThaiLifeStageBand.schoolAge ||
                band == ThaiLifeStageBand.earlyChildhood
            ? _PastFacet.schoolLearning
            : _PastFacet.newBeginnings,
      );
    }
    if (blob.contains('เปลี่ยน') ||
        blob.contains('พลิก') ||
        blob.contains('ผ่าน')) {
      out.add(_PastFacet.changeTransition);
    }
    if (blob.contains('สัมพันธ์') ||
        blob.contains('สุข') ||
        blob.contains('ครอบครัว')) {
      out.add(
        ThaiLifeStageContext.allowsAdultCareerMoneyRomance(band)
            ? _PastFacet.lovePartner
            : _PastFacet.homeFamily,
      );
    }
    if (blob.contains('ยอมรับ') ||
        blob.contains('ตัวตน') ||
        blob.contains('เปล่ง')) {
      out.add(_PastFacet.identityExpress);
    }
    if (blob.contains('ลงมือ') ||
        blob.contains('บุก') ||
        blob.contains('งาน')) {
      out.add(
        ThaiLifeStageContext.allowsAdultCareerMoneyRomance(band)
            ? _PastFacet.workPath
            : _PastFacet.dutyAndAdaptation,
      );
    }
    if (blob.contains('ใจ') ||
        blob.contains('ความรู้สึก') ||
        blob.contains('สงบ')) {
      out.add(_PastFacet.healthEnergy);
      out.add(_PastFacet.homeFamily);
    }
    return out;
  }

  static bool _allowedForBand(_PastFacet facet, ThaiLifeStageBand band) {
    switch (facet) {
      case _PastFacet.workPath:
      case _PastFacet.moneySecurity:
      case _PastFacet.lovePartner:
        return ThaiLifeStageContext.allowsAdultCareerMoneyRomance(band) ||
            (facet == _PastFacet.lovePartner && band == ThaiLifeStageBand.teen);
      case _PastFacet.schoolLearning:
        return band == ThaiLifeStageBand.earlyChildhood ||
            band == ThaiLifeStageBand.schoolAge ||
            band == ThaiLifeStageBand.teen ||
            band == ThaiLifeStageBand.youngAdult;
      default:
        return true;
    }
  }

  static _PastFacet _defaultFacet(ThaiLifeStageBand band) => switch (band) {
    ThaiLifeStageBand.earlyChildhood => _PastFacet.homeFamily,
    ThaiLifeStageBand.schoolAge => _PastFacet.schoolLearning,
    ThaiLifeStageBand.teen => _PastFacet.identityExpress,
    ThaiLifeStageBand.youngAdult => _PastFacet.newBeginnings,
    ThaiLifeStageBand.workingAdult => _PastFacet.workPath,
    ThaiLifeStageBand.midlife => _PastFacet.dutyAndAdaptation,
    ThaiLifeStageBand.elder => _PastFacet.healthEnergy,
  };

  /// [LifePlanetData.phaseName] already starts with "ช่วง…"; strip for templates.
  static String _phaseCore(LifePlanetData data) {
    final phase = data.phaseName.trim();
    return phase.startsWith('ช่วง') ? phase.substring('ช่วง'.length) : phase;
  }

  /// Prefer age-natural facet labels in openings without inventing new evidence.
  static _PastFacet _openingFacet(
    List<_PastFacet> facets,
    ThaiLifeStageBand band,
  ) {
    if (band == ThaiLifeStageBand.earlyChildhood ||
        band == ThaiLifeStageBand.schoolAge) {
      const preferred = [
        _PastFacet.homeFamily,
        _PastFacet.schoolLearning,
        _PastFacet.dutyAndAdaptation,
        _PastFacet.peersBelonging,
      ];
      for (final facet in preferred) {
        if (facets.contains(facet)) return facet;
      }
    }
    return facets.first;
  }

  static List<String> _openingLines(
    ThaiLifeStageBand band,
    LifePlanetData data,
    List<_PastFacet> facets,
  ) {
    final phase = _phaseCore(data);
    final planet = data.thaiName;
    final keyword = data.keyword;
    final essence = data.phaseEssence;
    final primary = _openingFacet(facets, band);
    final stage = ThaiLifeStageContext.bandLabelTh(band);
    final focus = _facetFocusLabel(primary, band);
    return [
      'ในช่วง$phase ของ$stage ภายใต้อิทธิพล$planet '
          'บรรยากาศหลักโยงกับเรื่อง$keyword และ$focus '
          'ซึ่ง$essence ทำให้ช่วงนี้มีน้ำหนักต่างจากจังหวะอื่นอย่างเห็นได้',
      'ย้อนไปช่วง$phase อิทธิพล$planet ทำให้เรื่อง$keyword '
          'กลายเป็นแกนของชีวิตใน$stage โดยเฉพาะด้าน$focus '
          'มากกว่าเรื่องอื่นในช่วงใกล้เคียง',
    ];
  }

  static List<String> _experienceLines(
    ThaiLifeStageBand band,
    LifePlanetData data,
    List<_PastFacet> facets,
  ) {
    final planet = data.thaiName;
    final keyword = data.keyword;
    final essence = data.phaseEssence;
    final lines = <String>[];
    for (final facet in facets.take(2)) {
      lines.addAll(_experienceForFacet(facet, band, planet, keyword, essence));
    }
    return lines;
  }

  static List<String> _innerEffectLines(
    ThaiLifeStageBand band,
    LifePlanetData data,
    List<_PastFacet> facets,
  ) {
    final keyword = data.keyword;
    final primary = facets.first;
    final secondary = facets.length > 1 ? facets[1] : facets.first;
    return [
      'ผลที่ตามมาคือนิสัยและมุมมองเรื่อง$keyword ก่อตัวขึ้นจริง '
          'ผ่าน${_facetFocusLabel(primary, band)} '
          'และ${_facetFocusLabel(secondary, band)} '
          'จนกลายเป็นพื้นอารมณ์ที่พกติดตัวต่อไป',
      'จังหวะนี้ฝังแบบแผนการปรับตัวเรื่อง$keyword ไว้ในตัว '
          'โดยเฉพาะเมื่อต้องเผชิญ${_facetFocusLabel(primary, band)} '
          'พร้อม${_facetFocusLabel(secondary, band)} '
          'และเปลี่ยนวิธีมองความมั่นคงของชีวิตตั้งแต่นั้น',
    ];
  }

  static List<String> _experienceForFacet(
    _PastFacet facet,
    ThaiLifeStageBand band,
    String planet,
    String keyword,
    String essence,
  ) {
    switch (facet) {
      case _PastFacet.homeFamily:
        if (band == ThaiLifeStageBand.earlyChildhood ||
            band == ThaiLifeStageBand.schoolAge) {
          return [
            'ช่วงนั้นชีวิตถูกกำหนดด้วยบ้าน ที่อยู่อาศัย และข้อจำกัดในครอบครัว '
                'การเปลี่ยนสภาพแวดล้อมหรือกฎในบ้านทำให้ต้องปรับตัวมากกว่าเพื่อนวัยเดียวกัน '
                'ภายใต้อิทธิพล$planet ที่โยงกับเรื่อง$keyword',
            'แรงหลักของจังหวะนี้ผ่านบรรยากาศผู้ดูแล ความใกล้ชิดหรือระยะห่างในบ้าน '
                'และความมั่นคงทางใจที่ผูกกับสภาพแวดล้อมใกล้ตัว โดย$essence',
          ];
        }
        return [
          'ช่วงนั้นฐานบ้าน ครอบครัว และการจัดระเบียบชีวิตส่วนตัวถูกบังคับให้ชัดขึ้น '
              'ภายใต้อิทธิพล$planet ที่โยงกับเรื่อง$keyword',
          'แรงหลักปรากฏผ่านการดูแลคนในบ้าน การปรับบทบาทในครอบครัว '
              'และการสร้างความรู้สึกมีที่พึ่ง โดย$essence',
        ];
      case _PastFacet.schoolLearning:
        return [
          'ช่วงนั้นการเรียน โรงเรียน ครู และเพื่อนเป็นเวทีหลักของชีวิต '
              'ความคาดหวังของผู้ใหญ่และการปรับตัวในห้องเรียนกำหนดจังหวะประจำวัน '
              'ภายใต้อิทธิพล$planet',
          'แรงหลักผ่านวิชาที่ถนัดหรือลังเล การบ้าน และการหาที่ยืนในกลุ่มเพื่อน '
              'โดยเรื่อง$keyword ทำงานคู่กับ$essence',
        ];
      case _PastFacet.peersBelonging:
        return [
          'ช่วงนั้นมิตรภาพและการยอมรับในกลุ่มกลายเป็นบททดสอบสำคัญ '
              'การหาที่ทางท่ามกลางคนรอบตัวกำหนดความมั่นใจ '
              'ภายใต้อิทธิพล$planet ที่โยงกับเรื่อง$keyword',
          'แรงหลักผ่านการเข้าออกกลุ่ม การเปรียบเทียบตัวเองกับเพื่อน '
              'และความต้องการเป็นส่วนหนึ่ง โดย$essence',
        ];
      case _PastFacet.identityExpress:
        return [
          'ช่วงนั้นการค้นหาตัวตนและการแสดงออกถูกผลักให้เด่น '
              'ความมั่นใจในการเลือกทางของตนเองถูกทดสอบจริง '
              'ภายใต้อิทธิพล$planet ที่โยงกับเรื่อง$keyword',
          'แรงหลักผ่านการทดลองบทบาทใหม่ การตั้งคำถามกับความคาดหวังเดิม '
              'และการตัดสินใจที่เริ่มเป็นของตนเอง โดย$essence',
        ];
      case _PastFacet.dutyAndAdaptation:
        return [
          'ช่วงนั้นความรับผิดชอบที่เหมาะกับวัยและข้อจำกัดเพิ่มขึ้นจริง '
              'การปรับตัวเมื่อมีภาระใหม่กลายเป็นแกนของชีวิต '
              'ภายใต้อิทธิพล$planet ที่โยงกับเรื่อง$keyword',
          'แรงหลักผ่านงานเล็ก ๆ ในบ้าน กฎที่ต้องทำตาม '
              'และความรู้สึกว่าต้องพึ่งพาตัวเองมากขึ้น โดย$essence',
        ];
      case _PastFacet.workPath:
        return [
          'ช่วงนั้นทิศทางงาน การเปลี่ยนงาน หรือการเริ่มเส้นทางอาชีพถูกบังคับให้ชัด '
              'ภายใต้อิทธิพล$planet ที่โยงกับเรื่อง$keyword',
          'แรงหลักผ่านภาระหน้าที่ในที่ทำงาน '
              'การเลือกระหว่างความมั่นคงกับโอกาสใหม่ '
              'และการจัดสมดุลงานกับชีวิต โดย$essence',
        ];
      case _PastFacet.moneySecurity:
        return [
          'ช่วงนั้นรายได้ ภาระการเงิน และความมั่นคงทางทรัพย์สินกลายเป็นแกนตัดสินใจ '
              'ภายใต้อิทธิพล$planet ที่โยงกับเรื่อง$keyword',
          'แรงหลักผ่านการวางแผนใช้เงิน การรับผิดชอบค่าใช้จ่าย '
              'และการสร้างฐานสำรองให้ชีวิต โดย$essence',
        ];
      case _PastFacet.lovePartner:
        return [
          'ช่วงนั้นความรัก คู่ครอง หรือความสัมพันธ์ระยะยาวถูกทดสอบเรื่องความจริงใจ '
              'ภายใต้อิทธิพล$planet ที่โยงกับเรื่อง$keyword',
          'แรงหลักผ่านการผูกพัน การไกล่เกลี่ยความต่าง '
              'และการเรียนรู้ขอบเขตในความสัมพันธ์ โดย$essence',
        ];
      case _PastFacet.healthEnergy:
        return [
          'ช่วงนั้นสุขภาพ พลังงาน และข้อจำกัดของร่างกายบังคับให้ปรับจังหวะชีวิต '
              'ภายใต้อิทธิพล$planet ที่โยงกับเรื่อง$keyword',
          'แรงหลักผ่านความเหนื่อยล้า การพักฟื้น '
              'และการเรียนรู้ขีดจำกัดของพลังกายและใจ โดย$essence',
        ];
      case _PastFacet.changeTransition:
        return [
          'ช่วงนั้นเกิดการเปลี่ยนแปลงครั้งสำคัญ การแยกจากสิ่งเดิม '
              'หรือการปิดบทหนึ่งเพื่อเปิดบทใหม่ '
              'ภายใต้อิทธิพล$planet ที่โยงกับเรื่อง$keyword',
          'แรงหลักผ่านการย้ายที่ การเปลี่ยนบทบาท '
              'หรือการสูญเสียความคุ้นเคยเดิม โดย$essence',
        ];
      case _PastFacet.newBeginnings:
        return [
          'ช่วงนั้นชีวิตเปิดบทใหม่ โอกาสขยายตัว และเส้นทางที่เคยปิดถูกผลักให้เดินต่อ '
              'ภายใต้อิทธิพล$planet ที่โยงกับเรื่อง$keyword',
          'แรงหลักผ่านเส้นทางเรียนหรืองานใหม่ '
              'การรู้จักคนใหม่ หรือการรับบทบาทที่กว้างขึ้น โดย$essence',
        ];
    }
  }

  static String _facetFocusLabel(_PastFacet facet, ThaiLifeStageBand band) {
    switch (facet) {
      case _PastFacet.homeFamily:
        return band == ThaiLifeStageBand.earlyChildhood ||
                band == ThaiLifeStageBand.schoolAge
            ? 'บ้าน ครอบครัว และการปรับตัวในสภาพแวดล้อมใกล้ตัว'
            : 'ฐานบ้าน ครอบครัว และการจัดระเบียบชีวิตส่วนตัว';
      case _PastFacet.schoolLearning:
        return 'การเรียน โรงเรียน และเพื่อนในวัยเรียน';
      case _PastFacet.peersBelonging:
        return 'มิตรภาพ การยอมรับ และการหาที่ยืนในกลุ่ม';
      case _PastFacet.identityExpress:
        return 'ตัวตน ความมั่นใจ และการแสดงออก';
      case _PastFacet.dutyAndAdaptation:
        return 'ความรับผิดชอบและข้อจำกัดที่ต้องปรับตัว';
      case _PastFacet.workPath:
        return 'งาน เส้นทางอาชีพ และการรับผิดชอบในหน้าที่';
      case _PastFacet.moneySecurity:
        return 'รายได้ ภาระการเงิน และความมั่นคงทางทรัพย์สิน';
      case _PastFacet.lovePartner:
        return 'ความรัก คู่ครอง และความสัมพันธ์ระยะยาว';
      case _PastFacet.healthEnergy:
        return 'สุขภาพ พลังงาน และจังหวะของร่างกาย';
      case _PastFacet.changeTransition:
        return 'การเปลี่ยนแปลง การแยกจาก และการเปลี่ยนผ่าน';
      case _PastFacet.newBeginnings:
        return 'การเริ่มต้นใหม่ โอกาส และการขยายตัวของชีวิต';
    }
  }

  static String _fitWordBudget(
    String text,
    ThaiLifeStageBand band,
    LifePlanetData data,
    List<_PastFacet> facets,
    int seed,
  ) {
    var words = approxWordCount(text);
    if (words >= 90 && words <= 160) return text;
    if (words < 90) {
      final extraFacet = facets.length > 2 ? facets[2] : facets.first;
      final pad = _pick(
        _experienceForFacet(
          extraFacet,
          band,
          data.thaiName,
          data.keyword,
          data.phaseEssence,
        ),
        seed ~/ 13,
      );
      final denser = '$text\n\n$pad';
      if (approxWordCount(denser) <= 170) return denser;
      return denser;
    }
    final parts = text.split('\n\n');
    if (parts.length >= 3 && words > 160) {
      final trimmed = '${parts[0]}\n\n${parts[1]}';
      if (approxWordCount(trimmed) >= 90) return trimmed;
    }
    return text;
  }

  static String _pick(List<String> options, int seed) {
    if (options.isEmpty) return '';
    return options[seed.abs() % options.length];
  }
}

enum _PastFacet {
  homeFamily,
  schoolLearning,
  peersBelonging,
  identityExpress,
  dutyAndAdaptation,
  workPath,
  moneySecurity,
  lovePartner,
  healthEnergy,
  changeTransition,
  newBeginnings,
}
