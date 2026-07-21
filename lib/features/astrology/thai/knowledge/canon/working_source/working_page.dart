/// Canon Working Source Adapter — page model.
///
/// A `WorkingPage` is **temporary** material shown to the reviewer during
/// authoring. It is NOT Canon and is never persisted into the Canon Database,
/// Atomic Knowledge, Ontology, Knowledge Graph, Workspace output or Review output.
/// Only a *reference* (book / edition / chapter / page) ever survives.
///
/// Pure Dart leaf — no Flutter/engine/runtime imports.
library;

/// One paragraph of temporary working text (ephemeral, never Canon).
class WorkingParagraph {
  const WorkingParagraph({required this.index, required this.text});

  final int index;
  final String text;

  @override
  bool operator ==(Object other) =>
      other is WorkingParagraph && other.index == index && other.text == text;

  @override
  int get hashCode => Object.hash(index, text);
}

/// One page of temporary working material: a page reference plus its paragraphs.
/// The prose is ephemeral; only [pageRef] is provenance that may survive.
class WorkingPage {
  const WorkingPage({required this.pageRef, required this.paragraphs});

  /// The page reference (e.g. `"127"`). The only part allowed to survive.
  final String pageRef;

  final List<WorkingParagraph> paragraphs;

  /// The reviewer-facing prose for this page. **Temporary** — never stored.
  String get text => paragraphs.map((p) => p.text).join('\n\n');

  bool get isEmpty => paragraphs.isEmpty;

  /// Deterministic content signature, used for value equality.
  String get signature =>
      '$pageRef::${paragraphs.map((p) => '${p.index}:${p.text}').join('|')}';

  @override
  bool operator ==(Object other) =>
      other is WorkingPage && other.signature == signature;

  @override
  int get hashCode => signature.hashCode;

  @override
  String toString() => 'WorkingPage($pageRef, ${paragraphs.length} paragraphs)';
}
