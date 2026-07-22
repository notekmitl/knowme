import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_repository.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_taksa_rotation_metadata.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_taksa_rotation_resolver.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/birth_normalization/birth_normalization.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_curated_block_selector.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_curated_narrative_block.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_confidence.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_domain.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_forbidden.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_formatting.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_activation.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

import 'thai_beta_narrative_fixtures.dart';

/// Real Report Quality Acceptance for Thai Beta Narrative V1.1.1.
///
/// Exercises analysis → curated narrative against Canon / Birth-Normalization
/// rules already in the repository. Does not invent astrology rules.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RQ matrix — calculation + narrative quality', () {
    test('RQ-A full birth time: success, full confidence path, no forbidden', () {
      final case_ = _runCase(ThaiBetaNarrativeFixtures.fixtureA);
      expect(case_.analysis.isSuccess, isTrue);
      expect(case_.analysis.input.hasBirthTime, isTrue);
      expect(case_.view.birthDataConfidence.isComplete, isTrue);
      expect(case_.heroEmpty, isFalse);
      expect(case_.forbidden, isEmpty, reason: case_.forbidden.join(', '));
      expect(case_.placeholders, isEmpty, reason: case_.placeholders.join(', '));
      expect(case_.duplicateBlockIds, isEmpty);
      expect(
        case_.traceMins.any(
          (m) => m >= ThaiBetaNarrativeConfidence.withBirthTime,
        ),
        isTrue,
      );
    });

    test('RQ-B no birth time: reduced confidence + limitation + no deep motive',
        () {
      final case_ = _runCase(ThaiBetaNarrativeFixtures.fixtureB);
      expect(case_.analysis.isSuccess, isTrue);
      expect(case_.analysis.input.hasBirthTime, isFalse);
      expect(case_.view.birthDataConfidence.isComplete, isFalse);
      expect(
        case_.text.contains('โดยไม่มีเวลาเกิด'),
        isTrue,
        reason: 'no-time limitation sentence required',
      );
      expect(case_.noBirthTimeViolations, isEmpty);
      expect(case_.forbidden, isEmpty);
      for (final min in case_.traceMins) {
        expect(
          min,
          lessThanOrEqualTo(ThaiBetaNarrativeConfidence.withoutBirthTime),
        );
      }
      for (final entry
          in case_.result.trace.entries.where((e) => e.blockId != null)) {
        expect(entry.requiresBirthTime, isFalse);
      }
    });

    test('RQ-C facet-tension profile composes without forbidden/placeholder',
        () {
      final case_ = _runCase(ThaiBetaNarrativeFixtures.fixtureC);
      expect(case_.analysis.isSuccess, isTrue);
      expect(case_.forbidden, isEmpty);
      expect(case_.placeholders, isEmpty);
      expect(case_.heroEmpty, isFalse);
    });

    test('RQ-D near-duplicate profile still produces coherent report', () {
      final a = _runCase(ThaiBetaNarrativeFixtures.fixtureA);
      final d = _runCase(ThaiBetaNarrativeFixtures.fixtureD);
      expect(a.analysis.isSuccess && d.analysis.isSuccess, isTrue);
      expect(d.forbidden, isEmpty);
      expect(d.placeholders, isEmpty);
      expect(d.duplicateBlockIds, isEmpty);
    });

    test('RQ-E different life period composes cleanly', () {
      final case_ = _runCase(ThaiBetaNarrativeFixtures.fixtureE);
      expect(case_.analysis.isSuccess, isTrue);
      expect(case_.forbidden, isEmpty);
      expect(case_.placeholders, isEmpty);
      expect(case_.view.lifeDashboard, isNotEmpty);
    });

    test(
      'RQ-W-DAY Wednesday daytime: Thai weekday พุธ + narrative still composes',
      () {
        final case_ = _runCase(ThaiBetaNarrativeFixtures.wednesdayDaytime);
        expect(case_.analysis.isSuccess, isTrue);
        final snap = case_.analysis.normalizedSnapshot!;
        expect(snap.usedPreviousDay, isFalse);
        expect(snap.thaiAstrologicalDate, '1972-04-05');
        expect(_thaiWeekdayNumber(snap.thaiAstrologicalDate), 4);
        expect(case_.analysis.input.hasBirthTime, isTrue);
        expect(case_.forbidden, isEmpty);
        expect(case_.placeholders, isEmpty);
        expect(case_.heroEmpty, isFalse);
      },
    );

    test(
      'RQ-W-NIGHT Wednesday night (pre-sunrise Thu): rolls to พุธ + composes',
      () {
        final case_ =
            _runCase(ThaiBetaNarrativeFixtures.wednesdayNightBeforeSunrise);
        expect(case_.analysis.isSuccess, isTrue);
        final snap = case_.analysis.normalizedSnapshot!;
        expect(snap.usedPreviousDay, isTrue);
        expect(snap.thaiAstrologicalDate, '1972-04-05');
        expect(_thaiWeekdayNumber(snap.thaiAstrologicalDate), 4);
        expect(case_.forbidden, isEmpty);
        expect(case_.placeholders, isEmpty);
        expect(case_.heroEmpty, isFalse);
      },
    );

    test(
      'RQ-W-NOTIME Wednesday without time: same Thai day, reduced confidence',
      () {
        final case_ = _runCase(ThaiBetaNarrativeFixtures.wednesdayNoBirthTime);
        expect(case_.analysis.isSuccess, isTrue);
        final snap = case_.analysis.normalizedSnapshot!;
        expect(snap.usedPreviousDay, isFalse);
        expect(snap.thaiAstrologicalDate, '1972-04-05');
        expect(_thaiWeekdayNumber(snap.thaiAstrologicalDate), 4);
        expect(case_.analysis.input.hasBirthTime, isFalse);
        expect(case_.text.contains('โดยไม่มีเวลาเกิด'), isTrue);
        expect(case_.noBirthTimeViolations, isEmpty);
        for (final min in case_.traceMins) {
          expect(
            min,
            lessThanOrEqualTo(ThaiBetaNarrativeConfidence.withoutBirthTime),
          );
        }
      },
    );

    test('RQ-UNKNOWN-FLAG birthTimeUnknown forces no-time path', () {
      final case_ =
          _runCase(ThaiBetaNarrativeFixtures.incompleteTimeUnknownFlag);
      expect(case_.analysis.isSuccess, isTrue);
      expect(case_.analysis.input.hasBirthTime, isFalse);
      expect(case_.view.birthDataConfidence.isComplete, isFalse);
      expect(case_.text.contains('โดยไม่มีเวลาเกิด'), isTrue);
      expect(case_.noBirthTimeViolations, isEmpty);
    });

    test('RQ-BOUNDARY sunrise edge: before→previous day, after→same day', () {
      final civil = DateTime(1972, 4, 5);
      final noon = BirthNormalizer.normalize(
        RawBirthInput(
          birthDate: civil,
          birthHour: 12,
          province: 'bangkok',
          timeZoneId: 'Asia/Bangkok',
        ),
      ).birth!;
      expect(noon.sunriseAvailable, isTrue);
      final sunrise = noon.sunrise;

      final beforeHour =
          sunrise.minute == 0 ? sunrise.hour - 1 : sunrise.hour;
      final beforeMinute = sunrise.minute == 0 ? 59 : sunrise.minute - 1;
      final before = BirthNormalizer.normalize(
        RawBirthInput(
          birthDate: civil,
          birthHour: beforeHour,
          birthMinute: beforeMinute,
          province: 'bangkok',
          timeZoneId: 'Asia/Bangkok',
        ),
      ).birth!;
      expect(before.thai.bornBeforeSunrise, isTrue);
      expect(before.thai.astrologicalDate, DateTime(1972, 4, 4));

      final after = BirthNormalizer.normalize(
        RawBirthInput(
          birthDate: civil,
          birthHour: sunrise.hour,
          birthMinute: sunrise.minute + 1,
          province: 'bangkok',
          timeZoneId: 'Asia/Bangkok',
        ),
      ).birth!;
      expect(after.thai.bornBeforeSunrise, isFalse);
      expect(after.thai.astrologicalDate, DateTime(1972, 4, 5));

      final beforeReport = _runCase(
        () => ThaiBetaAnalysisRunner.run(
          ThaiBetaInput(
            firstName: 'Edge',
            lastName: 'Before',
            birthDate: civil,
            birthHour: before.raw.birthHour,
            birthMinute: before.raw.birthMinute,
            province: 'กรุงเทพมหานคร',
            provinceKey: 'bangkok',
          ),
          startedAt: ThaiBetaNarrativeFixtures.referenceDate,
        ),
      );
      final afterReport = _runCase(
        () => ThaiBetaAnalysisRunner.run(
          ThaiBetaInput(
            firstName: 'Edge',
            lastName: 'After',
            birthDate: civil,
            birthHour: after.raw.birthHour,
            birthMinute: after.raw.birthMinute,
            province: 'กรุงเทพมหานคร',
            provinceKey: 'bangkok',
          ),
          startedAt: ThaiBetaNarrativeFixtures.referenceDate,
        ),
      );
      expect(beforeReport.analysis.isSuccess, isTrue);
      expect(afterReport.analysis.isSuccess, isTrue);
      expect(beforeReport.forbidden, isEmpty);
      expect(afterReport.forbidden, isEmpty);
    });

    test('RQ-TAKSA-WED Canon: weekday 4 is NOT_IN_SOURCE', () async {
      final repository = await ThaiCanonEvidenceRepository.loadFromAsset();
      final day = ThaiBetaNarrativeFixtures.wednesdayDaytime();
      final night = ThaiBetaNarrativeFixtures.wednesdayNightBeforeSunrise();
      final dayBirth = day.pipelineResult?.birthData;
      final nightBirth = night.pipelineResult?.birthData;
      expect(dayBirth?.thaiWeekdayNumber, 4);
      expect(nightBirth?.thaiWeekdayNumber, 4);

      final dayTaksa = ThaiTaksaRotationResolver.resolve(
        birthData: dayBirth,
        repository: repository,
      );
      final nightTaksa = ThaiTaksaRotationResolver.resolve(
        birthData: nightBirth,
        repository: repository,
      );
      expect(dayTaksa.metadata.blocker, TaksaRotationBlocker.notInSource);
      expect(nightTaksa.metadata.blocker, TaksaRotationBlocker.notInSource);
      expect(
        ThaiTaksaBirthWeekday.notInSourceWeekdayNumbers.contains(4),
        isTrue,
      );
      expect(
        ThaiTaksaNotInSourceWeekdayCase.wednesdayDaytime,
        isNot(ThaiTaksaNotInSourceWeekdayCase.wednesdayNightRahu),
      );
    });

    test('RQ-BLOCKS no duplicate curated blocks; advice prefixes valid', () {
      for (final load in [
        ThaiBetaNarrativeFixtures.fixtureA,
        ThaiBetaNarrativeFixtures.fixtureB,
        ThaiBetaNarrativeFixtures.wednesdayDaytime,
        ThaiBetaNarrativeFixtures.wednesdayNightBeforeSunrise,
      ]) {
        final case_ = _runCase(load);
        expect(case_.duplicateBlockIds, isEmpty);
        for (final item in case_.view.lifeDashboard) {
          if (item.suggestedAction.trim().isEmpty) continue;
          expect(
            ThaiBetaNarrativeForbidden.isValidAdvicePhrase(item.suggestedAction),
            isTrue,
            reason: item.suggestedAction,
          );
        }
      }
    });

    test(
      'RQ-SELECTOR unused same-domain advice preferred over reusing fallback',
      () {
        // leadership rarely tags luck advice; force fallback path with used id.
        final selection = ThaiBetaCuratedBlockSelector.select(
          CuratedBlockQuery(
            section: CuratedNarrativeSection.advice,
            primaryThemeId: 'leadership',
            domain: ThaiBetaLifeDomain.luck,
            hasBirthTime: true,
            usedBlockIds: const {'advice_luck_fallback_v1'},
            seed: 0,
          ),
        );
        expect(selection.block.id, isNot('advice_luck_fallback_v1'));
        expect(selection.block.domain, ThaiBetaLifeDomain.luck);
        expect(selection.block.section, CuratedNarrativeSection.advice);
      },
    );

    test('RQ-CONFIDENCE block mins consistent with birth-time policy', () {
      final withTime = _runCase(ThaiBetaNarrativeFixtures.fixtureA);
      final noTime = _runCase(ThaiBetaNarrativeFixtures.fixtureB);
      expect(
        withTime.traceMins.any(
          (m) => m >= ThaiBetaNarrativeConfidence.withBirthTime,
        ),
        isTrue,
      );
      expect(
        noTime.traceMins.every(
          (m) => m <= ThaiBetaNarrativeConfidence.withoutBirthTime,
        ),
        isTrue,
      );
    });
  });

  group('RQ matrix — Evidence Badge gate (unchanged invited_beta)', () {
    test('RQ-BADGE anonymous never renders under invited_beta', () {
      expect(ThaiEvidenceBadgeActivation.configuredState, 'invited_beta');
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
        isFalse,
      );
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          audience: const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
        ),
        isTrue,
      );
    });
  });

  group('RQ matrix — report UI mobile/desktop', () {
    late ThaiBetaAnalysis analysis;

    setUpAll(() {
      analysis = ThaiBetaNarrativeFixtures.fixtureA();
    });

    Future<void> pumpReport(WidgetTester tester, Size size) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('RQ-UI-MOBILE report paints; no badge; content present',
        (tester) async {
      await pumpReport(tester, const Size(390, 844));
      expect(find.byType(ThaiBetaReportPage), findsOneWidget);
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
      expect(
        find.byKey(const Key('thai_beta_report_page_scroll')),
        findsOneWidget,
      );
      expect(find.textContaining('คุณ'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RQ-UI-DESKTOP report paints; no badge for anonymous',
        (tester) async {
      await pumpReport(tester, const Size(1280, 800));
      expect(find.byType(ThaiBetaReportPage), findsOneWidget);
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

class _ReportCase {
  _ReportCase({
    required this.analysis,
    required this.result,
    required this.text,
    required this.forbidden,
    required this.noBirthTimeViolations,
    required this.placeholders,
    required this.duplicateBlockIds,
    required this.traceMins,
  });

  final ThaiBetaAnalysis analysis;
  final ThaiBetaNarrativeResult result;
  final String text;
  final List<String> forbidden;
  final List<String> noBirthTimeViolations;
  final List<String> placeholders;
  final List<String> duplicateBlockIds;
  final List<double> traceMins;

  ThaiMirrorConsumerViewState get view => result.view;

  bool get heroEmpty =>
      result.view.hero.headline.trim().isEmpty &&
      result.view.hero.summary.trim().isEmpty;
}

_ReportCase _runCase(ThaiBetaAnalysis Function() load) {
  final analysis = load();
  final result = ThaiBetaNarrativeComposer.compose(analysis);
  final view = result.view;
  final buf = StringBuffer()
    ..writeln(view.hero.headline)
    ..writeln(view.hero.summary)
    ..writeln(view.advice.body)
    ..writeln(view.birthDataConfidence.title)
    ..writeln(view.birthDataConfidence.body);
  for (final card in view.strengths.cards) {
    buf
      ..writeln(card.title)
      ..writeln(card.body)
      ..writeln(card.expandedBody ?? '');
  }
  for (final item in view.lifeDashboard) {
    buf
      ..writeln(item.label)
      ..writeln(item.currentState)
      ..writeln(item.whyItAppears)
      ..writeln(item.suggestedAction);
  }
  for (final section in view.narrativeSections) {
    buf
      ..writeln(section.label)
      ..writeln(section.overview)
      ..writeln(section.whyItAppears)
      ..writeln(section.advice);
  }
  final text = buf.toString();
  final blockIds = result.trace.entries
      .map((e) => e.blockId)
      .whereType<String>()
      .toList();
  final dupes = <String>[];
  final seen = <String>{};
  for (final id in blockIds) {
    if (!seen.add(id)) dupes.add(id);
  }

  final placeholders = <String>{};
  for (final pattern in [
    RegExp(r'\bTODO\b'),
    RegExp(r'\bFIXME\b'),
    RegExp(r'\bundefined\b', caseSensitive: false),
    // Internal curated ids must never appear in user-facing copy.
    RegExp(r'\b(?:hero|advice|fallback|dashboard|domain|strength)_[a-z0-9_]+_v\d+\b'),
    RegExp(r'CuratedNarrative'),
    RegExp(r'\$\{'),
    RegExp(r'\{\{'),
  ]) {
    for (final match in pattern.allMatches(text)) {
      placeholders.add(match.group(0)!);
    }
  }
  for (final pattern in ThaiBetaNarrativeFormatting.forbiddenPatterns) {
    for (final match in pattern.allMatches(text)) {
      placeholders.add(match.group(0)!);
    }
  }

  return _ReportCase(
    analysis: analysis,
    result: result,
    text: text,
    forbidden: ThaiBetaNarrativeForbidden.findForbidden(text),
    noBirthTimeViolations:
        ThaiBetaNarrativeForbidden.findNoBirthTimeViolations(text),
    placeholders: placeholders.toList(),
    duplicateBlockIds: dupes,
    traceMins: result.trace.entries
        .where((e) => e.blockId != null && e.minimumConfidence != null)
        .map((e) => e.minimumConfidence!)
        .toList(),
  );
}

int _thaiWeekdayNumber(String ymd) {
  final parts = ymd.split('-');
  final d = DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
  final w = d.weekday;
  return w == DateTime.sunday ? 1 : w + 1;
}
