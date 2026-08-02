import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import '../narrative/thai_beta_narrative_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fixtures = <String, ThaiBetaAnalysis Function()>{
    'fixture-a-known-time': ThaiBetaNarrativeFixtures.fixtureA,
    'fixture-b-no-time': ThaiBetaNarrativeFixtures.fixtureB,
    'fixture-c-known-time-male': () => _genderFixture(
      gender: 'male',
      birthDate: DateTime(1990, 8, 20),
      province: 'เชียงใหม่',
      provinceKey: 'chiang_mai',
    ),
    'fixture-d-known-time-female': () => _genderFixture(
      gender: 'female',
      birthDate: DateTime(1982, 4, 5),
      province: 'กรุงเทพมหานคร',
      provinceKey: 'bangkok',
    ),
    'fixture-e-younger-known-time': ThaiBetaNarrativeFixtures.fixtureE,
    'fixture-wednesday-day': ThaiBetaNarrativeFixtures.wednesdayDaytime,
    'fixture-wednesday-night':
        ThaiBetaNarrativeFixtures.wednesdayNightBeforeSunrise,
    'fixture-wednesday-no-time': ThaiBetaNarrativeFixtures.wednesdayNoBirthTime,
  };

  test(
    'eight deterministic Web and rendered PDF reports pass readability',
    () async {
      final audit = <String, Map<String, int>>{};
      for (final entry in fixtures.entries) {
        final analysis = entry.value();
        final reading = ThaiBirthProfileCoreReading.fromAnalysis(analysis);
        final pdf = ThaiBetaReportExportDocument.fromAnalysis(analysis);
        final webParagraphs = reading.sections
            .expand((section) => section.publicParagraphs)
            .toList(growable: false);
        final webText = webParagraphs.join('\n');
        final metrics = <String, int>{
          'longParagraphs': webParagraphs.where((p) => p.length > 220).length,
          'unexplainedTerms': _countMatches(webText, const [
            'ลัคนาอยู่ที่',
            'เจ้าเรือน',
            'เรือนการงาน',
            'เรือนการเงิน',
          ]),
          'systemLanguage': _countMatches(webText, const [
            'ระบบใช้',
            'ระบบคำนวณ',
            'แนวโน้มเด่น',
          ]),
          'deterministicLanguage': _countMatches(webText, const [
            'ทำให้บุคลิก',
            'ภาพงานจึง',
            'จึงควร',
          ]),
          'exactDuplicates':
              webParagraphs.length -
              webParagraphs.map(_normalize).toSet().length,
        };
        audit[entry.key] = metrics;
        final renderedPdf = await ThaiBetaReportPdfExporter.build(pdf);

        expect(analysis.isSuccess, isTrue, reason: entry.key);
        expect(reading.sections, isNotEmpty, reason: entry.key);
        expect(pdf.sections, isNotEmpty, reason: entry.key);
        expect(
          renderedPdf.bytes,
          isNotEmpty,
          reason: '${entry.key}: PDF bytes',
        );
        expect(
          renderedPdf.plainText,
          contains(ThaiBirthProfileCoreReading.reportTitle),
          reason: '${entry.key}: rendered PDF Core Reading',
        );
        for (final section in reading.sections) {
          final exported = pdf.sections.where(
            (item) => item.title == section.title,
          );
          expect(
            exported,
            hasLength(1),
            reason: '${entry.key}: ${section.title}',
          );
          expect(
            exported.single.paragraphs,
            orderedEquals(section.publicParagraphs),
            reason: '${entry.key}: ${section.title}',
          );
        }
        expect(
          metrics.values.every((count) => count == 0),
          isTrue,
          reason: '${entry.key}: $metrics',
        );
        final claims = reading.sections
            .expand((section) => section.claims)
            .toList();
        for (var left = 0; left < claims.length; left++) {
          for (var right = left + 1; right < claims.length; right++) {
            expect(
              ThaiBirthProfileCoreClaimDeduplicator.isNearDuplicate(
                claims[left],
                claims[right],
              ),
              isFalse,
              reason:
                  '${entry.key}: ${claims[left].semanticKey} / '
                  '${claims[right].semanticKey}',
            );
          }
        }
        expect(
          webText,
          isNot(
            matches(RegExp(r'(unit\.|ontology\.|themeId|sourceRef|uid[:=])')),
          ),
          reason: '${entry.key}: internal identifiers',
        );
      }
      // Printed data is fixture-only and records the post-fix comparison.
      // ignore: avoid_print
      print('READABILITY_AFTER=$audit');
      expect(audit, hasLength(8));
    },
  );
}

int _countMatches(String text, List<String> markers) =>
    markers.fold(0, (count, marker) => count + marker.allMatches(text).length);

String _normalize(String value) =>
    value.replaceAll(RegExp(r'[\s·•:;,.!?()\-–—]+'), '').toLowerCase();

ThaiBetaAnalysis _genderFixture({
  required String gender,
  required DateTime birthDate,
  required String province,
  required String provinceKey,
}) => ThaiBetaAnalysisRunner.run(
  ThaiBetaInput(
    firstName: 'Fixture',
    lastName: gender,
    birthDate: birthDate,
    birthHour: 10,
    birthMinute: 30,
    province: province,
    provinceKey: provinceKey,
    gender: gender,
  ),
  startedAt: ThaiBetaNarrativeFixtures.referenceDate,
);
