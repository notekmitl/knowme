import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/themes/theme_category.dart';
import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_type.dart';
import 'package:knowme/features/astrology/thai/foundation/integration/thai_foundation_resolver_bridge.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/models/profile_warning.dart';
import 'package:knowme/features/astrology/thai/foundation/thai_foundation_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_input.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_lens_source.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_hero_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/spec/thai_mirror_assembler_spec.dart'
    show ThaiMirrorAssemblerSpec;
import 'package:knowme/features/astrology/thai/mirror/spec/thai_mirror_contract.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_assembler.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_narrative_generator.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_presented_theme.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_evidence.dart';

const _bangkokOffset = Duration(hours: 7);

ThaiPresentedTheme _presented({
  required String themeId,
  required ThemeCategory category,
  required double score,
  ThaiThemeConfidenceLevel confidence = ThaiThemeConfidenceLevel.high,
  List<ThaiThemeEvidence> evidence = const [],
}) {
  final definition = ThemeRegistry.getById(themeId)!;
  return ThaiPresentedTheme(
    themeId: themeId,
    themeName: definition.name,
    category: category.displayName,
    description: definition.description,
    score: score,
    confidence: confidence,
    evidence: evidence,
  );
}

ThaiBirthData _bangkokBirth({
  required int year,
  required int month,
  required int day,
  int hour = 12,
  int minute = 0,
}) {
  return ThaiBirthData(
    localDateTime: DateTime(year, month, day, hour, minute),
    timeZoneOffset: _bangkokOffset,
    latitude: 13.75,
    longitude: 100.50,
    hasBirthTime: true,
  );
}

ThaiMirrorResult _assemble({
  List<ThaiPresentedTheme> themes = const [],
  ThaiAstrologyProfile profile = const ThaiAstrologyProfile(),
}) {
  return ThaiMirrorAssembler.assemble(
    ThaiMirrorInput(profile: profile, presentedThemes: themes),
  );
}

