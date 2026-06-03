import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../../domain/mbti_models.dart';

/// One pole pair — same scores as before; presentation only.
class MbtiDimensionPairData {
  const MbtiDimensionPairData({
    required this.leftLetter,
    required this.rightLetter,
    required this.leftHintKey,
    required this.rightHintKey,
    required this.leftScore,
    required this.rightScore,
    required this.dominantLetter,
  });

  final String leftLetter;
  final String rightLetter;
  final String leftHintKey;
  final String rightHintKey;
  final double leftScore;
  final double rightScore;
  final String dominantLetter;

  double get total => leftScore + rightScore;

  int get leftPercent =>
      total <= 0 ? 50 : ((leftScore / total) * 100).round().clamp(0, 100);

  int get rightPercent => 100 - leftPercent;

  bool get leftDominant => leftScore >= rightScore;

  int get dominantPercent => leftDominant ? leftPercent : rightPercent;

  /// 0 = ~50/50, 1 = strong lean — display-only (colors / subtle bar emphasis).
  double get leanStrength {
    final margin = (dominantPercent - 50).abs();
    return (margin / 50).clamp(0.0, 1.0);
  }

  String dominantTraitLabelKey() {
    const keys = {
      'E': 'mbti_trait_extroverted',
      'I': 'mbti_trait_introverted',
      'S': 'mbti_trait_sensing',
      'N': 'mbti_trait_intuition',
      'T': 'mbti_trait_thinking',
      'F': 'mbti_trait_feeling',
      'J': 'mbti_trait_judging',
      'P': 'mbti_trait_perceiving',
    };
    return keys[dominantLetter] ?? 'mbti_trait_extroverted';
  }
}

List<MbtiDimensionPairData> dimensionPairsFromSummary(MbtiResultSummary summary) {
  double d(String k) => summary.dimension(k);

  return [
    MbtiDimensionPairData(
      leftLetter: 'E',
      rightLetter: 'I',
      leftHintKey: 'mbti_pole_e_short',
      rightHintKey: 'mbti_pole_i_short',
      leftScore: d('E'),
      rightScore: d('I'),
      dominantLetter: d('E') >= d('I') ? 'E' : 'I',
    ),
    MbtiDimensionPairData(
      leftLetter: 'S',
      rightLetter: 'N',
      leftHintKey: 'mbti_pole_s_short',
      rightHintKey: 'mbti_pole_n_short',
      leftScore: d('S'),
      rightScore: d('N'),
      dominantLetter: d('S') >= d('N') ? 'S' : 'N',
    ),
    MbtiDimensionPairData(
      leftLetter: 'T',
      rightLetter: 'F',
      leftHintKey: 'mbti_pole_t_short',
      rightHintKey: 'mbti_pole_f_short',
      leftScore: d('T'),
      rightScore: d('F'),
      dominantLetter: d('T') >= d('F') ? 'T' : 'F',
    ),
    MbtiDimensionPairData(
      leftLetter: 'J',
      rightLetter: 'P',
      leftHintKey: 'mbti_pole_j_short',
      rightHintKey: 'mbti_pole_p_short',
      leftScore: d('J'),
      rightScore: d('P'),
      dominantLetter: d('J') >= d('P') ? 'J' : 'P',
    ),
  ];
}

/// Fixed-height comparison bar — fill width = dominance; color scales with lean.
class _FillWidthBar extends StatelessWidget {
  const _FillWidthBar({
    required this.leftPercent,
    required this.leftDominant,
    required this.accent,
    required this.leanStrength,
  });

  final int leftPercent;
  final bool leftDominant;
  final Color accent;
  final double leanStrength;

  static const double barHeight = 24;

  /// Slight visual emphasis on lean (display only; true % still shown in label).
  static int _displayFlex(int percent, double lean, int dominantPercent) {
    if (lean < 0.1) return percent.clamp(1, 99);
    final extra = ((dominantPercent - 50).abs() * lean * 0.4).round();
    if (percent > 50) return (percent + extra).clamp(1, 99);
    return (percent - extra).clamp(1, 99);
  }

  @override
  Widget build(BuildContext context) {
    final dominant = leftDominant ? leftPercent : (100 - leftPercent);
    final leftFlex = _displayFlex(leftPercent, leanStrength, dominant);
    final rightFlex = (100 - leftFlex).clamp(1, 99);
    final strong = Color.lerp(
      accent.withValues(alpha: 0.72),
      accent,
      0.55 + (0.45 * leanStrength),
    )!;
    final weak = Colors.grey.shade200;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: barHeight,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: leftFlex,
                child: ColoredBox(
                  color: leftDominant ? strong : weak,
                ),
              ),
              Expanded(
                flex: rightFlex,
                child: ColoredBox(
                  color: leftDominant ? weak : strong,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MbtiResultDimensionBars extends StatelessWidget {
  const MbtiResultDimensionBars({super.key, required this.pairs});

  final List<MbtiDimensionPairData> pairs;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppText.t('mbti_result_traits_title'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...pairs.map(
              (p) => _TraitRow(
                pair: p,
                accent: accent,
                isLast: p == pairs.last,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One dimension: title → bar → % → explanation (nothing else).
class _TraitRow extends StatelessWidget {
  const _TraitRow({
    required this.pair,
    required this.accent,
    required this.isLast,
  });

  final MbtiDimensionPairData pair;
  final Color accent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final leftWins = pair.leftDominant;
    final lean = pair.leanStrength;
    final barColor = accent;
    final labelColor = Colors.grey.shade500;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                pair.leftLetter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                  height: 1,
                ),
              ),
              const Spacer(),
              Text(
                pair.rightLetter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppText.t(pair.leftHintKey),
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.1,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  AppText.t(pair.rightHintKey),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.1,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _FillWidthBar(
            leftPercent: pair.leftPercent,
            leftDominant: leftWins,
            accent: barColor,
            leanStrength: lean,
          ),
          const SizedBox(height: 6),
          Text(
            '${pair.dominantPercent}%',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Color.lerp(
                barColor.withValues(alpha: 0.85),
                barColor,
                0.5 + (0.5 * lean),
              ),
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${AppText.t('mbti_result_trait_lean')} '
            '${AppText.t(pair.dominantTraitLabelKey())}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
