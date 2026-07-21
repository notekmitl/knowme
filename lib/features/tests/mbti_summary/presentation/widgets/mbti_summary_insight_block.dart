import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../../domain/mbti_summary_insight_models.dart';
import 'mbti_summary_layout.dart';
import 'mbti_summary_text_format.dart';

/// Scannable insight block: headline → contextual micro anchor → body.
class MbtiSummaryInsightBlock extends StatelessWidget {
  const MbtiSummaryInsightBlock({
    super.key,
    required this.pair,
    required this.blockIndex,
    this.showMicroAnchor = false,
  });

  final MbtiSummaryInsightPair pair;
  final int blockIndex;
  final bool showMicroAnchor;

  String get _anchorKey => blockIndex == 0
      ? 'mbti_sum_think_anchor_primary'
      : 'mbti_sum_think_anchor_secondary';

  @override
  Widget build(BuildContext context) {
    final body = MbtiSummaryTextFormat.singleParagraph(pair.body);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          pair.headline,
          style: TextStyle(
            fontSize: MbtiSummaryLayout.insightHeadlineSize,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
            height: 1.3,
          ),
          textAlign: TextAlign.left,
        ),
        if (showMicroAnchor) ...[
          const SizedBox(height: MbtiSummaryLayout.insightHeadlineAnchorGap),
          Text(
            AppText.t(_anchorKey),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: MbtiSummaryLayout.insightAnchorBodyGap),
        ] else
          const SizedBox(height: MbtiSummaryLayout.insightHeadlineAnchorGap),
        Text(
          body,
          style: TextStyle(
            fontSize: MbtiSummaryLayout.insightBodySize,
            fontWeight: FontWeight.w400,
            height: 1.55,
            color: Colors.grey.shade800,
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}
