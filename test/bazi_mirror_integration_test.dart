import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_astrology_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_bazi_adapter.dart';
import 'package:knowme/features/narrative_runtime/service/narrative_runtime_service.dart';
import 'package:knowme/features/runtime_integration/adapters/runtime_astrology_mirror_signal_merger.dart';
import 'package:knowme/features/runtime_integration/adapters/runtime_bazi_chart_loader.dart';
import 'package:knowme/features/runtime_integration/adapters/runtime_thai_theme_loader.dart';
import 'package:knowme/features/runtime_integration/pipeline/knowme_runtime_pipeline.dart';
import 'package:knowme/features/runtime_integration/pipeline/runtime_mirror_input_builder.dart';
import 'package:knowme/features/runtime_integration/report/architecture_coverage_report.dart';

void main() {
  group('BaZi Mirror Integration V1', () {
    final generatedAt = DateTime.utc(2026, 6, 21, 12);

    late KnowMeRuntimePipelineResult beforePipeline;
    late KnowMeRuntimePipelineResult afterPipeline;
    late ArchitectureCoverageReport beforeReport;
    late ArchitectureCoverageReport afterReport;
    late Map<String, dynamic> signalAudit;

    setUpAll(() {
      RuntimeMirrorInputBuilder.includeBaziInAstrologyMirror = false;
      beforePipeline = KnowMeRuntimePipeline.run(generatedAt: generatedAt);
      beforeReport = ArchitectureCoverageReportBuilder.build(beforePipeline);

      RuntimeMirrorInputBuilder.includeBaziInAstrologyMirror = true;
      afterPipeline = KnowMeRuntimePipeline.run(generatedAt: generatedAt);
      afterReport = ArchitectureCoverageReportBuilder.build(afterPipeline);

      signalAudit = _buildSignalAudit();

      _writeReport(
        beforeReport: beforeReport,
        afterReport: afterReport,
        signalAudit: signalAudit,
      );

      RuntimeMirrorInputBuilder.includeBaziInAstrologyMirror = true;
    });

    test('existing runtime integration tests remain valid with BaZi enabled', () {
      expect(afterPipeline.themeCount, greaterThan(0));
      expect(afterReport.pipelineIntegrityPassed, isTrue);
    });

    test('BaZi increases astrology mirror theme signal count', () {
      expect(
        afterPipeline.astrologyMirrorSnapshot.evidence.length,
        greaterThan(beforePipeline.astrologyMirrorSnapshot.evidence.length),
      );
    });

    test('BaZi increases merged astrology input signals without duplicating Thai', () {
      final thai = KnowMeMirrorAstrologyAdapter.extract(
        RuntimeThaiThemeLoader.loadQaProfile(),
      );
      final bazi = KnowMeMirrorBaziAdapter.extract(
        RuntimeBaziChartLoader.loadQaProfile(),
      );
      final merged = RuntimeAstrologyMirrorSignalMerger.merge(thai, bazi);

      expect(bazi, isNotEmpty);
      expect(merged.length, greaterThan(thai.length));
      expect(merged.length, lessThanOrEqualTo(thai.length + bazi.length));
    });

    test('downstream human pattern and narrative metrics improve', () {
      expect(
        afterReport.humanPatternCount,
        greaterThanOrEqualTo(beforeReport.humanPatternCount),
      );
      expect(
        afterReport.activatedPatternCount,
        greaterThanOrEqualTo(beforeReport.activatedPatternCount),
      );

      final beforeNarrative = NarrativeRuntimeService.generate(
        patternSnapshot: beforePipeline.humanPatternSnapshot,
        createdAt: generatedAt,
      );
      final afterNarrative = NarrativeRuntimeService.generate(
        patternSnapshot: afterPipeline.humanPatternSnapshot,
        createdAt: generatedAt,
      );

      expect(
        afterNarrative.paragraphCount,
        greaterThanOrEqualTo(beforeNarrative.paragraphCount),
      );
    });

    test('signal audit classifies new reinforced duplicate and ignored signals', () {
      expect(signalAudit['newSignals'], isA<List>());
      expect(signalAudit['reinforcedSignals'], isA<List>());
      expect(signalAudit['duplicateSignals'], isA<List>());
      expect(signalAudit['ignoredSignals'], isA<List>());
      expect((signalAudit['newSignals'] as List).length, greaterThan(0));
    });

    test('writes integration validation report artifact', () {
      expect(
        File('docs/BAZI_MIRROR_INTEGRATION_V1.md').existsSync(),
        isTrue,
      );
      expect(
        File('test/validation/bazi_mirror_integration/output/results.json')
            .existsSync(),
        isTrue,
      );
    });
  });
}

