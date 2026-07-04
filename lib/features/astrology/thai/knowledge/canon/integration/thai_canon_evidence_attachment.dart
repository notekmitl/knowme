import 'thai_canon_evidence_ref.dart';
import 'thai_canon_evidence_type.dart';

/// Internal Canon evidence metadata for one report signal or structural anchor.
///
/// Not for direct user display in this phase — [userFacingAllowed] is always
/// false for report attachments produced by [ThaiReportCanonEvidenceEnricher].
class ThaiCanonEvidenceAttachment {
  const ThaiCanonEvidenceAttachment({
    this.sectionId,
    required this.signalId,
    required this.evidenceType,
    required this.evidenceRefs,
    this.matchQuality = ThaiCanonEvidenceMatchQuality.exact,
    this.internalOnly = true,
    this.userFacingAllowed = false,
  });

  /// Mirror section id wire (e.g. `coreSelf`), or null for profile/timeline anchors.
  final String? sectionId;
  final String signalId;
  final ThaiCanonEvidenceType evidenceType;
  final List<ThaiCanonEvidenceRef> evidenceRefs;
  final ThaiCanonEvidenceMatchQuality matchQuality;
  final bool internalOnly;
  final bool userFacingAllowed;
}
