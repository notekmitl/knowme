import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';

import 'thai_canon_evidence_attachment.dart';
import 'thai_canon_evidence_trace.dart';

/// Frozen Thai Mirror pipeline output plus internal Canon evidence metadata.
///
/// Does not replace or mutate [pipelineResult] — attachments are additive only.
class ThaiMirrorCanonEvidenceBundle {
  const ThaiMirrorCanonEvidenceBundle({
    required this.pipelineResult,
    required this.attachments,
    required this.trace,
  });

  final ThaiMirrorPipelineResult pipelineResult;
  final List<ThaiCanonEvidenceAttachment> attachments;
  final ThaiCanonEvidenceTrace trace;

  int get attachmentCount => attachments.length;

  int get totalEvidenceRefs =>
      attachments.fold(0, (sum, a) => sum + a.evidenceRefs.length);
}
