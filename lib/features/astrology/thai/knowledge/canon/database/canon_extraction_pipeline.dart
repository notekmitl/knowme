import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_database.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_knowledge_index.dart';

/// The canonical extraction workflow, as an explicit, ordered and auditable
/// sequence of stages:
///
/// `book → chapter → section → knowledgeUnit → validation → canonDatabase →
/// knowledgeIndex → reasoningEngine`
///
/// Each stage is recorded so the path from a printed page to a reasoning insight
/// is fully reversible.
enum CanonPipelineStage {
  book,
  chapter,
  section,
  knowledgeUnit,
  validation,
  canonDatabase,
  knowledgeIndex,
  reasoningEngine,
}

extension CanonPipelineStageX on CanonPipelineStage {
  int get order => index;
  CanonPipelineStage? get next =>
      index + 1 < CanonPipelineStage.values.length
          ? CanonPipelineStage.values[index + 1]
          : null;

  String get label => switch (this) {
        CanonPipelineStage.book => 'Book',
        CanonPipelineStage.chapter => 'Chapter',
        CanonPipelineStage.section => 'Section',
        CanonPipelineStage.knowledgeUnit => 'Knowledge Unit',
        CanonPipelineStage.validation => 'Validation',
        CanonPipelineStage.canonDatabase => 'Canon Database',
        CanonPipelineStage.knowledgeIndex => 'Knowledge Index',
        CanonPipelineStage.reasoningEngine => 'Reasoning Engine',
      };
}

enum CanonStepStatus { pending, inProgress, done, failed }

/// One recorded execution of a pipeline stage (audit trail).
class CanonPipelineStep {
  const CanonPipelineStep({
    required this.stage,
    required this.status,
    this.inputId,
    this.outputIds = const [],
    this.issues = const [],
    this.note,
    this.at,
  });

  final CanonPipelineStage stage;
  final CanonStepStatus status;
  final String? inputId;
  final List<String> outputIds;
  final List<CanonDbIssue> issues;
  final String? note;
  final DateTime? at;

  bool get ok => status == CanonStepStatus.done && issues.every((i) => !i.isError);
}

/// An ordered, auditable record of a pipeline run.
class CanonPipelineRun {
  CanonPipelineRun([List<CanonPipelineStep>? steps])
      : steps = List.unmodifiable(steps ?? const []);

  final List<CanonPipelineStep> steps;

  CanonPipelineRun record(CanonPipelineStep step) =>
      CanonPipelineRun([...steps, step]);

  CanonPipelineStep? lastFor(CanonPipelineStage stage) {
    for (final s in steps.reversed) {
      if (s.stage == stage) return s;
    }
    return null;
  }

  bool get hasErrors =>
      steps.any((s) => s.status == CanonStepStatus.failed) ||
      steps.any((s) => s.issues.any((i) => i.isError));
}

/// Snapshot of how far the pipeline has progressed for the current corpus.
class CanonPipelineStatus {
  const CanonPipelineStatus({
    required this.reached,
    required this.perStage,
    required this.blockingIssues,
  });

  /// Furthest stage the corpus currently satisfies.
  final CanonPipelineStage reached;

  /// Whether each stage's precondition is met.
  final Map<CanonPipelineStage, bool> perStage;
  final List<CanonDbIssue> blockingIssues;

  double get progress =>
      (reached.order + 1) / CanonPipelineStage.values.length;

  String get summary =>
      'Reached "${reached.label}" '
      '(${(progress * 100).toStringAsFixed(0)}%)'
      '${blockingIssues.isEmpty ? '' : ', ${blockingIssues.length} blocking issue(s)'}.';
}

/// Pure helpers for the extraction pipeline. No I/O, no engine, no mutation of
/// existing systems — it observes a [CanonDatabase] and reports where the
/// corpus sits in the workflow.
abstract final class CanonExtractionPipeline {
  static const List<CanonPipelineStage> stages = CanonPipelineStage.values;

  /// Compute the pipeline status for a database. Each later stage requires the
  /// earlier ones to be non-empty/valid; validation must be error-free to reach
  /// [CanonPipelineStage.canonDatabase] and beyond.
  static CanonPipelineStatus statusFor(CanonDatabase db) {
    final cov = db.coverage();
    final issues = db.validate();
    final hasErrors = issues.any((i) => i.isError);
    final approved = cov.canonApprovedUnits > 0;

    final met = <CanonPipelineStage, bool>{
      CanonPipelineStage.book: cov.books > 0,
      CanonPipelineStage.chapter: cov.chapters > 0,
      CanonPipelineStage.section: cov.sections > 0,
      CanonPipelineStage.knowledgeUnit: cov.units > 0,
      CanonPipelineStage.validation: cov.units > 0 && !hasErrors,
      CanonPipelineStage.canonDatabase: cov.units > 0 && !hasErrors,
      CanonPipelineStage.knowledgeIndex: cov.units > 0 && !hasErrors,
      CanonPipelineStage.reasoningEngine:
          approved && !hasErrors,
    };

    var reached = CanonPipelineStage.book;
    var reachedAny = false;
    for (final s in stages) {
      if (met[s] == true) {
        reached = s;
        reachedAny = true;
      } else {
        break;
      }
    }
    // When nothing is met yet, report the first stage as not-yet-reached by
    // surfacing book stage with progress reflecting emptiness.
    return CanonPipelineStatus(
      reached: reachedAny ? reached : CanonPipelineStage.book,
      perStage: met,
      blockingIssues: issues.where((i) => i.isError).toList(),
    );
  }

  /// Build the read-only Knowledge Index — the last structural stage before the
  /// Reasoning Engine. Provided here so callers route through the documented
  /// pipeline rather than constructing the index ad hoc.
  static CanonKnowledgeIndex toKnowledgeIndex(CanonDatabase db) =>
      CanonKnowledgeIndex.build(db);
}
