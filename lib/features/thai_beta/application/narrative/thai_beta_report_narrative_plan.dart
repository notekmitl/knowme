/// V1.5 R6 report-level narrative authority.
///
/// This plan works from the complete forecast material before consumer prose
/// is written. It selects at most two motifs, assigns a different job to each
/// horizon, and keeps the Unknown-time evidence boundary at report level.
library;

import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';

import 'thai_beta_narrative_context.dart';

enum ThaiBetaReportMotifRole { primary, boundary, supporting }

class ThaiBetaReportNarrativePlan {
  const ThaiBetaReportNarrativePlan({
    required this.primary,
    required this.secondary,
    required this.themeId,
    required this.lifePeriodLabel,
    required this.evidenceAvailability,
    required this.materialsByDomain,
  });

  factory ThaiBetaReportNarrativePlan.fromPrediction({
    required PredictionSectionModel? prediction,
    required ThaiBetaNarrativeContext context,
  }) {
    final materials =
        prediction?.windows
            .expand((window) => window.domains)
            .map((domain) => domain.material)
            .whereType<ForecastMaterialFingerprint>()
            .toList(growable: false) ??
        const <ForecastMaterialFingerprint>[];
    final byDomain = <ForecastDomain, List<ForecastMaterialFingerprint>>{
      for (final domain in ForecastDomain.values)
        domain: materials
            .where((material) => material.domain == domain)
            .toList(growable: false),
    };
    final scores = <ForecastDomain, int>{
      for (final domain in ForecastDomain.values)
        domain: byDomain[domain]!.fold<int>(
          0,
          (total, material) =>
              total +
              switch (material.band) {
                ForecastBand.strong => 5,
                ForecastBand.active => 3,
                ForecastBand.quiet => 1,
              },
        ),
    };
    final themeId = context.orderedThemeIds.isEmpty
        ? 'grounded'
        : context.orderedThemeIds.first;
    final preferred = _themeDomain(themeId);
    final ranked = ForecastDomain.values.toList()
      ..sort((left, right) {
        final byScore = scores[right]!.compareTo(scores[left]!);
        if (byScore != 0) return byScore;
        if (left == preferred) return -1;
        if (right == preferred) return 1;
        return left.index.compareTo(right.index);
      });
    final primary = ranked.first;

    final riskFrequency = <ForecastDomain, int>{
      for (final domain in ForecastDomain.values) domain: 0,
    };
    for (final material in materials) {
      final risk = _forecastDomainForRisk(material.consumerRiskDomain);
      if (risk != null) riskFrequency[risk] = riskFrequency[risk]! + 1;
    }
    final secondaryCandidates =
        ForecastDomain.values.where((domain) => domain != primary).toList()
          ..sort((left, right) {
            final byRisk = riskFrequency[right]!.compareTo(
              riskFrequency[left]!,
            );
            if (byRisk != 0) return byRisk;
            final byLowScore = scores[left]!.compareTo(scores[right]!);
            if (byLowScore != 0) return byLowScore;
            return left.index.compareTo(right.index);
          });
    final secondary = secondaryCandidates.first;
    final availability =
        materials.any(
          (material) =>
              material.evidenceAvailability ==
              ForecastEvidenceAvailability.noLagna,
        )
        ? ForecastEvidenceAvailability.noLagna
        : ForecastEvidenceAvailability.full;

    return ThaiBetaReportNarrativePlan(
      primary: primary,
      secondary: secondary,
      themeId: themeId,
      lifePeriodLabel: context.lifePeriodLabel?.trim() ?? '',
      evidenceAvailability: availability,
      materialsByDomain:
          Map<ForecastDomain, List<ForecastMaterialFingerprint>>.unmodifiable({
            for (final entry in byDomain.entries)
              entry.key: List<ForecastMaterialFingerprint>.unmodifiable(
                entry.value,
              ),
          }),
    );
  }

  final ForecastDomain primary;
  final ForecastDomain secondary;
  final String themeId;
  final String lifePeriodLabel;
  final ForecastEvidenceAvailability evidenceAvailability;
  final Map<ForecastDomain, List<ForecastMaterialFingerprint>>
  materialsByDomain;

  bool get isUnknownTime =>
      evidenceAvailability == ForecastEvidenceAvailability.noLagna;

