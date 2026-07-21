import '../../content/models/thai_content_type.dart';

/// One contributing content mapping to an aggregated [ThaiThemeSignal].
class ThaiThemeSignalSource {
  const ThaiThemeSignalSource({
    required this.contentKey,
    required this.sourceType,
    required this.weightUsed,
    required this.rawWeight,
  });

  final String contentKey;
  final ThaiContentType sourceType;
  final double weightUsed;
  final double rawWeight;

  double get contribution => rawWeight * weightUsed;

  @override
  bool operator ==(Object other) {
    return other is ThaiThemeSignalSource &&
        other.contentKey == contentKey &&
        other.sourceType == sourceType &&
        other.weightUsed == weightUsed &&
        other.rawWeight == rawWeight;
  }

  @override
  int get hashCode =>
      Object.hash(contentKey, sourceType, weightUsed, rawWeight);
}
