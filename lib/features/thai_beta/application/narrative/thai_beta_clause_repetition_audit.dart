/// Clause-level reader-quality audit for Thai consumer narrative.
///
/// The audit works on Unicode code points and deliberately avoids Thai word
/// tokenization. It splits rendered paragraphs into sentence/clause units,
/// normalizes presentation slots, and reports exact, near-duplicate,
/// prefix/suffix, and skeleton reuse without excluding consumer prose.
library;

class ThaiBetaNarrativeAuditUnit {
  const ThaiBetaNarrativeAuditUnit({
    required this.unitId,
    required this.text,
    required this.section,
    this.domain = '',
    this.horizon = '',
    this.sourceClaimId = '',
    this.callbackNewInformation = '',
    this.isCallback = false,
    this.excluded = false,
  });

  final String unitId;
  final String text;
  final String section;
  final String domain;
  final String horizon;
  final String sourceClaimId;
  final String callbackNewInformation;
  final bool isCallback;
  final bool excluded;
}

class ThaiBetaNarrativeClause {
  const ThaiBetaNarrativeClause({
    required this.unitId,
    required this.section,
    required this.domain,
    required this.horizon,
    required this.text,
    required this.normalized,
    required this.skeleton,
  });

  final String unitId;
  final String section;
  final String domain;
  final String horizon;
  final String text;
  final String normalized;
  final String skeleton;
}

class ThaiBetaNarrativeClausePair {
  const ThaiBetaNarrativeClausePair({
    required this.left,
    required this.right,
    required this.similarity,
    required this.exact,
    required this.repeatedPrefix,
    required this.repeatedSuffix,
    required this.repeatedSkeleton,
  });

  final ThaiBetaNarrativeClause left;
  final ThaiBetaNarrativeClause right;
  final double similarity;
  final bool exact;
  final bool repeatedPrefix;
  final bool repeatedSuffix;
  final bool repeatedSkeleton;

  bool get flagged =>
      exact ||
      similarity >= ThaiBetaClauseRepetitionAudit.similarityThreshold ||
      repeatedPrefix ||
      repeatedSuffix ||
      repeatedSkeleton;
}

class ThaiBetaClauseAuditResult {
  const ThaiBetaClauseAuditResult({
    required this.clauses,
    required this.pairs,
    required this.callbackFailures,
    required this.keywordFrequency,
  });

  final List<ThaiBetaNarrativeClause> clauses;
  final List<ThaiBetaNarrativeClausePair> pairs;
  final List<String> callbackFailures;
  final Map<String, int> keywordFrequency;

  List<ThaiBetaNarrativeClausePair> get flaggedPairs =>
      pairs.where((pair) => pair.flagged).toList(growable: false);
}

abstract final class ThaiBetaClauseRepetitionAudit {
  static const similarityThreshold = .78;
  static const minimumNormalizedLength = 18;
  static const edgeLength = 18;

  static ThaiBetaClauseAuditResult audit(
    Iterable<ThaiBetaNarrativeAuditUnit> units, {
    Iterable<String> dynamicSlots = const [],
    Iterable<String> keywords = const [],
  }) {
    final included = units.where((unit) => !unit.excluded).toList();
    final clauses = <ThaiBetaNarrativeClause>[];
    for (final unit in included) {
      for (final text in splitClauses(unit.text)) {
        final normalized = normalize(text, dynamicSlots: dynamicSlots);
        if (normalized.runes.length < minimumNormalizedLength) continue;
        clauses.add(
          ThaiBetaNarrativeClause(
            unitId: unit.unitId,
            section: unit.section,
            domain: unit.domain,
            horizon: unit.horizon,
            text: text,
            normalized: normalized,
            skeleton: skeleton(text, dynamicSlots: dynamicSlots),
          ),
        );
      }
    }

    final pairs = <ThaiBetaNarrativeClausePair>[];
    for (var left = 0; left < clauses.length; left++) {
      for (var right = left + 1; right < clauses.length; right++) {
        final a = clauses[left];
        final b = clauses[right];
        if (a.unitId == b.unitId) continue;
        final exact = a.normalized == b.normalized;
        final prefix =
            _edge(a.normalized, fromStart: true) ==
            _edge(b.normalized, fromStart: true);
        final suffix =
            _edge(a.normalized, fromStart: false) ==
            _edge(b.normalized, fromStart: false);
        pairs.add(
          ThaiBetaNarrativeClausePair(
            left: a,
            right: b,
            similarity: _diceCharacterNgram(a.normalized, b.normalized),
            exact: exact,
            repeatedPrefix: prefix,
            repeatedSuffix: suffix,
            repeatedSkeleton: a.skeleton.isNotEmpty && a.skeleton == b.skeleton,
          ),
        );
      }
    }

    final callbackFailures = <String>[];
    for (final unit in included.where((unit) => unit.isCallback)) {
      final source = unit.sourceClaimId.trim();
      final added = normalize(
        unit.callbackNewInformation,
        dynamicSlots: dynamicSlots,
      );
      final body = normalize(unit.text, dynamicSlots: dynamicSlots);
      if (source.isEmpty ||
          added.runes.length < minimumNormalizedLength ||
          added == body) {
        callbackFailures.add(unit.unitId);
      }
    }

    final combined = included.map((unit) => unit.text).join('\n');
    final keywordFrequency = <String, int>{};
    for (final keyword in keywords) {
      final value = keyword.trim();
      if (value.isEmpty) continue;
      keywordFrequency[value] = value.allMatches(combined).length;
    }
    return ThaiBetaClauseAuditResult(
      clauses: List.unmodifiable(clauses),
      pairs: List.unmodifiable(pairs),
      callbackFailures: List.unmodifiable(callbackFailures),
      keywordFrequency: Map.unmodifiable(keywordFrequency),
    );
  }