  ThaiBetaReportMotifRole roleFor(ForecastDomain domain) => domain == primary
      ? ThaiBetaReportMotifRole.primary
      : domain == secondary
      ? ThaiBetaReportMotifRole.boundary
      : ThaiBetaReportMotifRole.supporting;

  ForecastBand bandFor(ForecastDomain domain, ForecastHorizon horizon) {
    for (final material in materialsByDomain[domain] ?? const []) {
      if (material.horizon == horizon) return material.band;
    }
    return ForecastBand.active;
  }

  String get materialIdentity => [
    'theme=$themeId',
    'period=${lifePeriodLabel.isEmpty ? 'unspecified' : lifePeriodLabel}',
    'availability=${evidenceAvailability.name}',
    'primary=${primary.name}',
    'secondary=${secondary.name}',
    for (final domain in ForecastDomain.values)
      '${domain.name}=${ForecastHorizon.values.map((horizon) => bandFor(domain, horizon).name).join('/')}',
  ].join('|');

  String get headline {
    if (isUnknownTime) {
      return 'ให้สิ่งที่เกิดซ้ำจริงนำทาง ก่อนขยับ${domainLabel(primary)}';
    }
    if (lifePeriodLabel.contains('เก็บเกี่ยว')) {
      return '${domainLabel(primary)}จะไปต่อได้ เมื่อ${boundaryLabel(secondary)}';
    }
    if (lifePeriodLabel.contains('เรียนรู้')) {
      return 'ให้${domainLabel(primary)}พิสูจน์ผลจริง ก่อนรับภาระเพิ่ม';
    }
    if (lifePeriodLabel.contains('พลิกผัน') ||
        lifePeriodLabel.contains('เปลี่ยนผ่าน')) {
      return 'ช่วงเปลี่ยนผ่านนี้ต้องจัด${domainLabel(primary)}กับ${domainLabel(secondary)}ให้อยู่ทางเดียวกัน';
    }
    return 'จังหวะนี้ต้องเลือก${domainLabel(primary)}โดยไม่ทิ้ง${domainLabel(secondary)}';
  }

  String get hook {
    final phase = lifePeriodLabel.isEmpty ? 'จังหวะปัจจุบัน' : lifePeriodLabel;
    if (isUnknownTime) {
      return 'ใน$phase ${domainLabel(primary)}ควรถูกตัดสินจากรูปแบบที่เกิดซ้ำจริง '
          'ขณะที่${domainLabel(secondary)}ทำหน้าที่บอกขอบเขตของทางเลือกนั้น '
          'หากรีบสรุปจากเหตุการณ์ครั้งเดียว คุณอาจผูกตัวเองกับทางที่ยังไม่มีหลักฐานพอ '
          '${decisionQuestion(primary, secondary)}';
    }

    final primaryDirection = _primaryDirection();
    final secondaryPressure = _secondaryPressure();
    return 'ใน$phase ${strengthLabel(themeId)}กลายเป็นแรงสำคัญของ${domainLabel(primary)} '
        '$primaryDirection $secondaryPressure '
        '${decisionQuestion(primary, secondary)}';
  }

  String summaryFor(ForecastHorizon horizon) {
    final phase = lifePeriodLabel.isEmpty ? 'ช่วงนี้' : lifePeriodLabel;
    return switch (horizon) {
      ForecastHorizon.current =>
        'ตอนนี้${strengthLabel(themeId)}ทำให้คุณต้องตัดสินใจเรื่อง${domainLabel(primary)}หนึ่งเรื่อง ขอบเขตตรวจของ$phaseคือ${observableLabel(secondary)}',
      ForecastHorizon.next12Months =>
        'ตลอด 12 เดือนของ$phase ให้${strengthLabel(themeId)}เฝ้า${triggerLabel(primary)}เป็นจุดกระตุ้นหลัก และนัดทบทวนเมื่อ${checkpointLabel(secondary)}',
      ForecastHorizon.nextLifePeriod =>
        'หลังพ้น$phase ${strengthLabel(themeId)}จะถูกใช้คัดสิ่งที่ควรรักษา ทิศทางหลักและผลระยะยาวจึงวัดจาก${longTermOutcome(primary)}โดยไม่เสีย${longTermOutcome(secondary)}',
    };
  }

