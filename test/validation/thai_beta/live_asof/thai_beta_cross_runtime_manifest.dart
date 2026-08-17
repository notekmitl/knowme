import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_evidence_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_content_context.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_stable_hash.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_canonical_degree.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import '../synthetic_audit/thai_beta_synthetic_matrix_300.dart';
import 'thai_beta_canonical_degree_vectors.dart';
import 'thai_beta_stable_hash_vectors.dart';

final syntheticAsOf = DateTime.utc(2026, 8, 3);
final frozenCanonicalAsOf = DateTime(2026, 8, 7);
final liveCanonicalAsOf = DateTime(2026, 8, 16, 16, 19, 44, 454, 535);

const acceptedFrozenCanonicalHashes = <String, String>{
  'owner-known-0035':
      '08f446d1b72a10f985b80c34702785a4de61ab96de5dc01374837876d32396e3',
  'owner-unknown':
      'dc1bd76ea0dfa6139a15f048503b92de228aa46809596a588abdb3b8e3681fab',
  'regression-known-0003':
      '2c1880acb74d1523cca814512b1e53d0c06df71f7e77fdd278e4ba43fdee3177',
  'comparison-known-bangkok':
      '1da55e88c330307029f235f907a0b5bb274930bc359fa80ae8842e6d46017599',
  'comparison-known-khon-kaen':
      'd5ff068385f39798040336eb4a60a0241048e1fc6c6b4df919a8c583f0c49d62',
};

Future<Map<String, Object?>> buildCrossRuntimeManifest({
  required String runLabel,
}) async {
  final cases = ThaiBetaSyntheticMatrix.build();
  final caseRows = <Map<String, Object?>>[];
  final reportHashes = <String>{};
  final narrativeHashes = <String>{};
  var known = 0;
  var unknown = 0;
  var unknownOmissionPass = 0;

  for (final syntheticCase in cases) {
    final row = _caseManifest(syntheticCase);
    caseRows.add(row);
    reportHashes.add(row['canonicalTextSha256']! as String);
    narrativeHashes.add(row['narrativeOnlySha256']! as String);
    if (row['birthTimeMode'] == 'known') {
      known++;
    } else {
      unknown++;
      final omission = row['unknownOmission']! as Map<String, Object?>;
      if (omission['pass'] == true) unknownOmissionPass++;
    }
  }

  final canonical = <Map<String, Object?>>[];
  for (final fixture in canonicalFixtures.entries) {
    canonical.add(await _canonicalManifest(fixture.key, fixture.value));
  }

  return {
    'schema': 'knowme-v15-cross-runtime-parity-v1',
    'runtime': identical(1, 1.0) ? 'compiled-javascript' : 'dart-vm',
    'runLabel': runLabel,
    'syntheticSeed': ThaiBetaSyntheticMatrix.seed,
    'explicitSyntheticAsOf': syntheticAsOf.toIso8601String(),
    'stableHashVectors': evaluateStableHashVectors(),
    'canonicalDegreeVectors': evaluateCanonicalDegreeVectors(),
    'summary': {
      'executed': caseRows.length,
      'known': known,
      'unknown': unknown,
      'unknownOmissionPass': unknownOmissionPass,
      'uniqueReports': reportHashes.length,
      'uniqueNarratives': narrativeHashes.length,
    },
    'cases': caseRows,
    'canonical': canonical,
  };
}

