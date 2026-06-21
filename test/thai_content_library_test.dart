import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/thai/content/models/content_status.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_defaults.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_section.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_type.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_fusion_theme_category.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_theme_mapping.dart';
import 'package:knowme/features/astrology/thai/content/providers/thai_content_provider.dart';
import 'package:knowme/features/astrology/thai/content/registry/thai_content_registry.dart';
import 'package:knowme/features/astrology/thai/content/repository/thai_content_repository.dart';

void main() {
  group('ThaiContentRegistry', () {
    test('knows all scaffolded keys', () {
      for (final key in ThaiContentKeys.all) {
        expect(ThaiContentRegistry.isKnownKey(key), isTrue);
      }
    });

    test('resolves approved lagna_aries', () {
      final section = ThaiContentRegistry.resolve(ThaiContentKeys.lagnaAries);
      expect(section, isNotNull);
      expect(section!.contentType, ThaiContentType.lagna);
      expect(section.themeMappings, isNotEmpty);
      expect(section.contentStatus, ContentStatus.approved);
      expect(section.version, kDefaultThaiContentVersion);
      expect(section.themeMappings.first.weight, greaterThanOrEqualTo(0.5));
      expect(section.themeMappings.first.weight, lessThanOrEqualTo(1.0));
    });

    test('resolves all 12 lagna entries', () {
      final lagna = ThaiContentRegistry.allLagna();
      expect(lagna.length, 12);
      for (final section in lagna) {
        expect(section.contentStatus, ContentStatus.approved);
        expect(section.version, 'v1');
        expect(section.themeMappings, isNotEmpty);
      }
    });

    test('lagna theme mappings use canonical theme ids', () {
      final usedThemeIds = <String>{};

      for (final section in ThaiContentRegistry.allLagna()) {
        expect(
          section.themeMappings.length,
          greaterThanOrEqualTo(2),
          reason: section.key,
        );
        expect(
          section.themeMappings.length,
          lessThanOrEqualTo(5),
          reason: section.key,
        );

        for (final mapping in section.themeMappings) {
          expect(
            ThemeRegistry.contains(mapping.theme),
            isTrue,
            reason: '${section.key} → ${mapping.theme}',
          );
          usedThemeIds.add(mapping.theme);
          expect(mapping.theme, matches(RegExp(r'^[a-z0-9_]+$')));
        }
      }

      expect(usedThemeIds.length, greaterThanOrEqualTo(20));
    });

    test('resolves approved ramahabhuta_earth', () {
      final section =
          ThaiContentRegistry.resolve(ThaiContentKeys.ramahabhutaEarth);
      expect(section, isNotNull);
      expect(section!.contentType, ThaiContentType.ramahabhuta);
      expect(section.contentStatus, ContentStatus.approved);
      expect(section.version, 'v1');
    });

    test('resolves all 4 ramahabhuta entries', () {
      final sections = ThaiContentRegistry.allRamahabhuta();
      expect(sections.length, 4);
      for (final section in sections) {
        expect(section.contentType, ThaiContentType.ramahabhuta);
        expect(section.contentStatus, ContentStatus.approved);
        expect(section.version, 'v1');
        expect(section.themeMappings, isNotEmpty);
      }
    });

    test('ramahabhuta theme mappings use canonical theme ids', () {
      final usedThemeIds = <String>{};

      for (final section in ThaiContentRegistry.allRamahabhuta()) {
        expect(
          section.themeMappings.length,
          greaterThanOrEqualTo(3),
          reason: section.key,
        );
        expect(
          section.themeMappings.length,
          lessThanOrEqualTo(5),
          reason: section.key,
        );

        for (final mapping in section.themeMappings) {
          expect(
            ThemeRegistry.contains(mapping.theme),
            isTrue,
            reason: '${section.key} → ${mapping.theme}',
          );
          usedThemeIds.add(mapping.theme);
          expect(mapping.theme, matches(RegExp(r'^[a-z0-9_]+$')));
        }
      }

      expect(usedThemeIds.length, greaterThanOrEqualTo(12));
    });

    test('reports no missing ramahabhuta keys', () {
      final missing = ThaiContentRegistry.missingKeysForType(
        ThaiContentType.ramahabhuta,
      );
      expect(missing, isEmpty);
    });

    test('resolves approved myanmar_seven_1', () {
      final section =
          ThaiContentRegistry.resolve(ThaiContentKeys.myanmarSeven1);
      expect(section, isNotNull);
      expect(section!.contentType, ThaiContentType.myanmarSeven);
      expect(section.contentStatus, ContentStatus.approved);
      expect(section.version, 'v1');
      expect(section.themeMappings, isNotEmpty);
    });

    test('resolves all 7 myanmar seven entries', () {
      final sections = ThaiContentRegistry.allMyanmarSeven();
      expect(sections.length, 7);
      for (final section in sections) {
        expect(section.contentType, ThaiContentType.myanmarSeven);
        expect(section.contentStatus, ContentStatus.approved);
        expect(section.version, 'v1');
        expect(section.themeMappings, isNotEmpty);
      }
    });

    test('myanmar seven theme mappings use canonical theme ids', () {
      final usedThemeIds = <String>{};

      for (final section in ThaiContentRegistry.allMyanmarSeven()) {
        expect(
          section.themeMappings.length,
          greaterThanOrEqualTo(3),
          reason: section.key,
        );
        expect(
          section.themeMappings.length,
          lessThanOrEqualTo(4),
          reason: section.key,
        );

        for (final mapping in section.themeMappings) {
          expect(
            ThemeRegistry.contains(mapping.theme),
            isTrue,
            reason: '${section.key} → ${mapping.theme}',
          );
          usedThemeIds.add(mapping.theme);
          expect(mapping.theme, matches(RegExp(r'^[a-z0-9_]+$')));
        }
      }

      expect(usedThemeIds.length, greaterThanOrEqualTo(20));
    });

    test('reports no missing myanmar seven keys', () {
      final missing = ThaiContentRegistry.missingKeysForType(
        ThaiContentType.myanmarSeven,
      );
      expect(missing, isEmpty);
    });

    test('resolves approved mahabhuta_pyadhi', () {
      final section =
          ThaiContentRegistry.resolve(ThaiContentKeys.mahabhutaPyadhi);
      expect(section, isNotNull);
      expect(section!.contentType, ThaiContentType.mahabhutaPosition);
      expect(section.contentStatus, ContentStatus.approved);
      expect(section.version, 'v1');
      expect(section.themeMappings, isNotEmpty);
    });

    test('resolves all 7 mahabhuta position entries', () {
      final sections = ThaiContentRegistry.allMahabhutaPosition();
      expect(sections.length, 7);
      for (final section in sections) {
        expect(section.contentType, ThaiContentType.mahabhutaPosition);
        expect(section.contentStatus, ContentStatus.approved);
        expect(section.version, 'v1');
        expect(section.themeMappings, isNotEmpty);
      }
    });

    test('mahabhuta position theme mappings use canonical theme ids', () {
      final usedThemeIds = <String>{};

      for (final section in ThaiContentRegistry.allMahabhutaPosition()) {
        expect(
          section.themeMappings.length,
          greaterThanOrEqualTo(3),
          reason: section.key,
        );
        expect(
          section.themeMappings.length,
          lessThanOrEqualTo(4),
          reason: section.key,
        );

        for (final mapping in section.themeMappings) {
          expect(
            ThemeRegistry.contains(mapping.theme),
            isTrue,
            reason: '${section.key} → ${mapping.theme}',
          );
          usedThemeIds.add(mapping.theme);
          expect(mapping.theme, matches(RegExp(r'^[a-z0-9_]+$')));
        }
      }

      expect(usedThemeIds.length, greaterThanOrEqualTo(20));
    });

    test('reports no missing mahabhuta position keys', () {
      final missing = ThaiContentRegistry.missingKeysForType(
        ThaiContentType.mahabhutaPosition,
      );
      expect(missing, isEmpty);
    });

    test('resolves all 7 lagna lord entries', () {
      final lords = ThaiContentRegistry.allLagnaLord();
      expect(lords.length, 7);
      for (final section in lords) {
        expect(section.contentType, ThaiContentType.lagnaLord);
        expect(section.contentStatus, ContentStatus.approved);
        expect(section.version, 'v1');
        expect(section.themeMappings, isNotEmpty);
      }
    });

    test('lagna lord theme mappings use canonical theme ids', () {
      final usedThemeIds = <String>{};

      for (final section in ThaiContentRegistry.allLagnaLord()) {
        expect(
          section.themeMappings.length,
          greaterThanOrEqualTo(2),
          reason: section.key,
        );
        expect(
          section.themeMappings.length,
          lessThanOrEqualTo(5),
          reason: section.key,
        );

        for (final mapping in section.themeMappings) {
          expect(
            ThemeRegistry.contains(mapping.theme),
            isTrue,
            reason: '${section.key} → ${mapping.theme}',
          );
          usedThemeIds.add(mapping.theme);
          expect(mapping.theme, matches(RegExp(r'^[a-z0-9_]+$')));
        }
      }

      expect(usedThemeIds.length, greaterThanOrEqualTo(15));
    });

    test('reports no missing lagna lord keys', () {
      final missing = ThaiContentRegistry.missingKeysForType(
        ThaiContentType.lagnaLord,
      );
      expect(missing, isEmpty);
    });

    test('reports no missing lagna keys', () {
      final missingLagna = ThaiContentRegistry.missingKeysForType(
        ThaiContentType.lagna,
      );
      expect(missingLagna, isEmpty);
    });
  });

  group('ThaiContentRepository', () {
    const repository = ThaiContentRepositoryImpl();

    test('getByKeys returns all 12 lagna sections', () {
      final lagna = repository.getByKeys(ThaiContentKeys.allLagna);
      expect(lagna.length, 12);
      expect(
        lagna.map((s) => s.key).toSet(),
        equals(ThaiContentKeys.allLagna.toSet()),
      );
    });

    test('getByType returns all 7 lagna lord sections', () {
      final lords = repository.getByType(ThaiContentType.lagnaLord);
      expect(lords.length, 7);
      expect(
        lords.every((s) => s.contentType == ThaiContentType.lagnaLord),
        isTrue,
      );
    });

    test('getByType lagna excludes lagna lord sections', () {
      final lagna = repository.getByType(ThaiContentType.lagna);
      expect(lagna.length, 12);
      expect(
        lagna.every((s) => s.contentType == ThaiContentType.lagna),
        isTrue,
      );
      expect(
        lagna.map((s) => s.key).toSet(),
        equals(ThaiContentKeys.allLagna.toSet()),
      );
    });

    test('getByType ramahabhuta returns all 4 sections', () {
      final sections = repository.getByType(ThaiContentType.ramahabhuta);
      expect(sections.length, 4);
      expect(
        sections.every((s) => s.contentType == ThaiContentType.ramahabhuta),
        isTrue,
      );
      expect(
        sections.map((s) => s.key).toSet(),
        equals(ThaiContentKeys.allRamahabhuta.toSet()),
      );
    });

    test('getByType mahabhutaPosition returns all 7 sections', () {
      final sections = repository.getByType(ThaiContentType.mahabhutaPosition);
      expect(sections.length, 7);
      expect(
        sections.every(
          (s) => s.contentType == ThaiContentType.mahabhutaPosition,
        ),
        isTrue,
      );
      expect(
        sections.map((s) => s.key).toSet(),
        equals(ThaiContentKeys.allMahabhutaPosition.toSet()),
      );
    });

    test('getByType myanmarSeven returns all 7 sections', () {
      final sections = repository.getByType(ThaiContentType.myanmarSeven);
      expect(sections.length, 7);
      expect(
        sections.every((s) => s.contentType == ThaiContentType.myanmarSeven),
        isTrue,
      );
      expect(
        sections.map((s) => s.key).toSet(),
        equals(ThaiContentKeys.allMyanmarSeven.toSet()),
      );
    });
  });

  group('ThaiContentSection hardening', () {
    test('fromMap applies migration-safe defaults', () {
      final section = ThaiContentSection.fromMap({
        'key': 'lagna_test',
        'content_type': 'lagna',
        'title': 'ทดสอบ',
        'summary': 'สรุป',
        'core_nature': 'แก่น',
        'growth_path': 'เติบโต',
        'theme_mappings': [
          {
            'category': 'core_self',
            'theme': 'อาจมีวินัย',
          },
        ],
      });

      expect(section.contentStatus, ContentStatus.placeholder);
      expect(section.version, kDefaultThaiContentVersion);
      expect(section.themeMappings.single.weight, kDefaultThaiThemeMappingWeight);
    });

    test('fromMap parses explicit weight, status, and version', () {
      final section = ThaiContentSection.fromMap({
        'key': 'lagna_lord_saturn',
        'content_type': 'lagna_lord',
        'title': 'เจ้าเรือนเสาร์',
        'summary': 'สรุป',
        'core_nature': 'แก่น',
        'growth_path': 'เติบโต',
        'content_status': 'approved',
        'version': 'v1.1',
        'theme_mappings': [
          {
            'category': 'core_self',
            'theme': 'มีวินัย',
            'weight': 0.9,
          },
          {
            'category': 'strengths',
            'theme': 'ความอดทน',
            'weight': 0.7,
          },
        ],
      });

      expect(section.contentStatus, ContentStatus.approved);
      expect(section.version, 'v1.1');
      expect(section.themeMappings[0].weight, 0.9);
      expect(section.themeMappings[1].weight, 0.7);
    });

    test('toMap round-trips hardened fields', () {
      const mapping = ThaiThemeMapping(
        category: ThaiFusionThemeCategory.coreSelf,
        theme: 'มีวินัย',
        weight: 0.9,
      );
      const section = ThaiContentSection(
        key: 'lagna_lord_saturn',
        contentType: ThaiContentType.lagnaLord,
        title: 'เจ้าเรือนเสาร์',
        summary: 'สรุป',
        coreNature: 'แก่น',
        strengths: [],
        challenges: [],
        growthPath: 'เติบโต',
        themeMappings: [mapping],
        contentStatus: ContentStatus.reviewed,
        version: 'v1.1',
      );

      final restored = ThaiContentSection.fromMap(section.toMap());
      expect(restored.key, section.key);
      expect(restored.contentStatus, section.contentStatus);
      expect(restored.version, section.version);
      expect(restored.themeMappings, section.themeMappings);
    });
  });

  group('ThaiContentProvider', () {
    test('loads and caches ramahabhuta content', () {
      final provider = ThaiContentProvider();

      final first = provider.loadByKey(ThaiContentKeys.ramahabhutaFire);
      final second = provider.loadByKey(ThaiContentKeys.ramahabhutaFire);

      expect(first, isNotNull);
      expect(second, same(first));
      expect(first!.contentStatus, ContentStatus.approved);
      expect(provider.error, isNull);
    });

    test('sets error for unknown key', () {
      final provider = ThaiContentProvider();
      final section = provider.loadByKey('lagna_unknown');

      expect(section, isNull);
      expect(provider.error, contains('Unknown'));
    });

    test('loads and caches myanmar seven content', () {
      final provider = ThaiContentProvider();

      final first = provider.loadByKey(ThaiContentKeys.myanmarSeven1);
      final second = provider.loadByKey(ThaiContentKeys.myanmarSeven1);

      expect(first, isNotNull);
      expect(second, same(first));
      expect(first!.contentType, ThaiContentType.myanmarSeven);
      expect(first.contentStatus, ContentStatus.approved);
      expect(provider.error, isNull);
    });
  });
}
