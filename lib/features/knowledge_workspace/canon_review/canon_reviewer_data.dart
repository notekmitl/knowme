/// Mahabhut Content Engineering V1 — Reviewer Workspace data.
///
/// Bundles everything the reviewer workspace renders for one ingestion batch:
/// the candidate store plus the derived review/coverage/consistency reports.
/// Pure data assembly over the existing ingestion toolchain — no new engine.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_ingestion.dart';

class CanonReviewerData {
  CanonReviewerData({
    required this.store,
    required this.review,
    required this.coverage,
    required this.consistency,
  });

  final CanonCandidateStore store;
  final CanonReviewResult review;
  final CanonCoverageReport coverage;
  final CanonConsistencyReport consistency;

  bool get isEmpty => store.length == 0;

  factory CanonReviewerData.fromStore(
    CanonCandidateStore store, {
    Set<String> knownIds = const {},
  }) =>
      CanonReviewerData(
        store: store,
        review: CanonReviewAssistant.review(store, knownIds: knownIds),
        coverage: CanonCoverageReport.analyze(store, knownIds: knownIds),
        consistency: CanonConsistencyChecker.check(store),
      );

  /// Parse a candidate JSON file (produced by `tool/canon_ingest.dart extract`).
  factory CanonReviewerData.fromCandidateJson(String jsonString) =>
      CanonReviewerData.fromStore(
        CanonCandidateStore.fromJsonString(jsonString),
      );

  /// Empty default — used until a candidate batch is loaded.
  factory CanonReviewerData.empty([String bookId = 'mahabhut']) =>
      CanonReviewerData.fromStore(CanonCandidateStore(bookId: bookId));
}