Map<String, Object?> _caseManifest(ThaiBetaSyntheticCase syntheticCase) {
  final input = syntheticCase.input;
  final analysis = ThaiBetaAnalysisRunner.run(
    input,
    startedAt: syntheticAsOf,
    asOf: syntheticAsOf,
  );
  if (!analysis.isSuccess) {
    throw StateError('${syntheticCase.id}: ${analysis.errorMessage}');
  }

  final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
  final reading = ThaiBirthProfileCoreReading.fromAnalysis(
    analysis,
    consumerView: view,
  );
  final document = ThaiBetaReportExportDocument.fromAnalysis(analysis);
  final mirror = analysis.pipelineResult!.mirrorResult!;
  final profile = analysis.profile!;
  final rawSiderealAscendant = profile.siderealAscendantDeg;
  final canonicalSiderealAscendant = ThaiBetaCanonicalDegree.fromDegrees(
    rawSiderealAscendant,
  );
  final lifePeriods = analysis.pipelineResult!.lifePeriods!;
  final presenter = _presenterSeed(analysis);
  final evidenceProfile = ThaiMirrorEvidenceComposer.profileFor(
    (presenter['orderedThemeIds']! as List<Object?>).cast<String>(),
  );
  final allThemeIds = (presenter['orderedThemeIds']! as List<Object?>)
      .cast<String>();
  final topThemeIds = (presenter['topThemeIds']! as List<Object?>)
      .cast<String>();
  final growthPathIds =
      mirror
          .sectionById(ThaiMirrorSectionId.growthPath)
          ?.supportingThemes
          .map((theme) => theme.themeId)
          .toList() ??
      const <String>[];
  final selectionContext = ThaiMirrorContentContext(
    allThemeIds: allThemeIds,
    topThemeIds: topThemeIds,
    profileSeed: presenter['profileSeed']! as int,
    lagnaKey: presenter['lagnaKey'] as String?,
    growthPathIds: growthPathIds,
  );

  final inputRecord = <String, Object?>{
    'birthDate': _date(input.birthDate),
    'birthHour': input.birthHour,
    'birthMinute': input.birthMinute,
    'birthTimeUnknown': input.birthTimeUnknown,
    'provinceKey': input.provinceKey,
  };
  final profileRecord = <String, Object?>{
    'lagnaKey': profile.lagnaKey,
    'lagnaLordKey': profile.lagnaLordKey,
    'siderealAscendant': profile.siderealAscendantDeg?.toStringAsFixed(9),
    'dominantMyanmarKey': profile.dominantMyanmarKey,
    'myanmarKeys': profile.myanmarKeys,
    'mahabhutaPositionKeys': profile.mahabhutaPositionKeys,
    'myanmarChartNumbers': profile.myanmarChartNumbers,
    'mahabhutaChartNumbers': profile.mahabhutaChartNumbers,
    'row4Sum': profile.row4Sum,
    'topThemes': [
      for (final theme in mirror.topThemes)
        {'id': theme.themeId, 'score': theme.score.toStringAsFixed(9)},
    ],
  };
  final lifeRecord = <String, Object?>{
    'currentAge': lifePeriods.currentAge,
    'currentIndex': lifePeriods.currentIndex,
    'startPlanet': lifePeriods.startPlanet.name,
    'periods': [
      for (final period in lifePeriods.periods)
        {
          'index': period.index,
          'planet': period.planet.name,
          'startAge': period.startAge,
          'endAge': period.endAge,
          'strength': period.strength,
          'isCurrent': period.isCurrent,
          'isPast': period.isPast,
          'progress': period.progress.toStringAsFixed(9),
          'remainingYears': period.remainingYears,
        },
    ],
  };
  final periodScores = <Map<String, Object?>>[
    for (
      var index = 0;
      index < (view.lifeTimeline?.periods.length ?? 0);
      index++
    )
      {
        'index': index,
        'scores': [
          for (final score in view.lifeTimeline!.periods[index].scores)
            '${score.label}:${score.value}',
        ],
        'easeIndex': view.lifeTimeline!.periods[index].easeIndex,
        'accentIndex': view.lifeTimeline!.periods[index].accentIndex,
      },
  ];
  final narrative = _narrativeParts(view);
  final critical = _criticalSections(view);
  final omittedDomains = const {
    ThaiBirthProfileCoreDomain.work,
    ThaiBirthProfileCoreDomain.money,
    ThaiBirthProfileCoreDomain.relationships,
    ThaiBirthProfileCoreDomain.wellbeing,
  };
  final presentDomains = reading.sections
      .map((section) => section.domain)
      .toSet();
  final failClosed =
      input.hasBirthTime ||
      omittedDomains.every((domain) => !presentDomains.contains(domain));

  return {
    'caseId': syntheticCase.id,
    'normalizedInputSignature': _shaJson(inputRecord),
    'birthTimeMode': input.hasBirthTime ? 'known' : 'unknown',
    'explicitAsOf': analysis.asOf.toIso8601String(),
    'profileEngineFactSignature': _shaJson(profileRecord),
    'lifePeriodSignature': _shaJson(lifeRecord),
    'periodScores': periodScores,
    'periodScoreSignature': _shaJson(periodScores),
    'presenterContentSeedSignature': _shaJson(presenter),
    'presenterSeed': presenter['profileSeed'],
    'evidenceProfile': {
      'orderedFacets': [
        for (final facet in evidenceProfile.orderedFacets) facet.name,
      ],
      'weights': {
        for (final entry in evidenceProfile.weights.entries)
          entry.key.name: entry.value,
      },
      'tone': evidenceProfile.tone.name,
    },
    'mirrorSectionThemeIds': {
      for (final section in mirror.sections)
        section.id.name: [
          for (final theme in section.supportingThemes) theme.themeId,
        ],
    },
    'selectionSeedTrace': _selectionSeedTrace(selectionContext),
    'rawNumericAudit': {
      'siderealAscendantDeg': rawSiderealAscendant?.toString(),
      'canonicalSiderealAscendantUnits': canonicalSiderealAscendant,
      'canonicalSiderealAscendantFixed': canonicalSiderealAscendant == null
          ? null
          : ThaiBetaCanonicalDegree.fixedDecimal(
              canonicalSiderealAscendant,
            ),
      'displayedDegree': _lagnaDegree(analysis),
      'lagnaKey': profile.lagnaKey,
      'lagnaLordKey': profile.lagnaLordKey,
    },
    'reportSnapshot': analysis.reportSnapshot,
    'reportSnapshotSha256': _shaJson(analysis.reportSnapshot),
    'reportHash': analysis.reportHash,
    'canonicalTextSha256': _sha(document.fullPlainText),
    'narrativeOnlySha256': _sha(narrative.join('\n')),
    'narrativeParts': narrative,
    'criticalSections': critical,
    'criticalSectionHashes': {
      for (final entry in critical.entries) entry.key: _shaJson(entry.value),
    },
    'unknownOmission': {
      'applicable': !input.hasBirthTime,
      'pass': failClosed,
      'omittedDomainCount': omittedDomains
          .where((domain) => !presentDomains.contains(domain))
          .length,
      'omissionDisclosureCount': reading.omissions.length,
    },
    'copyNormalizationImpact': crossRuntimeCopyNormalizationImpact(analysis),
  };
}

