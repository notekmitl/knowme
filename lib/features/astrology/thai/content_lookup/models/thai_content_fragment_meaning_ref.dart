import '../../interpretation/enums/thai_meaning_predicate.dart';

/// Optional meaning coordinates for standalone fragment export.
///
/// Not emitted in the default bundled pipeline — [ThaiInterpretationBundle]
/// is the meaning source of truth.
class ThaiContentFragmentMeaningRef {
  const ThaiContentFragmentMeaningRef({
    required this.predicate,
    required this.objectRef,
    required this.context,
  });

  final ThaiMeaningPredicate predicate;
  final String objectRef;
  final Map<String, String> context;

  factory ThaiContentFragmentMeaningRef.fromMap(Map<String, dynamic> map) {
    final predicateRaw = map['predicate'];
    ThaiMeaningPredicate? predicate;
    if (predicateRaw is ThaiMeaningPredicate) {
      predicate = predicateRaw;
    } else if (predicateRaw is String) {
      predicate = parseThaiMeaningPredicate(predicateRaw);
    }
    if (predicate == null) {
      throw FormatException('Invalid predicate: $predicateRaw');
    }

    return ThaiContentFragmentMeaningRef(
      predicate: predicate,
      objectRef: _requiredString(map['objectRef']),
      context: _stringMap(map['context']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'predicate': predicate.id,
      'objectRef': objectRef,
      'context': Map<String, String>.from(context),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiContentFragmentMeaningRef &&
        other.predicate == predicate &&
        other.objectRef == objectRef &&
        _mapEquals(other.context, context);
  }

  @override
  int get hashCode => Object.hash(
        predicate,
        objectRef,
        Object.hashAll(context.entries.map((e) => Object.hash(e.key, e.value))),
      );

  static String _requiredString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid string field: $raw');
    }
    return raw.trim();
  }

  static Map<String, String> _stringMap(dynamic raw) {
    if (raw is! Map) {
      return const {};
    }

    final result = <String, String>{};
    raw.forEach((key, value) {
      if (key is String && value is String) {
        result[key] = value;
      }
    });
    return Map<String, String>.unmodifiable(result);
  }

  static bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
