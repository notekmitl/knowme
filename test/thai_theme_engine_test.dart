import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_type.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_resolver_input.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_signal.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_signal_source.dart';
import 'package:knowme/features/astrology/thai/theme/thai_theme_confidence_rules.dart';
import 'package:knowme/features/astrology/thai/theme/thai_theme_engine.dart';
import 'package:knowme/features/astrology/thai/theme/thai_theme_resolver.dart';
import 'package:knowme/features/astrology/thai/theme/thai_theme_source_weights.dart';

void main() {
  group('ThaiThemeConfidenceRules', () {
    test('assigns high confidence for multi-source corroboration', () {
      expect(
        ThaiThemeConfidenceRules.evaluate(sourceCount: 3, totalScore: 2.145),
        ThaiThemeConfidenceLevel.high,
      );
    });

    test('assigns high confidence for two sources with strong score', () {
      expect(
        ThaiThemeConfidenceRules.evaluate(sourceCount: 2, totalScore: 1.54),
        ThaiThemeConfidenceLevel.high,
      );
    });

    test('assigns medium confidence for two sources below high score', () {
      expect(
        ThaiThemeConfidenceRules.evaluate(sourceCount: 2, totalScore: 1.2),
        ThaiThemeConfidenceLevel.medium,
      );
    });

    test('assigns medium confidence for strong single-source score', () {
      expect(
        ThaiThemeConfidenceRules.evaluate(sourceCount: 1, totalScore: 1.0),
        ThaiThemeConfidenceLevel.medium,
      );
    });

    test('assigns low confidence for weak single-source signal', () {
      expect(
        ThaiThemeConfidenceRules.evaluate(sourceCount: 1, totalScore: 0.54),
        ThaiThemeConfidenceLevel.low,
      );
    });
  });

  group('ThaiThemeEngine', () {
    test('calculates confidence from resolver signals', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          lagnaKey: ThaiContentKeys.lagnaCapricorn,
          lagnaLordKey: ThaiContentKeys.lagnaLordSaturn,
          myanmarKeys: [ThaiContentKeys.myanmarSeven7],
        ),
      );

      final results = ThaiThemeEngine.process(signals);
      final disciplined =
          results.firstWhere((result) => result.themeId == 'disciplined');

      expect(disciplined.score, closeTo(2.145, 0.001));
      expect(disciplined.confidence, ThaiThemeConfidenceLevel.high);
      expect(disciplined.evidence.length, 3);
    });

    test('assigns low confidence to single-source ramahabhuta theme', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          ramahabhutaKey: ThaiContentKeys.ramahabhutaEarth,
        ),
      );

      final results = ThaiThemeEngine.process(signals);
      final grounded = results.firstWhere((result) => result.themeId == 'grounded');

      expect(
        grounded.score,
        closeTo(0.9 * ThaiThemeSourceWeights.ramahabhuta, 0.001),
      );
      expect(grounded.confidence, ThaiThemeConfidenceLevel.low);
      expect(grounded.evidence.single.contentKey, ThaiContentKeys.ramahabhutaEarth);
    });

    test('generates evidence from signal sources only', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          lagnaKey: ThaiContentKeys.lagnaCapricorn,
          lagnaLordKey: ThaiContentKeys.lagnaLordSaturn,
        ),
      );

      final results = ThaiThemeEngine.process(signals);
      final builder = results.firstWhere((result) => result.themeId == 'builder');

      expect(builder.evidence.length, 2);
      expect(builder.evidence[0].contentKey, ThaiContentKeys.lagnaCapricorn);
      expect(builder.evidence[0].sourceType, ThaiContentType.lagna);
      expect(builder.evidence[0].contribution, closeTo(0.90, 0.001));
      expect(builder.evidence[1].contentKey, ThaiContentKeys.lagnaLordSaturn);
      expect(builder.evidence[1].sourceType, ThaiContentType.lagnaLord);
      expect(builder.evidence[1].contribution, closeTo(0.64, 0.001));
    });

    test('sorts results by score descending', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          lagnaKey: ThaiContentKeys.lagnaCapricorn,
          lagnaLordKey: ThaiContentKeys.lagnaLordSaturn,
          ramahabhutaKey: ThaiContentKeys.ramahabhutaEarth,
          myanmarKeys: [ThaiContentKeys.myanmarSeven7],
        ),
      );

      final results = ThaiThemeEngine.process(signals);

      for (var i = 0; i < results.length - 1; i++) {
        expect(
          results[i].score,
          greaterThanOrEqualTo(results[i + 1].score),
        );
      }
    });

    test('preserves one evidence entry per resolver source', () {
      const signal = ThaiThemeSignal(
        themeId: 'disciplined',
        score: 2.145,
        sources: [
          ThaiThemeSignalSource(
            contentKey: ThaiContentKeys.lagnaCapricorn,
            sourceType: ThaiContentType.lagna,
            weightUsed: 1.0,
            rawWeight: 0.95,
          ),
          ThaiThemeSignalSource(
            contentKey: ThaiContentKeys.lagnaCapricorn,
            sourceType: ThaiContentType.lagna,
            weightUsed: 1.0,
            rawWeight: 0.5,
          ),
        ],
      );

      final results = ThaiThemeEngine.process([signal]);
      final disciplined = results.single;

      expect(disciplined.evidence.length, 2);
      expect(
        disciplined.evidence.every(
          (item) => item.contentKey == ThaiContentKeys.lagnaCapricorn,
        ),
        isTrue,
      );
      expect(disciplined.evidence[0].contribution, closeTo(0.95, 0.001));
      expect(disciplined.evidence[1].contribution, closeTo(0.5, 0.001));
    });

    test('returns empty list for empty input', () {
      expect(ThaiThemeEngine.process([]), isEmpty);
    });

    test('processes every theme from resolver without hardcoding ids', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          lagnaKey: ThaiContentKeys.lagnaAries,
        ),
      );

      final results = ThaiThemeEngine.process(signals);

      expect(results.length, signals.length);
      expect(
        results.map((result) => result.themeId).toSet(),
        equals(signals.map((signal) => signal.themeId).toSet()),
      );
      expect(
        results.every((result) => result.evidence.isNotEmpty),
        isTrue,
      );
    });
  });
}