Map<String, Object?> _selectionSeedTrace(ThaiMirrorContentContext ctx) {
  const aspects = ['work', 'money', 'love', 'health', 'luck'];
  final strings = <String>{
    ...ctx.allThemeIds,
    ...ctx.topThemeIds,
    ...ctx.growthPathIds,
    ?ctx.lagnaKey,
    'advice',
    'advice_full',
    'advice_compose',
    for (final aspect in aspects) 'dash_partner_$aspect',
    for (final aspect in aspects) 'dash_$aspect',
  };
  return {
    'stableStringHashes': {
      for (final value in strings) value: ThaiMirrorStableHash.string(value),
    },
    'advice': [
      for (final theme in ctx.growthPathIds)
        {
          'theme': theme,
          'full': ctx.seedFor(primaryThemeId: theme, slot: 'advice_full'),
          'compose': ctx.seedFor(primaryThemeId: theme, slot: 'advice_compose'),
        },
    ],
    'dashboard': [
      for (var aspectIndex = 0; aspectIndex < aspects.length; aspectIndex++)
        for (final theme in ctx.allThemeIds)
          {
            'aspect': aspects[aspectIndex],
            'theme': theme,
            'partner': ctx.seedFor(
              primaryThemeId: theme,
              slot: 'dash_partner_${aspects[aspectIndex]}',
              offset: aspectIndex,
            ),
            'content': ctx.seedFor(
              primaryThemeId: theme,
              slot: 'dash_${aspects[aspectIndex]}',
              offset: aspectIndex,
            ),
          },
    ],
  };
}