  String get transitionLine {
    final phase = lifePeriodLabel.isEmpty ? 'จังหวะนี้' : lifePeriodLabel;
    return isUnknownTime
        ? 'จาก$phaseไปข้างหน้า ให้เพิ่มน้ำหนักเฉพาะรูปแบบที่เกิดซ้ำและตรวจสอบได้'
        : '$phaseไม่ได้ขอให้เร่งทุกด้านพร้อมกัน แต่ให้${strengthLabel(themeId)}พา${domainLabel(primary)}เดินหน้าเท่าที่${observableLabel(secondary)}ยังรองรับ';
  }

  String get evidenceBoundary => isUnknownTime
      ? 'รายงานนี้ไม่มีเวลาเกิด จึงไม่มีหลักฐานลัคนา เรือน หรือจังหวะที่ต้องอาศัยเวลาเกิดสำหรับฟันธง คำอ่านต่อไปนี้ใช้สิ่งที่สังเกตได้จริงเป็นหลัก'
      : '';

  String supportingContext(ForecastDomain domain, ForecastHorizon horizon) {
    final role = roleFor(domain);
    final phase = lifePeriodLabel.isEmpty ? 'ช่วงนี้' : lifePeriodLabel;
    final profileCue = isUnknownTime ? 'ตามรูปแบบที่เกิดซ้ำ' : 'ใน$phase';
    return switch ((horizon, role)) {
      (ForecastHorizon.current, ThaiBetaReportMotifRole.primary) =>
        'นี่คือแกนตัดสินใจ$profileCue คำถามตรวจคือ${currentEvidence(domain)}',
      (ForecastHorizon.current, ThaiBetaReportMotifRole.boundary) =>
        'ด้านนี้เป็นเส้นขอบของ${domainLabel(primary)} จึงต้องดูว่า${currentEvidence(domain)}',
      (ForecastHorizon.current, ThaiBetaReportMotifRole.supporting) =>
        supportingCurrentContext(domain, phase),
      (ForecastHorizon.next12Months, ThaiBetaReportMotifRole.primary) =>
        'เมื่อถึง${checkpointLabel(domain)} ให้เลือกว่าจะขยายทางเดิมหรือปรับแผนของ$phase',
      (ForecastHorizon.next12Months, ThaiBetaReportMotifRole.boundary) =>
        'ถ้า${checkpointLabel(domain)}ยังไม่ผ่าน ให้ลดขนาดแผน${domainLabel(primary)}ก่อนเพิ่มภาระ',
      (ForecastHorizon.next12Months, ThaiBetaReportMotifRole.supporting) =>
        supportingCheckpointContext(domain, primary),
      (ForecastHorizon.nextLifePeriod, ThaiBetaReportMotifRole.primary) =>
        'หลัง$phase ให้${domainLabel(domain)}คัดว่าประสบการณ์ใดควรรักษาและสิ่งใดควรส่งต่อ',
      (ForecastHorizon.nextLifePeriod, ThaiBetaReportMotifRole.boundary) =>
        '${longTermOutcome(domain)}จะเป็นเงื่อนไขว่าทิศทาง${domainLabel(primary)}ไปต่อได้นานเพียงใด',
      (ForecastHorizon.nextLifePeriod, ThaiBetaReportMotifRole.supporting) =>
        supportingLongTermContext(domain, primary),
    };
  }

  String get closing => isUnknownTime
      ? 'การตัดสินใจเดียวของรายงานนี้คือ เลือก${domainLabel(primary)}จากผลที่เกิดซ้ำ และยังไม่ผูกมัดเพิ่มจนกว่า${observableLabel(secondary)}จะยืนยันได้'
      : 'การตัดสินใจเดียวของ${lifePeriodLabel.isEmpty ? 'ช่วงนี้' : lifePeriodLabel}คือ เลือกทาง${domainLabel(primary)}ที่ทำให้${decisionBoundary(primary)} พร้อมรักษา${observableLabel(secondary)}ไว้';

