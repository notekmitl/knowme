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
          // Closing intentionally keeps Strength → Risk → Action in one
          // context; it may be longer than a single domain sentence.
          'longParagraphs': webParagraphs.where((p) => p.length > 320).length,
          'unexplainedTerms': _countMatches(webText, const [
            'sidereal',
            'ayanamsa',
            'whole-sign',
          ]),
          'systemLanguage': _countMatches(webText, const [
            'ระบบใช้',
            'ระบบคำนวณ',
            'แนวโน้มเด่น',
            'LEVEL 1 Canon',
            'Controlled beta',
            'Analytical',
            'Persistence',
            'Visionary',
          ]),
          'deterministicLanguage': _countMatches(webText, const [
            'คุณต้อง',
            'เกิดมาเพื่อ',
            'ดวงกำหนด',
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
          if (section.domain == ThaiBirthProfileCoreDomain.methodology) {
            // The PDF keeps the shared methodology facts, with short
            // subheadings added for scanability inside the final section.
            expect(
              exported.single.paragraphs,
              containsAll(section.publicParagraphs),
              reason: '${entry.key}: ${section.title}',
            );
          } else {
            expect(
              exported.single.paragraphs,
              orderedEquals(section.publicParagraphs),
              reason: '${entry.key}: ${section.title}',
            );
          }
        }
        for (final domain in const [
          ThaiBirthProfileCoreDomain.work,
          ThaiBirthProfileCoreDomain.money,
          ThaiBirthProfileCoreDomain.relationships,
          ThaiBirthProfileCoreDomain.wellbeing,
        ]) {
          final matching = reading.sections.where((s) => s.domain == domain);
          if (matching.isEmpty) continue;
          final domainText = matching.single.paragraphs.join('\n');
          // V1.5 gives each domain one supported synthesis; prioritised advice
          // belongs in the report ending instead of every domain card.
          expect(
            matching.single.claims.where(
              (claim) => claim.role == ThaiBirthProfileCoreClaimRole.synthesis,
            ),
            hasLength(1),
          );
          expect(domainText, isNot(contains('แนวโน้มหลัก:')));
          expect(domainText, isNot(contains('สิ่งที่ควรระวัง:')));
          expect(domainText, isNot(contains('สิ่งที่นำไปใช้ได้:')));
        }
        final methodology = reading.sections.singleWhere(
          (section) => section.isMethodology,
        );
        if (analysis.input.hasBirthTime) {
          expect(
            methodology.paragraphs.join('\n'),
            contains('วันเกิดตามสูติบัตร'),
          );
          expect(
            methodology.paragraphs.join('\n'),
            contains('วันทางโหราศาสตร์'),
          );
        } else {
          expect(
            methodology.paragraphs.join('\n'),
            contains('วันทางโหราศาสตร์อาจเป็นวันก่อนหน้า'),
          );
        }
        if (analysis.input.hasBirthTime) {
          expect(methodology.factRows, isNotEmpty, reason: entry.key);
        } else {
          expect(methodology.factRows, isNotEmpty, reason: entry.key);
          expect(methodology.factRows.first.label, 'ฐานวันตามปฏิทิน');
        }
        expect(renderedPdf.plainText, isNot(contains('internal/beta')));
        expect(renderedPdf.plainText, isNot(contains('capture / screenshot')));
        expect(renderedPdf.plainText, isNot(contains('Canon')));
        final closingSections = reading.sections.where(
          (section) =>
              section.title == ThaiBirthProfileCoreReadingCopy.closingTitle,
        );
        if (closingSections.isNotEmpty) {
          final closing = closingSections.single;
          expect(closing.claims, hasLength(1), reason: entry.key);
          expect(closing.claims.single.text, startsWith('แก่นของช่วง'));
        }
        if (reading.omissions.isEmpty) {
          expect(
            pdf.sections.where(
              (section) =>
                  section.title ==
                  ThaiBirthProfileCoreReadingCopy.omissionsTitle,
            ),
            isEmpty,
          );
        } else {
          expect(
            pdf.sections.last.title,
            ThaiBirthProfileCoreReadingCopy.omissionsTitle,
          );
          expect(
            pdf.sections.last.paragraphs,
            containsAll(reading.omissions.map((item) => item.publicText)),
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

  test('known-time report closes from an exact computed fallback fact', () {
    final analysis = _genderFixture(
      gender: 'unspecified',
      birthDate: DateTime(2001, 1, 15),
      province: 'กาญจนบุรี',
      provinceKey: 'kanchanaburi',
    );
    final reading = ThaiBirthProfileCoreReading.fromAnalysis(analysis);
    final closing = reading.sections.singleWhere(
      (section) =>
          section.title == ThaiBirthProfileCoreReadingCopy.closingTitle,
    );

    expect(closing.claims, hasLength(1));
    expect(closing.claims.single.text, startsWith('แก่นของช่วง'));
    expect(closing.claims.single.evidenceKeys, isNotEmpty);
    expect(
      closing.claims.single.sourceAtoms.every(
        (atom) => atom.sourceRef.isNotEmpty && atom.rawValue.isNotEmpty,
      ),
      isTrue,
    );
  });
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
