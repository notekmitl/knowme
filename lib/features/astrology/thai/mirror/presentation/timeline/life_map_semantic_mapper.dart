import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

import 'life_map_plain_thai_renderer.dart';
import 'life_map_verdict_semantics.dart';
import 'period_composite_score.dart';
import 'thai_life_stage_context.dart';

/// Deterministic mapping from period evidence → falsifiable life claims.
///
/// Claim Thai bodies are plain, short, and free of time-marker prefixes.
/// [LifeMapPlainThaiRenderer] assembles UI copy.
abstract final class LifeMapSemanticMapper {
  static LifeMapVerdictSemantics build({
    required LifeMapVerdictTense tense,
    required ThaiLifeStageBand band,
    required LifePlanetData data,
    required PeriodScores scores,
    required int seed,
  }) {
    final primaryDomain = _domainFromScoreKey(
      ThaiLifeStageContext.narrativeDomain(scores.topDomain, band),
      band,
      data,
    );
    final pressureDomain = _domainFromScoreKey(
      ThaiLifeStageContext.narrativeDomain(scores.weakestDomain, band),
      band,
      data,
    );
    final transition = _transitionFromPlanet(data, scores);
    final s = seed.abs();

    final primary = _claimFor(
      tense: tense,
      band: band,
      domain: primaryDomain,
      transition: transition,
      role: _ClaimRole.situation,
      variant: s,
      evidenceKeys: [
        'planet:${data.planet.name}',
        'score:${scores.topDomain}',
        'keyword:${data.keyword}',
        'band:${band.name}',
      ],
    );

    final pressureDomainFinal = pressureDomain == primaryDomain
        ? _alternateDomain(primaryDomain, data, band)
        : pressureDomain;
    final pressure = _claimFor(
      tense: tense,
      band: band,
      domain: pressureDomainFinal,
      transition: transition,
      role: _ClaimRole.pressure,
      variant: s ~/ 3,
      evidenceKeys: [
        'planet:${data.planet.name}',
        'score_weak:${scores.weakestDomain}',
        'pressure:${data.affinity.pressure}',
      ],
    );

    final consequence = _claimFor(
      tense: tense,
      band: band,
      domain: primaryDomain,
      transition: transition,
      role: _ClaimRole.consequence,
      variant: s ~/ 7,
      evidenceKeys: [
        'planet:${data.planet.name}',
        'score:${scores.topDomain}',
        'transition:${transition.name}',
      ],
    );

    LifeMapVerdictClaim? secondary;
    if (tense == LifeMapVerdictTense.past) {
      final alt = _alternateDomain(primaryDomain, data, band);
      if (alt != primaryDomain) {
        secondary = _claimFor(
          tense: tense,
          band: band,
          domain: alt,
          transition: transition,
          role: _ClaimRole.situation,
          variant: s ~/ 11,
          evidenceKeys: [
            'planet:${data.planet.name}',
            'affinity_secondary:${alt.id}',
          ],
        );
      }
    }

    final pressureFinal = pressure.semanticKey == primary.semanticKey
        ? null
        : pressure;
    final consequenceFinal = consequence.semanticKey == primary.semanticKey
        ? null
        : consequence;

    final beats = tense == LifeMapVerdictTense.past
        ? _pastBeats(
            band: band,
            data: data,
            primaryDomain: primaryDomain,
            primary: primary,
            secondary: secondary,
            pressure: pressureFinal,
            consequence: consequenceFinal,
            transition: transition,
            seed: s,
          )
        : const <LifeMapNarrativeBeat>[];

    return LifeMapVerdictSemantics(
      tense: tense,
      primary: primary,
      secondary: secondary,
      pressure: pressureFinal,
      consequence: consequenceFinal,
      beats: beats,
    );
  }