  String _primaryDirection() {
    final current = bandFor(primary, ForecastHorizon.current);
    final next = bandFor(primary, ForecastHorizon.nextLifePeriod);
    if (current == ForecastBand.strong && next == ForecastBand.strong) {
      return '${domainLabel(primary)}มีแรงส่งต่อเนื่องจากตอนนี้ไปถึงช่วงถัดไป';
    }
    if (current == ForecastBand.strong && next != ForecastBand.strong) {
      return '${domainLabel(primary)}เดินหน้าได้ในระยะใกล้ และช่วงถัดไปต้องคัดสิ่งที่จะรักษาไว้';
    }
    if (next == ForecastBand.quiet) {
      return '${domainLabel(primary)}ควรเริ่มจากการจัดฐานเดิมให้แน่นก่อนขยาย';
    }
    return '${domainLabel(primary)}ขยับได้เมื่อผลจริงยืนยันว่าฐานเดิมยังรับไหว';
  }

  String _secondaryPressure() {
    final next = bandFor(secondary, ForecastHorizon.nextLifePeriod);
    if (next == ForecastBand.quiet) {
      return 'ขณะเดียวกัน ${domainLabel(secondary)}จะเปราะบางขึ้นเมื่อภาระชุดใหม่เข้ามา';
    }
    if (next == ForecastBand.strong) {
      return 'ขณะเดียวกัน ${domainLabel(secondary)}จะกลายเป็นแรงกำหนดทิศทางของช่วงใหม่';
    }
    return 'ขณะเดียวกัน ${domainLabel(secondary)}ต้องมีขอบเขตที่ทำต่อได้จริง';
  }

  static String domainLabel(ForecastDomain domain) => switch (domain) {
    ForecastDomain.career => 'งาน',
    ForecastDomain.finance => 'การเงิน',
    ForecastDomain.relationship => 'ความสัมพันธ์',
    ForecastDomain.health => 'การพักและการฟื้นตัว',
  };

  static String boundaryLabel(ForecastDomain domain) => switch (domain) {
    ForecastDomain.career => 'งานหลักยังมีคุณภาพ',
    ForecastDomain.finance => 'เงินพร้อมใช้ยังพอ',
    ForecastDomain.relationship => 'ข้อตกลงยังชัดและทำได้จริง',
    ForecastDomain.health => 'ร่างกายยังฟื้นทัน',
  };

  static String triggerLabel(ForecastDomain domain) => switch (domain) {
    ForecastDomain.career => 'ขอบเขตหน้าที่ที่เปลี่ยนไป',
    ForecastDomain.finance => 'ยอดคงเหลือที่เปลี่ยนต่อเนื่อง',
    ForecastDomain.relationship => 'คำพูดที่กลายเป็นพฤติกรรมสม่ำเสมอ',
    ForecastDomain.health => 'เวลาฟื้นตัวหลังสัปดาห์หนัก',
  };

  static String observableLabel(ForecastDomain domain) => switch (domain) {
    ForecastDomain.career => 'คุณภาพของงานชิ้นหลัก',
    ForecastDomain.finance => 'เงินคงเหลือหลังค่าใช้จ่ายจำเป็น',
    ForecastDomain.relationship => 'พฤติกรรมที่ทำตามคำตกลง',
    ForecastDomain.health => 'การนอนและเวลาที่ใช้คืนแรง',
  };

  static String currentEvidence(ForecastDomain domain) => switch (domain) {
    ForecastDomain.career =>
      'งานชิ้นหลักยังได้มาตรฐานหลังรับหน้าที่ใหม่หรือไม่',
    ForecastDomain.finance => 'ยอดพร้อมใช้ยังเหลือหลังจ่ายรายการจำเป็นหรือไม่',
    ForecastDomain.relationship => 'สิ่งที่ตกลงกันถูกทำจริงต่อเนื่องหรือไม่',
    ForecastDomain.health => 'ตื่นแล้วมีแรงกลับมาตามปกติหรือไม่',
  };

  static String checkpointLabel(ForecastDomain domain) => switch (domain) {
    ForecastDomain.career => 'รอบส่งมอบงานกลางปี',
    ForecastDomain.finance => 'วันที่สรุปยอดคงเหลือรายไตรมาส',
    ForecastDomain.relationship => 'การทบทวนข้อตกลงหลังเห็นพฤติกรรมซ้ำ',
    ForecastDomain.health => 'เดือนที่เวลาฟื้นตัวไม่ยาวกว่าเดิม',
  };

