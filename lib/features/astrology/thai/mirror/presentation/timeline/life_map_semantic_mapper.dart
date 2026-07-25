import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

import 'life_map_verdict_semantics.dart';
import 'period_composite_score.dart';
import 'thai_life_stage_context.dart';

/// Deterministic mapping from period evidence → falsifiable life claims.
///
/// Uses only planet affinity, composite scores, keyword/essence already on
/// [LifePlanetData], and age band. Does not invent Canon events.
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

    // Pressure uses a different domain when possible to avoid slot paraphrase.
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

    return LifeMapVerdictSemantics(
      tense: tense,
      primary: primary,
      secondary: secondary,
      pressure: pressure.semanticKey == primary.semanticKey ? null : pressure,
      consequence: consequence.semanticKey == primary.semanticKey
          ? null
          : consequence,
    );
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
    final cons = _consequence(tense, domain, transition, variant);

    switch (role) {
      case _ClaimRole.situation:
        return LifeMapVerdictClaim(
          tense: tense,
          situationId: sit.id,
          domain: domain,
          pressureId: press.id,
          consequenceId: cons.id,
          situationTh: _frameSituation(tense, sit.text),
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

  static String _frameSituation(LifeMapVerdictTense tense, String body) {
    switch (tense) {
      case LifeMapVerdictTense.past:
        return 'ช่วงนั้น$body';
      case LifeMapVerdictTense.current:
        return 'ขณะนี้$body';
      case LifeMapVerdictTense.future:
        return 'ช่วงถัดไป$body';
    }
  }

  static _TextId _consequence(
    LifeMapVerdictTense tense,
    LifeMapClaimDomain domain,
    _TransitionKind transition,
    int variant,
  ) {
    final domainLabel = domain.labelTh;
    final lines = switch (transition) {
      _TransitionKind.forcedReorder => [
        _TextId(
          'cons_reorder',
          'ผลที่ตามมาคือคุณต้องจัดลำดับ$domainLabelใหม่และตัดสิ่งที่ไม่สร้างผลระยะยาวออก',
        ),
        _TextId(
          'cons_reorder2',
          'ชีวิตหลังจากนี้ให้ความสำคัญกับ$domainLabelมาก่อนความสบายใจชั่วคราว',
        ),
      ],
      _TransitionKind.separateRebuild => [
        _TextId(
          'cons_rebuild',
          'ผลที่ตามมาคือคุณแยกจากวิธีเดิมด้าน$domainLabelและสร้างหลักของตัวเองขึ้นใหม่',
        ),
        _TextId(
          'cons_rebuild2',
          'เส้นทางด้าน$domainLabelไม่กลับไปรูปแบบเดิม และเป้าหมายระยะยาวเปลี่ยนชัด',
        ),
      ],
      _TransitionKind.lockStability => [
        _TextId(
          'cons_lock',
          'ผลที่ตามมาคือการตัดสินใจด้าน$domainLabelยึดความมั่นคงไว้ก่อนความต้องการส่วนตัว',
        ),
        _TextId(
          'cons_lock2',
          'ภาระด้าน$domainLabelจำกัดทางเลือกอื่น และคุณต้องรับหน้าที่ที่หลีกเลี่ยงไม่ได้',
        ),
      ],
      _TransitionKind.expandRole => [
        _TextId(
          'cons_expand',
          'ผลที่ตามมาคือบทบาทด้าน$domainLabelขยาย และความรับผิดชอบเพิ่มขึ้นตามโอกาสที่เข้ามา',
        ),
        _TextId(
          'cons_expand2',
          'คุณออกจากกรอบเดิมด้าน$domainLabel และตัดสินใจด้วยตัวเองมากขึ้น',
        ),
      ],
      _TransitionKind.commitAction => [
        _TextId(
          'cons_act',
          'ผลที่ตามมาคือคุณต้องลงมือตัดสินใจด้าน$domainLabelแทนการเลื่อนปัญหาไว้',
        ),
        _TextId(
          'cons_act2',
          'ทิศทางด้าน$domainLabelถูกกำหนดจากการเลือกในช่วงนี้ และแยกจากทางเก่า',
        ),
      ],
      _TransitionKind.rebindRelations => [
        _TextId(
          'cons_rel',
          'ผลที่ตามมาคือรูปแบบความสัมพันธ์และขอบเขตด้าน$domainLabelถูกตั้งใหม่',
        ),
        _TextId(
          'cons_rel2',
          'คุณต้องสื่อสารและรับผิดชอบผลของความใกล้ชิดด้าน$domainLabelชัดขึ้น',
        ),
      ],
      _TransitionKind.seekRecognition => [
        _TextId(
          'cons_recog',
          'ผลที่ตามมาคือ$domainLabelถูกมองเห็นชัดขึ้น และบทบาทเปลี่ยนตาม',
        ),
        _TextId(
          'cons_recog2',
          'ผลที่ตามมาคือคุณต้องรับความคาดหวังใหม่ด้าน$domainLabelและรักษาสมดุลกับชีวิตส่วนตัว',
        ),
      ],
      _TransitionKind.restoreBalance => [
        _TextId(
          'cons_bal',
          'ผลที่ตามมาคือคุณต้องคืนสมดุลด้าน$domainLabelก่อนเร่งผลลัพธ์อื่น',
        ),
        _TextId(
          'cons_bal2',
          'ผลที่ตามมาคือชีวิตถูกปรับให้$domainLabelอยู่ได้โดยไม่เสียสุขภาพและที่พึ่ง',
        ),
      ],
      _TransitionKind.skillBuild => [
        _TextId(
          'cons_skill',
          'ผลที่ตามมาคือทักษะและวินัยด้าน$domainLabelถูกหล่อจนใช้ต่อได้จริง',
        ),
        _TextId(
          'cons_skill2',
          'คุณเลือกทางที่ถนัดด้าน$domainLabelชัดขึ้น และรับขอบเขตจากสภาพจริง',
        ),
      ],
    };
    final picked = lines[variant.abs() % lines.length];
    if (tense == LifeMapVerdictTense.future) {
      final body = picked.text.startsWith('ผลที่ตามมาคือ')
          ? picked.text.substring('ผลที่ตามมาคือ'.length)
          : picked.text;
      return _TextId(picked.id, 'สภาพใหม่ที่ตามมาคือ$body');
    }
    if (tense == LifeMapVerdictTense.past) {
      final body = picked.text.startsWith('ผลที่ตามมาคือคุณต้อง')
          ? picked.text.replaceFirst(
              'ผลที่ตามมาคือคุณต้อง',
              'ผลของช่วงนั้นทำให้คุณ',
            )
          : picked.text.startsWith('ผลที่ตามมาคือ')
          ? picked.text.replaceFirst('ผลที่ตามมาคือ', 'ผลของช่วงนั้นคือ')
          : 'ผลของช่วงนั้นคือ${picked.text}';
      return _TextId(picked.id, body);
    }
    return picked;
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
                    'ความคาดหวังเรื่องผลงานหรือทิศทางอนาคตถูกบังคับให้เลือกจริง',
                  ),
                  _TextId(
                    'sit_work_youth2',
                    'บทบาทในโรงเรียน กิจกรรม หรืองานเล็ก ๆ กำหนดเวลาทั้งวัน',
                  ),
                ]
              : [
                  _TextId(
                    'sit_work',
                    'ภาระงานและหน้าที่ในที่ทำงานบังคับให้จัดลำดับชีวิตใหม่',
                  ),
                  _TextId(
                    'sit_work2',
                    'บทบาทหรือขอบเขตงานที่เคยคุ้นเคยเปลี่ยน และต้องรับผิดชอบผลเอง',
                  ),
                ],
          pressures: [
            _TextId(
              'prs_work',
              'แรงกดดันหลักคือการแบกงานไว้หลายเรื่องจนเวลาและพลังถูกแบ่ง',
            ),
            _TextId(
              'prs_work2',
              'ความขัดแย้งหลักอยู่ที่ผลงานกับชีวิตส่วนตัวที่รับพร้อมกันไม่ไหว',
            ),
          ],
        );
      case LifeMapClaimDomain.moneySecurity:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_money',
              'ภาระรายจ่ายหรือข้อผูกมัดทางการเงินจำกัดทางเลือกอื่นของชีวิต',
            ),
            _TextId(
              'sit_money2',
              'การสร้างฐานสำรองและความมั่นคงทางทรัพย์สินกลายเป็นเกณฑ์ตัดสินใจหลัก',
            ),
          ],
          pressures: [
            _TextId(
              'prs_money',
              'แรงกดดันหลักคือต้องตัดสินใจเรื่องเงินภายใต้เวลาและข้อจำกัดที่มี',
            ),
            _TextId(
              'prs_money2',
              'ความขัดแย้งหลักอยู่ที่การใช้จ่ายระยะสั้นกับแผนความมั่นคงระยะยาว',
            ),
          ],
        );
      case LifeMapClaimDomain.relationshipBond:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_love',
              'ความสัมพันธ์ใกล้ชิดถูกทดสอบเรื่องขอบเขต ความจริงใจ และการอยู่ร่วม',
            ),
            _TextId(
              'sit_love2',
              'รูปแบบการผูกพันเปลี่ยน และคุณต้องรับผิดชอบผลของการเลือกใกล้ชิด',
            ),
          ],
          pressures: [
            _TextId(
              'prs_love',
              'แรงกดดันหลักคือคาดหวังเงียบ ๆ โดยไม่สื่อสารจนเกิดระยะห่าง',
            ),
            _TextId(
              'prs_love2',
              'ความขัดแย้งหลักอยู่ที่ความต้องการใกล้ชิดกับความต้องการมีพื้นที่ส่วนตัว',
            ),
          ],
        );
      case LifeMapClaimDomain.familyHome:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_home',
              'บ้าน ครอบครัว หรือสภาพแวดล้อมใกล้ตัวเปลี่ยน และบังคับให้ปรับกิจวัตร',
            ),
            _TextId(
              'sit_home2',
              'บทบาทในบ้านถูกจัดใหม่ และความมั่นคงทางใจผูกกับที่พึ่งใกล้ตัว',
            ),
          ],
          pressures: [
            _TextId(
              'prs_home',
              'แรงกดดันหลักคือความไม่สม่ำเสมอของการดูแลหรือกฎในบ้าน',
            ),
            _TextId(
              'prs_home2',
              'ความขัดแย้งหลักอยู่ที่หน้าที่ในบ้านกับความต้องการส่วนตัว',
            ),
          ],
        );
      case LifeMapClaimDomain.healthEnergy:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_health',
              'พลังกายและใจถูกใช้จนสุด และบังคับให้ปรับจังหวะพักกับงาน',
            ),
            _TextId(
              'sit_health2',
              'ข้อจำกัดของร่างกายทำให้ต้องลดภาระบางอย่างเพื่อรักษาพลังงาน',
            ),
          ],
          pressures: [
            _TextId('prs_health', 'แรงกดดันหลักคือการฝืนตัวเองจนสะสมความล้า'),
            _TextId(
              'prs_health2',
              'ความขัดแย้งหลักอยู่ที่ภาระที่มีกับเวลาพักที่ร่างกายต้องการจริง',
            ),
          ],
        );
      case LifeMapClaimDomain.identityBelonging:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_id',
              'การหาที่ยืนในกลุ่มและการแสดงออกถูกทดสอบจนกระทบความมั่นใจ',
            ),
            _TextId(
              'sit_id2',
              'ตัวตนถูกผลักให้เลือกทางของตนเองภายใต้ความคาดหวังรอบข้าง',
            ),
          ],
          pressures: [
            _TextId('prs_id', 'แรงกดดันหลักคือการเปรียบเทียบตัวเองกับคนรอบตัว'),
            _TextId(
              'prs_id2',
              'ความขัดแย้งหลักอยู่ที่อยากเป็นตัวเองกับอยากได้รับการยอมรับ',
            ),
          ],
        );
      case LifeMapClaimDomain.learningPath:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_learn',
              'การเรียน ทักษะ หรือการฝึกฝนกลายเป็นเวทีหลักที่กำหนดวันเวลา',
            ),
            _TextId(
              'sit_learn2',
              'ความคาดหวังของผู้ใหญ่และการหาที่ยืนในกลุ่มเพื่อนบังคับให้เลือกทางที่ถนัด',
            ),
          ],
          pressures: [
            _TextId(
              'prs_learn',
              'แรงกดดันหลักคือผลงานเรียนหรือทักษะที่ถูกเปรียบเทียบ',
            ),
            _TextId(
              'prs_learn2',
              'ความขัดแย้งหลักอยู่ที่สิ่งที่ถนัดกับสิ่งที่คนรอบตัวคาดหวัง',
            ),
          ],
        );
      case LifeMapClaimDomain.dutyBurden:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_duty',
              'หน้าที่และความรับผิดชอบเพิ่มขึ้นจนจำกัดทางเลือกอื่นของชีวิต',
            ),
            _TextId(
              'sit_duty2',
              'คุณต้องรับภาระที่หลีกเลี่ยงไม่ได้และจัดชีวิตให้รับน้ำหนักนั้นได้',
            ),
          ],
          pressures: [
            _TextId('prs_duty', 'แรงกดดันหลักคือภาระที่ต้องทำแม้จะไม่อยากรับ'),
            _TextId(
              'prs_duty2',
              'ความขัดแย้งหลักอยู่ที่หน้าที่กับความต้องการส่วนตัว',
            ),
          ],
        );
      case LifeMapClaimDomain.transitionRebuild:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_trans',
              'โครงสร้างชีวิตที่เคยคุ้นเคยเปลี่ยน และคุณต้องแยกจากวิธีเดิม',
            ),
            _TextId(
              'sit_trans2',
              'บทบาทหรือสภาพแวดล้อมปิดบทหนึ่งและเปิดบทใหม่ที่ต้องสร้างเอง',
            ),
          ],
          pressures: [
            _TextId(
              'prs_trans',
              'แรงกดดันหลักคือการสูญเสียความคุ้นเคยโดยยังไม่มีฐานใหม่ชัด',
            ),
            _TextId(
              'prs_trans2',
              'ความขัดแย้งหลักอยู่ที่อยากยึดของเดิมกับความจำเป็นต้องเดินต่อ',
            ),
          ],
        );
      case LifeMapClaimDomain.opportunityExpand:
        return _DomainPack(
          situations: [
            _TextId(
              'sit_opp',
              'โอกาสใหม่ด้านงาน รายได้ หรือบทบาทเข้ามาผ่านผลงานหรือเครือข่ายที่สะสม',
            ),
            _TextId(
              'sit_opp2',
              'ทางเลือกขยาย แต่ทุกโอกาสแลกด้วยความรับผิดชอบที่เพิ่มขึ้น',
            ),
          ],
          pressures: [
            _TextId('prs_opp', 'แรงกดดันหลักคือการรับทุกโอกาสไว้จนโฟกัสกระจาย'),
            _TextId(
              'prs_opp2',
              'ความขัดแย้งหลักอยู่ที่ทางเลือกมากมายกับลำดับความสำคัญของช่วงนี้',
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
  const _DomainPack({required this.situations, required this.pressures});
  final List<_TextId> situations;
  final List<_TextId> pressures;
}