  /// Past story beats from evidence only — no invented events.
  ///
  /// V1.3.3: vary role order and openers by seed so eight periods do not share
  /// one "โอกาส → รับมือ → เลือก" skeleton. Continuity uses transition /
  /// lingering evidence only — never fabricated events.
  static List<LifeMapNarrativeBeat> _pastBeats({
    required ThaiLifeStageBand band,
    required LifePlanetData data,
    required LifeMapClaimDomain primaryDomain,
    required LifeMapVerdictClaim primary,
    required LifeMapVerdictClaim? secondary,
    required LifeMapVerdictClaim? pressure,
    required LifeMapVerdictClaim? consequence,
    required _TransitionKind transition,
    required int seed,
  }) {
    final pack = _pack(primaryDomain, band);
    final s = seed.abs();
    final ctx = pack.contexts[s % pack.contexts.length];
    final linger = pack.lingerings[s % pack.lingerings.length];
    final keys = [
      'planet:${data.planet.name}',
      'keyword:${data.keyword}',
      'domain:${primaryDomain.id}',
    ];

    final byRole = <String, LifeMapNarrativeBeat>{
      'context': LifeMapNarrativeBeat(
        id: ctx.id,
        role: 'context',
        textTh: _varyPastOpener(ctx.text, s),
        evidenceKeys: [...keys, 'beat:context'],
      ),
      'change': LifeMapNarrativeBeat(
        id: primary.situationId,
        role: 'change',
        textTh: primary.situationTh,
        evidenceKeys: primary.evidenceKeys,
      ),
      if (secondary != null)
        'support': LifeMapNarrativeBeat(
          id: secondary.situationId,
          role: 'support',
          textTh: secondary.situationTh,
          evidenceKeys: secondary.evidenceKeys,
        ),
      if (pressure != null)
        'pressure': LifeMapNarrativeBeat(
          id: pressure.pressureId,
          role: 'pressure',
          textTh: pressure.pressureTh,
          evidenceKeys: pressure.evidenceKeys,
        ),
      if (consequence != null)
        'response': LifeMapNarrativeBeat(
          id: consequence.consequenceId,
          role: 'response',
          textTh: consequence.consequenceTh,
          evidenceKeys: consequence.evidenceKeys,
        ),
      'lingering': LifeMapNarrativeBeat(
        id: linger.id,
        role: 'lingering',
        textTh: linger.text,
        evidenceKeys: [
          ...keys,
          'beat:lingering',
          'transition:${transition.name}',
        ],
      ),
    };

    // Pattern templates — each starts with a different role when evidence allows.
    const patterns = <List<String>>[
      ['context', 'change', 'pressure', 'response', 'lingering'],
      ['change', 'pressure', 'response', 'lingering', 'support'],
      ['pressure', 'change', 'support', 'response', 'lingering'],
      ['context', 'pressure', 'change', 'lingering', 'response'],
      ['change', 'support', 'context', 'pressure', 'lingering'],
      ['support', 'change', 'pressure', 'lingering', 'response'],
      ['change', 'response', 'pressure', 'lingering', 'context'],
      ['context', 'support', 'change', 'response', 'lingering'],
    ];
    final order = patterns[s % patterns.length];

    final raw = <LifeMapNarrativeBeat>[];
    for (final role in order) {
      final beat = byRole[role];
      if (beat == null) continue;
      raw.add(beat);
    }
    // Ensure primary change is present even if pattern skipped a missing role.
    if (!raw.any((b) => b.role == 'change')) {
      raw.insert(0, byRole['change']!);
    }

    // Deduplicate by normalized text; keep pattern order. Cap at 5 for flow.
    final kept = <LifeMapNarrativeBeat>[];
    for (final beat in raw) {
      final t = beat.textTh.trim();
      if (t.isEmpty) continue;
      if (kept.any(
        (k) => LifeMapPlainThaiRenderer.sameMeaningPublic(k.textTh, t),
      )) {
        continue;
      }
      kept.add(beat);
      if (kept.length >= 5) break;
    }
    return kept;
  }

