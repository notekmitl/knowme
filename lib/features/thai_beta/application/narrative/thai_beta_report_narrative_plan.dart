/// V1.5 R4 report-level narrative authority.
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
      return 'ใน$phase ${domainLabel(primary)}กำลังเรียกร้องให้คุณเลือกจากสิ่งที่เห็นผลซ้ำจริง '
          'ขณะที่${domainLabel(secondary)}บอกว่าการตัดสินใจนั้นต้องเหลือพื้นที่ให้ชีวิตด้านอื่นด้วย '
          'หากรีบผูกภาระจากภาพที่ยังไม่เกิดซ้ำ ทางเลือกในช่วงถัดไปอาจแคบลง '
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
        'ใน$phase ${domainLabel(primary)}เป็นเรื่องที่ต้องตัดสินใจตอนนี้ ส่วน${domainLabel(secondary)}คือขอบเขตที่บอกว่าควรรับได้แค่ไหน',
      ForecastHorizon.next12Months =>
        'ใน 12 เดือนจากนี้ ขณะที่$phaseยังดำเนินอยู่ ให้ดู${triggerLabel(primary)}เป็นสัญญาณหลัก และใช้${triggerLabel(secondary)}ตรวจว่าทิศทางยังสมดุล',
      ForecastHorizon.nextLifePeriod =>
        'เมื่อพ้น$phase ทิศทางจะเปลี่ยนจากการรับเพิ่มไปสู่การเลือกสิ่งที่จะรักษา โดยผลตามมาจะชัดที่สุดใน${domainLabel(primary)}และ${domainLabel(secondary)}',
    };
  }

  String get evidenceBoundary => isUnknownTime
      ? 'รายงานนี้ไม่มีเวลาเกิด จึงไม่ใช้ลัคนา เรือน หรือจังหวะที่ต้องอาศัยเวลาเกิดมาฟันธง คำอ่านต่อไปนี้ใช้สิ่งที่สังเกตได้จริงเป็นหลัก'
      : '';

  String supportingContext(ForecastDomain domain, ForecastHorizon horizon) {
    final role = roleFor(domain);
    final current = bandFor(domain, ForecastHorizon.current);
    final next = bandFor(domain, ForecastHorizon.nextLifePeriod);
    final phase = lifePeriodLabel.isEmpty ? 'ช่วงนี้' : lifePeriodLabel;
    final nextDirection = switch (next) {
      ForecastBand.strong => 'ช่วงถัดไปยังเปิดพื้นที่ให้เรื่องนี้เติบโต',
      ForecastBand.quiet => 'ช่วงถัดไปควรรักษาเรื่องนี้ให้อยู่ในขนาดที่ดูแลได้',
      ForecastBand.active => 'ช่วงถัดไปต้องเลือกจังหวะและเงื่อนไขให้รอบคอบขึ้น',
    };
    return switch ((horizon, role)) {
      (ForecastHorizon.current, ThaiBetaReportMotifRole.primary) =>
        'ใน$phase นี่คือเรื่องหลักที่ต้องเลือกให้ชัด และ$nextDirection',
      (ForecastHorizon.current, ThaiBetaReportMotifRole.boundary) =>
        'ใน$phase ผลของเรื่องนี้จะบอกว่าแผนหลักควรรับได้แค่ไหน',
      (ForecastHorizon.current, ThaiBetaReportMotifRole.supporting)
          when current == ForecastBand.strong && next == ForecastBand.strong =>
        '${domainLabel(domain)}เป็นแรงหนุนที่ต่อเนื่องไปถึงช่วงถัดไป',
      (ForecastHorizon.current, ThaiBetaReportMotifRole.supporting)
          when next == ForecastBand.quiet =>
        '${domainLabel(domain)}ยังไม่ใช่เรื่องที่ควรเร่ง แต่ควรเก็บสัญญาณไว้เทียบกับภาระหลัก',
      (ForecastHorizon.current, ThaiBetaReportMotifRole.supporting) =>
        '${domainLabel(domain)}ทำหน้าที่ประคองการตัดสินใจ มากกว่ากำหนดทิศทางเอง',
      (ForecastHorizon.next12Months, ThaiBetaReportMotifRole.primary) =>
        'สัญญาณนี้ใช้ตัดสินว่าทิศทางหลักของ$phaseควรขยายหรือคงขนาดเดิม เพราะ$nextDirection',
      (ForecastHorizon.next12Months, ThaiBetaReportMotifRole.boundary) =>
        'หากสัญญาณนี้อ่อนลงใน$phase ให้ทบทวนแผนหลักก่อนเพิ่มข้อผูกพัน',
      (ForecastHorizon.next12Months, ThaiBetaReportMotifRole.supporting)
          when current == ForecastBand.strong && next != ForecastBand.strong =>
        'ใช้สัญญาณนี้คัดสิ่งที่จะพาเข้าสู่ช่วงถัดไป ไม่ใช่เปิดภาระใหม่ทั้งหมด',
      (ForecastHorizon.next12Months, ThaiBetaReportMotifRole.supporting)
          when next == ForecastBand.strong =>
        'หากรูปแบบนี้เกิดซ้ำ ${domainLabel(domain)}จะมีน้ำหนักมากขึ้นในช่วงถัดไป',
      (ForecastHorizon.next12Months, ThaiBetaReportMotifRole.supporting) =>
        'เรื่องนี้ควรใช้เป็นข้อมูลประกอบ ไม่ใช่เหตุผลเดียวของการตัดสินใจ',
      (ForecastHorizon.nextLifePeriod, ThaiBetaReportMotifRole.primary) =>
        'หลัง$phase นี่คือทิศทางหลักที่จะกำหนดสิ่งที่ควรรักษาและสิ่งที่ควรส่งต่อ',
      (ForecastHorizon.nextLifePeriod, ThaiBetaReportMotifRole.boundary) =>
        'เมื่อพ้น$phase ผลด้านนี้จะเป็นเพดานของการขยายเรื่องหลักในช่วงใหม่',
      (ForecastHorizon.nextLifePeriod, ThaiBetaReportMotifRole.supporting)
          when next == ForecastBand.strong =>
        '${domainLabel(domain)}จะหนุนให้การเปลี่ยนผ่านมีฐานที่มั่นคงขึ้น',
      (ForecastHorizon.nextLifePeriod, ThaiBetaReportMotifRole.supporting)
          when next == ForecastBand.quiet =>
        '${domainLabel(domain)}ควรอยู่ในขนาดที่ดูแลต่อได้ ไม่ใช่ขยายตามแรงของเรื่องอื่น',
      (ForecastHorizon.nextLifePeriod, ThaiBetaReportMotifRole.supporting) =>
        '${domainLabel(domain)}จะเป็นแรงประกอบที่ต้องปรับตามภาระชุดใหม่',
    };
  }

  String get closing => isUnknownTime
      ? 'ก่อนตัดสินใจครั้งสำคัญ ให้ดูว่าสิ่งที่เกิดซ้ำจริงยืนยันว่า${decisionBoundary(primary)}หรือยัง '
            'จากนั้นตรวจว่า${boundaryLabel(secondary)} แล้วจึงค่อยขยับจากหลักฐานที่มี'
      : 'ก่อนตัดสินใจครั้งสำคัญใน${lifePeriodLabel.isEmpty ? 'ช่วงนี้' : lifePeriodLabel} '
            'ให้กลับมาดูว่า${decisionBoundary(primary)}ชัดขึ้นจริงหรือยัง และ${boundaryLabel(secondary)} '
            'หากสองข้อนี้ไปด้วยกันได้ จึงค่อยขยับขั้นถัดไป';

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
