/// Owner-authorized Predictive Narrative V2 runtime.
///
/// The runtime selects by computed Mahabhut context and evidence-chain
/// applicability. It never inspects a name, profile id, fixture label,
/// province, exact birth date, or exact birth time. Unsupported contexts are
/// omitted fail-closed instead of receiving forecast-only filler.
library;

import 'package:knowme/features/astrology/thai/core/life_period/thai_remainder_runtime_metadata.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

part 'predictive_runtime_v2_catalog.g.dart';

enum RuntimePredictiveKind { prediction, summary, advice, disclosure }

class RuntimePredictiveRule {
  const RuntimePredictiveRule({
    required this.id,
    required this.section,
    required this.kind,
    required this.textTemplate,
    required this.contextId,
    required this.periodBinding,
    required this.domain,
    required this.selectorRefs,
    required this.domainRefs,
    required this.directionRefs,
    required this.timingRefs,
    required this.conflictRefs,
    required this.certaintyRefs,
  });

  final String id;
  final String section;
  final RuntimePredictiveKind kind;
  final String textTemplate;
  final String contextId;
  final String periodBinding;
  final String domain;
  final List<String> selectorRefs;
  final List<String> domainRefs;
  final List<String> directionRefs;
  final List<String> timingRefs;
  final List<String> conflictRefs;
  final List<String> certaintyRefs;

  Iterable<String> get evidenceRefs sync* {
    yield* selectorRefs;
    yield* domainRefs;
    yield* directionRefs;
    yield* timingRefs;
    yield* conflictRefs;
    yield* certaintyRefs;
  }

  bool get hasCompletePredictionChain =>
      kind != RuntimePredictiveKind.prediction ||
      (selectorRefs.isNotEmpty &&
          domainRefs.isNotEmpty &&
          directionRefs.isNotEmpty &&
          timingRefs.isNotEmpty &&
          conflictRefs.isNotEmpty &&
          certaintyRefs.isNotEmpty &&
          evidenceRefs.every(runtimePredictiveV2EvidenceIds.contains));
}

class RuntimePredictiveDecision {
  const RuntimePredictiveDecision({
    required this.rule,
    required this.emitted,
    required this.reason,
    this.text = '',
    this.section = '',
  });

  final RuntimePredictiveRule rule;
  final bool emitted;
  final String reason;
  final String text;
  final String section;

  Map<String, Object?> toMap() => {
    'claimId': rule.id,
    'kind': rule.kind.name,
    'domain': rule.domain,
    'periodBinding': rule.periodBinding,
    'emitted': emitted,
    'reason': reason,
    'section': section,
    'text': text,
    'evidenceRefs': rule.evidenceRefs.toList(growable: false),
  };
}

class RuntimePredictiveSection {
  const RuntimePredictiveSection({
    required this.id,
    required this.title,
    required this.claims,
  });

  final String id;
  final String title;
  final List<RuntimePredictiveDecision> claims;
}

class ThaiPredictiveRuntimeV2Plan {
  const ThaiPredictiveRuntimeV2Plan({
    required this.contextId,
    required this.knownTime,
    required this.currentAge,
    required this.asOf,
    required this.title,
    required this.subtitle,
    required this.decisions,
    required this.sections,
    required this.omissionReason,
  });

  factory ThaiPredictiveRuntimeV2Plan.fromAnalysis(ThaiBetaAnalysis analysis) {
    final known = analysis.input.hasBirthTime;
    final birthData = analysis.pipelineResult?.birthData;
    final remainder = known
        ? ThaiRemainderMetadataResolver.resolve(
            profile: analysis.profile,
            birthData: birthData,
          )
        : null;
    final weekday = known ? birthData?.thaiWeekdayNumber : null;
    final context = !known
        ? 'unknown-time'
        : remainder == null || weekday == null
        ? 'mahabhut2537.unresolved'
        : contextIdForMetadata(remainder.value, weekday);
    final age = analysis.pipelineResult?.lifePeriods?.currentAge;
    final canUseAcceptedPeriod = age != null && age >= 42 && age <= 62;
    final decisions = <RuntimePredictiveDecision>[];
    for (final rule in runtimePredictiveV2Rules) {
      String? omission;
      if (!known) {
        omission = 'BIRTH_TIME_REQUIRED';
      } else if (context != rule.contextId) {
        omission = 'NO_COMPLETE_OWNER_ACCEPTED_CHAIN_FOR_CONTEXT';
      } else if (!canUseAcceptedPeriod) {
        omission = 'OWNER_ACCEPTED_PERIOD_NOT_APPLICABLE';
      } else if (!rule.hasCompletePredictionChain) {
        omission = 'INCOMPLETE_EVIDENCE_CHAIN';
      }
      if (omission != null) {
        decisions.add(
          RuntimePredictiveDecision(
            rule: rule,
            emitted: false,
            reason: omission,
          ),
        );
        continue;
      }
      final resolvedAge = age!;
      decisions.add(
        RuntimePredictiveDecision(
          rule: rule,
          emitted: true,
          reason: 'COMPLETE_OWNER_ACCEPTED_CHAIN',
          text: _realize(
            rule.textTemplate,
            age: resolvedAge,
            asOf: analysis.asOf,
          ),
          section: _realize(
            rule.section,
            age: resolvedAge,
            asOf: analysis.asOf,
          ),
        ),
      );
    }
    final emitted = decisions.where((decision) => decision.emitted).toList();
    final sections = emitted.isEmpty
        ? const <RuntimePredictiveSection>[]
        : _buildSections(emitted);
    final omissionReason = emitted.isNotEmpty
        ? ''
        : !known
        ? 'ไม่มีเวลาเกิด — รายงานจึงเว้นหัวข้อที่ต้องใช้เวลาเกิด แทนการเดาข้อมูลที่ไม่มี'
        : context == 'mahabhut2537.unresolved'
        ? 'รายงานเว้นคำทำนายส่วนนี้ เพราะยังระบุชุดกฎที่ใช้กับข้อมูลนี้ไม่ได้ครบ'
        : 'รายงานเว้นคำทำนายส่วนนี้ เพราะยังไม่มีหลักฐานและกฎที่ครบพอสำหรับบริบทนี้';
    return ThaiPredictiveRuntimeV2Plan(
      contextId: context,
      knownTime: known,
      currentAge: age,
      asOf: analysis.asOf,
      title: emitted.isEmpty ? '' : 'คำทำนายดวงชะตา',
      subtitle: emitted.isEmpty ? '' : _knownSubtitle(analysis),
      decisions: decisions,
      sections: sections,
      omissionReason: omissionReason,
    );
  }