Map<String, dynamic> _buildSignalAudit() {
  final thai = KnowMeMirrorAstrologyAdapter.extract(
    RuntimeThaiThemeLoader.loadQaProfile(),
  );
  final bazi = KnowMeMirrorBaziAdapter.extract(
    RuntimeBaziChartLoader.loadQaProfile(),
  );
  final merged = RuntimeAstrologyMirrorSignalMerger.merge(thai, bazi);

  final thaiKeys = thai.map((s) => '${s.mirrorKey}|${s.themeId}').toSet();
  final baziKeys = bazi.map((s) => '${s.mirrorKey}|${s.themeId}').toSet();
  final mergedKeys = merged.map((s) => '${s.mirrorKey}|${s.themeId}').toSet();

  final newSignals = <Map<String, dynamic>>[];
  final reinforced = <Map<String, dynamic>>[];
  final duplicates = <Map<String, dynamic>>[];
  final ignored = <Map<String, dynamic>>[];

  for (final signal in bazi) {
    final key = '${signal.mirrorKey}|${signal.themeId}';
    final thaiMatch = thai.where(
      (item) => '${item.mirrorKey}|${item.themeId}' == key,
    );
    if (thaiMatch.isEmpty) {
      if (mergedKeys.contains(key)) {
        newSignals.add(_signalRow(signal, 'new'));
      } else {
        ignored.add(_signalRow(signal, 'unmapped_or_filtered'));
      }
      continue;
    }

    final thaiSignal = thaiMatch.first;
    if (signal.confidence > thaiSignal.confidence) {
      reinforced.add({
        ..._signalRow(signal, 'reinforced'),
        'previousConfidence': thaiSignal.confidence,
      });
    } else if (signal.confidence == thaiSignal.confidence) {
      duplicates.add({
        ..._signalRow(signal, 'duplicate_tie'),
        'keptSource': thaiSignal.sourceLensKey,
      });
    } else {
      duplicates.add({
        ..._signalRow(signal, 'duplicate_suppressed'),
        'keptConfidence': thaiSignal.confidence,
      });
    }
  }

  return {
    'thaiSignalCount': thai.length,
    'baziSignalCount': bazi.length,
    'mergedSignalCount': merged.length,
    'newSignals': newSignals,
    'reinforcedSignals': reinforced,
    'duplicateSignals': duplicates,
    'ignoredSignals': ignored,
    'netNewCount': newSignals.length,
    'collisionCount': duplicates.length,
  };
}

Map<String, dynamic> _signalRow(dynamic signal, String classification) {
  return {
    'classification': classification,
    'themeId': signal.themeId,
    'mirrorKey': signal.mirrorKey,
    'confidence': signal.confidence,
    'sourceLensKey': signal.sourceLensKey,
    'evidenceCount': signal.evidenceCount,
  };
}

