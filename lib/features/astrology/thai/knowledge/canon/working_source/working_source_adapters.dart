/// Canon Working Source Adapter — input adapters.
///
/// Concrete adapters for the supported temporary inputs — TXT, OCR text, PDF and
/// Images — all normalised to the **same** `WorkingPage` structure through one
/// shared paginator. Given equivalent content, every adapter produces identical
/// working pages. There is **no automatic extraction and no AI**: PDF/Image
/// adapters consume text the reviewer/tooling has already obtained per page; the
/// adapter only *supplies* that temporary text to the reviewer.
///
/// Pure Dart; depends only on the working-source interface + workspace provenance.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/working_source/working_page.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/working_source/working_source_base.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/extraction_source.dart';

/// One already-textual page handed to a per-page adapter (PDF/Image). The text
/// is whatever the reviewer extracted/transcribed — the adapter never does OCR.
class WorkingPageInput {
  const WorkingPageInput({required this.pageRef, required this.text});
  final String pageRef;
  final String text;
}

/// Shared behaviour: ephemeral storage, deterministic reads and the
/// provenance-only bridge. Lives in this library so adapters share one impl.
mixin _WorkingSourceCore implements WorkingSource {
  final List<WorkingPage> _pages = [];
  bool _disposed = false;

  void _init(List<WorkingPage> pages) {
    _pages
      ..clear()
      ..addAll(pages);
  }

  @override
  bool get isDisposed => _disposed;

  @override
  List<WorkingPage> pages() =>
      _disposed ? const [] : List<WorkingPage>.unmodifiable(_pages);

  @override
  WorkingPage? page(String pageRef) {
    for (final p in pages()) {
      if (p.pageRef == pageRef) return p;
    }
    return null;
  }

  @override
  ExtractionSource extractionSourceForPage(
    WorkingPage page, {
    String? reviewer,
    String? extractionDate,
  }) {
    final n = int.tryParse(page.pageRef.trim());
    return ExtractionSource(
      bookId: ref.bookId,
      edition: ref.edition,
      chapter: ref.chapter,
      pageStart: n,
      pageEnd: n,
      reviewer: reviewer,
      extractionDate: extractionDate,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _pages.clear();
  }
}

/// Plain-text working source (page markers `[หน้า N]` / `[page N]`).
class TxtWorkingSource with _WorkingSourceCore {
  TxtWorkingSource({required WorkingSourceRef ref, required String text})
      : _ref = ref {
    _init(WorkingSourcePaginator.parseMarkedText(text));
  }

  /// Build a TXT working source from pages that were already separated upstream
  /// (e.g. one OCR file per page from `WorkingSourceFolder`). The pages are used
  /// verbatim and in the given order — no merging, no marker parsing.
  TxtWorkingSource.fromPages(
      {required WorkingSourceRef ref, required List<WorkingPage> pages})
      : _ref = ref {
    _init(pages);
  }

  final WorkingSourceRef _ref;

  @override
  WorkingSourceType get type => WorkingSourceType.txt;
  @override
  WorkingSourceRef get ref => _ref;
}

/// OCR-text working source. OCR output is already text; it is parsed exactly like
/// plain text so equivalent content yields identical pages.
class OcrWorkingSource with _WorkingSourceCore {
  OcrWorkingSource({required WorkingSourceRef ref, required String ocrText})
      : _ref = ref {
    _init(WorkingSourcePaginator.parseMarkedText(ocrText));
  }

  final WorkingSourceRef _ref;

  @override
  WorkingSourceType get type => WorkingSourceType.ocr;
  @override
  WorkingSourceRef get ref => _ref;
}

/// PDF working source. The PDF text layer is extracted **externally** (no parser
/// here) and supplied per page; the adapter only normalises it.
class PdfWorkingSource with _WorkingSourceCore {
  PdfWorkingSource({
    required WorkingSourceRef ref,
    required List<WorkingPageInput> pageTexts,
  }) : _ref = ref {
    _init(WorkingSourcePaginator.pagesFromInputs(pageTexts));
  }

  final WorkingSourceRef _ref;

  @override
  WorkingSourceType get type => WorkingSourceType.pdf;
  @override
  WorkingSourceRef get ref => _ref;
}

/// Image working source. The reviewer transcribes each page image (no OCR/AI in
/// the adapter) and supplies the text per page; the adapter only normalises it.
class ImageWorkingSource with _WorkingSourceCore {
  ImageWorkingSource({
    required WorkingSourceRef ref,
    required List<WorkingPageInput> pageTexts,
  }) : _ref = ref {
    _init(WorkingSourcePaginator.pagesFromInputs(pageTexts));
  }

  final WorkingSourceRef _ref;

  @override
  WorkingSourceType get type => WorkingSourceType.image;
  @override
  WorkingSourceRef get ref => _ref;
}

/// Deterministic normalisation shared by every adapter.
abstract final class WorkingSourcePaginator {
  /// Page-marker line: `[หน้า 127]`, `[page 127]`, `[p. 127]` (case-insensitive).
  static final RegExp _marker = RegExp(
    r'^\s*\[\s*(?:หน้า|page|p\.?)\s*([0-9]+)\s*\]\s*$',
    caseSensitive: false,
  );

  /// Parse marked text into pages. Each marker starts a page; text before the
  /// first marker is ignored (front matter, not a numbered page). With no
  /// markers the whole text is a single page `"1"`. Deterministic.
  static List<WorkingPage> parseMarkedText(String raw) {
    final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = normalized.split('\n');
    final result = <WorkingPage>[];
    String? curRef;
    final buf = <String>[];
    var sawMarker = false;

    void flush() {
      if (curRef != null) result.add(paginate(curRef, buf.join('\n')));
      buf.clear();
    }

    for (final line in lines) {
      final m = _marker.firstMatch(line);
      if (m != null) {
        sawMarker = true;
        flush();
        curRef = m.group(1);
      } else {
        buf.add(line);
      }
    }
    flush();

    if (!sawMarker) {
      final whole = paginate('1', normalized);
      return whole.isEmpty ? <WorkingPage>[] : [whole];
    }
    return result;
  }

  /// Normalise already-paginated inputs (PDF/Image). Deterministic.
  static List<WorkingPage> pagesFromInputs(List<WorkingPageInput> inputs) =>
      [for (final i in inputs) paginate(i.pageRef, i.text)];

  /// Build one page that **preserves [text] verbatim** — the whole page is a
  /// single paragraph. Used when one source file already represents exactly one
  /// page (folder intake): the OCR text is not re-paragraphed, re-flowed,
  /// trimmed or otherwise rewritten. Callers normalise UTF-8 / line endings
  /// before calling. An empty page has no paragraphs.
  static WorkingPage pageVerbatim(String pageRef, String text) => WorkingPage(
        pageRef: pageRef.trim(),
        paragraphs: text.isEmpty
            ? const []
            : [WorkingParagraph(index: 0, text: text)],
      );

  /// Split [text] into trimmed, non-empty paragraphs (blank-line separated).
  static WorkingPage paginate(String pageRef, String text) {
    final paras = text
        .split(RegExp(r'\n[ \t]*\n+'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    return WorkingPage(
      pageRef: pageRef.trim(),
      paragraphs: [
        for (var i = 0; i < paras.length; i++)
          WorkingParagraph(index: i, text: paras[i]),
      ],
    );
  }
}