  /// Diversify Past openers without soft filler "ในช่วงนั้น" / "ช่วงนั้น".
  static String _varyPastOpener(String text, int seed) {
    var t = text.trim();
    if (t.isEmpty) return t;
    // Never reintroduce banned soft openers.
    t = t.replaceFirst(RegExp(r'^ในช่วงนั้น\s*'), '');
    t = t.replaceFirst(RegExp(r'^ช่วงนั้น\s*'), '');
    const stem = 'ก่อนหน้านั้น';
    if (!t.startsWith(stem)) return t;
    final rest = t.substring(stem.length).trimLeft();
    if (rest.isEmpty) return t;
    final alts = <String>[
      'ก่อนหน้านี้$rest',
      rest,
      'พื้นฐานก่อนเข้าช่วงนี้$rest',
      'จากจังหวะก่อนหน้าที่ส่งต่อมา $rest',
      'ก่อนจะถึงจุดนี้$rest',
    ];
    return alts[seed.abs() % alts.length];
  }

  static LifeMapClaimDomain _domainFromScoreKey(
    String narrativeDomain,
    ThaiLifeStageBand band,
    LifePlanetData data,
  ) {
    switch (narrativeDomain) {
      case 'career':
        return ThaiLifeStageContext.isChildOriented(band)
            ? LifeMapClaimDomain.learningPath
            : LifeMapClaimDomain.workRole;
      case 'money':
        return ThaiLifeStageContext.isChildOriented(band)
            ? LifeMapClaimDomain.familyHome
            : LifeMapClaimDomain.moneySecurity;
      case 'love':
        if (band == ThaiLifeStageBand.earlyChildhood ||
            band == ThaiLifeStageBand.schoolAge) {
          return LifeMapClaimDomain.familyHome;
        }
        if (band == ThaiLifeStageBand.teen) {
          return LifeMapClaimDomain.identityBelonging;
        }
        return LifeMapClaimDomain.relationshipBond;
      case 'health':
        return LifeMapClaimDomain.healthEnergy;
      case 'opportunity':
        return LifeMapClaimDomain.opportunityExpand;
      case 'growth':
      default:
        return _domainFromKeyword(data, band);
    }
  }

  static LifeMapClaimDomain _domainFromKeyword(
    LifePlanetData data,
    ThaiLifeStageBand band,
  ) {
    final k = data.keyword;
    if (k.contains('มั่นคง')) {
      return ThaiLifeStageContext.isChildOriented(band)
          ? LifeMapClaimDomain.familyHome
          : LifeMapClaimDomain.dutyBurden;
    }
    if (k.contains('เปลี่ยนแปลง') || k.contains('พลิก')) {
      return LifeMapClaimDomain.transitionRebuild;
    }
    if (k.contains('สัมพันธ์') || k.contains('สุข')) {
      return ThaiLifeStageContext.isChildOriented(band)
          ? LifeMapClaimDomain.familyHome
          : LifeMapClaimDomain.relationshipBond;
    }
    if (k.contains('ยอมรับ') || k.contains('ตัวตน')) {
      return LifeMapClaimDomain.identityBelonging;
    }
    if (k.contains('ลงมือ')) return LifeMapClaimDomain.workRole;
    if (k.contains('เรียนรู้') || k.contains('เติบโต')) {
      return ThaiLifeStageContext.isChildOriented(band)
          ? LifeMapClaimDomain.learningPath
          : LifeMapClaimDomain.opportunityExpand;
    }
    if (k.contains('ความรู้สึก')) return LifeMapClaimDomain.familyHome;
    return LifeMapClaimDomain.dutyBurden;
  }

