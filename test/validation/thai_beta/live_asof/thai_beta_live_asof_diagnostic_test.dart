import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

const _acceptedRoot = 'product-acceptance/thai-narrative-v1.5-r7.1/evidence';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Clock A/B/C disproves as-of as the Production mismatch cause',
    () async {
      final clockA = await _capture(
        label: 'clock-a-frozen-acceptance',
        startedAt: DateTime(2026, 8, 7),
        asOf: DateTime(2026, 8, 7),
      );
      final clockB = await _capture(
        label: 'clock-b-production-download-time',
        startedAt: DateTime(2026, 8, 16, 16, 15, 15, 572),
        asOf: DateTime(2026, 8, 16, 16, 19, 44, 454, 535),
      );

      final acceptedWeb = File(
        '$_acceptedRoot/owner-known-0035-web-text.txt',
      ).readAsStringSync();
      final acceptedPdf = File(
        '$_acceptedRoot/owner-known-0035-pdf-text.txt',
      ).readAsStringSync();
      expect(clockA.webText, acceptedWeb);
      expect(clockA.pdfText, acceptedPdf);
      expect(clockA.webText, clockA.pdfText);

      expect(clockB.webText, acceptedWeb);
      expect(clockB.pdfText, acceptedPdf);
      expect(clockB.webText, clockB.pdfText);
      expect(clockB.webText, clockA.webText);

      final productionRange = <_ClockCapture>[];
      for (final asOf in <DateTime>[
        DateTime(2026, 8, 16, 16, 15, 15, 572),
        DateTime(2026, 8, 16, 16, 16),
        DateTime(2026, 8, 16, 16, 17),
        DateTime(2026, 8, 16, 16, 18),
        DateTime(2026, 8, 16, 16, 19, 44, 454, 535),
      ]) {
        productionRange.add(
          await _capture(
            label: 'clock-b-range-${asOf.toIso8601String()}',
            startedAt: asOf,
            asOf: asOf,
            buildPdf: false,
          ),
        );
      }
      expect(
        productionRange.map((capture) => capture.webHash).toSet(),
        hasLength(1),
      );
      expect(productionRange.first.webHash, clockB.webHash);

      final sameAsOfA = await _capture(
        label: 'clock-c-open-before-midnight-submit-after',
        startedAt: DateTime(2026, 8, 15, 23, 59, 50),
        asOf: DateTime(2026, 8, 16, 0, 0, 10),
        buildPdf: false,
      );
      final sameAsOfB = await _capture(
        label: 'clock-c-open-after-midnight-submit-after',
        startedAt: DateTime(2026, 8, 16, 0, 0, 5),
        asOf: DateTime(2026, 8, 16, 0, 0, 10),
        buildPdf: false,
      );
      expect(sameAsOfA.webText, sameAsOfB.webText);

      final sameStartedDifferentAsOf = await _capture(
        label: 'clock-c-same-started-different-asof',
        startedAt: DateTime(2026, 8, 7),
        asOf: DateTime(2026, 8, 16),
        buildPdf: false,
      );
      expect(sameStartedDifferentAsOf.webText, clockB.webText);
      expect(sameStartedDifferentAsOf.webText, clockA.webText);

      final daily = <Map<String, Object?>>[];
      for (var day = 6; day <= 17; day++) {
        final asOf = DateTime(2026, 8, day, 12);
        final capture = await _capture(
          label: 'clock-c-day-$day',
          startedAt: asOf,
          asOf: asOf,
          buildPdf: false,
        );
        daily.add({
          'asOf': asOf.toIso8601String(),
          'webHash': capture.webHash,
          'reportHash': capture.reportHash,
          'currentPeriod': capture.currentPeriod,
          'nextPeriod': capture.nextPeriod,
          'financeLine': capture.financeLine,
          'nextTransitionLine': capture.nextTransitionLine,
        });
      }

      final result = <String, Object?>{
        'schema': 'knowme-v15-live-asof-root-cause-v1',
        'productionEvidenceWindow': {
          'earliestUtc': '2026-08-16T09:15:15.5721160Z',
          'latestUtc': '2026-08-16T09:19:44.4545351Z',
          'earliestAsiaBangkok': '2026-08-16T16:15:15.572116+07:00',
          'latestAsiaBangkok': '2026-08-16T16:19:44.454535+07:00',
          'basis': [
            'production-asset-verification.json verifiedUtc',
            'original Downloads PDF NTFS CreationTimeUtc',
          ],
          'stableThroughoutSampledRange': true,
        },
        'clockA': clockA.toJson(),
        'clockB': clockB.toJson(),
        'clockC': {
          'differentStartedSameAsOfIdentical':
              sameAsOfA.webHash == sameAsOfB.webHash,
          'sameStartedDifferentAsOfChanges':
              clockA.webHash != sameStartedDifferentAsOf.webHash,
          'openBeforeMidnight': sameAsOfA.toJson(),
          'openAfterMidnight': sameAsOfB.toJson(),
          'sameStartedDifferentAsOf': sameStartedDifferentAsOf.toJson(),
          'dailyBoundaryScan': daily,
        },
      };
      final encoded = const JsonEncoder.withIndent('  ').convert(result);
      final output = Platform.environment['KNOWME_LIVE_ASOF_DIAGNOSTIC_OUTPUT'];
      if (output != null && output.isNotEmpty) {
        final file = File(output);
        file.parent.createSync(recursive: true);
        file.writeAsStringSync('$encoded\n', flush: true);
      }
      // Kept in the raw test log so the pre-repair causal run is auditable.
      // ignore: avoid_print
      print(encoded);
    },
  );
}