  static String longTermOutcome(ForecastDomain domain) => switch (domain) {
    ForecastDomain.career => 'งานที่ใช้ประสบการณ์ได้เต็มที่',
    ForecastDomain.finance => 'ฐานเงินที่รองรับการเปลี่ยนบทบาท',
    ForecastDomain.relationship => 'ความสัมพันธ์ที่แบ่งเวลาและหน้าที่ได้จริง',
    ForecastDomain.health => 'กิจวัตรที่รักษาแรงได้ต่อเนื่อง',
  };

  static String supportingCurrentContext(
    ForecastDomain domain,
    String phase,
  ) => switch (domain) {
    ForecastDomain.career =>
      'งานไม่ใช่โจทย์นำของ$phase จึงดูเพียงว่างานชิ้นหลักยังได้มาตรฐาน',
    ForecastDomain.finance =>
      'ด้านเงินคุมขนาดทางเลือกด้วยยอดพร้อมใช้หลังรายการจำเป็น',
    ForecastDomain.relationship =>
      'ความสัมพันธ์เป็นข้อมูลตรวจ เมื่อพฤติกรรมจริงสอดคล้องกับสิ่งที่ตกลงกัน',
    ForecastDomain.health =>
      'การพักกำหนดเพดานของแผน จากเวลาที่ร่างกายใช้กลับมามีแรง',
  };

  static String supportingCheckpointContext(
    ForecastDomain domain,
    ForecastDomain primary,
  ) => switch (domain) {
    ForecastDomain.career =>
      'เก็บคุณภาพงานรอบส่งมอบไว้ดูว่า${triggerLabel(primary)}นำไปสู่ผลจริงหรือไม่',
    ForecastDomain.finance =>
      'บันทึกยอดคงเหลือรายไตรมาสเพื่อคุมทางเลือกในเรื่อง${domainLabel(primary)} ตัวเลขครั้งเดียวจึงยังไม่พอให้ขยายงบ',
    ForecastDomain.relationship =>
      'ใช้พฤติกรรมหลังการตกลงเป็นข้อมูล แล้วกลับไปตัดสินจาก${triggerLabel(primary)}',
    ForecastDomain.health =>
      'จดเวลาคืนแรงหลังสัปดาห์หนักเพื่อกำหนดขนาดแผน หมุดตรวจของ${domainLabel(primary)}ต้องยืนยันอีกชั้น',
  };

  static String supportingLongTermContext(
    ForecastDomain domain,
    ForecastDomain primary,
  ) => switch (domain) {
    ForecastDomain.career =>
      'งานส่วนสนับสนุนควรถูกส่งต่อ หากทำให้ไม่เหลือพื้นที่สำหรับ${longTermOutcome(primary)}',
    ForecastDomain.finance =>
      'เงินสำรองสำหรับรอยต่อช่วยสร้าง${longTermOutcome(primary)}โดยไม่ถูกบังคับด้วยรายจ่ายเร่งด่วน',
    ForecastDomain.relationship =>
      'การแบ่งเวลาและหน้าที่ใหม่ควรหนุน${longTermOutcome(primary)}โดยไม่ลดความชัดระหว่างกัน',
    ForecastDomain.health =>
      'กิจวัตรพักต้องรองรับ${longTermOutcome(primary)}โดยไม่ยืมแรงจากวันต่อไป',
  };