  static _TransitionKind _transitionFromPlanet(
    LifePlanetData data,
    PeriodScores scores,
  ) {
    if (data.affinity.pressure >= 70 || scores.pressure >= 70) {
      return _TransitionKind.forcedReorder;
    }
    if (data.keyword.contains('เปลี่ยนแปลง') ||
        data.planet == LifePlanet.rahu) {
      return _TransitionKind.separateRebuild;
    }
    if (data.keyword.contains('มั่นคง') || data.planet == LifePlanet.saturn) {
      return _TransitionKind.lockStability;
    }
    if (data.keyword.contains('เติบโต') ||
        data.keyword.contains('โอกาส') ||
        data.planet == LifePlanet.jupiter) {
      return _TransitionKind.expandRole;
    }
    if (data.keyword.contains('ลงมือ') || data.planet == LifePlanet.mars) {
      return _TransitionKind.commitAction;
    }
    if (data.keyword.contains('สัมพันธ์') || data.planet == LifePlanet.venus) {
      return _TransitionKind.rebindRelations;
    }
    if (data.planet == LifePlanet.sun) return _TransitionKind.seekRecognition;
    if (data.planet == LifePlanet.moon) return _TransitionKind.restoreBalance;
    return _TransitionKind.skillBuild;
  }

  static LifeMapClaimDomain _alternateDomain(
    LifeMapClaimDomain primary,
    LifePlanetData data,
    ThaiLifeStageBand band,
  ) {
    final ranked = data.affinity.supportRanked;
    for (final d in ranked) {
      final mapped = _domainFromScoreKey(d.name, band, data);
      if (mapped != primary) return mapped;
    }
    return primary == LifeMapClaimDomain.dutyBurden
        ? LifeMapClaimDomain.healthEnergy
        : LifeMapClaimDomain.dutyBurden;
  }

  static LifeMapVerdictClaim _claimFor({
    required LifeMapVerdictTense tense,
    required ThaiLifeStageBand band,
    required LifeMapClaimDomain domain,
    required _TransitionKind transition,
    required _ClaimRole role,
    required int variant,
    required List<String> evidenceKeys,
  }) {
    final pack = _pack(domain, band);
    final sit = pack.situations[variant.abs() % pack.situations.length];
    final press = pack.pressures[variant.abs() % pack.pressures.length];
    final cons = _consequence(transition, variant);
    final situationText =
        tense == LifeMapVerdictTense.future && sit.id == 'sit_opp'
        ? 'ช่วงนี้ชวนให้เปิดรับโอกาสผ่านงานหรือเครือข่าย แล้วดูจากผลที่เกิดขึ้นจริงว่าอะไรควรทำต่อ'
        : sit.text;

    switch (role) {
      case _ClaimRole.situation:
        return LifeMapVerdictClaim(
          tense: tense,
          situationId: sit.id,
          domain: domain,
          pressureId: press.id,
          consequenceId: cons.id,
          situationTh: situationText,
          pressureTh: press.text,
          consequenceTh: cons.text,
          evidenceKeys: evidenceKeys,
        );
      case _ClaimRole.pressure:
        return LifeMapVerdictClaim(
          tense: tense,
          situationId: press.id,
          domain: domain,
          pressureId: press.id,
          consequenceId: cons.id,
          situationTh: press.text,
          pressureTh: press.text,
          consequenceTh: cons.text,
          evidenceKeys: evidenceKeys,
        );
      case _ClaimRole.consequence:
        return LifeMapVerdictClaim(
          tense: tense,
          situationId: cons.id,
          domain: domain,
          pressureId: press.id,
          consequenceId: cons.id,
          situationTh: cons.text,
          pressureTh: press.text,
          consequenceTh: cons.text,
          evidenceKeys: evidenceKeys,
        );
    }
  }

