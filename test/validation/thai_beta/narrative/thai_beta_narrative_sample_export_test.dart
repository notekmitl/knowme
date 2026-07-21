import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_forbidden.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

import 'thai_beta_narrative_fixtures.dart';

String _composedNarrativeText(ThaiBetaAnalysis Function() fixture) {
  final view = ThaiBetaNarrativeComposer.compose(fixture()).view;
  final buf = StringBuffer()
    ..writeln(view.hero.headline)
    ..writeln(view.hero.summary)
    ..writeln(view.advice.body);
  for (final card in view.strengths.cards) {
    buf
      ..writeln(card.title)
      ..writeln(card.body)
      ..writeln(card.expandedBody ?? '');
  }
  for (final item in view.lifeDashboard) {
    buf
      ..writeln(item.currentState)
      ..writeln(item.whyItAppears)
      ..writeln(item.suggestedAction);
  }
  for (final section in view.narrativeSections) {
    buf
      ..writeln(section.overview)
      ..writeln(section.whyItAppears)
      ..writeln(section.advice);
  }
  return buf.toString();
}

/// Writes sample exports to build/ (local QA artifact — not committed).
void main() {
  test('write fixture A/B sample exports V1.1', () {
    final outDir = Directory('build/thai_beta_narrative_samples_v11');
    outDir.createSync(recursive: true);

    for (final entry in [
      ('fixture_a_with_time', ThaiBetaNarrativeFixtures.fixtureA),
      ('fixture_b_no_time', ThaiBetaNarrativeFixtures.fixtureB),
    ]) {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(entry.$2());
      expect(
        ThaiBetaNarrativeForbidden.findForbidden(_composedNarrativeText(entry.$2)),
        isEmpty,
      );
      File('${outDir.path}/${entry.$1}.txt').writeAsStringSync(doc.fullPlainText);
    }
    expect(outDir.existsSync(), isTrue);
  });
}
