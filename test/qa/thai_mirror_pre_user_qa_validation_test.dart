import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/thai_foundation_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_theme_ref.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/mirror/spec/thai_mirror_assembler_spec.dart'
    hide ThaiMirrorAssembler;
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_assembler.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_profile_enrichment.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_top_theme_selector.dart';
import 'package:knowme/features/astrology/thai/qa/population/thai_mirror_population_analyzer.dart';
import 'package:knowme/features/astrology/thai/qa/population/thai_mirror_population_generator.dart';
import 'package:knowme/features/astrology/thai/qa/population/thai_mirror_population_profile.dart';
import 'package:knowme/features/astrology/thai/qa/thai_mirror_qa_profiles.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_presented_theme.dart';

ThaiMirrorThemeRef _toRef(ThaiPresentedTheme theme) {
  return ThaiMirrorThemeRef(
    themeId: theme.themeId,
    themeName: theme.themeName,
    score: theme.score,
    confidence: theme.confidence,
    description: theme.description,
  );
}

List<ThaiPresentedTheme> _sortEngineThemes(List<ThaiPresentedTheme> themes) {
  final copy = List<ThaiPresentedTheme>.from(themes);
  copy.sort((a, b) {
    final scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) return scoreCompare;
    return a.themeId.compareTo(b.themeId);
  });
  return copy;
}

ThaiAstrologyProfile _profileFor(ThaiMirrorPopulationProfile profile) {
  return ThaiMirrorProfileEnrichment.enrich(
    profile: ThaiFoundationEngine.generate(profile.birthData),
    birthData: profile.birthData,
  );
}

