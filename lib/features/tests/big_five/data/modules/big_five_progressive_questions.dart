import 'package:knowme/data/questions/bigfive/bfi_44.dart';
import 'package:knowme/data/questions/bigfive/ipip_120.dart';
import 'package:knowme/data/questions/bigfive/tipi_10.dart';
import 'package:knowme/domain/models/test_question.dart';

import '../../domain/big_five_depth_tier.dart';

/// Progressive Big Five question sets (10 → 44 → 80).
///
/// Quick uses TIPI-10. Standard prefixes quick with BFI items. Deep extends
/// standard with IPIP items (legacy bank supports up to 120; product caps at 80).
abstract final class BigFiveProgressiveQuestions {
  static const String questionSetVersion =
      'knowme.big_five.progressive.v1';

  static final List<TestQuestion> quick =
      List<TestQuestion>.unmodifiable(tipiQuestions);

  static final List<TestQuestion> standard = List<TestQuestion>.unmodifiable([
    ...tipiQuestions,
    ...bfi44Questions.take(bigFiveStandardCheckpoint - bigFiveQuickCheckpoint),
  ]);

  static final List<TestQuestion> deep = List<TestQuestion>.unmodifiable(
    _buildDeepQuestions(),
  );

  /// Full legacy IPIP import — abstraction allows future expansion toward 120.
  static final List<TestQuestion> legacyExtendedBank =
      List<TestQuestion>.unmodifiable(ipip120Questions);

  static int get legacyBankAvailableCount => legacyExtendedBank.length;

  static List<TestQuestion> forDepthTier(BigFiveDepthTier tier) {
    return switch (tier) {
      BigFiveDepthTier.quick => quick,
      BigFiveDepthTier.standard => standard,
      BigFiveDepthTier.deep => deep,
    };
  }

  static List<TestQuestion> forTargetTotal(int total) {
    if (total >= bigFiveDeepCheckpoint) return deep;
    if (total >= bigFiveStandardCheckpoint) return standard;
    return quick;
  }

  static List<TestQuestion> _buildDeepQuestions() {
    final standardIds = standard.map((question) => question.id).toSet();
    final additions = <TestQuestion>[];
    for (final question in ipip120Questions) {
      if (standardIds.contains(question.id)) continue;
      additions.add(question);
      if (additions.length >= bigFiveDeepCheckpoint - bigFiveStandardCheckpoint) {
        break;
      }
    }

    return [...standard, ...additions];
  }
}