  String ownForecastClaim(
    ForecastDomain domain,
    ForecastHorizon horizon,
    String claim,
  ) {
    final frame = isUnknownTime
        ? 'จากรูปแบบที่เกิดซ้ำ'
        : switch (horizon) {
            ForecastHorizon.current =>
              'ในจังหวะที่${strengthLabel(themeId)}นำการตัดสินใจ',
            ForecastHorizon.next12Months =>
              'ตลอดปีที่${strengthLabel(themeId)}เป็นแรงหลัก',
            ForecastHorizon.nextLifePeriod =>
              'เมื่อ${strengthLabel(themeId)}คัดทางต่อไป',
          };
    final ownership = switch ((horizon, domain)) {
      (ForecastHorizon.current, ForecastDomain.career) =>
        'คุณภาพที่ส่งมอบคือหลักพิสูจน์เรื่องงาน$frame',
      (ForecastHorizon.current, ForecastDomain.finance) =>
        'ยอดพร้อมใช้คือหลักยืนยันการเงิน$frame',
      (ForecastHorizon.current, ForecastDomain.relationship) =>
        'พฤติกรรมจริงเป็นตัวชี้ขาดของความสัมพันธ์$frame',
      (ForecastHorizon.current, ForecastDomain.health) =>
        'เวลาคืนแรงคือเพดานของแผนชีวิต$frame',
      (ForecastHorizon.next12Months, ForecastDomain.career) =>
        'ผลส่งมอบจะเป็นหมุดติดตามงาน$frame',
      (ForecastHorizon.next12Months, ForecastDomain.finance) =>
        'กระแสเงินจะใช้วัดขนาดทางเลือก$frame',
      (ForecastHorizon.next12Months, ForecastDomain.relationship) =>
        'สิ่งที่คนทำซ้ำจะใช้ตรวจความสัมพันธ์$frame',
      (ForecastHorizon.next12Months, ForecastDomain.health) =>
        'ระยะฟื้นตัวรายเดือนจะใช้เทียบกำลัง$frame',
      (ForecastHorizon.nextLifePeriod, ForecastDomain.career) =>
        'ประสบการณ์จะคัดทิศทางงานใหม่$frame',
      (ForecastHorizon.nextLifePeriod, ForecastDomain.finance) =>
        'สภาพคล่องจะคุมฐานเงินระยะยาว$frame',
      (ForecastHorizon.nextLifePeriod, ForecastDomain.relationship) =>
        'การแบ่งบทบาทจะคัดความสัมพันธ์ระยะใหม่$frame',
      (ForecastHorizon.nextLifePeriod, ForecastDomain.health) =>
        'การรักษาแรงจะกำหนดกิจวัตรระยะใหม่$frame',
    };
    final clauseSubject = switch (domain) {
      ForecastDomain.career => 'รอบงาน',
      ForecastDomain.finance => 'กระแสเงิน',
      ForecastDomain.relationship => 'ข้อตกลง',
      ForecastDomain.health => 'เวลาคืนแรง',
    };
    final clauseFrame = isUnknownTime
        ? '$clauseSubjectตามรูปแบบที่เกิดซ้ำ'
        : '$clauseSubjectภายใต้${strengthLabel(themeId)}';
    final ownedClaim = claim
        .replaceAll(' แต่', ' แต่$clauseFrame')
        .replaceAll(' หาก', ' หาก$clauseFrame')
        .replaceAll(' โดย', ' โดย$clauseFrame');
    return '$ownership $ownedClaim';
  }

  static String decisionBoundary(ForecastDomain domain) => switch (domain) {
    ForecastDomain.career => 'บทบาทใหม่เพิ่มคุณภาพงาน ไม่ใช่เพียงเพิ่มจำนวนงาน',
    ForecastDomain.finance =>
      'รายรับใหม่เหลือเป็นเงินพร้อมใช้ ไม่ได้หายไปกับภาระใหม่',
    ForecastDomain.relationship => 'คำตกลงถูกทำต่อเนื่อง ไม่ได้ชัดเพียงตอนพูด',
    ForecastDomain.health => 'ตารางใหม่ยังเหลือเวลานอนและคืนแรง',
  };

  static String strengthLabel(String themeId) => switch (themeId) {
    'ambitious' => 'แรงผลักให้พัฒนาเป้าหมาย',
    'analytical' => 'ความสามารถในการเห็นรายละเอียด',
    'practical' => 'ความถนัดในการทำเรื่องให้เกิดผลจริง',
    'curious' => 'แรงเรียนรู้จากทางเลือกใหม่',
    'creative' => 'ความสามารถในการสร้างทางเลือกใหม่',
    'protective' => 'ความตั้งใจดูแลสิ่งสำคัญ',
    'independent' => 'การกำหนดทิศทางด้วยตัวเอง',
    'disciplined' => 'วินัยที่ทำเรื่องยากต่อเนื่อง',
    'adaptable' => 'ความสามารถในการปรับตามเงื่อนไข',
    'persistence' => 'ความอดทนที่พาเรื่องยากไปต่อ',
    'expressive' => 'ความสามารถในการทำความคิดให้คนอื่นเข้าใจ',
    'empathetic' => 'ความเข้าใจคนและมุมมองที่ต่างกัน',
    _ => 'ความถนัดในการสร้างฐานทีละขั้น',
  };