  /// Plain consequence — no domain-label injection.
  static _TextId _consequence(_TransitionKind transition, int variant) {
    final lines = switch (transition) {
      _TransitionKind.forcedReorder => [
        _TextId('cons_reorder', 'คุณต้องเลือกเก็บเฉพาะเรื่องที่สำคัญจริง ๆ'),
        _TextId(
          'cons_reorder2',
          'คุณต้องจัดลำดับชีวิตใหม่และหยุดบางอย่างที่ถ่วงไว้',
        ),
      ],
      _TransitionKind.separateRebuild => [
        _TextId('cons_rebuild', 'คุณต้องเริ่มใหม่และปล่อยวิธีเดิมไป'),
        _TextId(
          'cons_rebuild2',
          'ชีวิตไม่เหมือนเดิม และคุณต้องสร้างทางของตัวเอง',
        ),
      ],
      _TransitionKind.lockStability => [
        _TextId('cons_lock', 'คุณต้องยึดเรื่องมั่นคงไว้ก่อนความอยากส่วนตัว'),
        _TextId('cons_lock2', 'หน้าที่ที่หลีกเลี่ยงไม่ได้จำกัดทางเลือกอื่น'),
      ],
      _TransitionKind.expandRole => [
        _TextId('cons_expand', 'คุณต้องรับหน้าที่มากขึ้นตามโอกาสที่เข้ามา'),
        _TextId(
          'cons_expand2',
          'คุณออกจากวิธีเดิมและตัดสินใจด้วยตัวเองมากขึ้น',
        ),
      ],
      _TransitionKind.commitAction => [
        _TextId('cons_act', 'คุณต้องลงมือตัดสินใจแทนการเลื่อนปัญหาไว้'),
        _TextId('cons_act2', 'คุณมองอนาคตต่างจากเดิม'),
      ],
      _TransitionKind.rebindRelations => [
        _TextId(
          'cons_rel',
          'คุณต้องคุยกับคนใกล้ตัวและรับผิดชอบผลของการอยู่ด้วยกันชัดขึ้น',
        ),
        _TextId(
          'cons_rel2',
          'คุณต้องบอกคนใกล้ตัวว่าเรื่องใดรับได้ และเรื่องใดยังรับไม่ได้',
        ),
      ],
      _TransitionKind.seekRecognition => [
        _TextId(
          'cons_recog',
          'คนอื่นเห็นคุณชัดขึ้น และหน้าที่ของคุณเปลี่ยนตาม',
        ),
        _TextId(
          'cons_recog2',
          'คุณต้องรับความคาดหวังใหม่และรักษาสมดุลกับชีวิตตัวเอง',
        ),
      ],
      _TransitionKind.restoreBalance => [
        _TextId('cons_bal', 'คุณต้องคืนแรงก่อนเร่งเรื่องอื่น'),
        _TextId('cons_bal2', 'คุณต้องจัดชีวิตให้พักได้โดยไม่เสียสุขภาพ'),
      ],
      _TransitionKind.skillBuild => [
        _TextId('cons_skill', 'ทักษะที่ฝึกไว้ใช้ต่อได้จริง'),
        _TextId('cons_skill2', 'คุณเลือกทางที่ถนัดชัดขึ้น'),
      ],
    };
    return lines[variant.abs() % lines.length];
  }

