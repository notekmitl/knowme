import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/chinese_zodiac/application/zodiac_interpretation_resolver.dart';
import 'package:knowme/features/astrology/chinese_zodiac/application/zodiac_theme_mapper.dart';
import 'package:knowme/features/astrology/chinese_zodiac/data/zodiac_personality_library.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart';

BaziYearAnimal _animal(String en) => BaziYearAnimal(zh: '', roman: en, en: en);

void main() {
  group('ZodiacPersonalityLibrary', () {
    test('supports all 12 animals in th and en', () {
      for (final key in ZodiacPersonalityLibrary.supportedAnimals) {
        final th = ZodiacPersonalityLibrary.lookup(key, 'th');
        final en = ZodiacPersonalityLibrary.lookup(key, 'en');

        expect(th, isNotNull, reason: 'missing th profile for $key');
        expect(en, isNotNull, reason: 'missing en profile for $key');
        expect(th!.animalKey, key);
        expect(en!.animalKey, key);
        expect(th.coreTraits, isNotEmpty);
        expect(th.strengths.length, greaterThanOrEqualTo(2));
        expect(th.challenges.length, greaterThanOrEqualTo(2));
        expect(th.growthSuggestions.length, greaterThanOrEqualTo(2));
      }
    });
  });

  group('ZodiacInterpretationResolver', () {
    test('resolves from chart year animal', () {
      final chart = BaziChartModel.fromMap({
        'version': 'bazi_v1',
        'engine_version': 'test',
        'generated_at': '2026-01-01',
        'input_hash': 'x',
        'completeness': 'four_pillars',
        'dominant_element': 'fire',
        'day_master': {
          'stem': '丁',
          'stem_roman': 'ding',
          'element': 'fire',
          'polarity': 'yin',
          'pillar_label': '丁丑',
        },
        'year_animal': {'zh': '马', 'roman': 'horse', 'en': 'Horse'},
        'element_balance': {
          'wood': 0,
          'fire': 1,
          'earth': 0,
          'metal': 0,
          'water': 0,
          'total_slots': 8,
          'method': 'surface_stem_branch_v1',
        },
        'pillars': {
          'year': _pillar(),
          'month': _pillar(),
          'day': _pillar(),
          'hour': _pillar(),
        },
      });

      final profile = ZodiacInterpretationResolver.resolveFromChart(chart, 'en');
      expect(profile, isNotNull);
      expect(profile!.animalKey, 'horse');
    });

    test('displayAnimalName is localized', () {
      expect(
        ZodiacInterpretationResolver.displayAnimalName(_animal('Horse'), 'th'),
        'ม้า',
      );
      expect(
        ZodiacInterpretationResolver.displayAnimalName(_animal('Horse'), 'en'),
        'Horse',
      );
    });

    test('returns null for unknown animal', () {
      expect(
        ZodiacInterpretationResolver.resolve(_animal('Unicorn'), 'en'),
        isNull,
      );
    });
  });

  group('ZodiacThemeMapper', () {
    test('maps all supported animals to valid fusion theme ids', () {
      final validIds = FusionThemeRegistry.all.map((t) => t.id).toSet();

      for (final key in ZodiacPersonalityLibrary.supportedAnimals) {
        final bundle = ZodiacThemeMapper.themesForAnimal(key);
        expect(bundle, isNotNull, reason: 'missing theme bundle for $key');

        for (final id in ZodiacThemeMapper.allThemeIdsForAnimal(key)) {
          expect(validIds, contains(id), reason: '$key references unknown theme $id');
        }

        expect(bundle!.coreSelf, isNotEmpty);
        expect(bundle.relationships, isNotEmpty);
        expect(bundle.workAndAmbition, isNotEmpty);
        expect(bundle.strengths, isNotEmpty);
        expect(bundle.growthAreas, isNotEmpty);
      }
    });
  });
}

Map<String, dynamic> _pillar() => {
      'stem': '甲',
      'branch': '子',
      'stem_roman': 'jia',
      'branch_roman': 'zi',
      'stem_element': 'wood',
      'branch_element': 'water',
      'pillar_label': '甲子',
    };
