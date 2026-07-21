import '../enums/thai_content_fragment_kind.dart';
import 'thai_content_fragment_meaning_ref.dart';

/// Lean presentation atom from Content Lookup Layer.
///
/// Structural meaning lives in [ThaiInterpretationFact] — this object carries
/// readable text and a pointer back via [sourceFactId].
class ThaiContentFragment {
  const ThaiContentFragment({
    required this.resolutionId,
    required this.fragmentKind,
    required this.text,
    required this.sourceFactId,
    required this.contentKey,
    this.contentVersion,
    this.meaningRef,
    this.fragmentIndex,
  });

  final String resolutionId;
  final ThaiContentFragmentKind fragmentKind;
  final String text;
  final String sourceFactId;
  final String contentKey;
  final String? contentVersion;
  final ThaiContentFragmentMeaningRef? meaningRef;
  final int? fragmentIndex;

  factory ThaiContentFragment.fromMap(Map<String, dynamic> map) {
    final kindRaw = map['fragmentKind'] ?? map['fragment_kind'];
    ThaiContentFragmentKind? fragmentKind;
    if (kindRaw is ThaiContentFragmentKind) {
      fragmentKind = kindRaw;
    } else if (kindRaw is String) {
      fragmentKind = parseThaiContentFragmentKind(kindRaw);
    }
    if (fragmentKind == null) {
      throw FormatException('Invalid fragmentKind: $kindRaw');
    }

    final meaningRefRaw = map['meaningRef'] ?? map['meaning_ref'];
    ThaiContentFragmentMeaningRef? meaningRef;
    if (meaningRefRaw is ThaiContentFragmentMeaningRef) {
      meaningRef = meaningRefRaw;
    } else if (meaningRefRaw is Map) {
      meaningRef = ThaiContentFragmentMeaningRef.fromMap(
        Map<String, dynamic>.from(meaningRefRaw),
      );
    }

    final fragmentIndex = map['fragmentIndex'] ?? map['fragment_index'];
    int? parsedFragmentIndex;
    if (fragmentIndex is int) {
      parsedFragmentIndex = fragmentIndex;
    } else if (fragmentIndex is num) {
      parsedFragmentIndex = fragmentIndex.toInt();
    }

    return ThaiContentFragment(
      resolutionId: _requiredString(map['resolutionId'] ?? map['resolution_id']),
      fragmentKind: fragmentKind,
      text: _requiredString(map['text']),
      sourceFactId: _requiredString(map['sourceFactId'] ?? map['source_fact_id']),
      contentKey: _requiredString(map['contentKey'] ?? map['content_key']),
      contentVersion: _optionalString(map['contentVersion'] ?? map['content_version']),
      meaningRef: meaningRef,
      fragmentIndex: parsedFragmentIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resolutionId': resolutionId,
      'fragmentKind': fragmentKind.id,
      'text': text,
      'sourceFactId': sourceFactId,
      'contentKey': contentKey,
      if (contentVersion != null) 'contentVersion': contentVersion,
      if (meaningRef != null) 'meaningRef': meaningRef!.toMap(),
      if (fragmentIndex != null) 'fragmentIndex': fragmentIndex,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiContentFragment &&
        other.resolutionId == resolutionId &&
        other.fragmentKind == fragmentKind &&
        other.text == text &&
        other.sourceFactId == sourceFactId &&
        other.contentKey == contentKey &&
        other.contentVersion == contentVersion &&
        other.meaningRef == meaningRef &&
        other.fragmentIndex == fragmentIndex;
  }

  @override
  int get hashCode => Object.hash(
        resolutionId,
        fragmentKind,
        text,
        sourceFactId,
        contentKey,
        contentVersion,
        meaningRef,
        fragmentIndex,
      );

  static String _requiredString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid string field: $raw');
    }
    return raw.trim();
  }

  static String? _optionalString(dynamic raw) {
    if (raw is! String) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
