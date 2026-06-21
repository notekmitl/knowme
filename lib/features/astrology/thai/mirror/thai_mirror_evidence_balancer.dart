import '../content/models/thai_content_type.dart';
import 'models/thai_mirror_evidence.dart';
import 'models/thai_mirror_lens_source.dart';

/// Caps per-lens evidence rows inside a section to rebalance explorer counts.
abstract final class ThaiMirrorEvidenceBalancer {
  static const maxMahabhutaPerSection = 2;
  static const maxMyanmarPerSection = 2;
  static const maxLagnaPerSection = 1;
  static const maxLagnaLordPerSection = 1;

  static List<ThaiMirrorEvidence> balance(List<ThaiMirrorEvidence> evidence) {
    if (evidence.isEmpty) return evidence;

    final buckets = <ThaiMirrorLensSource, List<ThaiMirrorEvidence>>{};
    for (final item in evidence) {
      buckets.putIfAbsent(item.lensSource, () => []).add(item);
    }

    for (final entry in buckets.entries) {
      entry.value.sort((a, b) {
        final contribution = b.contribution.compareTo(a.contribution);
        if (contribution != 0) return contribution;
        return a.contentKey.compareTo(b.contentKey);
      });
    }

    final balanced = <ThaiMirrorEvidence>[];
    for (final item in evidence) {
      final bucket = buckets[item.lensSource]!;
      final limit = _limitFor(item.lensSource);
      final rank = bucket.indexOf(item);
      if (rank < limit) balanced.add(item);
    }

    balanced.sort((a, b) {
      final contribution = b.contribution.compareTo(a.contribution);
      if (contribution != 0) return contribution;
      return a.contentKey.compareTo(b.contentKey);
    });

    return List<ThaiMirrorEvidence>.unmodifiable(balanced);
  }

  static int _limitFor(ThaiMirrorLensSource source) {
    return switch (source) {
      ThaiMirrorLensSource.mahabhutaPosition => maxMahabhutaPerSection,
      ThaiMirrorLensSource.myanmarSeven => maxMyanmarPerSection,
      ThaiMirrorLensSource.lagna => maxLagnaPerSection,
      ThaiMirrorLensSource.lagnaLord => maxLagnaLordPerSection,
    };
  }
}

/// Lens caps used only for section evidence balancing — not Theme scoring.
extension ThaiMirrorEvidenceLensType on ThaiMirrorEvidence {
  ThaiContentType? get contentType {
    return switch (lensSource) {
      ThaiMirrorLensSource.lagna => ThaiContentType.lagna,
      ThaiMirrorLensSource.lagnaLord => ThaiContentType.lagnaLord,
      ThaiMirrorLensSource.myanmarSeven => ThaiContentType.myanmarSeven,
      ThaiMirrorLensSource.mahabhutaPosition =>
        ThaiContentType.mahabhutaPosition,
    };
  }
}
