// Mahabhut Ingestion Toolchain V1 — CLI utility.
//
// A code-free way to bring a chapter's prepared text into the candidate layer
// and inspect it. Run with the Dart SDK:
//
//   dart run tool/canon_ingest.dart extract <textFile> <bookId> [--source <id>] [--out <file>]
//   dart run tool/canon_ingest.dart validate <candidates.json>
//   dart run tool/canon_ingest.dart qa       <candidates.json>
//   dart run tool/canon_ingest.dart metrics  <candidates.json>
//   dart run tool/canon_ingest.dart diff     <old.json> <new.json>
//
// It creates Candidates only — never Canon nodes. Semantic fields
// (type/topic/subject/value) and cross-references are filled by a human in the
// candidate JSON before validation/approval. Nothing here invents knowledge.
//
// No engine / Swiss Ephemeris / runtime / provider / mirror / fusion / narrative
// dependency: the toolchain is pure Dart.

import 'dart:io';

import 'package:knowme/features/astrology/thai/knowledge/canon/ingestion/canon_ingestion.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    _usage();
    exitCode = 64;
    return;
  }
  final cmd = args.first;
  final rest = args.sublist(1);
  switch (cmd) {
    case 'extract':
      _extract(rest);
    case 'validate':
      _validate(rest);
    case 'qa':
      _qa(rest);
    case 'metrics':
      _metrics(rest);
    case 'diff':
      _diff(rest);
    default:
      stderr.writeln('Unknown command: $cmd');
      _usage();
      exitCode = 64;
  }
}

void _extract(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('extract needs <textFile> <bookId>');
    exitCode = 64;
    return;
  }
  final textFile = args[0];
  final bookId = args[1];
  final sourceId = _opt(args, '--source') ?? bookId;
  final out = _opt(args, '--out') ?? '$bookId.candidates.json';

  final text = File(textFile).readAsStringSync();
  final result =
      CanonExtractionEngine.extractText(text, bookId: bookId, sourceId: sourceId);
  final store = result.toStore();
  File(out).writeAsStringSync(store.toJsonString());

  stdout.writeln('Extracted ${store.length} candidate(s) from $textFile');
  stdout.writeln('  chapters: ${result.chapters.length}, '
      'sections: ${result.sections.length}');
  if (result.notes.isNotEmpty) {
    stdout.writeln('  notes:');
    for (final n in result.notes) {
      stdout.writeln('    - $n');
    }
  }
  stdout.writeln('Wrote candidates → $out');
  stdout.writeln('Next: assign type/topic/subject (+ cross refs) in $out, '
      'then run `validate`.');
}

void _validate(List<String> args) {
  final store = _loadStore(args);
  if (store == null) return;
  final report = CanonCandidateValidator.validate(store);
  if (report.isClean) {
    stdout.writeln('Validation clean (${store.length} candidate(s)).');
  } else {
    stdout.writeln('Validation issues:');
    for (final entry in report.countsByCode.entries) {
      stdout.writeln('  ${entry.key}: ${entry.value}');
    }
    for (final i in report.errors) {
      stdout.writeln('  - $i');
    }
    exitCode = 1;
  }
}

void _qa(List<String> args) {
  final store = _loadStore(args);
  if (store == null) return;
  for (final report in CanonQaTools.all(store)) {
    stdout.writeln('${report.name}: ${report.count}');
    for (final f in report.findings) {
      stdout.writeln('  - ${f.candidateId}: ${f.detail}');
    }
  }
}

void _metrics(List<String> args) {
  final store = _loadStore(args);
  if (store == null) return;
  final m = CanonExtractionMetrics.of(store);
  stdout.writeln(m.summary);
  for (final ch in m.perChapter) {
    stdout.writeln('  ${ch.chapterId}: '
        '${ch.extracted} extracted, ${ch.approved} approved, '
        '${ch.sections.length} section(s)');
  }
}

void _diff(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('diff needs <old.json> <new.json>');
    exitCode = 64;
    return;
  }
  final oldStore = CanonCandidateStore.fromJsonString(File(args[0]).readAsStringSync());
  final newStore = CanonCandidateStore.fromJsonString(File(args[1]).readAsStringSync());
  final report = CanonDiffEngine.diff(oldStore, newStore);
  stdout.writeln(report.summary);
  for (final id in report.added) {
    stdout.writeln('  + $id');
  }
  for (final id in report.removed) {
    stdout.writeln('  - $id');
  }
  for (final d in report.changed) {
    stdout.writeln('  ~ ${d.id}');
    for (final ch in d.changes) {
      stdout.writeln('      $ch');
    }
  }
}

CanonCandidateStore? _loadStore(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Need a candidates JSON file.');
    exitCode = 64;
    return null;
  }
  return CanonCandidateStore.fromJsonString(File(args.first).readAsStringSync());
}

String? _opt(List<String> args, String flag) {
  final i = args.indexOf(flag);
  if (i >= 0 && i + 1 < args.length) return args[i + 1];
  return null;
}

void _usage() {
  stdout.writeln('''
Mahabhut Canon ingestion CLI

  dart run tool/canon_ingest.dart extract <textFile> <bookId> [--source <id>] [--out <file>]
  dart run tool/canon_ingest.dart validate <candidates.json>
  dart run tool/canon_ingest.dart qa       <candidates.json>
  dart run tool/canon_ingest.dart metrics  <candidates.json>
  dart run tool/canon_ingest.dart diff     <old.json> <new.json>
''');
}