Future<Map<String, Object?>> _canonicalManifest(
  String id,
  ThaiBetaInput input,
) async {
  final frozen = ThaiBetaAnalysisRunner.run(
    input,
    startedAt: frozenCanonicalAsOf,
    asOf: frozenCanonicalAsOf,
  );
  final frozenDocument = ThaiBetaReportExportDocument.fromAnalysis(frozen);
  final frozenPdf = await ThaiBetaReportPdfExporter.build(frozenDocument);
  final liveFirst = ThaiBetaAnalysisRunner.run(
    input,
    startedAt: DateTime(2026, 8, 16, 16, 15),
    asOf: liveCanonicalAsOf,
  );
  final liveSecond = ThaiBetaAnalysisRunner.run(
    input,
    startedAt: DateTime(2026, 8, 16, 15),
    asOf: liveCanonicalAsOf,
  );
  final liveDocument = ThaiBetaReportExportDocument.fromAnalysis(liveFirst);
  final liveRepeatDocument = ThaiBetaReportExportDocument.fromAnalysis(
    liveSecond,
  );
  final livePdf = await ThaiBetaReportPdfExporter.build(liveDocument);
  final frozenHash = _sha(frozenDocument.fullPlainText);
  final liveHash = _sha(liveDocument.fullPlainText);

  return {
    'fixture': id,
    'frozenAsOf': frozen.asOf.toIso8601String(),
    'liveAsOf': liveFirst.asOf.toIso8601String(),
    'acceptedFrozenSha256': acceptedFrozenCanonicalHashes[id],
    'frozenCanonicalSha256': frozenHash,
    'frozenAcceptedExact': frozenHash == acceptedFrozenCanonicalHashes[id],
    'frozenWebPdfExact': frozenDocument.fullPlainText == frozenPdf.plainText,
    'liveCanonicalSha256': liveHash,
    'liveWebPdfExact': liveDocument.fullPlainText == livePdf.plainText,
    'liveRepeatExact':
        liveDocument.fullPlainText == liveRepeatDocument.fullPlainText,
    'reportHashRepeatExact': liveFirst.reportHash == liveSecond.reportHash,
    'lagnaDegree': _lagnaDegree(liveFirst),
    'unknownFailClosed': _unknownFailClosed(liveFirst),
  };
}

Map<String, Object?> _presenterSeed(ThaiBetaAnalysis analysis) {
  final mirror = analysis.pipelineResult!.mirrorResult!;
  final topThemeIds = mirror.topThemes.map((theme) => theme.themeId).toList();
  final seen = <String>{};
  final allThemeIds = <String>[];
  void add(Iterable<String> ids) {
    for (final id in ids) {
      if (seen.add(id)) allThemeIds.add(id);
    }
  }

  add(topThemeIds);
  final themeScores = <double>[];
  for (final sectionId in ThaiMirrorSectionId.values) {
    final section = mirror.sectionById(sectionId);
    if (section == null) continue;
    add(section.supportingThemes.map((theme) => theme.themeId));
    themeScores.addAll(section.supportingThemes.map((theme) => theme.score));
  }
  themeScores.addAll(mirror.topThemes.map((theme) => theme.score));
  final lagnaKey = mirror.profileContext.lagnaKey;
  var profileSeed = 0;
  for (var index = 0; index < allThemeIds.length; index++) {
    profileSeed = ThaiMirrorStableHash.exactXor(
      profileSeed,
      ThaiMirrorStableHash.string(allThemeIds[index]) * (index + 17),
    );
  }
  for (var index = 0; index < themeScores.length; index++) {
    profileSeed = ThaiMirrorStableHash.exactXor(
      profileSeed,
      (themeScores[index] * 10000).round() * (index + 1),
    );
  }
  if (lagnaKey != null && lagnaKey.isNotEmpty) {
    profileSeed = ThaiMirrorStableHash.exactXor(
      profileSeed,
      ThaiMirrorStableHash.string(lagnaKey) * 29,
    );
  }
  if (profileSeed == 0 && topThemeIds.isNotEmpty) {
    profileSeed = ThaiMirrorStableHash.string(topThemeIds.first);
  }
  return {
    'profileSeed': profileSeed,
    'orderedThemeIds': allThemeIds,
    'topThemeIds': topThemeIds,
    'themeScores': [for (final score in themeScores) score.toStringAsFixed(9)],
    'lagnaKey': lagnaKey,
  };
}

List<Map<String, Object?>> crossRuntimeCopyNormalizationImpact(
  ThaiBetaAnalysis analysis,
) {
  const target = 'ต่อไปมีโอกาสใหม่เข้ามาจากงานหรือคนรู้จัก';
  final finalView = ThaiBetaNarrativeComposer.narrativeView(analysis);
  final sourcePeriods =
      analysis.consumerViewState?.lifeTimeline?.periods ?? const [];
  final finalPeriods = finalView.lifeTimeline?.periods ?? const [];
  final impacts = <Map<String, Object?>>[];
  for (
    var period = 0;
    period < sourcePeriods.length && period < finalPeriods.length;
    period++
  ) {
    final before = sourcePeriods[period];
    final after = finalPeriods[period];
    final fields = <String, (String, String)>{
      'summary': (before.summary, after.summary),
      'whatChanges': (before.whatChanges, after.whatChanges),
      'easier': (before.easier, after.easier),
      'harder': (before.harder, after.harder),
      'comparison': (before.comparison, after.comparison),
      'evidenceLine': (before.evidenceLine, after.evidenceLine),
      'advice': (before.advice, after.advice),
    };
    for (final entry in fields.entries) {
      if (entry.value.$1.contains(target) && entry.value.$1 != entry.value.$2) {
        impacts.add({
          'periodIndex': period,
          'field': entry.key,
          'before': entry.value.$1,
          'after': entry.value.$2,
        });
      }
    }
  }
  return impacts;
}

