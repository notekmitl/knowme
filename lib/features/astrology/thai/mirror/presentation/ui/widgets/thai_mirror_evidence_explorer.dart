import 'package:flutter/material.dart';

import '../../../models/thai_mirror_lens_source.dart';
import '../../models/thai_mirror_evidence_explorer_state.dart';
import 'thai_mirror_evidence_row.dart';
import 'thai_mirror_lens_badge.dart';

/// Evidence Explorer — transparency block for Thai Mirror Result Page.
class ThaiMirrorEvidenceExplorer extends StatefulWidget {
  const ThaiMirrorEvidenceExplorer({
    super.key,
    required this.state,
  });

  final ThaiMirrorEvidenceExplorerState state;

  static const titleTh = 'แหล่งที่มาของผลลัพธ์';
  static const subtitleTh =
      'คุณสามารถตรวจสอบได้ว่าผลลัพธ์แต่ละส่วนมาจากข้อมูลใด';
  static const emptyMessage = 'แหล่งอ้างอิงจะปรากฏเมื่อมีผลวิเคราะห์พร้อม';

  /// Sort rows by supported-theme count (desc), then content key (asc).
  static List<ThaiMirrorEvidenceRowState> sortedRows(
    List<ThaiMirrorEvidenceRowState> rows,
  ) {
    final sorted = List<ThaiMirrorEvidenceRowState>.from(rows);
    sorted.sort((a, b) {
      final contributionCompare = b.supportedThemeIds.length
          .compareTo(a.supportedThemeIds.length);
      if (contributionCompare != 0) return contributionCompare;
      return a.contentKey.compareTo(b.contentKey);
    });
    return sorted;
  }

  @override
  State<ThaiMirrorEvidenceExplorer> createState() =>
      _ThaiMirrorEvidenceExplorerState();
}

class _ThaiMirrorEvidenceExplorerState extends State<ThaiMirrorEvidenceExplorer> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final hasEvidence = widget.state.rows.isNotEmpty;
    final sortedRows = ThaiMirrorEvidenceExplorer.sortedRows(widget.state.rows);

    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.38),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (value) => setState(() => _expanded = value),
        tilePadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        title: Text(
          ThaiMirrorEvidenceExplorer.titleTh,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            ThaiMirrorEvidenceExplorer.subtitleTh,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: muted.withValues(alpha: 0.95),
            ),
          ),
        ),
        children: [
          if (!hasEvidence)
            Text(
              ThaiMirrorEvidenceExplorer.emptyMessage,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: muted,
              ),
            )
          else ...[
            _LensSummary(lensCounts: widget.state.lensCounts),
            const SizedBox(height: 16),
            ...sortedRows.map(
              (row) => ThaiMirrorEvidenceRow(state: row),
            ),
          ],
        ],
      ),
    );
  }
}

class _LensSummary extends StatelessWidget {
  const _LensSummary({
    required this.lensCounts,
  });

  final Map<ThaiMirrorLensSource, int> lensCounts;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final entries = ThaiMirrorLensBadge.lensOrder
        .where((lens) => (lensCounts[lens] ?? 0) > 0)
        .map(
          (lens) => '${ThaiMirrorLensBadge.labelFor(lens, compact: true)} '
              '(${lensCounts[lens]})',
        )
        .toList();

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'สรุปตามเลนส์',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: entries
              .map(
                (label) => Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: muted.withValues(alpha: 0.95),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
