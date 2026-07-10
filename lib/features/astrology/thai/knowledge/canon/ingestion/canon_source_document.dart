/// Mahabhut Ingestion Toolchain V1 — Import Pipeline.
///
/// Parses user-prepared book text (OCR / plain text / Markdown / `.txt`) into a
/// structured document: pages, chapters, sections and paragraphs. **No PDF
/// parsing** — the user supplies text.
///
/// This layer is *purely structural*: it segments text the user provided. It
/// never invents content, never interprets meaning, and keeps every paragraph
/// verbatim. Pure Dart (no Flutter imports) so the CLI can run it.
library;

/// Configurable markers used to segment a document. Defaults recognise common
/// Thai book conventions plus Markdown headings; callers may override.
class CanonParseConfig {
  const CanonParseConfig({
    this.pagePattern = r'^\s*\[\s*(?:หน้า|page|p\.?)\s*([^\]]+?)\s*\]\s*$',
    this.chapterPattern = r'^\s*(?:#\s+|บทที่\s*|บท\s+|ภาค\s+|ตอนที่\s*)(.+?)\s*$',
    this.sectionPattern = r'^\s*(?:##\s+|หัวข้อ\s*|เรื่อง\s*)(.+?)\s*$',
  });

  final String pagePattern;
  final String chapterPattern;
  final String sectionPattern;

  RegExp get pageRe => RegExp(pagePattern, caseSensitive: false);
  RegExp get chapterRe => RegExp(chapterPattern, caseSensitive: false);
  RegExp get sectionRe => RegExp(sectionPattern, caseSensitive: false);
}

/// One verbatim paragraph plus the structural context it was found in.
class CanonParsedParagraph {
  const CanonParsedParagraph({
    required this.text,
    required this.chapterIndex,
    required this.sectionIndex,
    required this.paragraphIndex,
    this.page,
    this.chapterTitle,
    this.sectionTitle,
  });

  /// Verbatim paragraph text (joined lines, untouched wording).
  final String text;
  final int chapterIndex;
  final int sectionIndex;
  final int paragraphIndex;
  final String? page;
  final String? chapterTitle;
  final String? sectionTitle;
}

class CanonParsedSection {
  CanonParsedSection({
    required this.index,
    required this.chapterIndex,
    required this.title,
  });

  final int index;
  final int chapterIndex;
  final String title;
  final List<CanonParsedParagraph> paragraphs = [];
}

class CanonParsedChapter {
  CanonParsedChapter({required this.index, required this.title});

  final int index;
  final String title;
  final List<CanonParsedSection> sections = [];
}

/// The parsed structure of a single book's text.
class CanonSourceDocument {
  CanonSourceDocument({
    required this.bookId,
    required this.chapters,
    required this.paragraphs,
    required this.notes,
  });

  final String bookId;
  final List<CanonParsedChapter> chapters;

  /// Flat, ordered list of every paragraph (the extraction engine's input).
  final List<CanonParsedParagraph> paragraphs;

  /// Structural observations worth surfacing (e.g. text before any chapter).
  final List<String> notes;

  int get pageCount =>
      paragraphs.map((p) => p.page).whereType<String>().toSet().length;

  /// Parse [text] for [bookId]. Stateless and deterministic.
  static CanonSourceDocument parse(
    String text, {
    required String bookId,
    CanonParseConfig config = const CanonParseConfig(),
  }) {
    final lines = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
    final chapters = <CanonParsedChapter>[];
    final flat = <CanonParsedParagraph>[];
    final notes = <String>[];

    String? currentPage;
    CanonParsedChapter? chapter;
    CanonParsedSection? section;
    final buffer = <String>[];

    void flushParagraph() {
      if (buffer.isEmpty) return;
      final paragraphText = buffer.join(' ').trim();
      buffer.clear();
      if (paragraphText.isEmpty) return;
      // Auto-create implicit chapter/section if the text starts mid-stream.
      if (chapter == null) {
        chapter = CanonParsedChapter(index: chapters.length, title: '');
        chapters.add(chapter!);
        notes.add('Paragraph found before any chapter heading; '
            'placed in an untitled chapter (index ${chapter!.index}).');
      }
      if (section == null) {
        section = CanonParsedSection(
          index: chapter!.sections.length,
          chapterIndex: chapter!.index,
          title: '',
        );
        chapter!.sections.add(section!);
      }
      final paragraph = CanonParsedParagraph(
        text: paragraphText,
        chapterIndex: chapter!.index,
        sectionIndex: section!.index,
        paragraphIndex: section!.paragraphs.length,
        page: currentPage,
        chapterTitle: chapter!.title.isEmpty ? null : chapter!.title,
        sectionTitle: section!.title.isEmpty ? null : section!.title,
      );
      section!.paragraphs.add(paragraph);
      flat.add(paragraph);
    }

    for (final raw in lines) {
      final line = raw.trimRight();
      final trimmed = line.trim();

      final pageMatch = config.pageRe.firstMatch(line);
      if (pageMatch != null) {
        flushParagraph();
        currentPage = pageMatch.group(1)?.trim();
        continue;
      }

      final chapterMatch = config.chapterRe.firstMatch(line);
      if (chapterMatch != null) {
        flushParagraph();
        chapter = CanonParsedChapter(
          index: chapters.length,
          title: chapterMatch.group(1)?.trim() ?? '',
        );
        chapters.add(chapter!);
        section = null;
        continue;
      }

      final sectionMatch = config.sectionRe.firstMatch(line);
      if (sectionMatch != null) {
        flushParagraph();
        chapter ??= () {
          final c = CanonParsedChapter(index: chapters.length, title: '');
          chapters.add(c);
          return c;
        }();
        section = CanonParsedSection(
          index: chapter!.sections.length,
          chapterIndex: chapter!.index,
          title: sectionMatch.group(1)?.trim() ?? '',
        );
        chapter!.sections.add(section!);
        continue;
      }

      if (trimmed.isEmpty) {
        flushParagraph();
        continue;
      }
      buffer.add(trimmed);
    }
    flushParagraph();

    return CanonSourceDocument(
      bookId: bookId,
      chapters: chapters,
      paragraphs: flat,
      notes: notes,
    );
  }
}
