import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_type.dart';
import 'package:knowme/features/astrology/thai/content/registry/thai_content_registry.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_resolver_input.dart';
import 'package:knowme/features/astrology/thai/theme/thai_theme_resolver.dart';
import 'package:knowme/features/astrology/thai/theme/thai_theme_source_weights.dart';

void main() {
  group('Mahabhuta Position theme audit', () {
    test('all mahabhuta position theme ids exist in ThemeRegistry', () {
      final missing = <String>[];

      for (final section in ThaiContentRegistry.allMahabhutaPosition()) {
        for (final mapping in section.themeMappings) {
          if (!ThemeRegistry.contains(mapping.theme)) {
            missing.add('${section.key} → ${mapping.theme}');
          }
        }
      }

      expect(missing, isEmpty, reason: missing.join(', '));
    });
  });

  group('ThaiThemeResolver', () {
    test('aggregates theme signals across all lenses', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          lagnaKey: ThaiContentKeys.lagnaCapricorn,
          lagnaLordKey: ThaiContentKeys.lagnaLordSaturn,
          myanmarKeys: [ThaiContentKeys.myanmarSeven7],
        ),
      );

      expect(signals, isNotEmpty);

      final disciplined = signals.firstWhere((s) => s.themeId == 'disciplined');
      expect(disciplined.score, closeTo(2.145, 0.001));
      expect(disciplined.sources.length, 3);
    });

    test('applies source weighting per lens type', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          lagnaKey: ThaiContentKeys.lagnaCapricorn,
        ),
      );

      final disciplined = signals.firstWhere((s) => s.themeId == 'disciplined');
      final source = disciplined.sources.single;

      expect(source.contentKey, ThaiContentKeys.lagnaCapricorn);
      expect(source.sourceType, ThaiContentType.lagna);
      expect(source.weightUsed, ThaiThemeSourceWeights.lagna);
      expect(source.rawWeight, 0.95);
      expect(source.contribution, closeTo(0.95, 0.001));
      expect(disciplined.score, closeTo(0.95, 0.001));
    });

    test('merges duplicate theme ids from multiple sources', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          lagnaKey: ThaiContentKeys.lagnaCapricorn,
          lagnaLordKey: ThaiContentKeys.lagnaLordSaturn,
          myanmarKeys: [ThaiContentKeys.myanmarSeven7],
        ),
      );

      final builder = signals.firstWhere((s) => s.themeId == 'builder');
      expect(builder.sources.length, 3);
      expect(
        builder.score,
        closeTo(0.90 * 1.00 + 0.80 * 0.80 + 0.85 * 0.50, 0.001),
      );

      final persistence = signals.firstWhere((s) => s.themeId == 'persistence');
      expect(persistence.sources.length, 3);
    });

    test('sorts signals by score descending', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          lagnaKey: ThaiContentKeys.lagnaCapricorn,
          lagnaLordKey: ThaiContentKeys.lagnaLordSaturn,
          ramahabhutaKey: ThaiContentKeys.ramahabhutaEarth,
          myanmarKeys: [ThaiContentKeys.myanmarSeven7],
        ),
      );

      for (var i = 0; i < signals.length - 1; i++) {
        expect(
          signals[i].score,
          greaterThanOrEqualTo(signals[i + 1].score),
        );
      }
    });

    test('skips missing content without throwing', () {
      expect(
        () => ThaiThemeResolver.resolve(
          const ThaiThemeResolverInput(
            lagnaKey: 'lagna_unknown',
            lagnaLordKey: ThaiContentKeys.lagnaLordSun,
            ramahabhutaKey: 'not_a_real_key',
            myanmarKeys: ['myanmar_seven_99', ThaiContentKeys.myanmarSeven1],
          ),
        ),
        returnsNormally,
      );

      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          lagnaKey: 'lagna_unknown',
          lagnaLordKey: ThaiContentKeys.lagnaLordSun,
          ramahabhutaKey: 'not_a_real_key',
          myanmarKeys: ['myanmar_seven_99', ThaiContentKeys.myanmarSeven1],
        ),
      );

      expect(signals, isNotEmpty);
      expect(
        signals.every((signal) => signal.sources.isNotEmpty),
        isTrue,
      );
      expect(
        signals
            .expand((signal) => signal.sources)
            .any((source) => source.contentKey == 'lagna_unknown'),
        isFalse,
      );
    });

    test('returns empty list when all keys are missing or absent', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          lagnaKey: 'lagna_missing',
          myanmarKeys: ['myanmar_seven_missing'],
        ),
      );

      expect(signals, isEmpty);
    });

    test('includes ramahabhuta lens with lower source weight', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          ramahabhutaKey: ThaiContentKeys.ramahabhutaEarth,
        ),
      );

      expect(signals, isNotEmpty);

      final grounded = signals.firstWhere((s) => s.themeId == 'grounded');
      expect(grounded.sources.single.weightUsed, ThaiThemeSourceWeights.ramahabhuta);
      expect(grounded.score, closeTo(0.9 * ThaiThemeSourceWeights.ramahabhuta, 0.001));
    });

    test('aggregates mahabhuta position themes', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          mahabhutaPositionKeys: [ThaiContentKeys.mahabhutaAdhibodi],
        ),
      );

      expect(signals, isNotEmpty);

      final leadership = signals.firstWhere((s) => s.themeId == 'leadership');
      expect(
        leadership.score,
        closeTo(0.95 * ThaiThemeSourceWeights.mahabhutaPosition, 0.001),
      );
      expect(leadership.sources.single.contentKey, ThaiContentKeys.mahabhutaAdhibodi);
      expect(
        leadership.sources.single.sourceType,
        ThaiContentType.mahabhutaPosition,
      );
      expect(
        leadership.sources.single.weightUsed,
        ThaiThemeSourceWeights.mahabhutaPosition,
      );
    });

    test('handles multiple mahabhuta position keys', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          mahabhutaPositionKeys: [
            ThaiContentKeys.mahabhutaAdhibodi,
            ThaiContentKeys.mahabhutaThongchai,
          ],
        ),
      );

      final leadership = signals.firstWhere((s) => s.themeId == 'leadership');
      expect(leadership.sources.length, 1);
      expect(leadership.sources.single.contentKey, ThaiContentKeys.mahabhutaAdhibodi);
      expect(leadership.score, closeTo(0.95 * 0.65, 0.001));

      expect(signals.any((s) => s.themeId == 'visionary'), isTrue);
      expect(signals.any((s) => s.themeId == 'strategic'), isTrue);
    });

    test('combines mahabhuta positions with lagna', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          lagnaKey: ThaiContentKeys.lagnaCapricorn,
          mahabhutaPositionKeys: [ThaiContentKeys.mahabhutaAdhibodi],
        ),
      );

      final disciplined = signals.firstWhere((s) => s.themeId == 'disciplined');
      expect(disciplined.sources.length, 2);
      expect(
        disciplined.score,
        closeTo(0.95 * 1.0 + 0.9 * 0.65, 0.001),
      );
    });

    test('combines mahabhuta positions with myanmar seven', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          mahabhutaPositionKeys: [ThaiContentKeys.mahabhutaThaya],
          myanmarKeys: [ThaiContentKeys.myanmarSeven7],
        ),
      );

      final builder = signals.firstWhere((s) => s.themeId == 'builder');
      expect(builder.sources.length, 2);
      expect(
        builder.score,
        closeTo(0.75 * 0.65 + 0.85 * 0.50, 0.001),
      );
    });

    test('aggregates all lenses including mahabhuta positions', () {
      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          lagnaKey: ThaiContentKeys.lagnaCapricorn,
          lagnaLordKey: ThaiContentKeys.lagnaLordSaturn,
          mahabhutaPositionKeys: [ThaiContentKeys.mahabhutaAdhibodi],
          myanmarKeys: [ThaiContentKeys.myanmarSeven7],
        ),
      );

      final disciplined = signals.firstWhere((s) => s.themeId == 'disciplined');
      expect(disciplined.sources.length, 4);
      expect(
        disciplined.score,
        closeTo(0.95 * 1.0 + 0.90 * 0.80 + 0.90 * 0.65 + 0.95 * 0.50, 0.001),
      );
    });

    test('remains backward compatible with ramahabhutaKey', () {
      final legacyOnly = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          ramahabhutaKey: ThaiContentKeys.ramahabhutaEarth,
        ),
      );
      final combined = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          ramahabhutaKey: ThaiContentKeys.ramahabhutaEarth,
          mahabhutaPositionKeys: [ThaiContentKeys.mahabhutaThaya],
        ),
      );

      expect(legacyOnly, isNotEmpty);
      expect(
        legacyOnly.firstWhere((s) => s.themeId == 'grounded').score,
        closeTo(0.9 * ThaiThemeSourceWeights.ramahabhuta, 0.001),
      );

      final combinedGrounded =
          combined.firstWhere((s) => s.themeId == 'grounded');
      expect(
        combinedGrounded.sources.any(
          (s) => s.contentKey == ThaiContentKeys.ramahabhutaEarth,
        ),
        isTrue,
      );
      expect(
        combinedGrounded.sources.any(
          (s) => s.contentKey == ThaiContentKeys.mahabhutaThaya,
        ),
        isTrue,
      );
      expect(
        combinedGrounded.score,
        closeTo(
          0.9 * ThaiThemeSourceWeights.ramahabhuta +
              0.9 * ThaiThemeSourceWeights.mahabhutaPosition,
          0.001,
        ),
      );
    });

    test('ignores unknown mahabhuta position keys', () {
      expect(
        () => ThaiThemeResolver.resolve(
          const ThaiThemeResolverInput(
            mahabhutaPositionKeys: [
              'mahabhuta_unknown',
              ThaiContentKeys.mahabhutaPyadhi,
            ],
          ),
        ),
        returnsNormally,
      );

      final signals = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          mahabhutaPositionKeys: [
            'mahabhuta_unknown',
            ThaiContentKeys.mahabhutaPyadhi,
          ],
        ),
      );

      expect(signals, isNotEmpty);
      expect(
        signals
            .expand((s) => s.sources)
            .any((s) => s.contentKey == 'mahabhuta_unknown'),
        isFalse,
      );
      expect(
        signals.any((s) => s.themeId == 'sensitive'),
        isTrue,
      );
    });

    test('aggregates multiple myanmar keys independently', () {
      final single = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          myanmarKeys: [ThaiContentKeys.myanmarSeven1],
        ),
      );
      final dual = ThaiThemeResolver.resolve(
        const ThaiThemeResolverInput(
          myanmarKeys: [
            ThaiContentKeys.myanmarSeven1,
            ThaiContentKeys.myanmarSeven2,
          ],
        ),
      );

      expect(dual.length, greaterThan(single.length));

      final ambitiousSingle =
          single.firstWhere((s) => s.themeId == 'ambitious').score;
      final ambitiousDual =
          dual.firstWhere((s) => s.themeId == 'ambitious').score;
      expect(ambitiousDual, closeTo(ambitiousSingle, 0.001));

      expect(
        dual.any((s) => s.themeId == 'empathetic'),
        isTrue,
      );
    });
  });
}