void main() {
  group('ThaiMirrorPresenter', () {
    test('empty mirror result maps without exception', () {
      final viewState = ThaiMirrorPresenter.present(_assemble());

      expect(viewState, isNotNull);
      expect(viewState.topThemes, isEmpty);
      expect(viewState.sections, hasLength(8));
      expect(viewState.evidenceExplorer.totalEvidenceCount, 0);
      expect(viewState.profileContext.warningMessages, isEmpty);
      expect(viewState.hero.topThemeNames, isEmpty);
    });

    test('hero uses fallback summary when core self summary is absent', () {
      final viewState = ThaiMirrorPresenter.present(_assemble());

      expect(
        viewState.hero.reflectionSummary,
        ThaiMirrorHeroState.fallbackReflectionSummary,
      );
    });

    test('hero summary derived from core self first sentences', () {
      final structural = _assemble(
        themes: [
          _presented(
            themeId: 'grounded',
            category: ThemeCategory.coreSelf,
            score: 5,
          ),
        ],
      );
      final narrative = ThaiMirrorNarrativeGenerator.generate(structural);
      final coreSummary =
          narrative.sectionById(ThaiMirrorSectionId.coreSelf)!.summary!;

      final viewState = ThaiMirrorPresenter.present(narrative);

      expect(viewState.hero.reflectionSummary, isNotEmpty);
      expect(
        viewState.hero.reflectionSummary,
        isNot(ThaiMirrorHeroState.fallbackReflectionSummary),
      );
      expect(coreSummary.startsWith(viewState.hero.reflectionSummary.replaceAll('…', '')), isTrue);
    });

    test('top themes preserve domain order', () {
      final structural = _assemble(
        themes: [
          _presented(
            themeId: 'disciplined',
            category: ThemeCategory.coreSelf,
            score: 10,
          ),
          _presented(
            themeId: 'builder',
            category: ThemeCategory.workAndAmbition,
            score: 8,
          ),
          _presented(
            themeId: 'leadership',
            category: ThemeCategory.strengths,
            score: 6,
          ),
          _presented(
            themeId: 'analytical',
            category: ThemeCategory.thinkingStyle,
            score: 4,
          ),
        ],
      );

      final viewState = ThaiMirrorPresenter.present(structural);

      expect(viewState.topThemes, hasLength(3));
      expect(viewState.topThemes.map((t) => t.themeId).toList(), [
        'disciplined',
        'builder',
        'leadership',
      ]);
      expect(viewState.topThemes.map((t) => t.rank).toList(), [1, 2, 3]);
    });

    test('confidence labels mapped to Thai', () {
      final structural = _assemble(
        themes: [
          _presented(
            themeId: 'disciplined',
            category: ThemeCategory.coreSelf,
            score: 10,
            confidence: ThaiThemeConfidenceLevel.high,
          ),
          _presented(
            themeId: 'analytical',
            category: ThemeCategory.thinkingStyle,
            score: 9,
            confidence: ThaiThemeConfidenceLevel.medium,
          ),
          _presented(
            themeId: 'avoidance',
            category: ThemeCategory.growthAreas,
            score: 8,
            confidence: ThaiThemeConfidenceLevel.low,
          ),
        ],
      );

      final viewState = ThaiMirrorPresenter.present(structural);

      expect(viewState.topThemes[0].confidenceLabel, 'ความชัดเจนสูง');
      expect(viewState.topThemes[1].confidenceLabel, 'ปานกลาง');
      expect(viewState.topThemes[2].confidenceLabel, 'บางส่วน');
      expect(ThaiMirrorPresenter.confidenceLabel(ThaiThemeConfidenceLevel.high), 'ความชัดเจนสูง');
    });

    test('section ordering preserved from domain', () {
      final viewState = ThaiMirrorPresenter.present(_assemble());

      expect(
        viewState.sections.map((s) => s.id).toList(),
        [
          ThaiMirrorSectionId.coreSelf,
          ThaiMirrorSectionId.thinkingStyle,
          ThaiMirrorSectionId.emotionalWorld,
          ThaiMirrorSectionId.relationships,
          ThaiMirrorSectionId.workAndAmbition,
          ThaiMirrorSectionId.strengths,
          ThaiMirrorSectionId.growthAreas,
          ThaiMirrorSectionId.growthPath,
        ],
      );
    });

    test('section expansion defaults match specification', () {
      final viewState = ThaiMirrorPresenter.present(_assemble());

      expect(
        viewState.sections.firstWhere((s) => s.id == ThaiMirrorSectionId.coreSelf).isExpandedDefault,
        isTrue,
      );
      expect(
        viewState.sections.firstWhere((s) => s.id == ThaiMirrorSectionId.thinkingStyle).isExpandedDefault,
        isTrue,
      );
      expect(
        viewState.sections.firstWhere((s) => s.id == ThaiMirrorSectionId.emotionalWorld).isExpandedDefault,
        isTrue,
      );
      expect(
        viewState.sections.firstWhere((s) => s.id == ThaiMirrorSectionId.relationships).isExpandedDefault,
        isFalse,
      );
      expect(
        viewState.sections.firstWhere((s) => s.id == ThaiMirrorSectionId.workAndAmbition).isExpandedDefault,
        isFalse,
      );
      expect(
        viewState.sections.firstWhere((s) => s.id == ThaiMirrorSectionId.strengths).isExpandedDefault,
        isFalse,
      );
      expect(
        viewState.sections.firstWhere((s) => s.id == ThaiMirrorSectionId.growthAreas).isExpandedDefault,
        isFalse,
      );
      expect(
        viewState.sections.firstWhere((s) => s.id == ThaiMirrorSectionId.growthPath).isExpandedDefault,
        isFalse,
      );
    });

    test('evidence explorer aggregates all section evidence without loss', () {
      const lagnaKey = ThaiContentKeys.lagnaTaurus;
      const mahabhutaKey = ThaiContentKeys.mahabhutaPyadhi;

      final structural = _assemble(
        themes: [
          _presented(
            themeId: 'grounded',
            category: ThemeCategory.coreSelf,
            score: 5,
            evidence: const [
              ThaiThemeEvidence(
                contentKey: lagnaKey,
                sourceType: ThaiContentType.lagna,
                contribution: 0.9,
              ),
            ],
          ),
          _presented(
            themeId: 'empathetic',
            category: ThemeCategory.emotionalWorld,
            score: 4,
            evidence: const [
              ThaiThemeEvidence(
                contentKey: mahabhutaKey,
                sourceType: ThaiContentType.mahabhutaPosition,
                contribution: 0.5,
              ),
            ],
          ),
        ],
      );

      final domainEvidenceCount = structural.sections
          .fold<int>(0, (sum, section) => sum + section.evidence.length);

      final viewState = ThaiMirrorPresenter.present(structural);

      expect(viewState.evidenceExplorer.totalEvidenceCount, domainEvidenceCount);
      expect(viewState.evidenceExplorer.rows, hasLength(2));
      expect(
        viewState.evidenceExplorer.lensCounts[ThaiMirrorLensSource.lagna],
        1,
      );
      expect(
        viewState.evidenceExplorer.lensCounts[ThaiMirrorLensSource.mahabhutaPosition],
        1,
      );
      expect(viewState.topThemes.first.evidenceCount, greaterThan(0));
    });

    test('profile context maps warnings and birth time', () {
      final structural = ThaiMirrorAssembler.assemble(
        ThaiMirrorInput(
          profile: ThaiAstrologyProfile(
            hasBirthTime: false,
            calculationStandardVersion: 'v1.1',
            warnings: const [
              ProfileWarning(
                code: 'MISSING_BIRTH_TIME',
                severity: ProfileWarningSeverity.high,
                message: 'No birth time',
              ),
            ],
          ),
          presentedThemes: const [],
        ),
      );

      final viewState = ThaiMirrorPresenter.present(structural);

      expect(viewState.profileContext.hasBirthTime, isFalse);
      expect(viewState.profileContext.calculationStandardVersion, 'v1.1');
      expect(viewState.profileContext.warningMessages, ['No birth time']);
      expect(viewState.profileContext.hasWarnings, isTrue);
    });

    test('disclaimers passthrough unchanged', () {
      final structural = _assemble();
      final viewState = ThaiMirrorPresenter.present(structural);

      expect(viewState.disclaimers, ThaiMirrorContract.defaultDisclaimers);
    });

    test('narrative status passthrough unchanged', () {
      final structural = _assemble();
      final narrative = ThaiMirrorNarrativeGenerator.generate(structural);

      final viewState = ThaiMirrorPresenter.present(narrative);

      expect(viewState.narrativeStatus, ThaiMirrorNarrativeStatus.complete);
    });

    test('output is deterministic', () {
      final result = ThaiMirrorNarrativeGenerator.generate(
        _assemble(
          themes: [
            _presented(
              themeId: 'disciplined',
              category: ThemeCategory.coreSelf,
              score: 7,
              evidence: const [
                ThaiThemeEvidence(
                  contentKey: ThaiContentKeys.lagnaCapricorn,
                  sourceType: ThaiContentType.lagna,
                  contribution: 0.8,
                ),
              ],
            ),
          ],
        ),
      );

      expect(ThaiMirrorPresenter.present(result), ThaiMirrorPresenter.present(result));
    });

    test('full pipeline produces presentable view state', () {
      final profile = ThaiFoundationEngine.generate(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
      );

      final input = ThaiMirrorAssemblerSpec.inputFromProfile(profile);
      final structural = ThaiMirrorAssembler.assemble(input);
      final narrative = ThaiMirrorNarrativeGenerator.generate(structural);
      final viewState = ThaiMirrorPresenter.present(narrative);

      expect(viewState.hero.titleTh, ThaiMirrorHeroState.defaultTitleTh);
      expect(viewState.topThemes, isNotEmpty);
      expect(viewState.sections, hasLength(8));
      expect(viewState.sections.every((s) => s.summary != null), isTrue);
      expect(viewState.evidenceExplorer.totalEvidenceCount, greaterThan(0));
      expect(viewState.narrativeStatus, ThaiMirrorNarrativeStatus.complete);

      final bridgeInput = ThaiFoundationResolverBridge.toResolverInput(profile);
      expect(bridgeInput.lagnaKey, profile.lagnaKey);
    });

    test('ThaiMirrorViewState.empty is valid', () {
      expect(ThaiMirrorViewState.empty.topThemes, isEmpty);
      expect(ThaiMirrorViewState.empty.sections, isEmpty);
    });
  });
}