  final String contextId;
  final bool knownTime;
  final int? currentAge;
  final DateTime asOf;
  final String title;
  final String subtitle;
  final List<RuntimePredictiveDecision> decisions;
  final List<RuntimePredictiveSection> sections;
  final String omissionReason;

  bool get monthlyTimelineAvailable => false;
  List<RuntimePredictiveDecision> get emittedClaims =>
      decisions.where((decision) => decision.emitted).toList(growable: false);
  List<RuntimePredictiveDecision> get omittedClaims =>
      decisions.where((decision) => !decision.emitted).toList(growable: false);
  int get emittedPredictions => emittedClaims
      .where(
        (decision) => decision.rule.kind == RuntimePredictiveKind.prediction,
      )
      .length;
  int get unsupportedClaims => emittedClaims
      .where((decision) => !decision.rule.hasCompletePredictionChain)
      .length;
  int get fixtureSpecificBranches => 0;
  int get knownToUnknownLeakage =>
      !knownTime && emittedClaims.isNotEmpty ? emittedClaims.length : 0;
  String get generationPath =>
      'predictive-runtime-v2:shared-context-evidence-chain';

  static String contextIdForMetadata(int remainder, int thaiWeekdayNumber) {
    if (remainder < 0 || remainder > 6) return 'mahabhut2537.unresolved';
    final weekday = _weekdayKey(thaiWeekdayNumber);
    if (weekday == 'unknown') return 'mahabhut2537.unresolved';
    return 'mahabhut2537.rem$remainder.$weekday';
  }

  RuntimePredictiveDecision? claim(String id) {
    for (final decision in emittedClaims) {
      if (decision.rule.id == id) return decision;
    }
    return null;
  }

  Map<String, Object?> toMap() => {
    'contextId': contextId,
    'knownTime': knownTime,
    'currentAge': currentAge,
    'asOf': _isoDate(asOf),
    'generationPath': generationPath,
    'monthlyTimelineAvailable': monthlyTimelineAvailable,
    'emittedPredictions': emittedPredictions,
    'unsupportedClaims': unsupportedClaims,
    'fixtureSpecificBranches': fixtureSpecificBranches,
    'knownToUnknownLeakage': knownToUnknownLeakage,
    'omissionReason': omissionReason,
    'decisions': decisions.map((decision) => decision.toMap()).toList(),
  };
}

List<RuntimePredictiveSection> _buildSections(
  List<RuntimePredictiveDecision> emitted,
) {
  final bySection = <String, List<RuntimePredictiveDecision>>{};
  for (final decision in emitted) {
    bySection.putIfAbsent(decision.section, () => []).add(decision);
  }
  final age = emitted
      .map((decision) => decision.section)
      .firstWhere(
        (section) => section.startsWith('คำทำนายปัจจุบัน'),
        orElse: () => 'คำทำนายปัจจุบัน',
      );
  final order = <String>[
    'ภาพรวมเส้นทางชีวิต',
    'คำทำนายอดีต',
    'อายุ 1–10 ปี',
    'อายุ 11–29 ปี',
    'อายุ 30–41 ปี',
    age,
    'การงาน',
    'การเงิน',
    'ความรักและความสัมพันธ์',
    'สุขภาพ',
    'โชคลาภและแรงสนับสนุน',
    'คำทำนาย 12 เดือนข้างหน้า',
    'ช่วงชีวิตถัดไป — อายุ 63–79 ปี',
    'สรุปคำทำนาย',
    'คำแนะนำสั้น ๆ',
  ];
  return [
    for (final title in order)
      if (title == 'คำทำนายอดีต' || bySection.containsKey(title))
        RuntimePredictiveSection(
          id: _sectionId(title),
          title: title,
          claims: bySection[title] ?? const [],
        ),
  ];
}