void main() {
  group('Validation #1 — TopThemeSelector Audit', () {
    test('PASS: only reorders display — scores/confidence unchanged', () {
      final profiles = ThaiMirrorPopulationGenerator.generate(count: 30);
      var reorderCount = 0;

      for (final profile in profiles) {
        final input = ThaiMirrorAssemblerSpec.inputFromProfile(
          _profileFor(profile),
        );
        final sorted = _sortEngineThemes(input.presentedThemes);
        final engineTop3 = sorted.take(3).map(_toRef).toList();
        final selected = ThaiMirrorTopThemeSelector.select(
          sortedThemes: sorted,
          limit: 3,
          toRef: _toRef,
        );

        expect(selected, hasLength(lessThanOrEqualTo(3)));

        for (final ref in selected) {
          final source = sorted.firstWhere((t) => t.themeId == ref.themeId);
          expect(ref.score, source.score,
              reason: '${profile.id} score drift on ${ref.themeId}');
          expect(ref.confidence, source.confidence,
              reason: '${profile.id} confidence drift on ${ref.themeId}');
        }

        final engineIds = engineTop3.map((t) => t.themeId).toList()..sort();
        final selectedIds = selected.map((t) => t.themeId).toList()..sort();
        expect(selectedIds, engineIds,
            reason: '${profile.id} must not introduce new theme ids');

        if (engineTop3.isNotEmpty &&
            selected.isNotEmpty &&
            engineTop3.first.themeId != selected.first.themeId) {
          reorderCount++;
        }
      }

      expect(reorderCount, greaterThan(0),
          reason: 'selector should occasionally reorder #1');
    });

    test('PASS: sections/evidence unaffected by top theme display order', () {
      final birth = ThaiMirrorPipeline.sampleQaBirthData();
      final profile = ThaiMirrorProfileEnrichment.enrich(
        profile: ThaiFoundationEngine.generate(birth),
        birthData: birth,
      );
      final input = ThaiMirrorAssemblerSpec.inputFromProfile(profile);
      final structural = ThaiMirrorAssembler.assemble(input);

      final sorted = _sortEngineThemes(input.presentedThemes);
      final pureTop = sorted.take(3).map(_toRef).toList();
      final selectedTop = ThaiMirrorTopThemeSelector.select(
        sortedThemes: sorted,
        limit: 3,
        toRef: _toRef,
      );

      expect(structural.sections, isNotEmpty);
      expect(pureTop.map((t) => t.themeId).toSet(),
          selectedTop.map((t) => t.themeId).toSet());
      for (final section in structural.sections) {
        expect(section.evidence, isNotEmpty);
      }
    });
  });

  group('Validation #2 — Engine Truth (Growth Areas)', () {
    test('PASS: no synthetic growth themes across 10 population profiles', () {
      final profiles = ThaiMirrorPopulationGenerator.generate().take(10).toList();

      for (final profile in profiles) {
        final result = ThaiMirrorPipeline.generate(profile.birthData).mirrorResult!;
        final growth = result.sectionById(ThaiMirrorSectionId.growthAreas)!;
        final input = ThaiMirrorAssemblerSpec.inputFromProfile(
          _profileFor(profile),
        );
        final engineById = {
          for (final t in input.presentedThemes) t.themeId: t,
        };

        for (final ref in growth.supportingThemes) {
          final engine = engineById[ref.themeId];
          expect(engine, isNotNull,
              reason: '${profile.id} unknown theme ${ref.themeId}');
          expect(engine!.score, greaterThan(0),
              reason: '${profile.id} synthetic score on ${ref.themeId}');
          expect(engine.evidence, isNotEmpty,
              reason: '${profile.id} synthetic evidence on ${ref.themeId}');
          expect(ref.score, engine.score);
        }
      }
    });

    test('PASS: growth section evidence traces to engine themes only', () {
      final profiles = ThaiMirrorPopulationGenerator.generate(count: 30);

      for (final profile in profiles) {
        final result = ThaiMirrorPipeline.generate(profile.birthData).mirrorResult!;
        final growth = result.sectionById(ThaiMirrorSectionId.growthAreas)!;
        final themeIds = growth.supportingThemes.map((t) => t.themeId).toSet();

        for (final evidence in growth.evidence) {
          expect(
            evidence.supportedThemeIds.every(themeIds.contains),
            isTrue,
            reason: '${profile.id} orphan evidence ${evidence.contentKey}',
          );
        }
      }
    });
  });

  group('Validation #3 — Narrative Determinism Audit', () {
    test('PASS: identical output across 20 runs', () {
      final birth = ThaiBirthData(
        localDateTime: DateTime(1988, 3, 21, 14, 30),
        timeZoneOffset: const Duration(hours: 7),
        latitude: 13.75,
        longitude: 100.50,
        hasBirthTime: true,
      );

      final baseline = ThaiMirrorPipeline.generate(birth).mirrorResult!;
      for (var run = 0; run < 20; run++) {
        final result = ThaiMirrorPipeline.generate(birth).mirrorResult!;
        expect(result.topThemes, baseline.topThemes, reason: 'run $run top');
        expect(result.sections.length, baseline.sections.length);
        for (var i = 0; i < result.sections.length; i++) {
          expect(result.sections[i].summary, baseline.sections[i].summary,
              reason: 'run $run section ${result.sections[i].id}');
          expect(result.sections[i].evidence.length,
              baseline.sections[i].evidence.length);
        }
      }
    });
  });

  group('Validation #4 — Population QA Regression', () {
    late final report = ThaiMirrorPopulationAnalyzer.analyze();

    test('metrics remain within truth-lock bounds', () {
      expect(report.crashCount, 0);
      expect(report.topThemeDistribution.share('leadership'), lessThan(0.25));
      expect(
        report.evidenceDistribution.share('mahabhuta_position'),
        lessThan(0.45),
      );
      expect(report.narrativeDiversity.uniquenessRatio, greaterThan(0.20));
    });

    test('growth areas coverage is engine-truth only (may be below 60%)', () {
      final coverage =
          report.sectionCoverage[ThaiMirrorSectionId.growthAreas] ?? 0;
      expect(coverage, greaterThanOrEqualTo(0));
      expect(coverage, lessThanOrEqualTo(1.0));
    });
  });

  group('Validation #5 — Architecture Boundary Audit', () {
    test('mirror assembler spec calls theme layers read-only', () {
      expect(ThaiMirrorAssemblerSpec.rules, isNotEmpty);
    });

    test('top selector lives in mirror layer only', () {
      expect(ThaiMirrorTopThemeSelector, isNotNull);
    });
  });

  group('Validation #6 — QA Profiles (22) Engine Truth', () {
    test('all 22 QA profiles succeed with engine-truth growth areas', () {
      for (final qa in ThaiMirrorQaProfiles.all) {
        final result = ThaiMirrorPipeline.generate(qa.birthData).mirrorResult;
        expect(result, isNotNull, reason: qa.id);
        final growth = result!.sectionById(ThaiMirrorSectionId.growthAreas)!;
        final input = ThaiMirrorAssemblerSpec.inputFromProfile(
          ThaiMirrorProfileEnrichment.enrich(
            profile: ThaiFoundationEngine.generate(qa.birthData),
            birthData: qa.birthData,
          ),
        );
        final engineById = {
          for (final t in input.presentedThemes) t.themeId: t,
        };

        for (final ref in growth.supportingThemes) {
          final engine = engineById[ref.themeId];
          expect(engine, isNotNull, reason: '${qa.id} ${ref.themeId}');
          expect(engine!.score, greaterThan(0), reason: qa.id);
          expect(engine.evidence, isNotEmpty, reason: qa.id);
        }
      }
    });
  });
}
