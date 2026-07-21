/// Mahabhut Content Engineering V1 — Coverage Analysis.
///
/// Reports how completely a book has been converted: chapter coverage, section
/// coverage, knowledge density, citation coverage and validation coverage. Built
/// on top of the existing [CanonExtractionMetrics] + Validation Engine; no new
/// counting system. Pure Dart.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_candidate.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_candidate_validator.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_extraction_metrics.dart';

class CanonChapterCoverage {
  const CanonChapterCoverage({
    required this.chapterId,
    required this.units,
    required this.approved,
  });

  final String chapterId;
  final int units;
  final int approved;

  double get coverage => units == 0 ? 0 : approved / units;
}

/// Whole-book coverage analysis.
class CanonCoverageReport {
  const CanonCoverageReport({
    required this.bookId,
    required this.chapters,
    required this.sections,
    required this.units,
    required this.approvedUnits,
    required this.unitsWithCitation,
    required this.unitsWithPage,
    required this.cleanUnits,
    required this.pages,
    required this.perChapter,
  });

  final String bookId;
  final int chapters;
  final int sections;
  final int units;
  final int approvedUnits;
  final int unitsWithCitation;
  final int unitsWithPage;

  /// Units with no validation errors.
  final int cleanUnits;
  final int pages;
  final List<CanonChapterCoverage> perChapter;

  /// Fraction of chapters that have at least one approved unit.
  double get chapterCoverage => chapters == 0
      ? 0
      : perChapter.where((c) => c.approved > 0).length / chapters;

  /// Approved units ÷ total units.
  double get sectionCoverage => units == 0 ? 0 : approvedUnits / units;

  /// Units per distinct page referenced (how richly the book is captured).
  double get knowledgeDensity => pages == 0 ? 0 : units / pages;

  /// Fraction of units carrying both a quote and a page.
  double get citationCoverage =>
      units == 0 ? 0 : ((unitsWithCitation + unitsWithPage) / 2) / units;

  /// Fraction of units that pass validation cleanly.
  double get validationCoverage => units == 0 ? 0 : cleanUnits / units;

  String get summary =>
      '$bookId coverage — chapters ${(chapterCoverage * 100).toStringAsFixed(1)}%, '
      'sections ${(sectionCoverage * 100).toStringAsFixed(1)}%, '
      'density ${knowledgeDensity.toStringAsFixed(2)} units/page, '
      'citation ${(citationCoverage * 100).toStringAsFixed(1)}%, '
      'validation ${(validationCoverage * 100).toStringAsFixed(1)}%.';

  static CanonCoverageReport analyze(
    CanonCandidateStore store, {
    Set<String> knownIds = const {},
  }) {
    final metrics = CanonExtractionMetrics.of(store);
    final report =
        CanonCandidateValidator.validate(store, knownIds: knownIds);

    final pages = store.candidates
        .map((c) => c.page)
        .whereType<String>()
        .where((p) => p.trim().isNotEmpty)
        .toSet()
        .length;

    final perChapter = metrics.perChapter
        .map((c) => CanonChapterCoverage(
              chapterId: c.chapterId,
              units: c.extracted,
              approved: c.approved,
            ))
        .toList();

    return CanonCoverageReport(
      bookId: store.bookId,
      chapters: metrics.chapters,
      sections: metrics.sectionsCount,
      units: metrics.extracted,
      approvedUnits: metrics.approved,
      unitsWithCitation: store.candidates.where((c) => c.hasCitation).length,
      unitsWithPage: store.candidates.where((c) => c.hasPage).length,
      cleanUnits:
          store.candidates.where((c) => report.isCandidateClean(c.id)).length,
      pages: pages,
      perChapter: perChapter,
    );
  }
}