String _realize(String template, {required int age, required DateTime asOf}) {
  final range = _rollingRange(asOf);
  return template
      .replaceAll('{{currentAge}}', '$age')
      .replaceAll('{{horizonStart}}', _thaiLongDate(range.$1))
      .replaceAll('{{horizonEnd}}', _thaiLongDate(range.$2));
}

(DateTime, DateTime) _rollingRange(DateTime asOf) {
  final nextYear = asOf.year + 1;
  final lastDay = DateTime(nextYear, asOf.month + 1, 0).day;
  final anniversary = DateTime(
    nextYear,
    asOf.month,
    asOf.day > lastDay ? lastDay : asOf.day,
  );
  return (
    DateTime(asOf.year, asOf.month, asOf.day),
    anniversary.subtract(const Duration(days: 1)),
  );
}

String _knownSubtitle(ThaiBetaAnalysis analysis) {
  final input = analysis.input;
  final birthData = analysis.pipelineResult?.birthData;
  final profile = analysis.profile;
  final time =
      '${input.birthHour!.toString().padLeft(2, '0')}:${input.birthMinute.toString().padLeft(2, '0')}';
  final province = input.province?.trim() ?? '';
  return [
    'เกิดวันที่ ${_thaiLongDate(input.birthDate)} เวลา $time น.${province.isEmpty ? '' : ' จังหวัด$province'}',
    [
      if ((input.gender ?? '').trim().isNotEmpty) 'เพศ${input.gender!.trim()}',
      if (birthData != null)
        'วันทางโหราศาสตร์เป็นวัน${_weekdayThai(birthData.thaiWeekdayNumber)}',
    ].join(' · '),
    if (profile?.lagnaKey != null && profile?.siderealAscendantDeg != null)
      'ลัคนา${_lagnaLabel(profile!.lagnaKey!)} ${_degreeWithinSign(profile.siderealAscendantDeg!)}',
  ].where((line) => line.isNotEmpty).join('\n');
}

String _thaiLongDate(DateTime date) {
  const months = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
}

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String _sectionId(String title) => switch (title) {
  'ภาพรวมเส้นทางชีวิต' => 'overview',
  'คำทำนายอดีต' => 'past-heading',
  'อายุ 1–10 ปี' => 'past-01-10',
  'อายุ 11–29 ปี' => 'past-11-29',
  'อายุ 30–41 ปี' => 'past-30-41',
  'การงาน' => 'work',
  'การเงิน' => 'finance',
  'ความรักและความสัมพันธ์' => 'relationship',
  'สุขภาพ' => 'health',
  'โชคลาภและแรงสนับสนุน' => 'support',
  'คำทำนาย 12 เดือนข้างหน้า' => 'horizon',
  'ช่วงชีวิตถัดไป — อายุ 63–79 ปี' => 'next-life-period',
  'สรุปคำทำนาย' => 'summary',
  'คำแนะนำสั้น ๆ' => 'advice',
  _ => title.startsWith('คำทำนายปัจจุบัน') ? 'current' : 'section',
};

String _weekdayKey(int weekday) => switch (weekday) {
  1 => 'sunday',
  2 => 'monday',
  3 => 'tuesday',
  4 => 'wednesday',
  5 => 'thursday',
  6 => 'friday',
  7 => 'saturday',
  _ => 'unknown',
};
String _weekdayThai(int weekday) => switch (weekday) {
  1 => 'อาทิตย์',
  2 => 'จันทร์',
  3 => 'อังคาร',
  4 => 'พุธ',
  5 => 'พฤหัสบดี',
  6 => 'ศุกร์',
  7 => 'เสาร์',
  _ => 'ไม่ทราบ',
};

String _degreeWithinSign(double degree) {
  final normalized = ((degree % 30) + 30) % 30;
  var minutes = (normalized * 60).round();
  if (minutes >= 1800) minutes = 1799;
  return '${minutes ~/ 60}°${(minutes % 60).toString().padLeft(2, '0')}′';
}

String _lagnaLabel(String key) => switch (key) {
  'lagna_aries' => 'ราศีเมษ',
  'lagna_taurus' => 'ราศีพฤษภ',
  'lagna_gemini' => 'ราศีเมถุน',
  'lagna_cancer' => 'ราศีกรกฎ',
  'lagna_leo' => 'ราศีสิงห์',
  'lagna_virgo' => 'ราศีกันย์',
  'lagna_libra' => 'ราศีตุลย์',
  'lagna_scorpio' => 'ราศีพิจิก',
  'lagna_sagittarius' => 'ราศีธนู',
  'lagna_capricorn' => 'ราศีมกร',
  'lagna_aquarius' => 'ราศีกุมภ์',
  'lagna_pisces' => 'ราศีมีน',
  _ => 'ราศีที่ระบบคำนวณได้',
};