List<String> _narrativeParts(dynamic view) => <String>[
  view.hero.headline,
  view.hero.summary,
  view.signatureInsight.body,
  ...view.strengths.cards.expand((dynamic card) => [card.title, card.body]),
  ...view.cautions.cards.expand((dynamic card) => [card.title, card.body]),
  view.advice.body,
  ...view.lifeDashboard.expand(
    (dynamic item) => [
      item.currentState,
      item.whyItAppears,
      item.suggestedAction,
    ],
  ),
  ...view.narrativeSections.expand(
    (dynamic section) => [
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
  if (view.lifeTimeline != null) ...[
    view.lifeTimeline.currentStage.intro,
    ...view.lifeTimeline.periods.expand(
      (dynamic period) => [
        period.summary,
        period.whatChanges,
        period.easier,
        period.harder,
        period.comparison,
        period.advice,
      ],
    ),
  ],
  if (view.futurePrediction != null) ...[
    view.futurePrediction.sectionIntro,
    ...view.futurePrediction.windows.expand(
      (dynamic window) => [
        window.summary,
        window.topOpportunity,
        window.topRisk,
        window.why,
        window.whyNow,
        window.whatToWatch,
        ...window.domains.expand(
          (dynamic domain) => [domain.body, domain.caution],
        ),
      ],
    ),
    view.futurePrediction.transitionLine,
    view.futurePrediction.closingAdvice,
  ],
  ...view.reflectionSummary.points,
  view.closingMessage.message,
  view.secretTip,
].where((part) => part.trim().isNotEmpty).cast<String>().toList();

Map<String, Object?> _criticalSections(dynamic view) => {
  'hero': [view.hero.headline, view.hero.summary],
  'strengths': [
    for (final dynamic card in view.strengths.cards) [card.title, card.body],
  ],
  'cautions': [
    for (final dynamic card in view.cautions.cards) [card.title, card.body],
  ],
  'advice': view.advice.body,
  'dashboard': [
    for (final dynamic item in view.lifeDashboard)
      [item.currentState, item.whyItAppears, item.suggestedAction],
  ],
  'timeline': view.lifeTimeline == null
      ? const []
      : [
          for (final dynamic period in view.lifeTimeline.periods)
            [
              period.summary,
              period.whatChanges,
              period.easier,
              period.harder,
              period.comparison,
              period.advice,
            ],
        ],
  'prediction': view.futurePrediction == null
      ? const []
      : [
          for (final dynamic window in view.futurePrediction.windows)
            [
              window.summary,
              window.topOpportunity,
              window.topRisk,
              window.why,
              window.whyNow,
              window.whatToWatch,
            ],
        ],
  'closing': [view.closingMessage.message, view.secretTip],
};

String _lagnaDegree(ThaiBetaAnalysis analysis) {
  final value = analysis.profile?.siderealAscendantDeg;
  if (value == null) return 'unknown';
  final withinSign = value % 30;
  final minutes = (withinSign * 60).round();
  return '${minutes ~/ 60}°${(minutes % 60).toString().padLeft(2, '0')}′';
}

bool _unknownFailClosed(ThaiBetaAnalysis analysis) {
  if (analysis.input.hasBirthTime) return true;
  final reading = ThaiBirthProfileCoreReading.fromAnalysis(analysis);
  final domains = reading.sections.map((section) => section.domain).toSet();
  return !domains.contains(ThaiBirthProfileCoreDomain.work) &&
      !domains.contains(ThaiBirthProfileCoreDomain.money) &&
      !domains.contains(ThaiBirthProfileCoreDomain.relationships) &&
      !domains.contains(ThaiBirthProfileCoreDomain.wellbeing);
}

String _sha(String value) => sha256.convert(utf8.encode(value)).toString();
String _shaJson(Object? value) => _sha(jsonEncode(value));

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

final canonicalFixtures = <String, ThaiBetaInput>{
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
