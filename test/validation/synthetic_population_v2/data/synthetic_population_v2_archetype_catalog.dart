import '../../synthetic_population/models/synthetic_human_archetype_spec.dart';
import '../../synthetic_population/models/synthetic_human_attachment_style.dart';

/// Generates 250 deterministic archetypes for Synthetic Population V2.
abstract final class SyntheticPopulationV2ArchetypeCatalog {
  static const populationArchetypeCount = 250;
  static const variantsPerArchetype = 4;
  static const targetPopulationSize = 1000;

  static const _mbtiTypes = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP',
  ];

  static const _eqLevels = ['emerging', 'moderate', 'strong'];
  static const _attachments = SyntheticHumanAttachmentStyle.values;

  static List<SyntheticHumanArchetypeSpec> generate() {
    final specs = <SyntheticHumanArchetypeSpec>[];
    var index = 0;

    for (var mbtiIndex = 0;
        mbtiIndex < _mbtiTypes.length && specs.length < populationArchetypeCount;
        mbtiIndex++) {
      for (var seed = 0;
          seed < 16 && specs.length < populationArchetypeCount;
          seed++) {
        final id = 'pop2_${(index + 1).toString().padLeft(3, '0')}';
        final name = 'Archetype ${index + 1}';
        final mbti = _mbtiTypes[mbtiIndex];
        final traitBase = (mbtiIndex * 17 + seed * 13 + index * 7) % 100;

        specs.add(
          SyntheticHumanArchetypeSpec(
            id: id,
            name: name,
            mbtiType: mbti,
            openness: _trait(traitBase, 0),
            conscientiousness: _trait(traitBase, 1),
            extraversion: _trait(traitBase, 2),
            agreeableness: _trait(traitBase, 3),
            neuroticism: _trait(traitBase, 4),
            eqAwarenessLevel: _eqLevels[(traitBase + seed) % _eqLevels.length],
            eqRegulationLevel:
                _eqLevels[(traitBase + seed + 1) % _eqLevels.length],
            attachmentStyle: _attachments[(mbtiIndex + seed) % _attachments.length],
            yearAnimalIndex: (index + seed) % 12,
            dayMasterSpecIndex: (index + mbtiIndex) % 4,
            birthYearOffset: index % 35,
          ),
        );
        index++;
      }
    }

    assert(specs.length == populationArchetypeCount);
    return List.unmodifiable(specs);
  }

  static int _trait(int base, int offset) {
    return (28 + ((base + offset * 19) % 67)).clamp(20, 95);
  }
}
