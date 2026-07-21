/// Mahabhut Ingestion Toolchain V1 — Canon Extraction Engine.
///
/// Turns a parsed [CanonSourceDocument] into **Candidate** units plus the
/// structural skeleton (chapters/sections) discovered in the text.
///
/// Critical boundary: this engine performs **structural segmentation only**. It
/// copies each paragraph verbatim into a candidate's `statement` and seeds the
/// evidence quote with the same verbatim text. It does **not** assign meaning —
/// `type`, `topic`, `subject` and `value` are left empty for a human reviewer.
/// Nothing is approved here.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_entities.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_candidate.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_source_document.dart';

/// Result of an extraction pass: the candidates and the structural entities they
/// reference (ready to be promoted into the Canon Database).
class CanonExtractionResult {
  CanonExtractionResult({
    required this.bookId,
    required this.chapters,
    required this.sections,
    required this.candidates,
    required this.notes,
  });

  final String bookId;
  final List<CanonChapter> chapters;
  final List<CanonSection> sections;
  final List<CanonCandidateUnit> candidates;
  final List<String> notes;

  CanonCandidateStore toStore({int version = 1}) =>
      CanonCandidateStore(bookId: bookId, version: version, candidates: candidates);
}

abstract final class CanonExtractionEngine {
  /// Extract candidates from already-parsed text.
  static CanonExtractionResult extract(
    CanonSourceDocument document, {
    String? sourceId,
  }) {
    final bookId = document.bookId;
    final chapters = <CanonChapter>[];
    final sections = <CanonSection>[];
    final candidates = <CanonCandidateUnit>[];

    String chapterId(int i) => '$bookId-ch${_pad(i)}';
    String sectionId(int ci, int si) => '$bookId-ch${_pad(ci)}-s${_pad(si)}';

    for (final ch in document.chapters) {
      chapters.add(CanonChapter(
        id: chapterId(ch.index),
        bookId: bookId,
        number: ch.index + 1,
        title: ch.title.isEmpty ? '(untitled chapter ${ch.index + 1})' : ch.title,
      ));
      for (final sec in ch.sections) {
        sections.add(CanonSection(
          id: sectionId(ch.index, sec.index),
          chapterId: chapterId(ch.index),
          bookId: bookId,
          title: sec.title.isEmpty
              ? '(untitled section ${sec.index + 1})'
              : sec.title,
          pageStart: sec.paragraphs.isEmpty ? null : sec.paragraphs.first.page,
          pageEnd: sec.paragraphs.isEmpty ? null : sec.paragraphs.last.page,
        ));
      }
    }

    var counter = 0;
    for (final p in document.paragraphs) {
      counter++;
      final id = '$bookId-c${_pad(counter, 4)}';
      candidates.add(CanonCandidateUnit(
        id: id,
        bookId: bookId,
        sourceId: sourceId ?? bookId,
        // The verbatim paragraph is *working material* for the reviewer to read
        // and rewrite into structured knowledge — it is not the canonical text.
        statement: p.text,
        // Provenance is by *reference* (page + chapter/section). We do NOT seed a
        // verbatim quote: the platform never stores copyrighted paragraphs.
        page: p.page,
        chapterId: chapterId(p.chapterIndex),
        sectionId: sectionId(p.chapterIndex, p.sectionIndex),
        // Semantic fields intentionally left blank — assigned by a human.
        status: CanonCandidateStatus.candidate,
      ));
    }

    final notes = <String>[...document.notes];
    for (final p in document.paragraphs) {
      if (p.page == null) {
        notes.add('Paragraph in ${chapterId(p.chapterIndex)}/'
            '${sectionId(p.chapterIndex, p.sectionIndex)} has no page marker; '
            'add a [หน้า N] marker in the source before approval.');
        break; // one representative note is enough
      }
    }

    return CanonExtractionResult(
      bookId: bookId,
      chapters: chapters,
      sections: sections,
      candidates: candidates,
      notes: notes,
    );
  }

  /// Convenience: parse + extract in one call.
  static CanonExtractionResult extractText(
    String text, {
    required String bookId,
    String? sourceId,
    CanonParseConfig config = const CanonParseConfig(),
  }) =>
      extract(
        CanonSourceDocument.parse(text, bookId: bookId, config: config),
        sourceId: sourceId,
      );
}

String _pad(int n, [int width = 2]) => n.toString().padLeft(width, '0');
