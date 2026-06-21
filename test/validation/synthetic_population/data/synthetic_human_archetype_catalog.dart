import 'package:knowme/features/tests/eq/domain/eq_models.dart';

import '../models/synthetic_human_archetype_spec.dart';
import '../models/synthetic_human_attachment_style.dart';

/// 50 internally coherent human archetypes for population validation.
abstract final class SyntheticHumanArchetypeCatalog {
  static const _emerging = EqLevelIds.emerging;
  static const _moderate = EqLevelIds.moderate;
  static const _strong = EqLevelIds.strong;

  static const _secure = SyntheticHumanAttachmentStyle.secure;
  static const _anxious = SyntheticHumanAttachmentStyle.anxious;
  static const _avoidant = SyntheticHumanAttachmentStyle.avoidant;
  static const _fearful = SyntheticHumanAttachmentStyle.fearful;

  static List<SyntheticHumanArchetypeSpec> all() => List.unmodifiable(_entries);

  static final _entries = <SyntheticHumanArchetypeSpec>[
    _s('architect', 'Architect', 'INTJ', 78, 86, 32, 48, 38, _strong, _moderate, _secure, 0, 0, 0),
    _s('builder', 'Builder', 'ISTJ', 52, 88, 40, 58, 35, _moderate, _strong, _secure, 1, 1, 1),
    _s('teacher', 'Teacher', 'ENFJ', 68, 72, 74, 82, 42, _strong, _moderate, _secure, 2, 0, 2),
    _s('caregiver', 'Caregiver', 'ISFJ', 55, 76, 48, 86, 48, _moderate, _moderate, _anxious, 3, 1, 3),
    _s('explorer', 'Explorer', 'ENFP', 82, 48, 78, 72, 44, _strong, _moderate, _secure, 4, 0, 4),
    _s('analyst', 'Analyst', 'INTP', 84, 68, 36, 46, 40, _moderate, _moderate, _avoidant, 5, 1, 5),
    _s('leader', 'Leader', 'ENTJ', 72, 82, 76, 52, 36, _strong, _strong, _secure, 6, 0, 6),
    _s('creator', 'Creator', 'INFP', 86, 54, 42, 68, 52, _moderate, _emerging, _fearful, 7, 1, 7),
    _s('mediator', 'Mediator', 'INFJ', 80, 70, 44, 74, 46, _strong, _moderate, _secure, 8, 0, 8),
    _s('entrepreneur', 'Entrepreneur', 'ESTP', 62, 58, 82, 54, 38, _moderate, _moderate, _avoidant, 9, 1, 9),
    _s('strategist', 'Strategist', 'INTJ', 76, 84, 38, 50, 34, _strong, _strong, _secure, 10, 0, 10),
    _s('investigator', 'Investigator', 'ISTP', 70, 62, 46, 44, 36, _moderate, _strong, _avoidant, 11, 1, 11),
    _s('protector', 'Protector', 'ISFJ', 50, 80, 42, 84, 46, _moderate, _moderate, _anxious, 0, 0, 12),
    _s('advisor', 'Advisor', 'INFJ', 78, 74, 46, 76, 42, _strong, _moderate, _secure, 1, 1, 13),
    _s('innovator', 'Innovator', 'ENTP', 88, 52, 72, 58, 40, _strong, _moderate, _secure, 2, 0, 14),
    _s('healer', 'Healer', 'INFP', 82, 56, 44, 80, 54, _strong, _emerging, _fearful, 3, 1, 15),
    _s('mentor', 'Mentor', 'ENFJ', 70, 76, 70, 84, 40, _strong, _moderate, _secure, 4, 0, 16),
    _s('visionary', 'Visionary', 'ENFP', 90, 46, 76, 70, 46, _strong, _moderate, _secure, 5, 1, 17),
    _s('harmonizer', 'Harmonizer', 'ESFJ', 58, 72, 68, 88, 44, _moderate, _moderate, _anxious, 6, 0, 18),
    _s('rebel', 'Rebel', 'ESTP', 64, 46, 84, 48, 42, _emerging, _moderate, _avoidant, 7, 1, 19),
    _s('scholar', 'Scholar', 'INTJ', 86, 80, 30, 44, 36, _strong, _moderate, _avoidant, 8, 0, 20),
    _s('diplomat', 'Diplomat', 'ENFJ', 66, 70, 72, 86, 38, _strong, _moderate, _secure, 9, 1, 21),
    _s('craftsman', 'Craftsman', 'ISTP', 58, 78, 44, 52, 34, _moderate, _strong, _secure, 10, 0, 22),
    _s('pioneer', 'Pioneer', 'ENTP', 84, 50, 74, 56, 38, _moderate, _moderate, _secure, 11, 1, 23),
    _s('guardian', 'Guardian', 'ESTJ', 54, 86, 68, 62, 36, _moderate, _strong, _secure, 0, 0, 24),
    _s('catalyst', 'Catalyst', 'ENFP', 86, 48, 80, 66, 42, _strong, _moderate, _secure, 1, 1, 25),
    _s('peacemaker', 'Peacemaker', 'ISFP', 72, 58, 52, 82, 48, _moderate, _moderate, _fearful, 2, 0, 26),
    _s('realist', 'Realist', 'ISTJ', 48, 84, 44, 56, 38, _moderate, _strong, _secure, 3, 1, 27),
    _s('idealist', 'Idealist', 'INFJ', 84, 64, 40, 72, 50, _strong, _emerging, _fearful, 4, 0, 28),
    _s('commander', 'Commander', 'ENTJ', 70, 88, 78, 48, 32, _strong, _strong, _secure, 5, 1, 29),
    _s('nurturer', 'Nurturer', 'ESFJ', 56, 74, 66, 90, 46, _moderate, _moderate, _anxious, 6, 0, 30),
    _s('observer', 'Observer', 'ISTJ', 62, 76, 34, 50, 40, _moderate, _strong, _avoidant, 7, 1, 31),
    _s('performer', 'Performer', 'ESFP', 68, 48, 88, 74, 44, _moderate, _moderate, _secure, 8, 0, 32),
    _s('optimizer', 'Optimizer', 'ESTJ', 52, 90, 64, 54, 34, _moderate, _strong, _secure, 9, 1, 33),
    _s('pathfinder', 'Pathfinder', 'ENTP', 82, 54, 70, 60, 40, _strong, _moderate, _secure, 10, 0, 34),
    _s('stabilizer', 'Stabilizer', 'ISFJ', 50, 82, 38, 80, 42, _moderate, _strong, _secure, 11, 1, 35),
    _s('maverick', 'Maverick', 'ESTP', 66, 44, 86, 46, 44, _emerging, _moderate, _avoidant, 0, 0, 36),
    _s('curator', 'Curator', 'ISTJ', 64, 84, 36, 54, 36, _moderate, _strong, _avoidant, 1, 1, 37),
    _s('advocate', 'Advocate', 'ENFJ', 74, 68, 68, 86, 44, _strong, _moderate, _secure, 2, 0, 38),
    _s('sentinel', 'Sentinel', 'ISTJ', 54, 88, 40, 58, 38, _moderate, _strong, _secure, 3, 1, 39),
    _s('dreamer', 'Dreamer', 'INFP', 88, 50, 40, 70, 56, _moderate, _emerging, _fearful, 4, 0, 40),
    _s('pragmatist', 'Pragmatist', 'ESTJ', 50, 86, 62, 52, 36, _moderate, _strong, _secure, 5, 1, 41),
    _s('connector', 'Connector', 'ESFP', 70, 52, 84, 78, 42, _strong, _moderate, _secure, 6, 0, 42),
    _s('specialist', 'Specialist', 'INTJ', 80, 82, 34, 46, 38, _strong, _moderate, _avoidant, 7, 1, 43),
    _s('generalist', 'Generalist', 'ENFP', 78, 56, 72, 68, 44, _strong, _moderate, _secure, 8, 0, 44),
    _s('steward', 'Steward', 'ISFJ', 52, 84, 44, 82, 40, _moderate, _strong, _secure, 9, 1, 45),
    _s('challenger', 'Challenger', 'ESTP', 60, 50, 82, 50, 46, _moderate, _moderate, _avoidant, 10, 0, 46),
    _s('sage', 'Sage', 'INFJ', 82, 72, 38, 68, 42, _strong, _moderate, _secure, 11, 1, 47),
    _s('empath', 'Empath', 'INFP', 84, 54, 46, 84, 58, _strong, _emerging, _fearful, 0, 0, 48),
    _s('executor', 'Executor', 'ESTJ', 48, 92, 66, 50, 32, _moderate, _strong, _secure, 1, 1, 49),
  ];

  static SyntheticHumanArchetypeSpec _s(
    String id,
    String name,
    String mbti,
    int o,
    int c,
    int e,
    int a,
    int n,
    String eqAwareness,
    String eqRegulation,
    SyntheticHumanAttachmentStyle attachment,
    int animalIndex,
    int dayMasterIndex,
    int birthYearOffset,
  ) {
    return SyntheticHumanArchetypeSpec(
      id: id,
      name: name,
      mbtiType: mbti,
      openness: o,
      conscientiousness: c,
      extraversion: e,
      agreeableness: a,
      neuroticism: n,
      eqAwarenessLevel: eqAwareness,
      eqRegulationLevel: eqRegulation,
      attachmentStyle: attachment,
      yearAnimalIndex: animalIndex,
      dayMasterSpecIndex: dayMasterIndex,
      birthYearOffset: birthYearOffset,
    );
  }
}
