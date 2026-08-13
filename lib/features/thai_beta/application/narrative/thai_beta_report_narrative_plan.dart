/// V1.5 R3 report-level narrative authority.
///
/// The plan ranks the evidence already present in all forecast windows before
/// any consumer sentence is written. It gives the report one central tension,
/// at most two motifs, and a different job for each horizon.
library;

import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';

import 'thai_beta_narrative_context.dart';

class ThaiBetaReportNarrativePlan {
  const ThaiBetaReportNarrativePlan({
    required this.primary,
    required this.secondary,
    required this.themeId,
    required this.lifePeriodLabel,
    required this.centralTension,
    required this.consequence,
    required this.decisionQuestion,
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
    final scores = <ForecastDomain, int>{
      for (final domain in ForecastDomain.values) domain: 0,
    };
    for (final material in materials) {
      scores[material.domain] =
          scores[material.domain]! +
          switch (material.band) {
            ForecastBand.strong => 5,
            ForecastBand.active => 3,
            ForecastBand.quiet => 1,
          };
      final riskDomain = _forecastDomainForRisk(
        material.consumerRiskDomain.name,
      );
      if (riskDomain != null) scores[riskDomain] = scores[riskDomain]! + 2;
      if (material.spansTransition) {
        scores[material.domain] = scores[material.domain]! + 1;
      }
    }
    final ranked = ForecastDomain.values.toList()
      ..sort((left, right) {
        final byScore = scores[right]!.compareTo(scores[left]!);
        return byScore != 0 ? byScore : left.index.compareTo(right.index);
      });
    final primary = ranked.first;
    final secondary = ranked.length > 1 ? ranked[1] : ranked.first;
    final themeId = context.orderedThemeIds.isEmpty
        ? 'grounded'
        : context.orderedThemeIds.first;
    return ThaiBetaReportNarrativePlan(
      primary: primary,
      secondary: secondary,
      themeId: themeId,
      lifePeriodLabel: context.lifePeriodLabel ?? '',
      centralTension: _tension(primary, secondary, themeId),
      consequence: _consequence(primary, secondary),
      decisionQuestion: _question(primary, secondary),
    );
  }

  final ForecastDomain primary;
  final ForecastDomain secondary;
  final String themeId;
  final String lifePeriodLabel;
  final String centralTension;
  final String consequence;
  final String decisionQuestion;

  bool isPrimary(ForecastDomain domain) => domain == primary;
  bool isSecondary(ForecastDomain domain) => domain == secondary;

  String get headline =>
      'ลายเซ็นของคำอ่าน: ${domainLabel(primary)}เดินหน้าได้ เมื่อ${boundaryLabel(secondary)}';

  String get hook => '$centralTension $consequence $decisionQuestion';

  String horizonDelta(ForecastDecisionPlan plan) {
    final role = isPrimary(plan.domain)
        ? 'แกนหลัก'
        : isSecondary(plan.domain)
        ? 'เงื่อนไขสำคัญ'
        : 'แรงประกอบ';
    final strength = switch (themeId) {
      'ambitious' => 'แรงผลักให้ไปไกล',
      'analytical' => 'สายตาที่เห็นรายละเอียด',
      'practical' => 'ความถนัดในการทำให้เกิดผลจริง',
      'curious' => 'แรงอยากทดลองทางใหม่',
      'protective' => 'ความตั้งใจดูแลสิ่งสำคัญ',
      'independent' => 'การตัดสินใจด้วยตัวเอง',
      'disciplined' => 'วินัยที่ทำเรื่องยากต่อเนื่อง',
      'adaptable' => 'ความสามารถในการปรับตามสถานการณ์',
      _ => 'ความมั่นคงที่สร้างทีละขั้น',
    };
    final check = switch (plan.consumerRiskDomain.name) {
      'career' => 'งานหลักถูกเบียดเวลา',
      'money' => 'เงินพร้อมใช้ลดลง',
      'love' => 'ความคาดหวังเริ่มไม่ตรงกัน',
      'health' => 'การพักฟื้นแรงไม่ทัน',
      _ => 'ภาระจริงเริ่มเกินพื้นที่ที่มี',
    };
    final phase = lifePeriodLabel.isEmpty ? 'ช่วงนี้' : lifePeriodLabel;
    final unavailable =
        plan.evidenceAvailability == ForecastEvidenceAvailability.noLagna
        ? ' และต้องยืนยันจากสิ่งที่เกิดซ้ำเพราะไม่มีเวลาเกิด'
        : '';
    return switch (plan.horizon) {
      ForecastHorizon.current =>
        'ในภาพรวมตอนนี้ เรื่องนี้เป็น$role: ใช้$strengthรับมือ${triggerLabel(plan.domain)}ใน$phase และหยุดเมื่อ$check$unavailable',
      ForecastHorizon.next12Months =>
        'สัญญาณเปลี่ยนคือ${triggerLabel(plan.domain)}ระหว่าง$phase; ใช้$strengthทบทวนก่อน$check$unavailable',
      ForecastHorizon.nextLifePeriod =>
        'ระยะยาว ให้เก็บ$strengthจาก$phaseเป็นฐานของ${domainLabel(plan.domain)} เพื่อไม่ให้$check$unavailable',
    };
  }

  static String domainLabel(ForecastDomain domain) => switch (domain) {
    ForecastDomain.career => 'งาน',
    ForecastDomain.finance => 'การเงิน',
    ForecastDomain.relationship => 'ความสัมพันธ์',
    ForecastDomain.health => 'กำลังและการฟื้นตัว',
  };

  static String boundaryLabel(ForecastDomain domain) => switch (domain) {
    ForecastDomain.career => 'งานหลักยังมีคุณภาพ',
    ForecastDomain.finance => 'เงินพร้อมใช้ยังไม่ถูกเบียด',
    ForecastDomain.relationship => 'ข้อตกลงยังชัดและทำได้จริง',
    ForecastDomain.health => 'ร่างกายยังฟื้นทัน',
  };

  static String triggerLabel(ForecastDomain domain) => switch (domain) {
    ForecastDomain.career => 'ขอบเขตหน้าที่เริ่มเปลี่ยน',
    ForecastDomain.finance => 'ยอดคงเหลือเปลี่ยนต่อเนื่องหลายรอบ',
    ForecastDomain.relationship => 'คำพูดกลายเป็นพฤติกรรมที่สม่ำเสมอ',
    ForecastDomain.health => 'ตารางหนักเริ่มรบกวนการพัก',
  };

  static String _tension(
    ForecastDomain primary,
    ForecastDomain secondary,
    String themeId,
  ) {
    final strength = switch (themeId) {
      'ambitious' => 'แรงผลักให้ไปให้ไกล',
      'analytical' => 'ความสามารถในการมองรายละเอียด',
      'practical' => 'นิสัยที่ชอบทำให้เห็นผลจริง',
      'curious' => 'แรงอยากลองทางใหม่',
      'protective' => 'ความตั้งใจดูแลสิ่งสำคัญ',
      'independent' => 'ความถนัดในการตัดสินใจด้วยตัวเอง',
      'disciplined' => 'วินัยที่พาเรื่องยากไปต่อ',
      'adaptable' => 'ความสามารถในการปรับตัว',
      _ => 'ความมั่นคงที่คุณค่อย ๆ สร้าง',
    };
    return 'แกนของรายงานนี้คือ$strengthกำลังพา${domainLabel(primary)}ไปข้างหน้า '
        'แต่จังหวะเดียวกันก็กดให้${boundaryLabel(secondary)}ยากขึ้น';
  }

  static String _consequence(
    ForecastDomain primary,
    ForecastDomain secondary,
  ) =>
      'ถ้าขยาย${domainLabel(primary)}โดยไม่เผื่อ${domainLabel(secondary)} '
      'โอกาสที่ดูดีอาจกลายเป็นภาระที่ลดพื้นที่เลือกในช่วงถัดไป';

  static String _question(ForecastDomain primary, ForecastDomain secondary) =>
      'คำถามสำคัญจึงไม่ใช่ว่าจะรับเพิ่มได้ไหม แต่คือจะรักษา${domainLabel(secondary)}ไว้แค่ไหนก่อนขยับ${domainLabel(primary)}';

  static ForecastDomain? _forecastDomainForRisk(String risk) => switch (risk) {
    'career' => ForecastDomain.career,
    'money' => ForecastDomain.finance,
    'love' => ForecastDomain.relationship,
    'health' => ForecastDomain.health,
    _ => null,
  };
}
