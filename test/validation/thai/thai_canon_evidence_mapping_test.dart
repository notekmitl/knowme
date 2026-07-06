import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Evidence Mapping Layer — frozen Canon loader, index, mapper, runtime key map.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  group('ThaiCanonProductionLoader', () {
    test('loads frozen Canon successfully', () {
      expect(repository.loadResult.isValid, isTrue, reason: repository.loadResult.issues.join('; '));
      expect(repository.loadResult.sourceBookId, 'mahabhut');
    });

    test('atomic unit count is 826', () {
      expect(repository.atomicCount, 826);
    });

    test('reference-table cell count is 28', () {
      expect(repository.referenceCellCount, 28);
    });

    test('all loaded units preserve provenance', () {
      for (final unit in repository.index.units) {
        expect(unit.evidence.hasReference, isTrue, reason: unit.id);
        expect(unit.evidence.page, isNotNull);
        expect(unit.evidence.page, isNotEmpty);
      }
      for (final cell in repository.index.referenceCells) {
        expect(cell.evidence.hasReference, isTrue, reason: cell.id);
        expect(cell.evidence.page, isNotNull);
      }
    });
  });

  group('ThaiCanonEvidenceIndex queries', () {
    test('query by subject works', () {
      final jupiter = repository.index.bySubject('planet.jupiter');
      expect(jupiter, isNotEmpty);
      expect(jupiter.every((u) => u.subject == 'planet.jupiter'), isTrue);
    });

    test('query by object works', () {
      final learning = repository.index.byObject('domain.learning');
      expect(learning, isNotEmpty);
      expect(learning.every((u) => u.object == 'domain.learning'), isTrue);
    });

    test('query by relation works', () {
      final located = repository.index.byRelation(AtomicRelation.locatedIn);
      expect(located.length, greaterThan(100));
    });

    test('query by context type works', () {
      final archetype = repository.index.byContextType(
        AtomicContextType.archetypeChart,
      );
      expect(archetype, isNotEmpty);
    });

    test('query by source page works', () {
      final p220 = repository.index.bySourcePage('220');
      expect(p220, isNotEmpty);
      expect(p220.every((u) => u.evidence.page == '220'), isTrue);
    });

    test('query by domain works', () {
      final remedies = repository.index.byDomain(KnowledgeDomain.remedies);
      expect(remedies.length, 87);
    });
  });

  group('ThaiCanonEvidenceMapper', () {
    test('planet.jupiter and domain.learning returns Canon units', () {
      final refs = repository.mapper.evidenceForSubjectAndObject(
        subject: 'planet.jupiter',
        object: 'domain.learning',
      );
      expect(refs, isNotEmpty);
      expect(refs.first.subject, 'planet.jupiter');
      expect(refs.first.object, 'domain.learning');
      expect(refs.first.sourcePage, isNotNull);
    });

    test('mahabhutPosition.thongchai returns related units', () {
      final refs = repository.mapper.evidenceForMahabhutPosition(
        'mahabhutPosition.thongchai',
      );
      expect(refs, isNotEmpty);
      expect(
        refs.any((r) => r.object == 'mahabhutPosition.thongchai'),
        isTrue,
      );
    });

    test('taksaRole.kalakini returns Taksa-related units', () {
      final refs = repository.mapper.evidenceForTaksaRole('taksaRole.kalakini');
      expect(refs, isNotEmpty);
      expect(refs.every((r) => r.object == 'taksaRole.kalakini'), isTrue);
    });

    test('remedy evidence is internal-only and not safe for user output', () {
      final refs = repository.mapper.evidenceForRemedyDomain();
      expect(refs.length, 87);
      for (final ref in refs) {
        expect(ref.safety, ThaiCanonEvidenceSafety.remedyInternalOnly);
        expect(ref.safety.isNotSafeForUserOutput, isTrue);
        expect(ref.safety.isInternalOnly, isTrue);
      }

      final sadoe = repository.mapper.evidenceForRemedyId('remedy.sadoeKhroh');
      expect(sadoe, isNotEmpty);
      expect(sadoe.first.safety.isNotSafeForUserOutput, isTrue);
    });
  });

  group('ThaiCanonOntologyRuntimeMapping', () {
    test('planet ontology maps to LifePlanet runtime keys', () {
      expect(
        ThaiCanonOntologyRuntimeMapping.runtimePlanetKey('planet.sun'),
        'sun',
      );
      expect(
        ThaiCanonOntologyRuntimeMapping.runtimePlanetKey('planet.jupiter'),
        'jupiter',
      );
      expect(
        ThaiCanonOntologyRuntimeMapping.runtimePlanetKey('planet.ketu'),
        isNull,
      );
    });

    test('mahabhut positions map to ThaiContentKeys where present', () {
      expect(
        ThaiCanonOntologyRuntimeMapping.contentKeyForMahabhutPosition(
          'mahabhutPosition.thongchai',
        ),
        ThaiContentKeys.mahabhutaThongchai,
      );
      expect(
        ThaiCanonOntologyRuntimeMapping.contentKeyForMahabhutPosition(
          'mahabhutPosition.khumsap',
        ),
        isNull,
      );
    });

    test('runtime content key reverse-maps to Canon position', () {
      final refs = repository.mapper.evidenceForRuntimeContentKey(
        ThaiContentKeys.mahabhutaThongchai,
      );
      expect(refs, isNotEmpty);
    });

    test('unmapped Canon entities are reported, not ignored', () {
      final unmapped = repository.unmappedCanonEntityIds;
      expect(unmapped, isNot(contains('taksaRole.sri')));
      expect(unmapped, isNot(contains('periodStatus.duengKhuen')));
      expect(unmapped, isNot(contains('periodStatus.duengTok')));

      final periodStatusMaps =
          ThaiCanonOntologyRuntimeMapping.periodStatusMappings();
      expect(periodStatusMaps.every((m) => m.isMapped), isTrue);
      expect(
        ThaiCanonPeriodStatusRuntimeMapping.canonIdForRuntimeLabel('ดวงขึ้น'),
        'periodStatus.duengKhuen',
      );
      expect(
        ThaiCanonPeriodStatusRuntimeMapping.canonIdForRuntimeLabel('ดวงตก'),
        'periodStatus.duengTok',
      );

      final ketu = repository.planetMappings
          .where((m) => m.canonEntityId == 'planet.ketu')
          .single;
      expect(ketu.isMapped, isFalse);

      final khumsap = repository.mahabhutPositionMappings
          .where((m) => m.canonEntityId == 'mahabhutPosition.khumsap')
          .single;
      expect(khumsap.isMapped, isFalse);

      final taksaMaps = ThaiCanonOntologyRuntimeMapping.taksaRoleMappings();
      expect(taksaMaps.every((m) => m.isMapped), isTrue);
    });
  });

  group('Thai runtime output unchanged', () {
    String pipelineFingerprint() {
      final birth = ThaiMirrorPipeline.sampleQaBirthData();
      final result = ThaiMirrorPipeline.generate(birth);
      expect(result.isSuccess, isTrue);

      final mirror = result.mirrorResult!;
      final view = result.viewState!;
      return [
        mirror.contractVersion,
        mirror.topThemes.map((t) => t.themeId).join(','),
        mirror.sections.map((s) => '${s.id.name}:${s.evidence.length}').join('|'),
        view.topThemes.map((t) => t.themeId).join(','),
        view.hero.reflectionSummary,
        result.profile!.mahabhutaPositionKeys.join(','),
      ].join('::');
    }

    test('ThaiMirrorPipeline output unchanged after evidence layer load', () {
      final before = pipelineFingerprint();
      // Touch the repository to prove loading does not mutate runtime state.
      expect(repository.atomicCount, 826);
      final after = pipelineFingerprint();
      expect(after, before);
    });

    test('deterministic pipeline output across repeated runs', () {
      final birth = ThaiBirthData(
        localDateTime: DateTime(1985, 6, 15, 8, 30),
        timeZoneOffset: const Duration(hours: 7),
        latitude: 13.75,
        longitude: 100.50,
        hasBirthTime: true,
      );
      final first = ThaiMirrorPipeline.generate(birth);
      final second = ThaiMirrorPipeline.generate(birth);
      expect(first.mirrorResult!.topThemes.map((t) => t.themeId).toList(),
          second.mirrorResult!.topThemes.map((t) => t.themeId).toList());
    });
  });
}
