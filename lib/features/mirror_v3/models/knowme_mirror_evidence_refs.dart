import 'knowme_mirror_evidence_ref.dart';
import 'knowme_mirror_lineage_chain.dart';

/// Full evidence bundle required on every mirror object.
class KnowMeMirrorEvidenceRefs {
  const KnowMeMirrorEvidenceRefs({
    required this.themeIds,
    required this.evidenceRefs,
    required this.lineage,
    this.interpretationIds = const [],
    this.signalIds = const [],
    this.meaningIds = const [],
  });

  final List<String> themeIds;
  final List<String> interpretationIds;
  final List<String> signalIds;
  final List<String> meaningIds;
  final List<KnowMeMirrorEvidenceRef> evidenceRefs;
  final KnowMeMirrorLineageChain lineage;

  Map<String, dynamic> toMap() {
    return {
      'themeIds': themeIds,
      'interpretationIds': interpretationIds,
      'signalIds': signalIds,
      'meaningIds': meaningIds,
      'evidenceRefs': evidenceRefs.map((ref) => ref.toMap()).toList(),
      'lineage': lineage.toMap(),
    };
  }

  factory KnowMeMirrorEvidenceRefs.fromMap(Map<String, dynamic> map) {
    return KnowMeMirrorEvidenceRefs(
      themeIds: _stringList(map['themeIds']),
      interpretationIds: _stringList(map['interpretationIds']),
      signalIds: _stringList(map['signalIds']),
      meaningIds: _stringList(map['meaningIds']),
      evidenceRefs: _evidenceRefList(map['evidenceRefs']),
      lineage: KnowMeMirrorLineageChain.fromMap(
        Map<String, dynamic>.from(map['lineage'] as Map),
      ),
    );
  }
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<String>().toList(growable: false);
}

List<KnowMeMirrorEvidenceRef> _evidenceRefList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map(
        (item) => KnowMeMirrorEvidenceRef.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList(growable: false);
}
