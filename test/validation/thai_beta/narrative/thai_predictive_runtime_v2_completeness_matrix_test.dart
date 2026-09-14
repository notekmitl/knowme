import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/birth_normalization/application/birth_normalizer.dart';
import 'package:knowme/features/birth_normalization/application/thai_provinces.dart';
import 'package:knowme/features/birth_normalization/domain/raw_birth_input.dart';
import 'package:knowme/features/thai_beta/application/narrative/predictive_runtime_v2.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

final _asOf = DateTime(2026, 9, 11);
const _genderValues = <String?>['ชาย', 'หญิง', 'อื่น ๆ', 'ไม่ระบุ', null];

void main() {
  group('Candidate 0029 supported-input completeness matrix', () {
    test(
      'normalizes every minute in every province across all seven civil weekdays',
      () {
        final failures = _FailureLedger();
        final civilWeekdays = <int>{};
        final astrologicalWeekdays = <int>{};
        final provinces = <String>{};
        var beforeSunrise = 0;
        var atOrAfterSunrise = 0;
        var cases = 0;

        for (final date in _sevenCivilWeekdayDates) {
          civilWeekdays.add(date.weekday);
          for (final province in kThaiProvincesAll) {
            provinces.add(province.key);
            for (var minuteOfDay = 0; minuteOfDay < 1440; minuteOfDay++) {
              final hour = minuteOfDay ~/ 60;
              final minute = minuteOfDay % 60;
              final label =
                  '${_isoDate(date)}|${province.key}|${_clock(hour, minute)}';
              final result = BirthNormalizer.normalize(
                RawBirthInput(
                  birthDate: date,
                  birthHour: hour,
                  birthMinute: minute,
                  province: province.key,
                  placeLabel: province.nameTh,
                  timeZoneId: ThaiProvince.thaiTimeZoneId,
                ),
              );
              cases++;
              if (!result.isValid || result.birth == null) {
                failures.add('NORMALIZATION_FAILED', label, result.error);
                continue;
              }
              final birth = result.birth!;
              final thai = birth.thai;
              failures.check(
                birth.latitude == province.latitude &&
                    birth.longitude == province.longitude,
                'PROVINCE_COORDINATE_MISMATCH',
                label,
              );
              failures.check(
                thai.hasBirthTime &&
                    thai.localDateTime.hour == hour &&
                    thai.localDateTime.minute == minute,
                'KNOWN_TIME_NOT_PRESERVED',
                label,
              );
              failures.check(
                thai.sunriseAvailable,
                'THAI_SUNRISE_UNAVAILABLE',
                label,
              );
              final expectedBefore = thai.localDateTime.isBefore(
                thai.localSunrise,
              );
              failures.check(
                thai.bornBeforeSunrise == expectedBefore,
                'SUNRISE_SIDE_MISMATCH',
                label,
              );
              final expectedAstrologicalDate = expectedBefore
                  ? date.subtract(const Duration(days: 1))
                  : date;
              failures.check(
                _sameDate(thai.astrologicalDate, expectedAstrologicalDate),
                'ASTROLOGICAL_DATE_MISMATCH',
                label,
              );
              astrologicalWeekdays.add(thai.astrologicalDate.weekday);
              if (thai.bornBeforeSunrise) {
                beforeSunrise++;
              } else {
                atOrAfterSunrise++;
              }
            }
          }
        }

        failures.check(cases == 776160, 'CASE_COUNT_NOT_776160', '$cases');
        failures.check(
          civilWeekdays.length == 7,
          'CIVIL_WEEKDAY_COUNT_NOT_7',
          '${civilWeekdays.length}',
        );
        failures.check(
          astrologicalWeekdays.length == 7,
          'ASTROLOGICAL_WEEKDAY_COUNT_NOT_7',
          '${astrologicalWeekdays.length}',
        );
        failures.check(
          provinces.length == 77,
          'PROVINCE_COUNT_NOT_77',
          '${provinces.length}',
        );
        failures.check(
          beforeSunrise > 0 && atOrAfterSunrise > 0,
          'SUNRISE_SIDES_NOT_BOTH_REACHED',
          '$beforeSunrise/$atOrAfterSunrise',
        );
        failures.expectNone();
        // ignore: avoid_print
        print(
          'NORMALIZATION_MATRIX cases=$cases weekdays=${civilWeekdays.length} '
          'minutes=1440 provinces=${provinces.length} '
          'beforeSunrise=$beforeSunrise atOrAfterSunrise=$atOrAfterSunrise',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test(
      'proves complete plans and reader documents across the supported axes',
      () {
        final failures = _FailureLedger();
        final caseKeys = <String>{};
        final observedMinutes = <int>{};
        final observedHours = <int>{};
        final observedCivilWeekdays = <int>{};
        final observedAstrologicalWeekdays = <int>{};
        final observedProvinces = <String>{};
        final observedGenders = <String?>{};
        final observedContexts = <String>{};
        final observedLagna = <String>{};
        final observedPeriods = <String>{};
        var cases = 0;
        var documents = 0;

        void runCase({
          required DateTime date,
          required int hour,
          required int minute,
          required ThaiProvince province,
          required String? gender,
          required String source,
          DateTime? asOf,
          String? expectedContext,
          String? expectedPeriod,
          bool renderDocument = false,
        }) {
          final readingDate = asOf ?? _asOf;
          final key = [
            _isoDate(date),
            _clock(hour, minute),
            province.key,
            gender ?? '<null>',
            _isoDate(readingDate),
            expectedContext ?? '',
            expectedPeriod ?? '',
            renderDocument ? 'document' : 'plan',
          ].join('|');
          if (!caseKeys.add(key)) return;
          final label = '$source|$key';
          final input = ThaiBetaInput(
            firstName: 'Completeness',
            lastName: 'Matrix',
            birthDate: date,
            birthHour: hour,
            birthMinute: minute,
            birthTimeUnknown: false,
            province: province.nameTh,
            provinceKey: province.key,
            gender: gender,
          );
          final analysis = ThaiBetaAnalysisRunner.run(input, asOf: readingDate);
          cases++;
          observedMinutes.add(hour * 60 + minute);
          observedHours.add(hour);
          observedCivilWeekdays.add(date.weekday);
          observedProvinces.add(province.key);
          observedGenders.add(gender);
          if (!analysis.isSuccess) {
            failures.add('ANALYSIS_FAILED', label, analysis.errorMessage);
            return;
          }
          final document = renderDocument
              ? ThaiBetaReportExportDocument.candidate(analysis)
              : null;
          if (document != null) documents++;
          final plan =
              document?.predictiveRuntimeV2 ??
              ThaiPredictiveRuntimeV2Plan.fromAnalysis(analysis);
          observedContexts.add(plan.contextId);
          observedAstrologicalWeekdays.add(
            analysis.pipelineResult!.birthData!.thaiWeekdayNumber,
          );
          final lagna = analysis.profile?.lagnaKey;
          if (lagna != null) observedLagna.add(lagna);
          final period = plan.currentPeriod;
          if (period != null) {
            observedPeriods.add(period.matrixApplicationId);
          }
          _checkCompleteKnownPlan(
            failures,
            label,
            plan,
            expectedClock: _clock(hour, minute),
            expectedProvince: province.nameTh,
            expectedContext: expectedContext,
            expectedPeriod: expectedPeriod,
          );
          if (document != null) {
            _checkCompleteKnownDocument(failures, label, document);
          }
        }

        // Every clock minute reaches a complete evidence-bound plan at least
        // once; all provinces, weekdays and gender form values rotate through.
        for (var minuteOfDay = 0; minuteOfDay < 1440; minuteOfDay++) {
          runCase(
            date: _sevenCivilWeekdayDates[minuteOfDay % 7],
            hour: minuteOfDay ~/ 60,
            minute: minuteOfDay % 60,
            province: kThaiProvincesAll[minuteOfDay % 77],
            gender: _genderValues[minuteOfDay % _genderValues.length],
            source: 'every-minute',
          );
        }

        // Render one complete document per supported province while rotating
        // through all seven civil weekdays. The exhaustive normalization gate
        // above already proves every province/day/minute sunrise-side branch.
        for (
          var provinceIndex = 0;
          provinceIndex < kThaiProvincesAll.length;
          provinceIndex++
        ) {
          runCase(
            date: _sevenCivilWeekdayDates[provinceIndex % 7],
            hour: 12,
            minute: 30,
            province: kThaiProvincesAll[provinceIndex],
            gender: _genderValues[provinceIndex % _genderValues.length],
            source: 'province-document',
            renderDocument: true,
          );
        }

        // Every one of the 392 supported context/age periods is exercised at
        // its inclusive end boundary through an actual analysis. Both static
        // boundaries are also checked directly against the period resolver.
        final representatives = _contextRepresentatives(failures);
        failures.check(
          representatives.length == 49,
          'CONTEXT_REPRESENTATIVE_COUNT_NOT_49',
          '${representatives.length}',
        );
        final renderedPeriodContexts = <String>{};
        for (
          var rowIndex = 0;
          rowIndex < runtimePredictiveV2PeriodRows.length;
          rowIndex++
        ) {
          final row = runtimePredictiveV2PeriodRows[rowIndex];
          final representative = representatives[row.contextId];
          if (representative == null) continue;
          failures.check(
            ThaiPredictiveRuntimeV2Plan.resolvePeriod(
                  contextId: row.contextId,
                  age: row.ageStart,
                )?.matrixApplicationId ==
                row.matrixApplicationId,
            'PERIOD_START_RESOLVER_MISMATCH',
            row.matrixApplicationId,
          );
          failures.check(
            ThaiPredictiveRuntimeV2Plan.resolvePeriod(
                  contextId: row.contextId,
                  age: row.ageEnd,
                )?.matrixApplicationId ==
                row.matrixApplicationId,
            'PERIOD_END_RESOLVER_MISMATCH',
            row.matrixApplicationId,
          );
          final age = row.ageEnd;
          final asOf = _anniversaryAtAge(representative.birthDate, age);
          final province =
              kThaiProvincesAll[(rowIndex + age) % kThaiProvincesAll.length];
          runCase(
            date: representative.birthDate,
            hour: representative.birthHour!,
            minute: representative.birthMinute,
            province: province,
            gender: _genderValues[(rowIndex + age) % _genderValues.length],
            source: 'period-end-age-$age',
            asOf: asOf,
            expectedContext: row.contextId,
            expectedPeriod: row.matrixApplicationId,
            renderDocument: renderedPeriodContexts.add(row.contextId),
          );
        }

        failures.check(
          observedMinutes.length == 1440,
          'RENDERED_MINUTE_COUNT_NOT_1440',
          '${observedMinutes.length}',
        );
        failures.check(
          observedHours.length == 24,
          'RENDERED_HOUR_COUNT_NOT_24',
          '${observedHours.length}',
        );
        failures.check(
          observedCivilWeekdays.length == 7,
          'RENDERED_CIVIL_WEEKDAY_COUNT_NOT_7',
          '${observedCivilWeekdays.length}',
        );
        failures.check(
          observedAstrologicalWeekdays.length == 7,
          'RENDERED_ASTROLOGICAL_WEEKDAY_COUNT_NOT_7',
          '${observedAstrologicalWeekdays.length}',
        );
        failures.check(
          observedProvinces.length == 77,
          'RENDERED_PROVINCE_COUNT_NOT_77',
          '${observedProvinces.length}',
        );
        failures.check(
          observedGenders.length == _genderValues.length,
          'RENDERED_GENDER_COUNT_NOT_5',
          '${observedGenders.length}',
        );
        failures.check(
          observedContexts.length == 49,
          'RENDERED_CONTEXT_COUNT_NOT_49',
          '${observedContexts.length}',
        );
        failures.check(
          observedLagna.length == 12,
          'RENDERED_LAGNA_COUNT_NOT_12',
          '${observedLagna.length}',
        );
        failures.check(
          observedPeriods.length == 392,
          'RENDERED_PERIOD_COUNT_NOT_392',
          '${observedPeriods.length}',
        );
        failures.expectNone();
        // ignore: avoid_print
        print(
          'KNOWN_REPORT_MATRIX cases=$cases minutes=${observedMinutes.length} '
          'hours=${observedHours.length} provinces=${observedProvinces.length} '
          'civilWeekdays=${observedCivilWeekdays.length} '
          'astrologicalWeekdays=${observedAstrologicalWeekdays.length} '
          'genders=${observedGenders.length} lagna=${observedLagna.length} '
          'contexts=${observedContexts.length} periods=${observedPeriods.length} '
          'documents=$documents',
        );
      },
      timeout: const Timeout(Duration(minutes: 8)),
    );

    test(
      'unknown time stays explicitly fail-closed in every province and weekday',
      () {
        final failures = _FailureLedger();
        var cases = 0;
        for (var dayIndex = 0; dayIndex < 7; dayIndex++) {
          final date = _sevenCivilWeekdayDates[dayIndex];
          for (
            var provinceIndex = 0;
            provinceIndex < kThaiProvincesAll.length;
            provinceIndex++
          ) {
            final province = kThaiProvincesAll[provinceIndex];
            final label = '${_isoDate(date)}|${province.key}|unknown-time';
            final analysis = ThaiBetaAnalysisRunner.run(
              ThaiBetaInput(
                firstName: 'Unknown',
                lastName: 'Matrix',
                birthDate: date,
                birthHour: null,
                birthMinute: 0,
                birthTimeUnknown: true,
                province: province.nameTh,
                provinceKey: province.key,
                gender:
                    _genderValues[(dayIndex + provinceIndex) %
                        _genderValues.length],
              ),
              asOf: _asOf,
            );
            cases++;
            if (!analysis.isSuccess) {
              failures.add(
                'UNKNOWN_ANALYSIS_FAILED',
                label,
                analysis.errorMessage,
              );
              continue;
            }
            final document = ThaiBetaReportExportDocument.candidate(analysis);
            final plan = document.predictiveRuntimeV2;
            failures.check(plan != null, 'UNKNOWN_PLAN_MISSING', label);
            if (plan == null) continue;
            failures.check(!plan.knownTime, 'UNKNOWN_MARKED_KNOWN', label);
            failures.check(
              plan.contextId == 'unknown-time',
              'UNKNOWN_CONTEXT_MISMATCH',
              label,
            );
            failures.check(
              plan.emittedClaims.isEmpty && plan.knownToUnknownLeakage == 0,
              'UNKNOWN_PREDICTION_LEAKAGE',
              label,
            );
            failures.check(
              document.infographic == null,
              'UNKNOWN_INFOGRAPHIC_LEAKAGE',
              label,
            );
            failures.check(
              document.fullPlainText.contains('ไม่ทราบเวลาเกิด') &&
                  document.fullPlainText.contains('เว้น'),
              'UNKNOWN_OMISSION_NOT_EXPLAINED',
              label,
            );
          }
        }
        failures.check(cases == 539, 'UNKNOWN_CASE_COUNT_NOT_539', '$cases');
        failures.expectNone();
        // ignore: avoid_print
        print('UNKNOWN_MATRIX cases=$cases provinces=77 weekdays=7');
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}

void _checkCompleteKnownPlan(
  _FailureLedger failures,
  String label,
  ThaiPredictiveRuntimeV2Plan plan, {
  required String expectedClock,
  required String expectedProvince,
  String? expectedContext,
  String? expectedPeriod,
}) {
  failures.check(plan.knownTime, 'KNOWN_MARKED_UNKNOWN', label);
  failures.check(
    runtimePredictiveV2ContextIds.contains(plan.contextId),
    'UNSUPPORTED_CONTEXT',
    '$label|${plan.contextId}',
  );
  if (expectedContext != null) {
    failures.check(
      plan.contextId == expectedContext,
      'CONTEXT_BOUNDARY_MISMATCH',
      '$label|actual=${plan.contextId}',
    );
  }
  if (expectedPeriod != null) {
    failures.check(
      plan.currentPeriod?.matrixApplicationId == expectedPeriod,
      'PERIOD_BOUNDARY_MISMATCH',
      '$label|actual=${plan.currentPeriod?.matrixApplicationId}',
    );
  }
  failures.check(
    plan.currentAge != null && plan.currentPeriod != null,
    'CURRENT_AGE_OR_PERIOD_MISSING',
    label,
  );
  failures.check(
    plan.missingSemanticOwners.isEmpty,
    'MISSING_SEMANTIC_OWNER',
    '$label|${plan.missingSemanticOwners.join(',')}',
  );
  failures.check(!plan.baselineFallbackUsed, 'BASELINE_FALLBACK_USED', label);
  failures.check(
    plan.emittedClaims.length >= 12 && plan.emittedClaims.length <= 13,
    'EMITTED_CLAIM_COUNT_OUTSIDE_12_TO_13',
    '$label|${plan.emittedClaims.length}',
  );
  failures.check(
    plan.emittedPredictions >= 9,
    'PREDICTION_COUNT_BELOW_9',
    '$label|${plan.emittedPredictions}',
  );
  failures.check(plan.omittedClaims.isEmpty, 'CLAIMS_OMITTED', label);
  failures.check(plan.unsupportedClaims == 0, 'UNSUPPORTED_CLAIMS', label);
  failures.check(
    plan.fixtureSpecificBranches == 0 && plan.fixtureReferenceLeakage == 0,
    'FIXTURE_BRANCH_OR_LEAKAGE',
    label,
  );
  final bindingErrors = RuntimePredictiveClaimBindingValidator.validate(plan);
  failures.check(
    bindingErrors.isEmpty,
    'CLAIM_BINDING_ERROR',
    '$label|${bindingErrors.take(3).join(',')}',
  );
  failures.check(
    plan.subtitle.contains('เวลา $expectedClock น.') &&
        plan.subtitle.contains('จังหวัด$expectedProvince'),
    'KNOWN_IDENTITY_COPY_INCOMPLETE',
    '$label|${plan.subtitle.replaceAll('\n', '/')}',
  );
  final current = plan.claimForOwner('current');
  failures.check(
    current != null && current.text.startsWith('ปัจจุบัน'),
    'CURRENT_INTRO_NOT_PRESENT_TENSE',
    '$label|${current?.text}',
  );
  final relationship = plan.claimForOwner('relationship');
  if ((plan.currentAge ?? 0) >= 18) {
    failures.check(
      relationship != null &&
          relationship.text.contains('คนมีคู่') &&
          relationship.text.contains('คนโสด'),
      'ADULT_RELATIONSHIP_AUDIENCE_INCOMPLETE',
      '$label|${relationship?.text}',
    );
  }
  final rolling = plan.claimForOwner('rolling12');
  failures.check(
    rolling != null &&
        rolling.text.contains('จะเด่นเรื่อง') &&
        rolling.text.contains('และเด่นเรื่อง'),
    'ROLLING_HIGHLIGHTS_INCOMPLETE',
    '$label|${rolling?.text}',
  );
  final pastHeadings = plan.sections
      .where((section) => section.title == 'คำทำนายอดีต')
      .length;
  failures.check(
    pastHeadings == 1,
    'PAST_CHAPTER_HEADING_COUNT_NOT_1',
    '$label|$pastHeadings',
  );
  failures.check(
    !plan.sections.any(
      (section) => RegExp(r'(^|—\s*)อายุ 0[–-]').hasMatch(section.title),
    ),
    'ZERO_BASED_PAST_RANGE_PRESENT',
    label,
  );
}

void _checkCompleteKnownDocument(
  _FailureLedger failures,
  String label,
  ThaiBetaReportExportDocument document,
) {
  final plan = document.predictiveRuntimeV2!;
  failures.check(
    document.infographic != null,
    'KNOWN_INFOGRAPHIC_MISSING',
    label,
  );

  final currentSections = document.sections
      .where((section) => section.id == 'report-body-predictive-v2-current')
      .toList(growable: false);
  failures.check(
    currentSections.length == 1,
    'CURRENT_READER_SECTION_COUNT_NOT_1',
    '$label|${currentSections.length}',
  );
  if (currentSections.length == 1) {
    final current = currentSections.single;
    const leads = <String>[
      'ปัจจุบัน',
      'ด้านการงาน',
      'ด้านการเงิน',
      'ด้านความรักและความสัมพันธ์',
      'ด้านสุขภาพ',
      'ด้านโชคลาภและแรงสนับสนุน',
    ];
    failures.check(
      current.paragraphs.length == leads.length,
      'CURRENT_PARAGRAPH_COUNT_NOT_6',
      '$label|${current.paragraphs.length}',
    );
    for (
      var index = 0;
      index < current.paragraphs.length && index < leads.length;
      index++
    ) {
      failures.check(
        current.paragraphs[index].startsWith(leads[index]),
        'CURRENT_PARAGRAPH_LEAD_MISMATCH',
        '$label|$index|${current.paragraphs[index]}',
      );
    }
  }
  const forbiddenStandaloneCurrentTitles = <String>{
    'การงาน',
    'การเงิน',
    'ความรักและความสัมพันธ์',
    'สุขภาพ',
    'โชคลาภและแรงสนับสนุน',
  };
  failures.check(
    !document.sections.any(
      (section) =>
          section.id.contains('predictive-v2-') &&
          forbiddenStandaloneCurrentTitles.contains(section.title),
    ),
    'CURRENT_DOMAIN_SUBHEADING_PRESENT',
    label,
  );
  failures.check(
    document.sections.isNotEmpty && document.sections.last.title == 'ข้อจำกัด',
    'LIMITATIONS_NOT_ABSOLUTE_FINAL',
    '$label|last=${document.sections.isEmpty ? '<empty>' : document.sections.last.title}',
  );
  final provenanceIndex = document.sections.indexWhere(
    (section) => section.title == 'ที่มาของผลวิเคราะห์',
  );
  final limitationsIndex = document.sections.lastIndexWhere(
    (section) => section.title == 'ข้อจำกัด',
  );
  failures.check(
    provenanceIndex >= 0 && limitationsIndex > provenanceIndex,
    'LIMITATIONS_NOT_AFTER_PROVENANCE',
    '$label|$provenanceIndex/$limitationsIndex',
  );

  final chartSections = document.sections
      .where((section) => section.title == 'โครงสร้างดวงหลัก')
      .toList(growable: false);
  failures.check(
    chartSections.length == 1,
    'MAIN_CHART_SECTION_COUNT_NOT_1',
    '$label|${chartSections.length}',
  );
  if (chartSections.length == 1) {
    failures.check(
      chartSections.single.paragraphs.length == 7,
      'MAIN_CHART_FACT_COUNT_NOT_7',
      '$label|${chartSections.single.paragraphs.length}',
    );
    failures.check(
      chartSections.single.paragraphs.every(
        (paragraph) => !paragraph.contains(' — '),
      ),
      'MAIN_CHART_EXPLANATORY_TAIL_PRESENT',
      label,
    );
  }

  final lifePeriodSections = plan.sections.where(
    (section) =>
        section.claims.isNotEmpty &&
        (section.id.startsWith('past-') ||
            section.id == 'current' ||
            section.id == 'next-life-period'),
  );
  failures.check(
    lifePeriodSections.isNotEmpty &&
        lifePeriodSections.every(
          (section) => RegExp(r'ดาว.+เสวยอายุ').hasMatch(section.title),
        ),
    'LIFE_PERIOD_PLANET_LABEL_MISSING',
    label,
  );
  failures.check(
    !document.fullPlainText.contains('{{'),
    'UNRESOLVED_TEMPLATE_PLACEHOLDER',
    label,
  );
  failures.check(
    document.sections.every(
      (section) =>
          section.title.trim().isNotEmpty &&
          section.paragraphs.every((paragraph) => paragraph.trim().isNotEmpty),
    ),
    'EMPTY_READER_TITLE_OR_PARAGRAPH',
    label,
  );
}

Map<String, ThaiBetaInput> _contextRepresentatives(_FailureLedger failures) {
  final representatives = <String, ThaiBetaInput>{};
  var date = DateTime(1975, 1, 1);
  final end = DateTime(1985, 1, 1);
  while (representatives.length < 49 && date.isBefore(end)) {
    final input = ThaiBetaInput(
      firstName: 'Context',
      lastName: 'Representative',
      birthDate: date,
      birthHour: 12,
      birthMinute: 0,
      birthTimeUnknown: false,
      province: 'เชียงใหม่',
      provinceKey: 'chiang mai',
      gender: 'ไม่ระบุ',
    );
    final analysis = ThaiBetaAnalysisRunner.run(input, asOf: _asOf);
    if (!analysis.isSuccess) {
      failures.add(
        'CONTEXT_SEARCH_ANALYSIS_FAILED',
        _isoDate(date),
        analysis.errorMessage,
      );
    } else {
      final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(analysis);
      if (runtimePredictiveV2ContextIds.contains(plan.contextId)) {
        representatives.putIfAbsent(plan.contextId, () => input);
      }
    }
    date = date.add(const Duration(days: 1));
  }
  return representatives;
}

DateTime _anniversaryAtAge(DateTime birthDate, int age) {
  final year = birthDate.year + age;
  final lastDay = DateTime(year, birthDate.month + 1, 0).day;
  return DateTime(
    year,
    birthDate.month,
    birthDate.day > lastDay ? lastDay : birthDate.day,
  );
}

final _sevenCivilWeekdayDates = List<DateTime>.generate(
  7,
  (index) => DateTime(1982, 6, 7).add(Duration(days: index)),
  growable: false,
);

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _clock(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

class _FailureLedger {
  static const _exampleLimit = 30;

  var count = 0;
  final examples = <String>[];

  void check(bool condition, String code, String label) {
    if (!condition) add(code, label);
  }

  void add(String code, String label, [Object? detail]) {
    count++;
    if (examples.length >= _exampleLimit) return;
    examples.add('$code|$label${detail == null ? '' : '|$detail'}');
  }

  void expectNone() {
    expect(count, 0, reason: examples.join('\n'));
  }
}