Future<_ClockCapture> _capture({
  required String label,
  required DateTime startedAt,
  required DateTime asOf,
  bool buildPdf = true,
}) async {
  final analysis = ThaiBetaAnalysisRunner.run(
    _ownerKnown0035(),
    startedAt: startedAt,
    asOf: asOf,
  );
  expect(analysis.isSuccess, isTrue, reason: label);
  final document = ThaiBetaReportExportDocument.fromAnalysis(analysis);
  final pdfText = buildPdf
      ? (await ThaiBetaReportPdfExporter.build(document)).plainText
      : document.fullPlainText;
  final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
  final mirror = analysis.pipelineResult!.mirrorResult!;
  final seenThemeIds = <String>{};
  final allThemeIds = <String>[];
  void addThemeIds(Iterable<String> ids) {
    for (final id in ids) {
      if (seenThemeIds.add(id)) allThemeIds.add(id);
    }
  }

  addThemeIds(mirror.topThemes.map((theme) => theme.themeId));
  final themeScores = <double>[];
  for (final sectionId in ThaiMirrorSectionId.values) {
    final section = mirror.sectionById(sectionId);
    if (section == null) continue;
    addThemeIds(section.supportingThemes.map((theme) => theme.themeId));
    themeScores.addAll(section.supportingThemes.map((theme) => theme.score));
  }
  themeScores.addAll(mirror.topThemes.map((theme) => theme.score));
  final lagnaKey = mirror.profileContext.lagnaKey;
  var presenterSeed = 0;
  for (var i = 0; i < allThemeIds.length; i++) {
    presenterSeed ^= allThemeIds[i].hashCode * (i + 17);
  }
  for (var i = 0; i < themeScores.length; i++) {
    presenterSeed ^= (themeScores[i] * 10000).round() * (i + 1);
  }
  if (lagnaKey != null && lagnaKey.isNotEmpty) {
    presenterSeed ^= lagnaKey.hashCode * 29;
  }
  if (presenterSeed == 0 && mirror.topThemes.isNotEmpty) {
    presenterSeed = mirror.topThemes.first.themeId.hashCode;
  }
  final timeline = view.lifeTimeline!;
  final current = timeline.periods.firstWhere((period) => period.isCurrent);
  final next = timeline.periods.firstWhere(
    (period) => !period.isCurrent && !period.isPast,
  );
  final lines = document.fullPlainText.split('\n');
  String matching(String pattern) =>
      lines.firstWhere((line) => line.contains(pattern), orElse: () => '');
  return _ClockCapture(
    label: label,
    startedAt: startedAt,
    asOf: asOf,
    webText: document.fullPlainText,
    pdfText: pdfText,
    reportHash: analysis.reportHash ?? '',
    reportSnapshotHash: _sha(jsonEncode(analysis.reportSnapshot)),
    presenterSeed: presenterSeed,
    orderedThemeIds: allThemeIds,
    topThemeIds: mirror.topThemes.map((theme) => theme.themeId).toList(),
    themeScores: themeScores,
    lagnaKey: lagnaKey ?? '',
    currentPeriod:
        '${current.ageLabel}|${current.phaseName}|${current.planetLine}|${current.keyword}',
    nextPeriod:
        '${next.ageLabel}|${next.phaseName}|${next.planetLine}|${next.keyword}',
    currentMaterial: [
      for (final domain in current.lifeDomains)
        {
          'title': domain.title,
          'body': domain.body,
          'evidenceKeys': domain.evidenceKeys,
        },
    ],
    nextMaterial: [
      for (final domain in next.lifeDomains)
        {
          'title': domain.title,
          'body': domain.body,
          'evidenceKeys': domain.evidenceKeys,
        },
    ],
    financeLine: matching('ด้านการเงิน'),
    nextTransitionLine: matching('ต่อไปงาน'),
  );
}

