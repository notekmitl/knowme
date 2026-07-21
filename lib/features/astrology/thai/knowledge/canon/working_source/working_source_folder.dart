/// Canon Working Source Adapter — folder intake.
///
/// Reads a whole folder of per-page OCR `.txt` files directly into a
/// `TxtWorkingSource`. This is an **implementation improvement of the existing
/// TXT working source** (D-064), not a new platform layer: the resulting source
/// flows through the unchanged pipeline (Working Source → Authoring Studio →
/// Workspace → Canon).
///
/// Contract:
/// - **One `.txt` file = exactly one `WorkingPage`.** Files are never merged.
/// - The **page number comes from the filename** (e.g. `page_001.txt` → 1) and
///   pages are returned in numeric page order.
/// - The OCR text is preserved **verbatim**; the loader only normalises UTF-8
///   (strips a leading BOM) and line endings (CRLF/CR → LF). It never rewrites,
///   summarises, infers, translates or "cleans" terminology.
///
/// Uses `dart:io`; this is a desktop reviewer/intake tool, not runtime.
library;

import 'dart:io';

import 'package:knowme/features/astrology/thai/knowledge/canon/working_source/working_page.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/working_source/working_source_adapters.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/working_source/working_source_base.dart';

abstract final class WorkingSourceFolder {
  /// The last run of digits in the file *stem*, e.g. `page_001` → `1`,
  /// `p12_part3` → `3` (the page index is conventionally the trailing number).
  static final RegExp _trailingDigits = RegExp(r'(\d+)(?!.*\d)');

  /// Extract the page number from a filename, or null when it has no digits.
  static int? pageNumberFromFilename(String filename) {
    final base = filename.contains('/') || filename.contains(r'\')
        ? filename.split(RegExp(r'[\\/]')).last
        : filename;
    final stem = base.replaceFirst(RegExp(r'\.[^.]*$'), '');
    final m = _trailingDigits.firstMatch(stem);
    return m == null ? null : int.tryParse(m.group(1)!);
  }

  /// Normalise UTF-8 (strip a leading BOM) and line endings (CRLF/CR → LF).
  /// This is the ONLY transformation applied to the OCR text.
  static String normalizeText(String raw) {
    var s = raw;
    if (s.isNotEmpty && s.codeUnitAt(0) == 0xFEFF) s = s.substring(1);
    return s.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  }

  /// Build deterministic, page-ordered `WorkingPage`s from a list of
  /// (filename, rawText) pairs. Pure (no I/O) so it is fully testable.
  ///
  /// Throws [ArgumentError] if a filename has no page number or two files map to
  /// the same page number (ambiguous order — surfaced, never silently merged).
  static List<WorkingPage> pagesFromFiles(
      Iterable<({String filename, String rawText})> files) {
    final entries = <({int page, String filename, String text})>[];
    for (final f in files) {
      final n = pageNumberFromFilename(f.filename);
      if (n == null) {
        throw ArgumentError('Filename has no page number: "${f.filename}".');
      }
      entries.add((page: n, filename: f.filename, text: normalizeText(f.rawText)));
    }
    entries.sort((a, b) =>
        a.page != b.page ? a.page.compareTo(b.page) : a.filename.compareTo(b.filename));

    final seen = <int>{};
    for (final e in entries) {
      if (!seen.add(e.page)) {
        throw ArgumentError('Duplicate page number ${e.page} '
            '(file "${e.filename}") — pages must be unique.');
      }
    }
    return [
      for (final e in entries)
        WorkingSourcePaginator.pageVerbatim(e.page.toString(), e.text),
    ];
  }

  /// Load every `.txt` file in [folderPath] as one page each, in page order, and
  /// return a `TxtWorkingSource`. Reads files as UTF-8.
  static TxtWorkingSource loadTxt({
    required WorkingSourceRef ref,
    required String folderPath,
  }) {
    final dir = Directory(folderPath);
    if (!dir.existsSync()) {
      throw ArgumentError('Working source folder not found: $folderPath');
    }
    final files = <({String filename, String rawText})>[];
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      if (!entity.path.toLowerCase().endsWith('.txt')) continue;
      final name = entity.uri.pathSegments.last;
      files.add((filename: name, rawText: entity.readAsStringSync()));
    }
    return TxtWorkingSource.fromPages(
        ref: ref, pages: pagesFromFiles(files));
  }
}