  static _DomainPack _pack(LifeMapClaimDomain domain, ThaiLifeStageBand band) {
    final child = ThaiLifeStageContext.isChildOriented(band);
    final teen = band == ThaiLifeStageBand.teen;
    switch (domain) {
      case LifeMapClaimDomain.workRole:
        return _DomainPack(
          situations: child || teen
              ? [
                  _TextId(
                    'sit_work_youth',
                    'คุณต้องเลือกทางเรียนหรือกิจกรรมที่ผู้ใหญ่คาดหวัง',
                  ),
                  _TextId(
                    'sit_work_youth2',
                    'โรงเรียน กิจกรรม หรืองานเล็ก ๆ กินเวลาทั้งวันของคุณ',
                  ),
                ]
              : [
                  _TextId(
                    'sit_work',
                    'งานและหน้าที่บังคับให้คุณจัดลำดับชีวิตใหม่',
                  ),
                  _TextId('sit_work2', 'งานที่เคยทำแบบเดิมเริ่มเปลี่ยนไป'),
                ],
          pressures: [
            _TextId('prs_work', 'คุณต้องแบกงานหลายเรื่องจนเวลาและพลังไม่พอ'),
            _TextId(
              'prs_work2',
              'คุณมีทั้งงานและเรื่องส่วนตัวให้จัดการพร้อมกันจนทำไม่ไหว',
            ),
          ],
          contexts: child || teen
              ? [
                  _TextId(
                    'ctx_work_youth',
                    'ก่อนหน้านั้นวันของคุณยังหมุนรอบการเรียนและกิจกรรมที่คุ้นเคย',
                  ),
                ]
              : [
                  _TextId(
                    'ctx_work',
                    'ก่อนหน้านั้นคุณยังทำงานในแบบที่คุ้นเคยและรู้ว่าต้องทำอะไรต่อไป',
                  ),
                ],
          lingerings: [
            _TextId(
              'ling_work',
              'บทเรียนเรื่องงานนี้ยังติดตัวไปตอนที่คุณต้องเลือกทางต่อมา',
            ),
            _TextId(
              'ling_work2',
              'คุณเริ่มมองหน้าที่และความรับผิดชอบต่างจากเดิม',
            ),
          ],
        );
      case LifeMapClaimDomain.moneySecurity:
        return _DomainPack(
          situations: [
            _TextId('sit_money', 'เรื่องเงินจำกัดทางเลือกอื่นในชีวิตของคุณ'),
            _TextId(
              'sit_money2',
              'คุณต้องคิดเรื่องเก็บเงินและความมั่นคงก่อนเรื่องอื่น',
            ),
          ],
          pressures: [
            _TextId(
              'prs_money',
              'คุณต้องตัดสินใจเรื่องเงินภายใต้เวลาและข้อจำกัดที่มี',
            ),
            _TextId(
              'prs_money2',
              'คุณอยากใช้เงินวันนี้ แต่ยังต้องเก็บเพื่อแผนระยะยาว',
            ),
          ],
          contexts: [
            _TextId(
              'ctx_money',
              'ก่อนหน้านั้นเรื่องเงินยังไม่ใช่สิ่งที่คุณต้องคิดทุกวัน',
            ),
          ],
          lingerings: [
            _TextId(
              'ling_money',
              'คุณเริ่มให้ความสำคัญกับความมั่นคงทางการเงินมากขึ้น',
            ),
          ],
        );
      case LifeMapClaimDomain.relationshipBond:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_love',
              'ความใกล้ชิดถูกทดสอบเรื่องความจริงใจและการอยู่ร่วม',
            ),
            _TextId(
              'sit_love2',
              'คุณต้องเลือกว่าจะให้เวลากับงานหรือกับคนใกล้ตัวก่อน',
            ),
          ],
          pressures: [
            _TextId(
              'prs_love',
              'คุณคาดหวังเงียบ ๆ โดยไม่คุยจนเกิดระยะห่าง',
            ),
            _TextId(
              'prs_love2',
              'คุณอยากใกล้ชิด แต่ก็ยังต้องการพื้นที่ส่วนตัว',
            ),
          ],
          contexts: [
            _TextId(
              'ctx_love',
              'ก่อนหน้านั้นความสัมพันธ์ยังเดินไปในแบบที่คุณคุ้นเคย',
            ),
          ],
          lingerings: [
            _TextId('ling_love', 'คุณเริ่มระวังมากขึ้นเวลาเลือกใกล้ชิดกับใคร'),
          ],
        );
      case LifeMapClaimDomain.familyHome:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_home',
              'คนในบ้านมีผลต่อชีวิตคุณมาก',
            ),
            _TextId(
              'sit_home2',
              'หน้าที่ในบ้านเปลี่ยนไป และคุณต้องพึ่งคนใกล้ตัวมากขึ้น',
            ),
          ],
          pressures: [
            _TextId('prs_home', 'คุณต้องทำตามความคาดหวังของผู้ใหญ่'),
            _TextId(
              'prs_home2',
              'คุณมีหน้าที่ในบ้านมากขึ้นจนเวลาส่วนตัวเหลือน้อย',
            ),
          ],
          contexts: [
            _TextId(
              'ctx_home',
              'ก่อนหน้านั้นชีวิตในบ้านยังเดินตามแบบเดิมที่คุณคุ้นเคย',
            ),
          ],
          lingerings: [
            _TextId(
              'ling_home',
              'เรื่องบ้านยังติดอยู่ในใจและมีผลต่อทางเลือกของคุณต่อมา',
            ),
          ],
        );
      case LifeMapClaimDomain.healthEnergy:
        return _DomainPack(
          situations: [
            _TextId('sit_health', 'ร่างกายและใจถูกใช้จนสุดแรง'),
            _TextId('sit_health2', 'คุณต้องลดภาระบางอย่างเพื่อรักษาแรงไว้'),
          ],
          pressures: [
            _TextId('prs_health', 'คุณฝืนตัวเองจนสะสมความล้า'),
            _TextId('prs_health2', 'คุณมีหน้าที่หลายอย่าง จนแทบไม่มีเวลาพัก'),
          ],
          contexts: [
            _TextId(
              'ctx_health',
              'ก่อนหน้านั้นคุณยังผลักดันตัวเองได้โดยไม่รู้สึกหมดแรงง่าย',
            ),
          ],
          lingerings: [
            _TextId(
              'ling_health',
              'คุณเริ่มรู้ว่าต้องรักษาแรงไว้ ไม่ใช่ผลักทุกเรื่องพร้อมกัน',
            ),
          ],
        );
      case LifeMapClaimDomain.identityBelonging:
        return _DomainPack(
          situations: [
            _TextId('sit_id', 'คุณต้องหาที่ยืนในกลุ่มและแสดงออกให้คนอื่นเห็น'),
            _TextId(
              'sit_id2',
              'คุณถูกผลักให้เลือกทางของตัวเองท่ามกลางคนรอบตัว',
            ),
          ],
          pressures: [
            _TextId('prs_id', 'คุณเปรียบเทียบตัวเองกับคนรอบตัวบ่อย'),
            _TextId('prs_id2', 'คุณอยากเป็นตัวเอง แต่ก็ยังอยากให้คนอื่นยอมรับ'),
          ],
          contexts: [
            _TextId(
              'ctx_id',
              'ก่อนหน้านั้นคุณยังหาที่ยืนในกลุ่มแบบค่อยเป็นค่อยไป',
            ),
          ],
          lingerings: [
            _TextId(
              'ling_id',
              'คุณเริ่มกล้าเลือกทางของตัวเองมากขึ้นแม้คนรอบตัวจะมองต่าง',
            ),
          ],
        );
      case LifeMapClaimDomain.learningPath:
        return _DomainPack(
          situations: [
            _TextId('sit_learn', 'การเรียนและการฝึกฝนกินเวลาส่วนใหญ่ของคุณ'),
            _TextId(
              'sit_learn2',
              'คุณต้องเลือกทางที่ถนัดท่ามกลางความคาดหวังของคนรอบตัว',
            ),
          ],
          pressures: [
            _TextId(
              'prs_learn',
              'ผลงานเรียนถูกนำไปเปรียบกับคนอื่น',
            ),
            _TextId(
              'prs_learn2',
              'สิ่งที่ถนัดกับสิ่งที่คนรอบตัวคาดหวังไม่ตรงกัน',
            ),
          ],
          contexts: [
            _TextId(
              'ctx_learn',
              'ก่อนหน้านั้นการเรียนยังเป็นแค่ส่วนหนึ่งของวัน',
            ),
          ],
          lingerings: [
            _TextId(
              'ling_learn',
              'คุณเริ่มรู้ว่าต้องเลือกทางที่ถนัด ไม่ใช่ทำทุกอย่างตามที่คนอื่นอยาก',
            ),
          ],
        );
      case LifeMapClaimDomain.dutyBurden:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_duty',
              'หน้าที่และความรับผิดชอบเพิ่มขึ้นจนเลือกทางอื่นได้ยาก',
            ),
            _TextId('sit_duty2', 'คุณต้องรับภาระที่หลีกเลี่ยงไม่ได้'),
          ],
          pressures: [
            _TextId('prs_duty', 'มีภาระที่ต้องทำแม้จะไม่อยากรับ'),
            _TextId(
              'prs_duty2',
              'คุณต้องทำหน้าที่ก่อน ทั้งที่อยากมีเวลาให้ตัวเอง',
            ),
          ],
          contexts: [
            _TextId('ctx_duty', 'ก่อนหน้านั้นภาระของคุณยังไม่หนักเท่านี้'),
          ],
          lingerings: [
            _TextId(
              'ling_duty',
              'คุณเริ่มจัดลำดับว่าอะไรต้องรับ และอะไรปล่อยได้',
            ),
          ],
        );
      case LifeMapClaimDomain.transitionRebuild:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_trans',
              'ชีวิตที่เคยคุ้นเคยเปลี่ยน และคุณต้องแยกจากวิธีเดิม',
            ),
            _TextId(
              'sit_trans2',
              'บทหนึ่งจบลง และคุณต้องสร้างทางใหม่ด้วยตัวเอง',
            ),
          ],
          pressures: [
            _TextId('prs_trans', 'คุณเสียความคุ้นเคยไปทั้งที่ฐานใหม่ยังไม่ชัด'),
            _TextId(
              'prs_trans2',
              'คุณยังอยากยึดของเดิม แต่ก็รู้ว่าต้องเดินต่อ',
            ),
          ],
          contexts: [
            _TextId(
              'ctx_trans',
              'ก่อนหน้านั้นชีวิตยังอยู่ในกรอบที่คุณรู้จักดี',
            ),
          ],
          lingerings: [
            _TextId(
              'ling_trans',
              'คุณเริ่มยอมรับว่าต้องสร้างทางใหม่ แม้ยังไม่สมบูรณ์',
            ),
          ],
        );
      case LifeMapClaimDomain.opportunityExpand:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_opp',
              'มีโอกาสใหม่เข้ามาจากงานหรือคนรู้จัก',
            ),
            _TextId(
              'sit_opp2',
              'มีทางเลือกมากขึ้น แต่ทุกทางแลกด้วยหน้าที่ที่เพิ่มขึ้น',
            ),
          ],
          pressures: [
            _TextId('prs_opp', 'คุณรับทุกโอกาสไว้จนโฟกัสกระจาย'),
            _TextId('prs_opp2', 'ทางเลือกเยอะจนเลือกลำดับความสำคัญได้ยาก'),
          ],
          contexts: [
            _TextId(
              'ctx_opp',
              'ก่อนหน้านั้นโอกาสใหม่ยังเข้ามาน้อยและคุณยังโฟกัสเรื่องเดิมได้',
            ),
          ],
          lingerings: [
            _TextId(
              'ling_opp',
              'คุณเริ่มเลือกโอกาสที่สำคัญจริง ๆ แทนการรับทุกอย่าง',
            ),
          ],
        );
    }
  }
}

enum _ClaimRole { situation, pressure, consequence }

enum _TransitionKind {
  forcedReorder,
  separateRebuild,
  lockStability,
  expandRole,
  commitAction,
  rebindRelations,
  seekRecognition,
  restoreBalance,
  skillBuild,
}

class _TextId {
  const _TextId(this.id, this.text);
  final String id;
  final String text;
}

class _DomainPack {
  const _DomainPack({
    required this.situations,
    required this.pressures,
    required this.contexts,
    required this.lingerings,
  });
  final List<_TextId> situations;
  final List<_TextId> pressures;
  final List<_TextId> contexts;
  final List<_TextId> lingerings;
}
