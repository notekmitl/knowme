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
import 'package:knowme/features/astrology/thai/mirror/spec/thai_mirror_assembler_spec.dart'
    show ThaiMirrorAssemblerSpec;
import 'package:knowme/features/astrology/thai/mirror/spec/thai_mirror_contract.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_assembler.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_presented_theme.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_evidence.dart';
import 'package:knowme/features/astrology/thai/theme/thai_theme_engine.dart';
import 'package:knowme/features/astrology/thai/theme/thai_theme_presenter.dart';
import 'package:knowme/features/astrology/thai/theme/thai_theme_resolver.dart';

const _bangkokOffset = Duration(hours: 7);

ThaiPresentedTheme _presented({
  required String themeId,
  required String themeName,
  required ThemeCategory category,
  required double score,
  List<ThaiThemeEvidence> evidence = const [],
}) {
  return ThaiPresentedTheme(
    themeId: themeId,
    themeName: themeName,
    category: category.displayName,
    description: ThemeRegistry.getById(themeId)!.description,
    score: score,
    confidence: ThaiThemeConfidenceLevel.high,
    evidence: evidence,
  );
}

ThaiBirthData _bangkokBirth({
  required int year,
  required int month,
  required int day,
  int hour = 12,
  int minute = 0,
  bool hasBirthTime = true,
}) {
  return ThaiBirthData(
    localDateTime: DateTime(year, month, day, hour, minute),
    timeZoneOffset: _bangkokOffset,
    latitude: 13.75,
    longitude: 100.50,
    hasBirthTime: hasBirthTime,
  );
}

