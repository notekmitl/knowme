/// Canon Knowledge Authoring Studio V1 — editable draft unit.
///
/// A `DraftKnowledgeUnit` is the **editable** mirror of an `AtomicKnowledgeUnit`.
/// Nothing here is Canon; drafts are authored, batch-edited, validated (via the
/// Workspace validator) and only then imported. It stays atomic: one
/// subject/relation/object plus structured qualifiers — no narrative fields.
///
/// Pure Dart; depends only on the atomic knowledge layer.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canon_json.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart'
    show KnowledgeConfidence;

class DraftKnowledgeUnit {
  DraftKnowledgeUnit({
    required this.id,
    this.subject = '',
    this.subjectKind = AtomicEntityKind.planet,
    this.relation = AtomicRelation.relatesTo,
    this.object = '',
    this.objectKind = AtomicEntityKind.other,
    this.domain = KnowledgeDomain.other,
    this.condition,
    this.effect,
    this.strength = AtomicStrength.none,
    this.confidence = KnowledgeConfidence.none,
    AtomicEvidenceRef? evidence,
    this.notes,
  }) : evidence = evidence ?? const AtomicEvidenceRef(bookId: '');

  String id;
  String subject;
  AtomicEntityKind subjectKind;
  AtomicRelation relation;
  String object;
  AtomicEntityKind objectKind;
  KnowledgeDomain domain;
  String? condition;
  String? effect;
  AtomicStrength strength;
  KnowledgeConfidence confidence;
  AtomicEvidenceRef evidence;
  String? notes;

  /// Deterministic identity of the *fact* being asserted (ignores qualifiers).
  String get factKey =>
      '${subjectKind.name}:$subject|${relation.wire}|'
      '${objectKind.name}:$object|${condition ?? ''}';

  /// Total conversion to an atomic unit (used to drive the Workspace validator).
  AtomicKnowledgeUnit toAtomic() => AtomicKnowledgeUnit(
        id: id,
        subject: subject,
        subjectKind: subjectKind,
        relation: relation,
        object: object,
        objectKind: objectKind,
        domain: domain,
        condition: condition,
        effect: effect,
        strength: strength,
        confidence: confidence,
        notes: notes,
        evidence: evidence,
      );

  /// A deep copy with a new [newId] (used by duplicate/split).
  DraftKnowledgeUnit cloneWith(String newId, {String? object}) =>
      DraftKnowledgeUnit(
        id: newId,
        subject: subject,
        subjectKind: subjectKind,
        relation: relation,
        object: object ?? this.object,
        objectKind: objectKind,
        domain: domain,
        condition: condition,
        effect: effect,
        strength: strength,
        confidence: confidence,
        evidence: evidence,
        notes: notes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'subjectKind': subjectKind.name,
        'relation': relation.wire,
        'object': object,
        'objectKind': objectKind.name,
        'domain': domain.name,
        if (condition != null) 'condition': condition,
        if (effect != null) 'effect': effect,
        'strength': strength.name,
        'confidence': confidence.name,
        if (notes != null) 'notes': notes,
        'evidence': evidence.toJson(),
      };

  static DraftKnowledgeUnit fromJson(Map<String, dynamic> m) {
    return DraftKnowledgeUnit(
      id: (m['id'] as String?)?.trim() ?? '',
      subject: (m['subject'] as String?) ?? '',
      subjectKind: AtomicEntityKind.fromName(m['subjectKind'] as String?),
      relation:
          AtomicRelation.fromWire(m['relation'] as String?) ?? AtomicRelation.relatesTo,
      object: (m['object'] as String?) ?? '',
      objectKind: AtomicEntityKind.fromName(m['objectKind'] as String?),
      domain: KnowledgeDomain.fromName(m['domain'] as String?),
      condition: (m['condition'] as String?)?.trim(),
      effect: (m['effect'] as String?)?.trim(),
      strength: AtomicStrength.fromName(m['strength'] as String?),
      confidence: canonEnumByName(
              KnowledgeConfidence.values, m['confidence'] as String?) ??
          KnowledgeConfidence.none,
      notes: (m['notes'] as String?)?.trim(),
      evidence: m['evidence'] is Map<String, dynamic>
          ? AtomicEvidenceRef.fromJson(m['evidence'] as Map<String, dynamic>)
          : null,
    );
  }
}
