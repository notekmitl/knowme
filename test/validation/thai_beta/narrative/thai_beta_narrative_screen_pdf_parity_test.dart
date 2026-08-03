import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';

import 'thai_beta_narrative_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Screen / PDF parity', () {
    test('PDF starts from the authoritative Core Reading, not legacy hero', () {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      final screen = ThaiBetaNarrativeComposer.narrativeView(analysis);
      final core = ThaiBirthProfileCoreReading.fromAnalysis(analysis);
      final export = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      expect(export.sections.first.title, core.title);
      expect(export.fullPlainText, isNot(contains(screen.hero.headline)));
      for (final section in core.sections) {
        final exported = export.sections.singleWhere(
          (candidate) => candidate.title == section.title,
        );
        expect(exported.paragraphs, section.publicParagraphs);
      }
    });

    test('PDF text uses same polished narrative', () async {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final result = await ThaiBetaReportPdfExporter.build(doc);
      expect(result.plainText, doc.fullPlainText);
      expect(
        result.plainText,
        contains(ThaiBirthProfileCoreReading.reportTitle),
      );
      expect(
        result.plainText,
        isNot(
          contains(ThaiBetaNarrativeComposer.narrativeView(analysis).hero.headline),
        ),
      );
    });

    test('unknown-time disclosure lives in Core Reading only when needed', () {
      final known = ThaiBetaNarrativeFixtures.fixtureA();
      final analysis = ThaiBetaNarrativeFixtures.fixtureB();
      final export = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      expect(export.fullPlainText, contains('ไม่มีเวลาเกิด'));
      expect(
        ThaiBetaReportExportDocument.fromAnalysis(known).fullPlainText,
        isNot(contains('ไม่มีเวลาเกิด')),
      );
    });

    test('engine traits unchanged after narrative compose', () {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      final engineTags = analysis.consumerViewState!.hero.tags;
      final composed = ThaiBetaNarrativeComposer.narrativeView(analysis);
      expect(composed.hero.tags, engineTags.take(3).toList());
    });
  });
}