ThaiBetaInput _ownerKnown0035() => ThaiBetaInput(
  firstName: 'Acceptance',
  lastName: 'Fixture',
  birthDate: DateTime(1982, 6, 6),
  birthHour: 0,
  birthMinute: 35,
  province: 'เชียงใหม่',
  provinceKey: 'chiang_mai',
);

String _sha(String value) => sha256.convert(utf8.encode(value)).toString();

class _ClockCapture {
  const _ClockCapture({
    required this.label,
    required this.startedAt,
    required this.asOf,
    required this.webText,
    required this.pdfText,
    required this.reportHash,
    required this.reportSnapshotHash,
    required this.presenterSeed,
    required this.orderedThemeIds,
    required this.topThemeIds,
    required this.themeScores,
    required this.lagnaKey,
    required this.currentPeriod,
    required this.nextPeriod,
    required this.currentMaterial,
    required this.nextMaterial,
    required this.financeLine,
    required this.nextTransitionLine,
  });

  final String label;
  final DateTime startedAt;
  final DateTime asOf;
  final String webText;
  final String pdfText;
  final String reportHash;
  final String reportSnapshotHash;
  final int presenterSeed;
  final List<String> orderedThemeIds;
  final List<String> topThemeIds;
  final List<double> themeScores;
  final String lagnaKey;
  final String currentPeriod;
  final String nextPeriod;
  final List<Map<String, Object?>> currentMaterial;
  final List<Map<String, Object?>> nextMaterial;
  final String financeLine;
  final String nextTransitionLine;

  String get webHash => _sha(webText);
  String get pdfHash => _sha(pdfText);

  Map<String, Object?> toJson() => {
    'label': label,
    'startedAt': startedAt.toIso8601String(),
    'asOf': asOf.toIso8601String(),
    'timezone': {
      'isUtc': asOf.isUtc,
      'offset': asOf.timeZoneOffset.toString(),
      'civilDateUsedByEngine':
          '${asOf.year.toString().padLeft(4, '0')}-${asOf.month.toString().padLeft(2, '0')}-${asOf.day.toString().padLeft(2, '0')}',
    },
    'currentPeriod': currentPeriod,
    'nextPeriod': nextPeriod,
    'currentMaterial': currentMaterial,
    'nextMaterial': nextMaterial,
    'financeLine': financeLine,
    'nextTransitionLine': nextTransitionLine,
    'webCanonicalHash': webHash,
    'pdfCanonicalHash': pdfHash,
    'webPdfExact': webText == pdfText,
    'reportHash': reportHash,
    'reportSnapshotHash': reportSnapshotHash,
    'presenterSeed': presenterSeed,
    'orderedThemeIds': orderedThemeIds,
    'topThemeIds': topThemeIds,
    'themeScores': themeScores,
    'lagnaKey': lagnaKey,
  };
}
