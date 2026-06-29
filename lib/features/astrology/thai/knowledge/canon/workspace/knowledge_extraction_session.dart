/// Canon Knowledge Extraction Workspace V4 — extraction session.
///
/// A `KnowledgeExtractionSession` is the unit of work for converting book pages
/// into Atomic Knowledge. Nothing enters Canon directly: every imported unit
/// belongs to exactly one session, and a session walks a deterministic
/// lifecycle. Pure Dart; reuses the atomic layer only.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/extraction_source.dart';

enum SessionState {
  draft,
  extracting,
  validated,
  reviewed,
  approved,
  imported,
  archived;

  static SessionState fromName(String? name) {
    for (final s in SessionState.values) {
      if (s.name == name) return s;
    }
    return SessionState.draft;
  }
}

/// Result of a lifecycle transition attempt.
class SessionTransition {
  const SessionTransition(this.ok, this.from, this.to, [this.reason]);

  final bool ok;
  final SessionState from;
  final SessionState to;
  final String? reason;
}

class KnowledgeExtractionSession {
  KnowledgeExtractionSession({
    required this.id,
    required this.source,
    List<AtomicKnowledgeUnit>? units,
    this.state = SessionState.draft,
  }) : units = units ?? <AtomicKnowledgeUnit>[];

  final String id;
  final ExtractionSource source;
  final List<AtomicKnowledgeUnit> units;
  SessionState state;

  /// Deterministic allowed transitions. Forward through the lifecycle, with a
  /// few explicit backward edges (re-extract / re-validate / re-review) and the
  /// ability to archive from any non-terminal state.
  static const Map<SessionState, List<SessionState>> _allowed = {
    SessionState.draft: [SessionState.extracting, SessionState.archived],
    SessionState.extracting: [
      SessionState.validated,
      SessionState.draft,
      SessionState.archived,
    ],
    SessionState.validated: [
      SessionState.reviewed,
      SessionState.extracting,
      SessionState.archived,
    ],
    SessionState.reviewed: [
      SessionState.approved,
      SessionState.validated,
      SessionState.archived,
    ],
    SessionState.approved: [
      SessionState.imported,
      SessionState.reviewed,
      SessionState.archived,
    ],
    SessionState.imported: [SessionState.archived],
    SessionState.archived: [],
  };

  bool canTransitionTo(SessionState target) =>
      (_allowed[state] ?? const []).contains(target);

  /// Attempt a transition. Deterministic: same current state + target always
  /// yields the same result. On success [state] is updated.
  SessionTransition transitionTo(SessionState target) {
    final from = state;
    if (target == from) {
      return SessionTransition(false, from, target, 'already in $from');
    }
    if (!canTransitionTo(target)) {
      return SessionTransition(
          false, from, target, 'illegal transition $from → $target');
    }
    state = target;
    return SessionTransition(true, from, target);
  }

  /// Units sorted by id (deterministic view).
  List<AtomicKnowledgeUnit> get sortedUnits {
    final list = [...units];
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  bool get isTerminal => state == SessionState.archived;
  bool get isImported => state == SessionState.imported;

  Map<String, dynamic> toJson() => {
        'id': id,
        'state': state.name,
        'source': source.toJson(),
        'units': sortedUnits.map((u) => u.toJson()).toList(),
      };
}
