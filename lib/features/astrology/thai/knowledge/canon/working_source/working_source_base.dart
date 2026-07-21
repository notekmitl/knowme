/// Canon Working Source Adapter — the common interface.
///
/// The Authoring Studio (and only the Authoring Studio) consumes temporary
/// working material through this single interface — never a concrete file type.
/// A working source yields pages and, for a selected page, a provenance-only
/// `ExtractionSource` (book / edition / chapter / page). Prose is never exposed
/// beyond the reviewer and never crosses into Canon.
///
/// Pure Dart; depends only on the (frozen) workspace `ExtractionSource`.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/working_source/working_page.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/extraction_source.dart';

enum WorkingSourceType { txt, ocr, pdf, image }

/// Provenance reference for a working source. These fields — and *only* these —
/// may survive into Canon (D-057). No copyrighted prose lives here.
class WorkingSourceRef {
  const WorkingSourceRef({
    required this.bookId,
    this.edition,
    this.chapter,
    this.title,
  });

  final String bookId;
  final String? edition;
  final String? chapter;
  final String? title;
}

/// The common, file-type-agnostic working-source interface. Temporary by design:
/// [dispose] discards all prose, after which Canon must remain fully intact.
abstract class WorkingSource {
  WorkingSourceType get type;
  WorkingSourceRef get ref;

  /// True once [dispose] has discarded the working material.
  bool get isDisposed;

  /// The working pages in deterministic order. Empty after [dispose].
  List<WorkingPage> pages();

  /// The page with [pageRef], or null.
  WorkingPage? page(String pageRef);

  /// The provenance-only `ExtractionSource` for [page] — book / edition / chapter
  /// / page number. It carries **no prose**, so wiring it into the Authoring
  /// Studio cannot leak copyrighted text into Canon.
  ExtractionSource extractionSourceForPage(
    WorkingPage page, {
    String? reviewer,
    String? extractionDate,
  });

  /// Discard the temporary material. Idempotent.
  void dispose();
}