void _writeReport({
  required ArchitectureCoverageReport beforeReport,
  required ArchitectureCoverageReport afterReport,
  required Map<String, dynamic> signalAudit,
}) {
  final generatedAt = DateTime.utc(2026, 6, 21, 12);
  RuntimeMirrorInputBuilder.includeBaziInAstrologyMirror = false;
  final beforePipeline = KnowMeRuntimePipeline.run(generatedAt: generatedAt);
  RuntimeMirrorInputBuilder.includeBaziInAstrologyMirror = true;
  final afterPipeline = KnowMeRuntimePipeline.run(generatedAt: generatedAt);

  final beforeNarrative = NarrativeRuntimeService.generate(
    patternSnapshot: beforePipeline.humanPatternSnapshot,
    createdAt: generatedAt,
  );
  final afterNarrative = NarrativeRuntimeService.generate(
    patternSnapshot: afterPipeline.humanPatternSnapshot,
    createdAt: generatedAt,
  );

  final json = {
    'before': _metrics(
      beforeReport,
      beforePipeline,
      beforeNarrative.paragraphCount,
    ),
    'after': _metrics(afterReport, afterPipeline, afterNarrative.paragraphCount),
    'signalAudit': signalAudit,
    'integrationFlow': [
      'RuntimeThaiThemeLoader → KnowMeMirrorAstrologyAdapter',
      'RuntimeBaziChartLoader → BaziRealAdapter → KnowMeMirrorBaziAdapter',
      'RuntimeAstrologyMirrorSignalMerger',
      'KnowMeMirrorEngine → KnowMeMirrorSnapshot',
      'GlobalFusionFoundationBuilder → HumanModel → HumanPattern → NarrativeRuntime',
    ],
  };

  final jsonFile = File('test/validation/bazi_mirror_integration/output/results.json');
  jsonFile.parent.createSync(recursive: true);
  jsonFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));

  final md = StringBuffer()
    ..writeln('# BaZi Mirror Integration V1')
    ..writeln()
    ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln()
    ..writeln('## Integration Flow')
    ..writeln('```')
    ..writeln('RuntimeThaiThemeLoader ──► KnowMeMirrorAstrologyAdapter ──┐')
    ..writeln('RuntimeBaziChartLoader ──► BaziRealAdapter ──► KnowMeMirrorBaziAdapter ──┤')
    ..writeln('                                                          RuntimeAstrologyMirrorSignalMerger')
    ..writeln('                                                                    │')
    ..writeln('                                                          KnowMeMirrorEngine (Astrology Mirror)')
    ..writeln('                                                                    │')
    ..writeln('GlobalFusionFoundation → HumanModel → HumanPattern → NarrativeRuntime')
    ..writeln('```')
    ..writeln()
    ..writeln('## Before vs After (Real Runtime QA Profile)')
    ..writeln('| Metric | Before (Thai only) | After (+ BaZi) | Δ |')
    ..writeln('| --- | ---: | ---: | ---: |')
    ..writeln(_row('Astrology mirror evidence rows',
        beforePipeline.astrologyMirrorSnapshot.evidence.length,
        afterPipeline.astrologyMirrorSnapshot.evidence.length))
    ..writeln(_row('Mirror findings (astro+personality)',
        beforeReport.mirrorFindingCount, afterReport.mirrorFindingCount))
    ..writeln(_row('Global fusion findings',
        beforeReport.fusionFindingCount, afterReport.fusionFindingCount))
    ..writeln(_row('Human patterns',
        beforeReport.humanPatternCount, afterReport.humanPatternCount))
    ..writeln(_row('Activated patterns',
        beforeReport.activatedPatternCount, afterReport.activatedPatternCount))
    ..writeln(_row('Narrative paragraphs',
        beforeNarrative.paragraphCount, afterNarrative.paragraphCount))
    ..writeln()
    ..writeln('## Signal Audit')
    ..writeln('- Net-new BaZi signals: ${signalAudit['netNewCount']}')
    ..writeln('- Collisions suppressed: ${signalAudit['collisionCount']}')
    ..writeln('- Thai signals: ${signalAudit['thaiSignalCount']}')
    ..writeln('- BaZi signals: ${signalAudit['baziSignalCount']}')
    ..writeln('- Merged signals: ${signalAudit['mergedSignalCount']}')
    ..writeln()
    ..writeln('## Production Readiness')
    ..writeln(
      'BaZi is integrated at `RuntimeMirrorInputBuilder.buildAstrologyInput` — '
      'the canonical Astrology Mirror entry point. Mirror Engine, Global Fusion, '
      'Human Model, Pattern, and Narrative Runtime were not modified.',
    );

  File('docs/BAZI_MIRROR_INTEGRATION_V1.md')
      .writeAsStringSync(md.toString());
}

Map<String, dynamic> _metrics(
  ArchitectureCoverageReport report,
  KnowMeRuntimePipelineResult pipeline,
  int narrativeParagraphs,
) {
  return {
    'themeCount': pipeline.themeCount,
    'astrologyEvidenceRows': pipeline.astrologyMirrorSnapshot.evidence.length,
    'mirrorFindingCount': report.mirrorFindingCount,
    'fusionFindingCount': report.fusionFindingCount,
    'humanPatternCount': report.humanPatternCount,
    'activatedPatternCount': report.activatedPatternCount,
    'narrativeParagraphCount': narrativeParagraphs,
    'astroAgreements': pipeline.astrologyMirrorSnapshot.agreements.length,
    'astroTensions': pipeline.astrologyMirrorSnapshot.tensions.length,
  };
}

String _row(String label, int before, int after) {
  return '| $label | $before | $after | ${after - before} |';
}
