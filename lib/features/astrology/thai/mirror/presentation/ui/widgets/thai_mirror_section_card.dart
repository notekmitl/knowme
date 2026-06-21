import 'package:flutter/material.dart';

import '../../../models/thai_mirror_section_id.dart';
import '../../models/thai_mirror_section_card_state.dart';

/// Expandable fusion section card for Thai Mirror Result Page.
class ThaiMirrorSectionCard extends StatefulWidget {
  const ThaiMirrorSectionCard({
    super.key,
    required this.state,
  });

  final ThaiMirrorSectionCardState state;

  static const emptySummaryMessage = 'ยังไม่มีข้อมูลเพียงพอในส่วนนี้';

  @override
  State<ThaiMirrorSectionCard> createState() => _ThaiMirrorSectionCardState();
}

class _ThaiMirrorSectionCardState extends State<ThaiMirrorSectionCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.state.isExpandedDefault;
  }

  @override
  void didUpdateWidget(covariant ThaiMirrorSectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.id != widget.state.id) {
      _expanded = widget.state.isExpandedDefault;
    }
  }

  bool get _showsEvidenceCount =>
      widget.state.id != ThaiMirrorSectionId.strengths &&
      widget.state.evidenceCount > 0;

  Color _cardColor(ColorScheme scheme) {
    return switch (widget.state.id) {
      ThaiMirrorSectionId.growthAreas =>
        scheme.tertiaryContainer.withValues(alpha: 0.42),
      ThaiMirrorSectionId.growthPath =>
        scheme.primaryContainer.withValues(alpha: 0.35),
      _ => scheme.surfaceContainerHighest.withValues(alpha: 0.38),
    };
  }

  Color _summaryColor(ColorScheme scheme, bool hasSummary) {
    if (!hasSummary) {
      return scheme.onSurfaceVariant;
    }

    return switch (widget.state.id) {
      ThaiMirrorSectionId.growthAreas =>
        scheme.onTertiaryContainer.withValues(alpha: 0.92),
      ThaiMirrorSectionId.growthPath =>
        scheme.onPrimaryContainer.withValues(alpha: 0.92),
      _ => scheme.onSurface,
    };
  }

  Color _chipBackground(ColorScheme scheme) {
    return switch (widget.state.id) {
      ThaiMirrorSectionId.growthAreas =>
        scheme.surface.withValues(alpha: 0.72),
      ThaiMirrorSectionId.growthPath =>
        scheme.surface.withValues(alpha: 0.78),
      _ => scheme.surface.withValues(alpha: 0.65),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final summary = widget.state.summary?.trim();
    final hasSummary = summary != null && summary.isNotEmpty;
    final isGrowthPath = widget.state.id == ThaiMirrorSectionId.growthPath;

    return Material(
      color: _cardColor(scheme),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (value) => setState(() => _expanded = value),
        tilePadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.state.titleTh,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            if (isGrowthPath)
              Text(
                '→',
                style: TextStyle(
                  fontSize: 15,
                  color: scheme.primary.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        subtitle: _showsEvidenceCount
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${widget.state.evidenceCount} แหล่งอ้างอิง',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: muted.withValues(alpha: 0.9),
                  ),
                ),
              )
            : null,
        children: [
          Text(
            hasSummary ? summary : ThaiMirrorSectionCard.emptySummaryMessage,
            style: TextStyle(
              fontSize: 15,
              height: 1.62,
              color: _summaryColor(scheme, hasSummary),
            ),
          ),
          if (widget.state.themeChips.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.state.themeChips
                  .map(
                    (chip) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _chipBackground(scheme),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        chip,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
