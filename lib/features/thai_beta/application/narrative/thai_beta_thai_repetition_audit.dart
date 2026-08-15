/// Thai-aware similarity utilities for consumer past-reflection copy.
///
/// The comparison uses Unicode code-point character n-grams and does not rely
/// on whitespace tokenization. Dynamic ages, phase names and theme names are
/// removed before both similarity and skeleton checks.
library;

enum ThaiBetaPastUnitKind { theme, question }

class ThaiBetaThaiSimilarityResult {
  const ThaiBetaThaiSimilarityResult({
    required this.similarity,
    required this.leftNormalized,
    required this.rightNormalized,
    required this.leftSkeleton,
    required this.rightSkeleton,
  });

  final double similarity;
  final String leftNormalized;
  final String rightNormalized;
  final String leftSkeleton;
  final String rightSkeleton;

  bool get repeatedSkeleton =>
      leftSkeleton.isNotEmpty && leftSkeleton == rightSkeleton;
}

abstract final class ThaiBetaThaiRepetitionAudit {
  static ThaiBetaThaiSimilarityResult comparePastUnits(
    String left,
    String right, {
    required ThaiBetaPastUnitKind kind,
  }) {
    final leftNormalized = normalizePastUnit(left, kind: kind);
    final rightNormalized = normalizePastUnit(right, kind: kind);
    return ThaiBetaThaiSimilarityResult(
      similarity: _diceCharacterNgram(leftNormalized, rightNormalized),
      leftNormalized: leftNormalized,
      rightNormalized: rightNormalized,
      leftSkeleton: skeleton(left, kind: kind),
      rightSkeleton: skeleton(right, kind: kind),
    );
  }

  static String normalizePastUnit(
    String value, {
    required ThaiBetaPastUnitKind kind,
  }) {
    var text = value.trim().toLowerCase();
    text = text.replaceFirst(
      kind == ThaiBetaPastUnitKind.theme
          ? RegExp(r'^ธีมสำหรับทบทวน\s*:\s*')
          : RegExp(r'^คำถามสะท้อน\s*:\s*'),
      '',
    );
    text = text
        .replaceAll(RegExp(r'[0-9๐-๙]+\s*[–-]\s*[0-9๐-๙]+'), '<age>')
        .replaceAll(RegExp(r'[0-9๐-๙]+'), '<number>');
    text = _normalizeDynamicSlots(text, kind);
    return text
        .replaceAll(RegExp(r'[\s\u200b\u200c\u200d\ufeff]+'), '')
        .replaceAll(RegExp(r'''[\-–—:;,.!?()“”"'•·]+'''), '');
  }

  static String skeleton(String value, {required ThaiBetaPastUnitKind kind}) {
    var text = normalizePastUnit(value, kind: kind);
    text = text
        .replaceAll(RegExp(r'<age>|<number>'), '<slot>')
        .replaceAll(RegExp(r'<phase>|<theme>'), '<slot>');
    return text;
  }

  static String _normalizeDynamicSlots(
    String value,
    ThaiBetaPastUnitKind kind,
  ) {
    var text = value;
    if (kind == ThaiBetaPastUnitKind.theme) {
      text = text
          .replaceFirst(
            RegExp(r'^ใน.+?ช่วงอายุ\s*<age>'),
            'ใน<phase>ช่วงอายุ<age>',
          )
          .replaceFirst(
            RegExp(r'ลองย้อนดูว่า.+?ปรากฏผ่านเรื่อง'),
            'ลองย้อนดูว่า<theme>ปรากฏผ่านเรื่อง',
          );
    } else {
      text = text
          .replaceFirst(
            RegExp(r'^เมื่อคิดถึง.+?ในวัย\s*<age>'),
            'เมื่อคิดถึง<phase>ในวัย<age>',
          )
          .replaceFirst(
            RegExp(r'ทำให้คุณเข้าใจ.+?ต่างจากเดิม'),
            'ทำให้คุณเข้าใจ<theme>ต่างจากเดิม',
          );
    }
    return text;
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
