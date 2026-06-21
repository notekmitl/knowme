import 'synthetic_human_attachment_style.dart';

/// Coherent trait template for one of 50 population archetypes.
class SyntheticHumanArchetypeSpec {
  const SyntheticHumanArchetypeSpec({
    required this.id,
    required this.name,
    required this.mbtiType,
    required this.openness,
    required this.conscientiousness,
    required this.extraversion,
    required this.agreeableness,
    required this.neuroticism,
    required this.eqAwarenessLevel,
    required this.eqRegulationLevel,
    required this.attachmentStyle,
    required this.yearAnimalIndex,
    required this.dayMasterSpecIndex,
    required this.birthYearOffset,
  });

  final String id;
  final String name;
  final String mbtiType;
  final int openness;
  final int conscientiousness;
  final int extraversion;
  final int agreeableness;
  final int neuroticism;
  final String eqAwarenessLevel;
  final String eqRegulationLevel;
  final SyntheticHumanAttachmentStyle attachmentStyle;
  final int yearAnimalIndex;
  final int dayMasterSpecIndex;
  final int birthYearOffset;
}
