import '../domain/narrative_mode.dart';
import '../domain/narrative_result.dart';

/// Profile narrative view model — identity + growth focus.
class ProfileNarrativeData {
  const ProfileNarrativeData({
    required this.isAvailable,
    required this.identityParagraphs,
    required this.relationshipParagraphs,
    required this.decisionParagraphs,
    required this.growthParagraphs,
    required this.confidenceBand,
    required this.sourceSnapshotId,
  });

  final bool isAvailable;
  final List<ProfileNarrativeParagraph> identityParagraphs;
  final List<ProfileNarrativeParagraph> relationshipParagraphs;
  final List<ProfileNarrativeParagraph> decisionParagraphs;
  final List<ProfileNarrativeParagraph> growthParagraphs;
  final String confidenceBand;
  final String sourceSnapshotId;
}

class ProfileNarrativeParagraph {
  const ProfileNarrativeParagraph({
    required this.text,
    required this.patternLabel,
    required this.confidenceBand,
    required this.paragraphId,
  });

  final String text;
  final String patternLabel;
  final String confidenceBand;
  final String paragraphId;
}

abstract final class ProfileNarrativeMapper {
  static ProfileNarrativeData fromResult(NarrativeResult? narrative) {
    if (narrative == null || narrative.paragraphCount == 0) {
      return const ProfileNarrativeData(
        isAvailable: false,
        identityParagraphs: [],
        relationshipParagraphs: [],
        decisionParagraphs: [],
        growthParagraphs: [],
        confidenceBand: 'low',
        sourceSnapshotId: '',
      );
    }

    return ProfileNarrativeData(
      isAvailable: true,
      identityParagraphs: _mapSection(narrative, NarrativeMode.identity),
      relationshipParagraphs: _mapSection(narrative, NarrativeMode.relationship),
      decisionParagraphs: _mapSection(narrative, NarrativeMode.decision),
      growthParagraphs: _mapSection(narrative, NarrativeMode.growth),
      confidenceBand: narrative.confidence.band,
      sourceSnapshotId: narrative.sourceSnapshotId,
    );
  }

  static List<ProfileNarrativeParagraph> _mapSection(
    NarrativeResult narrative,
    NarrativeMode mode,
  ) {
    final section = narrative.sectionFor(mode);
    if (section == null) return const [];

    return section.paragraphs
        .map(
          (paragraph) => ProfileNarrativeParagraph(
            text: paragraph.text,
            patternLabel: paragraph.patternLabel,
            confidenceBand: paragraph.confidence.band,
            paragraphId: paragraph.paragraphId,
          ),
        )
        .toList(growable: false);
  }
}