  static List<String> splitClauses(String value) {
    var expanded = value.replaceAll(RegExp(r'[\r\n]+'), '\n');
    expanded = expanded.replaceAll(RegExp(r'[.!?;,:]+'), '\n');
    expanded = expanded.replaceAllMapped(
      RegExp(r'\s+(หาก|แต่|ขณะที่|ส่วน|เพราะ|ผลตามมาคือ|จากนั้น|แล้วจึง|โดย)'),
      (match) => '\n${match.group(1)}',
    );
    return expanded
        .split('\n')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }

  static String normalize(
    String value, {
    Iterable<String> dynamicSlots = const [],
  }) {
    var text = value.toLowerCase().trim();
    final slots =
        dynamicSlots
            .map((slot) => slot.trim().toLowerCase())
            .where((slot) => slot.isNotEmpty)
            .toSet()
            .toList()
          ..sort((left, right) => right.length.compareTo(left.length));
    for (final slot in slots) {
      text = text.replaceAll(slot, '<slot>');
    }
    text = text
        .replaceAll(RegExp(r'[0-9๐-๙]+\s*[–-]\s*[0-9๐-๙]+'), '<range>')
        .replaceAll(RegExp(r'[0-9๐-๙]+'), '<number>')
        .replaceAll(
          RegExp(
            r'ช่วงนี้|ตอนนี้|ใน 12 เดือน|ช่วงชีวิตถัดไป|ช่วงถัดไป|ระยะข้างหน้า',
          ),
          '<horizon>',
        )
        .replaceAll(
          RegExp(
            r'การงาน|งาน|การเงิน|ความรัก|ความสัมพันธ์|สุขภาพ|การพักและการฟื้นตัว',
          ),
          '<domain>',
        )
        .replaceAll(RegExp(r'[\s\u200b\u200c\u200d\ufeff]+'), '')
        .replaceAll(RegExp(r'''[\-–—:;,.!?()“”"'•·]+'''), '');
    return text;
  }

  static String skeleton(
    String value, {
    Iterable<String> dynamicSlots = const [],
  }) => normalize(
    value,
    dynamicSlots: dynamicSlots,
  ).replaceAll(RegExp(r'<range>|<number>|<slot>|<horizon>|<domain>'), '<slot>');

  static String _edge(String value, {required bool fromStart}) {
    final chars = value.runes.toList(growable: false);
    if (chars.length < edgeLength) return value;
    final selected = fromStart
        ? chars.take(edgeLength)
        : chars.skip(chars.length - edgeLength);
    return String.fromCharCodes(selected);
  }

  static double _diceCharacterNgram(String left, String right) {
    const width = 3;
    Map<String, int> grams(String value) {
      final chars = value.runes.toList(growable: false);
      if (chars.isEmpty) return const {};
      if (chars.length < width) return {String.fromCharCodes(chars): 1};
      final out = <String, int>{};
      for (var index = 0; index <= chars.length - width; index++) {
        final gram = String.fromCharCodes(chars.sublist(index, index + width));
        out.update(gram, (count) => count + 1, ifAbsent: () => 1);
      }
      return out;
    }

    final leftGrams = grams(left);
    final rightGrams = grams(right);
    if (leftGrams.isEmpty && rightGrams.isEmpty) return 1;
    var intersection = 0;
    for (final entry in leftGrams.entries) {
      final other = rightGrams[entry.key] ?? 0;
      intersection += entry.value < other ? entry.value : other;
    }
    final leftTotal = leftGrams.values.fold<int>(0, (a, b) => a + b);
    final rightTotal = rightGrams.values.fold<int>(0, (a, b) => a + b);
    return (2 * intersection) / (leftTotal + rightTotal);
  }
}
