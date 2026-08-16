import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_context.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_report_narrative_plan.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

void main() {
  final fixtures = <String, ThaiBetaInput>{
    'owner-known-0035': _owner(known: true, minute: 35),
    'owner-unknown': _owner(known: false),
    'regression-known-0003': _owner(known: true, minute: 3),
    'comparison-known-bangkok': ThaiBetaInput(
      firstName: 'Comparison',
      lastName: 'Fixture',
      birthDate: DateTime(1991, 11, 18),
      birthHour: 14,
      birthMinute: 20,
      province: 'กรุงเทพมหานคร',
      provinceKey: 'bangkok',
    ),
    'comparison-known-khon-kaen': ThaiBetaInput(
      firstName: 'Comparison',
      lastName: 'Fixture',
      birthDate: DateTime(1974, 2, 27),
      birthHour: 6,
      birthMinute: 45,
      province: 'ขอนแก่น',
      provinceKey: 'khon_kaen',
    ),
  };

  late Map<String, ThaiBetaAnalysis> analyses;
  late Map<String, ThaiBetaReportNarrativePlan> plans;

  setUpAll(() {
    analyses = {
      for (final entry in fixtures.entries) entry.key: _run(entry.value),
    };
    plans = {
      for (final entry in analyses.entries)
        entry.key: ThaiBetaReportNarrativePlan.fromPrediction(
          prediction: entry.value.consumerViewState!.futurePrediction,
          context: ThaiBetaNarrativeContext.fromAnalysis(entry.value),
        ),
    };
  });

  test('materially different reports have distinct hook headline and body', () {
    final byMaterial = <String, ({String headline, String hook, String id})>{};
    for (final entry in analyses.entries) {
      final plan = plans[entry.key]!;
      final view = ThaiBetaNarrativeComposer.narrativeView(entry.value);
      final existing = byMaterial[plan.materialIdentity];
      if (existing != null) {
        expect(view.hero.headline, existing.headline, reason: entry.key);
        expect(view.hero.summary.split('\n\n').first, existing.hook);
      } else {
        byMaterial[plan.materialIdentity] = (
          headline: view.hero.headline,
          hook: view.hero.summary.split('\n\n').first,
          id: entry.key,
        );
      }
    }
    final groups = byMaterial.values.toList(growable: false);
    for (var left = 0; left < groups.length; left++) {
      for (var right = left + 1; right < groups.length; right++) {
        expect(
          groups[left].headline,
          isNot(groups[right].headline),
          reason: '${groups[left].id} / ${groups[right].id}',
        );
        expect(
          _normalize(groups[left].hook),
          isNot(_normalize(groups[right].hook)),
          reason: '${groups[left].id} / ${groups[right].id}',
        );
      }
    }
  });

  test('all rendered forecasts cover 4x3 and each horizon adds a new kind', () {
    for (final entry in analyses.entries) {
      final view = ThaiBetaNarrativeComposer.narrativeView(entry.value);
      final text = ThaiBetaReportExportDocument.fromAnalysis(
        entry.value,
      ).fullPlainText;
      final windows = view.futurePrediction!.windows;
      expect(windows, hasLength(3), reason: entry.key);
      expect(windows.every((window) => window.domains.length == 4), isTrue);
      expect(windows[0].summary, contains('ตัดสินใจ'));
      expect(windows[1].summary, contains('สัญญาณ'));
      expect(windows[2].summary, contains('ช่วงชีวิตถัดไป'));
      for (final window in windows) {
        for (final domain in window.domains) {
          expect(
            text,
            contains(domain.body),
            reason: '${entry.key}:${domain.title}',
          );
        }
      }
    }
  });

  test(
    'Unknown-time boundary is report-level and never repeated per domain',
    () {
      final analysis = analyses['owner-unknown']!;
      final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
      final text = ThaiBetaReportExportDocument.fromAnalysis(
        analysis,
      ).fullPlainText;
      final boundary = view
          .futurePrediction!
          .windows
          .first
          .domains
          .first
          .uncertaintyDisclosure;
      expect(boundary, isNotEmpty);
      expect(boundary.allMatches(text), hasLength(1));
      for (final domain in view.futurePrediction!.windows.expand(
        (window) => window.domains,
      )) {
        expect(
          domain.body,
          isNot(matches(RegExp(r'ไม่มีเวลาเกิด|ลัคนา|เรือน|ดาว'))),
          reason: domain.title,
        );
        expect(
          domain.body,
          isNot(contains('และต้องยืนยันจากสิ่งที่เกิดซ้ำเพราะไม่มีเวลาเกิด')),
        );
      }
      expect(view.hero.headline, isNot(plans['owner-known-0035']!.headline));
    },
  );

  test(
    'past is one disclaimer plus distinct theme and reflection per period',
    () {
      for (final entry in analyses.entries) {
        final view = ThaiBetaNarrativeComposer.narrativeView(entry.value);
        final text = ThaiBetaReportExportDocument.fromAnalysis(
          entry.value,
        ).fullPlainText;
        const disclosure =
            'ส่วนนี้ใช้ตั้งคำถามกับความทรงจำจริง ไม่ใช่ข้อสรุปว่าเหตุการณ์ใดเคยเกิดขึ้น';
        expect(disclosure.allMatches(text), hasLength(1), reason: entry.key);
        expect(
          'นี่เป็นกรอบตั้งคำถาม ไม่ใช่ข้อสรุป'.allMatches(text),
          isEmpty,
          reason: entry.key,
        );
        final past = view.lifeTimeline!.periods.where(
          (period) => period.isPast,
        );
        final reflections = <String>[];
        for (final period in past) {
          expect(period.summary, startsWith('ธีมสำหรับทบทวน:'));
          expect(period.whatChanges, startsWith('คำถามสะท้อน:'));
          expect(period.lifeDomains, isEmpty);
          reflections.add('${period.summary}\n${period.whatChanges}');
        }
        expect(reflections.toSet(), hasLength(reflections.length));
      }
    },
  );

  test(
    'technical chart labels stay in methodology, not consumer paragraphs',
    () {
      for (final entry in analyses.entries.where(
        (entry) => entry.value.input.hasBirthTime,
      )) {
        final view = ThaiBetaNarrativeComposer.narrativeView(entry.value);
        final reading = ThaiBirthProfileCoreReading.fromAnalysis(
          entry.value,
          consumerView: view,
        );
        final consumer = reading.sections
            .where((section) => !section.isMethodology)
            .expand((section) => section.paragraphs)
            .join('\n');
        expect(consumer, isNot(matches(RegExp(r'^ราศี', multiLine: true))));
        expect(consumer, isNot(contains('เรือนนี้')));
        final methodology = reading.sections.singleWhere(
          (section) => section.isMethodology,
        );
        expect(methodology.factRows, isNotEmpty);
        expect(
          methodology.factRows.map((row) => row.publicText).join('\n'),
          contains('ราศี'),
        );
      }
    },
  );

  test(
    'consumer prose has no rejected patterns or repeated long templates',
    () {
      const forbidden = <String>[
        'ใช้ความมั่นคงที่สร้างทีละขั้น',
        'ระยะยาว ให้เก็บ',
        'และต้องยืนยันจากสิ่งที่เกิดซ้ำเพราะไม่มีเวลาเกิด',
        'กดให้เงินพร้อมใช้ยังไม่ถูกเบียดยากขึ้น',
        'เพื่อไม่ให้การพักฟื้นแรงไม่ทัน',
        'คุณถูกผลักให้',
        'ร่างกายและใจถูกใช้จนสุดแรง',
        'คุณต้องแบกงานหลายเรื่อง',
        'น้ำหนักเด่น',
        'น้ำหนักปานกลาง',
        'น้ำหนักเบา',
        'คาบเกี่ยวรอยต่อ',
      ];
      for (final entry in analyses.entries) {
        final view = ThaiBetaNarrativeComposer.narrativeView(entry.value);
        final text = ThaiBetaReportExportDocument.fromAnalysis(
          entry.value,
        ).fullPlainText;
        expect(text, isNot(contains(';')), reason: entry.key);
        for (final phrase in forbidden) {
          expect(text, isNot(contains(phrase)), reason: '${entry.key}:$phrase');
        }
        final bodies = view.futurePrediction!.windows
            .expand((window) => window.domains)
            .map((domain) => _normalize(domain.body))
            .toList(growable: false);
        expect(bodies.toSet(), hasLength(bodies.length));
        for (var left = 0; left < bodies.length; left++) {
          for (var right = left + 1; right < bodies.length; right++) {
            expect(
              _ngramSimilarity(bodies[left], bodies[right]),
              lessThan(0.72),
              reason: '${entry.key}:$left/$right',
            );
          }
        }
      }
    },
  );
}

ThaiBetaInput _owner({required bool known, int minute = 0}) => ThaiBetaInput(
  firstName: 'Acceptance',
  lastName: 'Fixture',
  birthDate: DateTime(1982, 6, 6),
  birthHour: known ? 0 : null,
  birthMinute: known ? minute : 0,
  birthTimeUnknown: !known,
  province: 'เชียงใหม่',
  provinceKey: 'chiang_mai',
);

ThaiBetaAnalysis _run(ThaiBetaInput input) =>
    ThaiBetaAnalysisRunner.run(input, startedAt: DateTime(2026, 8, 7));

String _normalize(String value) => value
    .replaceAll(RegExp(r'\s+'), '')
    .replaceAll(RegExp(r'[\-–—:;,.!?()•]'), '')
    .toLowerCase();

double _ngramSimilarity(String left, String right) {
  Set<String> grams(String value) {
    const width = 12;
    if (value.length < width) return {value};
    return {
      for (var index = 0; index <= value.length - width; index++)
        value.substring(index, index + width),
    };
  }

  final leftGrams = grams(left);
  final rightGrams = grams(right);
  final union = leftGrams.union(rightGrams);
  if (union.isEmpty) return 0;
  return leftGrams.intersection(rightGrams).length / union.length;
}