void main() {
  group('ThaiMirrorAssembler', () {
    test('empty themes produces empty structural result', () {
      final result = ThaiMirrorAssembler.assemble(
        const ThaiMirrorInput(
          profile: ThaiAstrologyProfile(hasBirthTime: false),
          presentedThemes: [],
        ),
      );

      expect(result.topThemes, isEmpty);
      expect(result.sections, hasLength(8));
      expect(result.sections.every((s) => s.supportingThemes.isEmpty), isTrue);
      expect(result.sections.every((s) => s.evidence.isEmpty), isTrue);
      expect(result.contractVersion, ThaiMirrorContract.version);
    });

    test('top themes limited to 3 by score descending', () {
      final result = ThaiMirrorAssembler.assemble(
        ThaiMirrorInput(
          profile: const ThaiAstrologyProfile(),
          presentedThemes: [
            _presented(
              themeId: 'disciplined',
              themeName: 'Disciplined',
              category: ThemeCategory.coreSelf,
              score: 10,
            ),
            _presented(
              themeId: 'builder',
              themeName: 'Builder',
              category: ThemeCategory.workAndAmbition,
              score: 8,
            ),
            _presented(
              themeId: 'leadership',
              themeName: 'Leadership',
              category: ThemeCategory.strengths,
              score: 6,
            ),
            _presented(
              themeId: 'analytical',
              themeName: 'Analytical',
              category: ThemeCategory.thinkingStyle,
              score: 4,
            ),
          ],
        ),
      );

      expect(result.topThemes, hasLength(3));
      expect(result.topThemes.map((t) => t.themeId).toList(), [
        'disciplined',
        'builder',
        'leadership',
      ]);
    });

    test('groups themes into sections by ThemeRegistry category', () {
      final result = ThaiMirrorAssembler.assemble(
        ThaiMirrorInput(
          profile: const ThaiAstrologyProfile(),
          presentedThemes: [
            _presented(
              themeId: 'disciplined',
              themeName: 'Disciplined',
              category: ThemeCategory.coreSelf,
              score: 5,
            ),
            _presented(
              themeId: 'analytical',
              themeName: 'Analytical',
              category: ThemeCategory.thinkingStyle,
              score: 7,
            ),
            _presented(
              themeId: 'leadership',
              themeName: 'Leadership',
              category: ThemeCategory.strengths,
              score: 9,
            ),
          ],
        ),
      );

      expect(
        result.sectionById(ThaiMirrorSectionId.coreSelf)!.supportingThemes,
        hasLength(1),
      );
      expect(
        result.sectionById(ThaiMirrorSectionId.coreSelf)!.supportingThemes.first.themeId,
        'disciplined',
      );
      expect(
        result.sectionById(ThaiMirrorSectionId.thinkingStyle)!.supportingThemes.first.themeId,
        'analytical',
      );
      expect(
        result.sectionById(ThaiMirrorSectionId.strengths)!.supportingThemes.first.themeId,
        'leadership',
      );
      expect(
        result.sectionById(ThaiMirrorSectionId.relationships)!.supportingThemes,
        isEmpty,
      );
    });

    test('sections follow fixed fusion order', () {
      final result = ThaiMirrorAssembler.assemble(
        const ThaiMirrorInput(
          profile: ThaiAstrologyProfile(),
          presentedThemes: [],
        ),
      );

      expect(
        result.sections.map((s) => s.id).toList(),
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

    test('maps theme evidence to mirror evidence with lens source', () {
      const contentKey = ThaiContentKeys.lagnaTaurus;
      final result = ThaiMirrorAssembler.assemble(
        ThaiMirrorInput(
          profile: const ThaiAstrologyProfile(lagnaKey: contentKey),
          presentedThemes: [
            _presented(
              themeId: 'grounded',
              themeName: 'Grounded',
              category: ThemeCategory.coreSelf,
              score: 3,
              evidence: const [
                ThaiThemeEvidence(
                  contentKey: contentKey,
                  sourceType: ThaiContentType.lagna,
                  contribution: 0.95,
                ),
              ],
            ),
          ],
        ),
      );

      final section = result.sectionById(ThaiMirrorSectionId.coreSelf)!;
      expect(section.evidence, hasLength(1));
      expect(section.evidence.first.lensSource, ThaiMirrorLensSource.lagna);
      expect(section.evidence.first.contentKey, contentKey);
      expect(section.evidence.first.contribution, 0.95);
      expect(section.evidence.first.supportedThemeIds, ['grounded']);
      expect(section.evidence.first.contentTitle, isNotNull);
    });

    test('merges duplicate evidence keys within a section', () {
      const contentKey = ThaiContentKeys.lagnaTaurus;
      final result = ThaiMirrorAssembler.assemble(
        ThaiMirrorInput(
          profile: const ThaiAstrologyProfile(),
          presentedThemes: [
            _presented(
              themeId: 'grounded',
              themeName: 'Grounded',
              category: ThemeCategory.coreSelf,
              score: 5,
              evidence: const [
                ThaiThemeEvidence(
                  contentKey: contentKey,
                  sourceType: ThaiContentType.lagna,
                  contribution: 0.5,
                ),
              ],
            ),
            _presented(
              themeId: 'practical',
              themeName: 'Practical',
              category: ThemeCategory.coreSelf,
              score: 4,
              evidence: const [
                ThaiThemeEvidence(
                  contentKey: contentKey,
                  sourceType: ThaiContentType.lagna,
                  contribution: 0.3,
                ),
              ],
            ),
          ],
        ),
      );

      final evidence = result.sectionById(ThaiMirrorSectionId.coreSelf)!.evidence;
      expect(evidence, hasLength(1));
      expect(evidence.first.contribution, closeTo(0.8, 0.0001));
      expect(evidence.first.supportedThemeIds, ['grounded', 'practical']);
    });

    test('all section summaries are null', () {
      final result = ThaiMirrorAssembler.assemble(
        ThaiMirrorInput(
          profile: const ThaiAstrologyProfile(),
          presentedThemes: [
            _presented(
              themeId: 'disciplined',
              themeName: 'Disciplined',
              category: ThemeCategory.coreSelf,
              score: 1,
            ),
          ],
        ),
      );

      expect(result.sections.every((s) => s.summary == null), isTrue);
    });

    test('narrativeStatus is structuralOnly', () {
      final result = ThaiMirrorAssembler.assemble(
        const ThaiMirrorInput(
          profile: ThaiAstrologyProfile(),
          presentedThemes: [],
        ),
      );

      expect(result.narrativeStatus, ThaiMirrorNarrativeStatus.structuralOnly);
      expect(result.hasNarrative, isFalse);
    });

    test('maps profile context from ThaiAstrologyProfile', () {
      final result = ThaiMirrorAssembler.assemble(
        ThaiMirrorInput(
          profile: ThaiAstrologyProfile(
            hasBirthTime: false,
            calculationStandardVersion: 'v1.1',
            lagnaKey: ThaiContentKeys.lagnaAries,
            lagnaLordKey: ThaiContentKeys.lagnaLordMars,
            myanmarKeys: const ['a', 'b'],
            mahabhutaPositionKeys: const ['c'],
            warnings: const [
              ProfileWarning(
                code: 'MISSING_BIRTH_TIME',
                severity: ProfileWarningSeverity.high,
                message: 'No time',
              ),
            ],
          ),
          presentedThemes: const [],
        ),
      );

      final context = result.profileContext;
      expect(context.hasBirthTime, isFalse);
      expect(context.calculationStandardVersion, 'v1.1');
      expect(context.lagnaKey, ThaiContentKeys.lagnaAries);
      expect(context.lagnaLordKey, ThaiContentKeys.lagnaLordMars);
      expect(context.myanmarKeyCount, 2);
      expect(context.mahabhutaKeyCount, 1);
      expect(context.warnings, hasLength(1));
    });

    test('uses default reflective disclaimers', () {
      final result = ThaiMirrorAssembler.assemble(
        const ThaiMirrorInput(
          profile: ThaiAstrologyProfile(),
          presentedThemes: [],
        ),
      );

      expect(result.disclaimers, ThaiMirrorContract.defaultDisclaimers);
    });

    test('full pipeline Profile → Resolver → Engine → Presenter → Assembler', () {
      final profile = ThaiFoundationEngine.generate(
        _bangkokBirth(year: 1972, month: 4, day: 4, hour: 2),
      );

      final resolverInput = ThaiFoundationResolverBridge.toResolverInput(profile);
      final signals = ThaiThemeResolver.resolve(resolverInput);
      final results = ThaiThemeEngine.process(signals);
      final presented = ThaiThemePresenter.present(results);

      final input = ThaiMirrorAssemblerSpec.inputFromProfile(profile);
      expect(input.presentedThemes, presented);

      final mirror = ThaiMirrorAssembler.assemble(input);

      expect(mirror.contractVersion, 'v1');
      expect(mirror.topThemes.length, lessThanOrEqualTo(3));
      expect(mirror.sections, hasLength(8));
      expect(mirror.narrativeStatus, ThaiMirrorNarrativeStatus.structuralOnly);

      final hasEvidence = mirror.sections.any((s) => s.evidence.isNotEmpty);
      expect(hasEvidence, isTrue);
    });
  });
}
