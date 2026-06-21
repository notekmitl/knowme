import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/themes/theme_category.dart';
import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_type.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_evidence.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_resolver_input.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_result.dart';
import 'package:knowme/features/astrology/thai/theme/thai_theme_engine.dart';
import 'package:knowme/features/astrology/thai/theme/thai_theme_presenter.dart';
import 'package:knowme/features/astrology/thai/theme/thai_theme_resolver.dart';

void main() {
  group('ThaiThemePresenter', () {
    test('presents theme metadata from registry', () {
      final results = ThaiThemeEngine.process(
        ThaiThemeResolver.resolve(
          const ThaiThemeResolverInput(
            lagnaKey: ThaiContentKeys.lagnaCapricorn,
            lagnaLordKey: ThaiContentKeys.lagnaLordSaturn,
            myanmarKeys: [ThaiContentKeys.myanmarSeven7],
          ),
        ),
      );

      final presented = ThaiThemePresenter.present(results);
      final disciplined =
          presented.firstWhere((theme) => theme.themeId == 'disciplined');
      final definition = ThemeRegistry.getById('disciplined');

      expect(definition, isNotNull);
      expect(disciplined.themeName, definition!.name);
      expect(disciplined.category, definition.category.displayName);
      expect(disciplined.description, definition.description);
      expect(disciplined.score, closeTo(2.145, 0.001));
    });

    test('skips themes missing from registry without throwing', () {
      final results = [
        const ThaiThemeResult(
          themeId: 'disciplined',
          score: 2.145,
          confidence: ThaiThemeConfidenceLevel.high,
          evidence: [],
        ),
        const ThaiThemeResult(
          themeId: 'unknown_theme_xyz',
          score: 1.5,
          confidence: ThaiThemeConfidenceLevel.medium,
          evidence: [],
        ),
      ];

      expect(() => ThaiThemePresenter.present(results), returnsNormally);

      final presented = ThaiThemePresenter.present(results);
      expect(presented.length, 1);
      expect(presented.single.themeId, 'disciplined');
    });

    test('passes confidence through unchanged', () {
      final results = [
        const ThaiThemeResult(
          themeId: 'disciplined',
          score: 2.145,
          confidence: ThaiThemeConfidenceLevel.high,
          evidence: [],
        ),
        const ThaiThemeResult(
          themeId: 'grounded',
          score: 0.54,
          confidence: ThaiThemeConfidenceLevel.low,
          evidence: [],
        ),
      ];

      final presented = ThaiThemePresenter.present(results);

      expect(
        presented.firstWhere((theme) => theme.themeId == 'disciplined').confidence,
        ThaiThemeConfidenceLevel.high,
      );
      expect(
        presented.firstWhere((theme) => theme.themeId == 'grounded').confidence,
        ThaiThemeConfidenceLevel.low,
      );
    });

    test('passes evidence through unchanged', () {
      const evidence = [
        ThaiThemeEvidence(
          contentKey: ThaiContentKeys.lagnaCapricorn,
          sourceType: ThaiContentType.lagna,
          contribution: 0.95,
        ),
        ThaiThemeEvidence(
          contentKey: ThaiContentKeys.lagnaLordSaturn,
          sourceType: ThaiContentType.lagnaLord,
          contribution: 0.72,
        ),
      ];

      final results = [
        const ThaiThemeResult(
          themeId: 'disciplined',
          score: 2.145,
          confidence: ThaiThemeConfidenceLevel.high,
          evidence: evidence,
        ),
      ];

      final presented = ThaiThemePresenter.present(results);

      expect(presented.single.evidence, evidence);
    });

    test('preserves engine ordering after skipping missing themes', () {
      final results = [
        const ThaiThemeResult(
          themeId: 'disciplined',
          score: 3.0,
          confidence: ThaiThemeConfidenceLevel.high,
          evidence: [],
        ),
        const ThaiThemeResult(
          themeId: 'missing_theme_a',
          score: 2.5,
          confidence: ThaiThemeConfidenceLevel.high,
          evidence: [],
        ),
        const ThaiThemeResult(
          themeId: 'builder',
          score: 2.0,
          confidence: ThaiThemeConfidenceLevel.high,
          evidence: [],
        ),
        const ThaiThemeResult(
          themeId: 'missing_theme_b',
          score: 1.5,
          confidence: ThaiThemeConfidenceLevel.medium,
          evidence: [],
        ),
        const ThaiThemeResult(
          themeId: 'persistence',
          score: 1.0,
          confidence: ThaiThemeConfidenceLevel.medium,
          evidence: [],
        ),
      ];

      final presented = ThaiThemePresenter.present(results);

      expect(
        presented.map((theme) => theme.themeId).toList(),
        ['disciplined', 'builder', 'persistence'],
      );
      expect(
        presented.map((theme) => theme.score).toList(),
        [3.0, 2.0, 1.0],
      );
    });

    test('returns empty list for empty input', () {
      expect(ThaiThemePresenter.present([]), isEmpty);
    });

    test('presents every resolvable engine result from full pipeline', () {
      final results = ThaiThemeEngine.process(
        ThaiThemeResolver.resolve(
          const ThaiThemeResolverInput(
            lagnaKey: ThaiContentKeys.lagnaCapricorn,
            lagnaLordKey: ThaiContentKeys.lagnaLordSaturn,
            ramahabhutaKey: ThaiContentKeys.ramahabhutaEarth,
            myanmarKeys: [ThaiContentKeys.myanmarSeven7],
          ),
        ),
      );

      final presented = ThaiThemePresenter.present(results);

      expect(presented.length, results.length);
      for (final theme in presented) {
        expect(ThemeRegistry.contains(theme.themeId), isTrue);
        expect(theme.themeName, isNotEmpty);
        expect(theme.category, isNotEmpty);
        expect(theme.description, isNotEmpty);
      }
    });
  });
}
