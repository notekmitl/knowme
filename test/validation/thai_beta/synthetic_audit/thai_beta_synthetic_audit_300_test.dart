import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_safety.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

const _referenceDate = '2026-08-03T00:00:00.000Z';

String _forecastField(PredictionDomainModel model, ForecastField field) =>
    switch (field) {
      ForecastField.claim => model.claim,
      ForecastField.risk => model.risk,
      ForecastField.decisionImpact => model.decisionImpact,
      ForecastField.action => model.preparationAction,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cases = _SyntheticMatrix.build();

  test('matrix has exactly 300 reproducible privacy-safe cases', () {
    expect(cases, hasLength(300));
    expect(cases.map((c) => c.id).toSet(), hasLength(300));
    expect(cases.where((c) => c.input.hasBirthTime), hasLength(225));
    expect(cases.where((c) => !c.input.hasBirthTime), hasLength(75));
    expect(cases.map((c) => c.input.birthDate.weekday).toSet(), hasLength(7));
    expect(cases.map((c) => c.input.birthDate.month).toSet(), hasLength(12));
    expect(
      cases.any(
        (c) => c.input.birthDate.month == 2 && c.input.birthDate.day == 29,
      ),
      isTrue,
    );
    expect(cases.any((c) => c.input.birthDate.day == 31), isTrue);
    expect(
      cases.any((c) => c.input.birthHour == 0 && c.input.birthMinute == 0),
      isTrue,
    );
    expect(
      cases.any((c) => c.input.birthHour == 23 && c.input.birthMinute == 59),
      isTrue,
    );
    for (final c in cases) {
      expect(c.input.firstName, c.id);
      expect(c.input.lastName, 'Synthetic');
      expect(c.id, matches(RegExp(r'^S[0-9]{3}$')));
    }
  });

  test(
    'synthetic matrix invokes cross-mode material sensitivity',
    () {
      var compared = 0;
      var different = 0;
      final bands = <ForecastBand>{};
      final risks = <Object?>{};
      final availabilities = <ForecastEvidenceAvailability>{};
      final transitions = <bool>{};
      final differenceCoverage = <String>{};
      final fieldCoverage = <ForecastField>{};
      for (final c in cases.where((c) => c.input.hasBirthTime).take(75)) {
        final known = _run(c);
        final unknown = ThaiBetaAnalysisRunner.run(
          ThaiBetaInput(
            firstName: c.id,
            lastName: 'Synthetic',
            birthDate: c.input.birthDate,
            birthTimeUnknown: true,
            province: c.input.province,
            provinceKey: c.input.provinceKey,
          ),
          startedAt: DateTime.parse(_referenceDate),
          asOf: DateTime.parse(_referenceDate),
        );
        List<PredictionDomainModel> blocks(ThaiBetaAnalysis analysis) =>
            ThaiBetaNarrativeComposer.narrativeView(analysis)
                .futurePrediction!
                .windows
                .expand((window) => window.domains)
                .toList();
        String identity(PredictionDomainModel model) =>
            '${model.material!.horizon.name}/${model.material!.domain.name}';
        final right = {
          for (final model in blocks(unknown)) identity(model): model,
        };
        for (final left in blocks(known)) {
          final match = right.remove(identity(left))!;
          compared += ForecastField.values.length;
          bands.add(left.material!.band);
          bands.add(match.material!.band);
          risks.add(left.material!.riskDomain);
          risks.add(match.material!.riskDomain);
          availabilities.add(left.material!.evidenceAvailability);
          availabilities.add(match.material!.evidenceAvailability);
          transitions.add(left.material!.spansTransition);
          transitions.add(match.material!.spansTransition);
          if (left.material!.band != match.material!.band) {
            differenceCoverage.add('band');
          }
          if (left.material!.riskDomain != match.material!.riskDomain) {
            differenceCoverage.add('risk');
          }
          if (left.material!.evidenceAvailability !=
              match.material!.evidenceAvailability) {
            differenceCoverage.add('availability');
          }
          if (left.material!.spansTransition !=
              match.material!.spansTransition) {
            differenceCoverage.add('transition');
          }
          for (final field in ForecastField.values) {
            fieldCoverage.add(field);
            final a = left.material!.projection(field).toString();
            final b = match.material!.projection(field).toString();
            if (a != b) {
              different++;
              expect(
                _forecastField(left, field),
                isNot(_forecastField(match, field)),
                reason:
                    '${c.id}/${identity(left)}/${field.name} '
                    '${left.material!.riskDomain} vs ${match.material!.riskDomain}',
              );
            }
          }
          expect(left.preparationAction, isNot(contains('ไม่มีหลักฐานลัคนา')));
          expect(match.preparationAction, isNot(contains('ไม่มีหลักฐานลัคนา')));
        }
        expect(right, isEmpty, reason: '${c.id}: unmatched unknown identity');
      }
      expect(compared, greaterThan(0));
      expect(different, greaterThan(0), reason: 'vacuous matrix must fail');
      expect(bands, containsAll(ForecastBand.values));
      expect(risks.whereType<Object>().length, greaterThan(1));
      expect(availabilities, containsAll(ForecastEvidenceAvailability.values));
      expect(transitions, containsAll({true, false}));
      expect(differenceCoverage, containsAll({'band', 'risk', 'availability'}));
      expect(fieldCoverage, containsAll(ForecastField.values));
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );

  test(
    'all 300 cases pass structured, narrative, omission and safety contracts',
    () {
      final fullTextFrequency = <String, int>{};
      final narrativeFrequency = <String, int>{};
      final narrativeCases = <String, List<String>>{};
      final paragraphFrequency = <String, int>{};
      final paragraphSource = <String, String>{};
      var known = 0;
      var unknown = 0;
      var omittedDomainCases = 0;
      final knownTimeOmissions = <String, int>{};

      for (final c in cases) {
        final analysis = _run(c);
        expect(
          analysis.isSuccess,
          isTrue,
          reason: '${c.id}: ${analysis.errorMessage}',
        );
        expect(analysis.reportHash, isNotNull, reason: c.id);
        expect(analysis.reportSnapshot, isNotEmpty, reason: c.id);
        final reading = ThaiBirthProfileCoreReading.fromAnalysis(analysis);
        final document = ThaiBetaReportExportDocument.fromAnalysis(analysis);
        final publicText = document.fullPlainText;
        expect(reading.sections, isNotEmpty, reason: c.id);
        expect(publicText.trim(), isNotEmpty, reason: c.id);
        expect(
          ThaiBetaReportExportSafety.containsForbidden(publicText),
          isFalse,
          reason: c.id,
        );
        expect(
          publicText,
          isNot(
            contains(
              RegExp(
                r'\{\{[^}]+\}\}|<[^>]+>|stack trace|debug|TODO',
                caseSensitive: false,
              ),
            ),
          ),
          reason: c.id,
        );
        expect(
          publicText,
          isNot(
            contains(
              RegExp(
                r'OPENAI[_-]?API[_-]?KEY|api\.openai\.com|firebase[_-]?admin|developer instruction',
                caseSensitive: false,
              ),
            ),
          ),
          reason: c.id,
        );
        expect(
          publicText,
          isNot(
            contains(RegExp(r'\b(null|undefined|NaN)\b', caseSensitive: false)),
          ),
          reason: c.id,
        );

        final seen = <String>{};
        for (final section in reading.sections) {
          for (final claim in section.claims) {
            final normalized = _normalize(claim.text);
            expect(
              normalized,
              isNotEmpty,
              reason: '${c.id}/${section.domain.name}',
            );
            expect(
              seen.add(normalized),
              isTrue,
              reason: '${c.id}: exact duplicate paragraph',
            );
            if (!section.isMethodology) {
              expect(
                claim.sourceAtoms,
                isNotEmpty,
                reason: '${c.id}/${section.domain.name}: missing atoms',
              );
              expect(
                claim.evidenceKeys,
                isNotEmpty,
                reason: '${c.id}/${section.domain.name}: missing provenance',
              );
              for (final atom in claim.sourceAtoms) {
                expect(
                  ThaiBirthProfileCoreDomainPolicy.acceptsAtom(
                    section.domain,
                    atom,
                  ),
                  isTrue,
                  reason: '${c.id}/${section.domain.name}/${atom.sourceRef}',
                );
                expect(
                  claim.evidenceKeys,
                  contains(atom.sourceRef),
                  reason: '${c.id}/${section.domain.name}',
                );
              }
            }
            paragraphFrequency.update(
              normalized,
              (v) => v + 1,
              ifAbsent: () => 1,
            );
            paragraphSource.putIfAbsent(
              normalized,
              () => '${section.domain.name}/${claim.semanticKey}',
            );
          }
        }

        final domains = reading.sections.map((s) => s.domain).toSet();
        if (c.input.hasBirthTime) {
          known++;
          expect(reading.hasBirthTime, isTrue, reason: c.id);
          // A known birth time enables house-derived domains, but each domain
          // still fails closed independently when its exact facts are absent.
          for (final domain in const <ThaiBirthProfileCoreDomain>[
            ThaiBirthProfileCoreDomain.work,
            ThaiBirthProfileCoreDomain.money,
            ThaiBirthProfileCoreDomain.relationships,
            ThaiBirthProfileCoreDomain.wellbeing,
          ]) {
            if (!domains.contains(domain)) {
              knownTimeOmissions.update(
                domain.name,
                (value) => value + 1,
                ifAbsent: () => 1,
              );
            }
          }
        } else {
          unknown++;
          expect(reading.hasBirthTime, isFalse, reason: c.id);
          expect(
            domains.contains(ThaiBirthProfileCoreDomain.work),
            isFalse,
            reason: c.id,
          );
          expect(
            domains.contains(ThaiBirthProfileCoreDomain.money),
            isFalse,
            reason: c.id,
          );
          expect(
            domains.contains(ThaiBirthProfileCoreDomain.relationships),
            isFalse,
            reason: c.id,
          );
          expect(
            domains.contains(ThaiBirthProfileCoreDomain.wellbeing),
            isFalse,
            reason: c.id,
          );
          omittedDomainCases++;
        }
        fullTextFrequency.update(
          _normalize(publicText),
          (v) => v + 1,
          ifAbsent: () => 1,
        );
        final narrativeSignature = _narrativeSignature(analysis);
        narrativeFrequency.update(
          narrativeSignature,
          (v) => v + 1,
          ifAbsent: () => 1,
        );
        narrativeCases.putIfAbsent(narrativeSignature, () => []).add(c.id);
      }

      final identicalReports = fullTextFrequency.values
          .where((v) => v > 1)
          .fold<int>(0, (a, b) => a + b);
      final identicalNarratives = narrativeFrequency.values
          .where((v) => v > 1)
          .fold<int>(0, (a, b) => a + b);
      final topParagraphs = paragraphFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      // Distribution is evidence, not a guessed product threshold.
      // ignore: avoid_print
      print(
        jsonEncode({
          'seed': _SyntheticMatrix.seed,
          'cases': cases.length,
          'knownTime': known,
          'unknownTime': unknown,
          'omittedDomainCases': omittedDomainCases,
          'knownTimeOmissions': knownTimeOmissions,
          'identicalFullReports': identicalReports,
          'uniqueFullReports': fullTextFrequency.length,
          'identicalNarrativeReports': identicalNarratives,
          'uniqueNarrativeReports': narrativeFrequency.length,
          'duplicateNarrativeCases': narrativeCases.values
              .where((ids) => ids.length > 1)
              .toList(),
          'uniqueParagraphs': paragraphFrequency.length,
          'topParagraphFrequencies': topParagraphs
              .take(10)
              .map(
                (entry) => {
                  'count': entry.value,
                  'source': paragraphSource[entry.key],
                },
              )
              .toList(),
        }),
      );
      expect(
        identicalReports,
        0,
        reason:
            'Different material inputs must not collapse to identical full reports',
      );
      expect(
        identicalNarratives,
        0,
        reason:
            'Different material inputs must remain distinct in consumer narrative, '
            'independent of metadata and methodology',
      );
    },
    timeout: const Timeout(Duration(minutes: 15)),
  );

  test(
    '30 stratified cases are deterministic across three runs',
    () {
      final sample = <_SyntheticCase>[
        ...cases.where((c) => !c.input.hasBirthTime).take(10),
        ...cases.where((c) => c.boundary).take(10),
        ...cases.where((c) => c.input.hasBirthTime && !c.boundary).take(10),
      ];
      expect(sample, hasLength(30));
      for (final c in sample) {
        final fingerprints = List.generate(3, (_) => _fingerprint(_run(c)));
        expect(fingerprints.toSet(), hasLength(1), reason: c.id);
      }
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );

  test(
    '60-case deep narrative sample has ownership and no within-report collapse',
    () {
      final sample = List.generate(60, (i) => cases[i * 5]);
      for (final c in sample) {
        final reading = ThaiBirthProfileCoreReading.fromAnalysis(_run(c));
        final paragraphs = reading.sections.expand((s) => s.claims).toList();
        expect(paragraphs, isNotEmpty, reason: c.id);
        for (var i = 0; i < paragraphs.length; i++) {
          for (var j = i + 1; j < paragraphs.length; j++) {
            expect(
              ThaiBirthProfileCoreClaimDeduplicator.isNearDuplicate(
                paragraphs[i],
                paragraphs[j],
              ),
              isFalse,
              reason:
                  '${c.id}: ${paragraphs[i].semanticKey}/${paragraphs[j].semanticKey}\n'
                  '${paragraphs[i].text}\n${paragraphs[j].text}',
            );
          }
        }
      }
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );

  test(
    '20 representative cases produce real PDFs with Web semantic parity',
    () async {
      final sample = <_SyntheticCase>[
        ...cases.where((c) => !c.input.hasBirthTime).take(5),
        ...cases.where((c) => c.boundary && c.input.hasBirthTime).take(10),
        ...cases.where((c) => !c.boundary && c.input.hasBirthTime).take(5),
      ];
      expect(sample, hasLength(20));
      final outputPath = Platform.environment['THAI_BETA_PDF_AUDIT_OUTPUT'];
      final outputDirectory = outputPath == null
          ? null
          : await Directory(outputPath).create(recursive: true);
      for (final c in sample) {
        final analysis = _run(c);
        final reading = ThaiBirthProfileCoreReading.fromAnalysis(analysis);
        final document = ThaiBetaReportExportDocument.fromAnalysis(analysis);
        final rendered = await ThaiBetaReportPdfExporter.build(document);
        if (outputDirectory != null) {
          await File(
            '${outputDirectory.path}${Platform.pathSeparator}${c.id}.pdf',
          ).writeAsBytes(rendered.bytes, flush: true);
        }
        expect(rendered.bytes.length, greaterThan(1000), reason: c.id);
        expect(
          utf8.decode(rendered.bytes.take(4).toList()),
          '%PDF',
          reason: c.id,
        );
        expect(rendered.plainText, document.fullPlainText, reason: c.id);
        for (final section in reading.sections) {
          expect(
            rendered.plainText,
            contains(section.title),
            reason: '${c.id}/${section.domain.name}',
          );
          for (final paragraph in section.publicParagraphs) {
            expect(
              rendered.plainText,
              contains(paragraph),
              reason: '${c.id}/${section.domain.name}',
            );
          }
        }
        expect(
          ThaiBetaReportExportSafety.containsForbidden(rendered.plainText),
          isFalse,
          reason: c.id,
        );
      }
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );
}

String _narrativeSignature(ThaiBetaAnalysis analysis) {
  final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
  final parts = <String>[
    view.hero.headline,
    view.hero.summary,
    view.signatureInsight.body,
    ...view.strengths.cards.expand((card) => [card.title, card.body]),
    ...view.cautions.cards.expand((card) => [card.title, card.body]),
    view.advice.body,
    ...view.lifeDashboard.expand(
      (item) => [item.currentState, item.whyItAppears, item.suggestedAction],
    ),
    ...view.narrativeSections.expand(
      (section) => [
        section.pullQuote,
        section.overview,
        section.whyItAppears,
        section.advice,
        section.transitionIn,
        section.discovery,
        section.reflectionQuestion,
        section.tension,
      ],
    ),
    if (view.lifeTimeline case final timeline?) ...[
      timeline.currentStage.intro,
      ...timeline.periods.expand(
        (period) => [
          period.summary,
          period.whatChanges,
          period.easier,
          period.harder,
          period.comparison,
          period.advice,
        ],
      ),
    ],
    if (view.futurePrediction case final prediction?) ...[
      prediction.sectionIntro,
      ...prediction.windows.expand(
        (window) => [
          window.summary,
          window.topOpportunity,
          window.topRisk,
          window.why,
          window.whyNow,
          window.whatToWatch,
          ...window.domains.expand((domain) => [domain.body, domain.caution]),
        ],
      ),
      prediction.transitionLine,
      prediction.closingAdvice,
    ],
    ...view.reflectionSummary.points,
    view.closingMessage.message,
    view.secretTip,
  ];
  return _normalize(parts.where((part) => part.trim().isNotEmpty).join('\n'));
}

ThaiBetaAnalysis _run(_SyntheticCase c) => ThaiBetaAnalysisRunner.run(
  c.input,
  startedAt: DateTime.parse(_referenceDate),
  asOf: DateTime.parse(_referenceDate),
);

String _fingerprint(ThaiBetaAnalysis analysis) {
  final reading = ThaiBirthProfileCoreReading.fromAnalysis(analysis);
  final document = ThaiBetaReportExportDocument.fromAnalysis(analysis);
  return jsonEncode({
    'hash': analysis.reportHash,
    'snapshot': analysis.reportSnapshot,
    'sections': reading.sections
        .map(
          (s) => {
            'domain': s.domain.name,
            'claims': s.claims
                .map(
                  (c) => {
                    'text': c.text,
                    'role': c.role.name,
                    'semanticKey': c.semanticKey,
                    'evidence': c.evidenceKeys,
                  },
                )
                .toList(),
          },
        )
        .toList(),
    'pdfDocument': document.fullPlainText,
  });
}

String _normalize(String value) => value
    .replaceAll(RegExp(r'\s+'), '')
    .replaceAll(RegExp(r'[\-–—:;,.!?()•]'), '')
    .toLowerCase();

class _SyntheticCase {
  const _SyntheticCase({
    required this.id,
    required this.input,
    required this.boundary,
  });
  final String id;
  final ThaiBetaInput input;
  final bool boundary;
}

abstract final class _SyntheticMatrix {
  static const seed = 20260803;
  static const _locations = <(String, String)>[
    ('กรุงเทพมหานคร', 'bangkok'),
    ('เชียงใหม่', 'chiang mai'),
    ('ขอนแก่น', 'khon kaen'),
    ('ภูเก็ต', 'phuket'),
    ('สงขลา', 'songkhla'),
    ('อุบลราชธานี', 'ubon ratchathani'),
  ];
  static const _times = <(int, int)>[
    (0, 0),
    (0, 1),
    (2, 0),
    (5, 29),
    (5, 30),
    (5, 31),
    (11, 59),
    (12, 0),
    (12, 1),
    (18, 0),
    (23, 0),
    (23, 59),
  ];
  static final _boundaries = <DateTime>[
    DateTime(1952, 2, 29),
    DateTime(1960, 12, 31),
    DateTime(1961, 1, 1),
    DateTime(1972, 4, 5),
    DateTime(1972, 4, 6),
    DateTime(1980, 2, 29),
    DateTime(1988, 1, 31),
    DateTime(1990, 4, 30),
    DateTime(1999, 12, 31),
    DateTime(2000, 1, 1),
    DateTime(2000, 2, 29),
    DateTime(2004, 2, 29),
    DateTime(2008, 12, 31),
    DateTime(2009, 1, 1),
    DateTime(2012, 2, 29),
    DateTime(2016, 7, 31),
    DateTime(2020, 2, 29),
    DateTime(2020, 12, 31),
    DateTime(2021, 1, 1),
    DateTime(2024, 2, 29),
    DateTime(2024, 3, 1),
    DateTime(2025, 12, 31),
    DateTime(2026, 1, 1),
    DateTime(2026, 7, 31),
  ];

  static List<_SyntheticCase> build() => List.generate(300, (index) {
    final id = 'S${(index + 1).toString().padLeft(3, '0')}';
    // One in four cases is unknown-time. Offset 2 keeps the explicit
    // 00:00, 00:01, sunrise-neighbour and 23:59 boundaries in known-time
    // cases while preserving the required 225/75 split.
    final unknown = index % 4 == 2;
    final boundary = index < _boundaries.length;
    final date = boundary ? _boundaries[index] : _validDate(index);
    final time = _times[index % _times.length];
    final location = _locations[index % _locations.length];
    return _SyntheticCase(
      id: id,
      boundary: boundary,
      input: ThaiBetaInput(
        firstName: id,
        lastName: 'Synthetic',
        birthDate: date,
        birthHour: unknown ? null : time.$1,
        birthMinute: unknown ? 0 : time.$2,
        birthTimeUnknown: unknown,
        province: location.$1,
        provinceKey: location.$2,
      ),
    );
  });

  static DateTime _validDate(int index) {
    // Break the 228-row joint cycle of year/month/location so every synthetic
    // case exercises distinct consumer material rather than differing only in
    // birth-date metadata.
    final materialCycle = index ~/ 228;
    final year = 1950 + ((index * 37 + materialCycle + seed) % 76);
    final month = 1 + (index % 12);
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = 1 + ((index * 11 + seed) % lastDay);
    return DateTime(year, month, day);
  }
}
