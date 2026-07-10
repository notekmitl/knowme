/// Mahabhut Ingestion Toolchain V1 — Extraction Metrics.
///
/// Counts per book/chapter/section and per status, plus coverage and progress.
/// Pure Dart.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_candidate.dart';

class CanonSectionMetrics {
  const CanonSectionMetrics({
    required this.sectionId,
    required this.extracted,
    required this.validated,
    required this.reviewed,
    required this.approved,
  });

  final String sectionId;
  final int extracted;
  final int validated;
  final int reviewed;
  final int approved;
}

class CanonChapterMetrics {
  const CanonChapterMetrics({
    required this.chapterId,
    required this.extracted,
    required this.approved,
    required this.sections,
  });

  final String chapterId;
  final int extracted;
  final int approved;
  final List<CanonSectionMetrics> sections;
}

/// Whole-book extraction metrics.
class CanonExtractionMetrics {
  const CanonExtractionMetrics({
    required this.bookId,
    required this.chapters,
    required this.sectionsCount,
    required this.extracted,
    required this.validated,
    required this.reviewed,
    required this.approved,
    required this.perChapter,
  });

  final String bookId;
  final int chapters;
  final int sectionsCount;

  /// Total candidates (every extracted unit counts as "extracted").
  final int extracted;
  final int validated;
  final int reviewed;
  final int approved;
  final List<CanonChapterMetrics> perChapter;

  /// Fraction of candidates that reached canonApproved.
  double get coverage => extracted == 0 ? 0 : approved / extracted;

  /// Fraction that moved beyond the raw candidate stage.
  double get progress =>
      extracted == 0 ? 0 : (validated + reviewed + approved) / extracted;

  String get summary =>
      '$bookId: $chapters chapter(s), $sectionsCount section(s), '
      '$extracted extracted → $validated validated → $reviewed reviewed → '
      '$approved approved '
      '(coverage ${(coverage * 100).toStringAsFixed(1)}%, '
      'progress ${(progress * 100).toStringAsFixed(1)}%).';

  static CanonExtractionMetrics of(CanonCandidateStore store) {
    final byChapter = <String, List<CanonCandidateUnit>>{};
    final sectionIds = <String>{};
    for (final c in store.candidates) {
      byChapter.putIfAbsent(c.chapterId ?? '(none)', () => []).add(c);
      if (c.sectionId != null) sectionIds.add(c.sectionId!);
    }

    int count(Iterable<CanonCandidateUnit> xs, CanonCandidateStatus s) =>
        xs.where((c) => c.status == s).length;
    int atLeast(Iterable<CanonCandidateUnit> xs, CanonCandidateStatus s) =>
        xs.where((c) => c.status.rank >= s.rank).length;

    final perChapter = <CanonChapterMetrics>[];
    final chapterKeys = byChapter.keys.toList()..sort();
    for (final ck in chapterKeys) {
      final xs = byChapter[ck]!;
      final bySection = <String, List<CanonCandidateUnit>>{};
      for (final c in xs) {
        bySection.putIfAbsent(c.sectionId ?? '(none)', () => []).add(c);
      }
      final secMetrics = <CanonSectionMetrics>[];
      final secKeys = bySection.keys.toList()..sort();
      for (final sk in secKeys) {
        final sx = bySection[sk]!;
        secMetrics.add(CanonSectionMetrics(
          sectionId: sk,
          extracted: sx.length,
          validated: atLeast(sx, CanonCandidateStatus.validated),
          reviewed: atLeast(sx, CanonCandidateStatus.reviewed),
          approved: count(sx, CanonCandidateStatus.canonApproved),
        ));
      }
      perChapter.add(CanonChapterMetrics(
        chapterId: ck,
        extracted: xs.length,
        approved: count(xs, CanonCandidateStatus.canonApproved),
        sections: secMetrics,
      ));
    }

    final all = store.candidates;
    return CanonExtractionMetrics(
      bookId: store.bookId,
      chapters: byChapter.length,
      sectionsCount: sectionIds.length,
      extracted: all.length,
      validated: atLeast(all, CanonCandidateStatus.validated),
      reviewed: atLeast(all, CanonCandidateStatus.reviewed),
      approved: count(all, CanonCandidateStatus.canonApproved),
      perChapter: perChapter,
    );
  }
}
