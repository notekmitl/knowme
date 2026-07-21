import '../../content/models/thai_content_type.dart';

/// Traceable evidence for one contributing content lens.
class ThaiThemeEvidence {
  const ThaiThemeEvidence({
    required this.contentKey,
    required this.sourceType,
    required this.contribution,
  });

  final String contentKey;
  final ThaiContentType sourceType;
  final double contribution;

  @override
  bool operator ==(Object other) {
    return other is ThaiThemeEvidence &&
        other.contentKey == contentKey &&
        other.sourceType == sourceType &&
        other.contribution == contribution;
  }

  @override
  int get hashCode => Object.hash(contentKey, sourceType, contribution);
}