  static String decisionQuestion(
    ForecastDomain primary,
    ForecastDomain secondary,
  ) => switch ((primary, secondary)) {
    (ForecastDomain.career, ForecastDomain.finance) =>
      'คำถามคือ บทบาทใหม่เพิ่มอำนาจตัดสินใจมากพอจะคุ้มกับเงินที่ต้องผูกไว้หรือไม่',
    (ForecastDomain.career, ForecastDomain.relationship) =>
      'คำถามคือ งานที่กำลังขยายยังเหลือเวลาและความชัดให้คนที่เกี่ยวข้องหรือไม่',
    (ForecastDomain.career, ForecastDomain.health) =>
      'คำถามคือ งานก้อนใหม่เพิ่มคุณภาพของบทบาท หรือเพียงย้ายเวลาพักไปเป็นหนี้ของสัปดาห์ถัดไป',
    (ForecastDomain.finance, ForecastDomain.career) =>
      'คำถามคือ รายได้และภาระงานก้อนใดควรไปต่อพร้อมกัน และก้อนไหนควรหยุดก่อนรอยต่อ',
    (ForecastDomain.finance, ForecastDomain.relationship) =>
      'คำถามคือ แผนการเงินที่กำลังขยายยังเปิดพื้นที่ให้ข้อตกลงร่วมกันทำได้จริงหรือไม่',
    (ForecastDomain.finance, ForecastDomain.health) =>
      'คำถามคือ เงินที่เพิ่มขึ้นคุ้มกับจังหวะพักที่ต้องแลกไปหรือไม่',
    (ForecastDomain.relationship, ForecastDomain.career) =>
      'คำถามคือ ข้อตกลงร่วมกันรองรับหน้าที่ที่กำลังเปลี่ยน หรือทำให้ฝ่ายใดฝ่ายหนึ่งต้องแบกเพิ่ม',
    (ForecastDomain.relationship, ForecastDomain.finance) =>
      'คำถามคือ ความชัดในความสัมพันธ์พาไปสู่แผนการเงินที่ทั้งสองฝ่ายรับได้จริงหรือไม่',
    (ForecastDomain.relationship, ForecastDomain.health) =>
      'คำถามคือ ความใกล้ชิดแบบใดช่วยให้ทั้งสองฝ่ายมีแรงอยู่กับความสัมพันธ์ได้นาน',
    (ForecastDomain.health, ForecastDomain.career) =>
      'คำถามคือ ตารางงานแบบใดทำให้ผลงานเดินต่อโดยไม่ใช้แรงของวันพรุ่งนี้ล่วงหน้า',
    (ForecastDomain.health, ForecastDomain.finance) =>
      'คำถามคือ ภาระการเงินก้อนไหนกำลังซื้อความมั่นคง และก้อนไหนกำลังกินเวลาฟื้นตัว',
    (ForecastDomain.health, ForecastDomain.relationship) =>
      'คำถามคือ ขอบเขตแบบใดช่วยให้ความสัมพันธ์ไปต่อโดยไม่ทำให้ใครหมดแรง',
    _ =>
      'คำถามคือ ทางเลือกใดทำให้เรื่องสำคัญเดินหน้าโดยไม่ทิ้งฐานที่ต้องใช้ต่อ',
  };

  static ForecastDomain _themeDomain(String themeId) => switch (themeId) {
    'grounded' || 'analytical' => ForecastDomain.finance,
    'protective' => ForecastDomain.relationship,
    'adaptable' => ForecastDomain.health,
    _ => ForecastDomain.career,
  };

  static ForecastDomain? _forecastDomainForRisk(LifeDomain risk) =>
      switch (risk) {
        LifeDomain.career => ForecastDomain.career,
        LifeDomain.money => ForecastDomain.finance,
        LifeDomain.love => ForecastDomain.relationship,
        LifeDomain.health => ForecastDomain.health,
        _ => null,
      };
}
