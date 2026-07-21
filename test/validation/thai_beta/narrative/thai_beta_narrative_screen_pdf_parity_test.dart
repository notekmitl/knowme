import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';

import 'thai_beta_narrative_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Screen / PDF parity', () {
    test('screen narrative equals export narrative for hero', () {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      final screen = ThaiBetaNarrativeComposer.narrativeView(analysis);
      final export = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      expect(export.fullPlainText, contains(screen.hero.headline));
      expect(export.fullPlainText, contains(screen.hero.summary.split('\n\n').first));
    });

    test('PDF text uses same polished narrative', () async {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      final doc = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final result = await ThaiBetaReportPdfExporter.build(doc);
      expect(result.plainText, contains(
        ThaiBetaNarrativeComposer.narrativeView(analysis).hero.headline,
      ));
    });

    test('input with no birth time preserves limitation wording', () {
      final analysis = ThaiBetaNarrativeFixtures.fixtureB();
      final screen = ThaiBetaNarrativeComposer.narrativeView(analysis);
      final export = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      expect(screen.hero.summary, contains('ไม่มีเวลาเกิด'));
      expect(export.fullPlainText, contains('ไม่มีเวลาเกิด'));
    });

    test('engine traits unchanged after narrative compose', () {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      final engineTags = analysis.consumerViewState!.hero.tags;
      final composed = ThaiBetaNarrativeComposer.narrativeView(analysis);
      expect(composed.hero.tags, engineTags.take(3).toList());
    });
  });
}
