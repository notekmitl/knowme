import 'package:knowme/data/mbti/mbti_types.dart';
import 'package:knowme/domain/models/mbti_type.dart';

/// Resolves MBTI result narrative copy from shared [MbtiType] metadata (`mbti_types.dart`).
///
/// All user-facing strings for section **titles** come from [AppText] keys on the page;
/// paragraph and list items use the `en` / `th` maps already stored per type.
class MbtiResultLocalizedContent {
  MbtiResultLocalizedContent({
    required this.typeCode,
    required this.lang,
  }) : _model = mbtiTypes[typeCode];

  final String typeCode;
  final String lang;
  final MbtiType? _model;

  String _pick(Map<String, String> map) => map[lang] ?? map['en'] ?? '';

  List<String> _lines(List<Map<String, String>> items) {
    if (_model == null) return const [];
    return items
        .map((m) => _pick(m))
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Short overview (existing `description` field — bilingual per type).
  String summary(String whenUnknown) {
    final m = _model;
    if (m == null) return whenUnknown;
    return _pick(m.description);
  }

  List<String> get strengths {
    final m = _model;
    if (m == null) return const [];
    return _lines(m.strengths);
  }

  /// Friendly “things to watch for” — sourced from `weaknesses` data, not labeled as weaknesses in UI.
  List<String> get cautions {
    final m = _model;
    if (m == null) return const [];
    return _lines(m.weaknesses);
  }

  List<String> get careers {
    final m = _model;
    if (m == null) return const [];
    return _lines(m.careers);
  }

  /// Single paragraph built from relationship bullet strings.
  String relationshipsParagraph() {
    final m = _model;
    if (m == null) return '';
    final parts = _lines(m.relationships);
    if (parts.isEmpty) return '';
    return parts.join(' ');
  }
}
