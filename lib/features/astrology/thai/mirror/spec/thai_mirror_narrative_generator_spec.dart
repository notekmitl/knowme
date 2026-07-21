import '../models/thai_mirror_result.dart';
import '../models/thai_mirror_section_id.dart';

/// Specification for future narrative generation — **not implemented in V1**.
///
/// See `docs/THAI_MIRROR_SPECIFICATION_V1.md` § Narrative Rules.
abstract final class ThaiMirrorNarrativeGeneratorSpec {
  /// Input: structural [ThaiMirrorResult] with evidence populated, summaries null.
  /// Output: copy of result with section summaries filled.
  static const inputType = ThaiMirrorResult;

  /// Output contract version must remain [ThaiMirrorContract.version].
  static const outputType = ThaiMirrorResult;

  /// Required hedging phrases (at least one per summary paragraph).
  static const requiredHedgingTh = <String>[
    'อาจ',
    'หลายครั้ง',
    'มีแนวโน้ม',
    'มักจะ',
    'บางครั้ง',
    'คุณอาจรู้สึกว่า',
  ];

  static const requiredHedgingEn = <String>[
    'may',
    'often',
    'tends to',
    'might',
    'sometimes',
    'you may notice',
  ];

  /// Banned predictive / fortune-telling vocabulary.
  static const bannedTermsTh = <String>[
    'จะรวย',
    'จะจน',
    'จะแต่งงาน',
    'จะหย่า',
    'จะเจอเนื้อคู่',
    'โชคลาภ',
    'ชะตา',
    'กำหนดแล้ว',
    'แน่นอน',
    'ต้องเป็น',
    'จะประสบความสำเร็จ',
    'จะล้มเหลว',
  ];

  static const bannedTermsEn = <String>[
    'will be rich',
    'will marry',
    'soulmate',
    'destiny',
    'fate',
    'guaranteed',
    'certain to',
    'will succeed',
    'will fail',
    'fortune',
    'lottery',
  ];

  /// Sections that receive narrative summaries in V1.1+.
  static const narrativeSectionIds = <ThaiMirrorSectionId>[
    ThaiMirrorSectionId.coreSelf,
    ThaiMirrorSectionId.thinkingStyle,
    ThaiMirrorSectionId.emotionalWorld,
    ThaiMirrorSectionId.relationships,
    ThaiMirrorSectionId.workAndAmbition,
    ThaiMirrorSectionId.strengths,
    ThaiMirrorSectionId.growthAreas,
    ThaiMirrorSectionId.growthPath,
  ];

  /// Content sources allowed for narrative assembly (no AI invention).
  static const allowedContentSources = <String>[
    'thai_content_library.section.summary',
    'thai_content_library.section.coreNature',
    'thai_content_library.section.strengths',
    'thai_content_library.section.challenges',
    'thai_content_library.section.growthPath',
    'theme_registry.definition.description',
  ];

  /// Constraints enforced at generation time.
  static const constraints = <String>[
    'Every summary must cite at least one evidence contentKey in metadata.',
    'No theme may appear without traceable lens evidence.',
    'No new theme ids may be invented at narrative time.',
    'Summaries must be reflective (self-understanding), not prescriptive.',
    'Top Themes section uses theme names only — no long narrative.',
    'When birth time is missing, lagna-related copy must acknowledge limitation.',
  ];
}

/// Future interface for narrative generation implementations.
abstract class ThaiMirrorNarrativeGenerator {
  /// Fills [ThaiMirrorSection.summary] for narrative sections.
  ///
  /// Must not modify theme scores, evidence, or theme ids.
  ThaiMirrorResult generate(ThaiMirrorResult structural);
}
