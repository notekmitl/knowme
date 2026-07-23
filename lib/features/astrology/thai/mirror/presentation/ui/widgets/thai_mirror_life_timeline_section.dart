import 'package:flutter/material.dart';

import '../../timeline/relevant_life_periods_selector.dart';
import '../../timeline/thai_mirror_life_timeline_state.dart';

/// V8 — Life Timeline section.
///
/// Premium "where are you in life" header card + a horizontal life-phase strip +
/// an expandable list of planetary periods, each interpreted in life language.
///
/// When [relevantPeriodsOnly] is true (Thai Beta V1.2.1), the list and strip
/// show only previous/current/next (max 3). Source [state.periods] is not
/// mutated — selection is a presentation projection.
///
/// When [lifeMapMode] is true (V1.2.3+), all eight periods are shown with
/// past/current/future labels; period details start collapsed. V1.2.6 shows
/// age-aware narrative sections (ไม่แสดงกราฟคะแนน / ดาวแทรก / ทักษาจรดิบ).
class ThaiMirrorLifeTimelineSection extends StatefulWidget {
  const ThaiMirrorLifeTimelineSection({
    super.key,
    required this.state,
    this.relevantPeriodsOnly = false,
    this.lifeMapMode = false,
  });

  final ThaiMirrorLifeTimelineState state;

  /// V1.2.1 — limit displayed periods/segments to relevant neighbours.
  final bool relevantPeriodsOnly;

  /// V1.2.3 — full eight-period Life Map presentation.
  final bool lifeMapMode;

  /// Copy shown beside period domain scores (presentation-only; scores unchanged).
  /// V1.2.2 — warmer wording; meaning unchanged (not accuracy / not a guarantee).
  static const scoreExplanation =
      'ตัวเลขนี้ช่วยจัดลำดับว่าเรื่องไหนเด่นพอให้อ่านก่อน '
      'ไม่ใช่เปอร์เซ็นต์ความแม่นยำหรือการรับประกันเหตุการณ์ในอนาคต';

  static const expandDetailsLabel = 'ดูรายละเอียดช่วงชีวิต';
  static const collapseDetailsLabel = 'ซ่อนรายละเอียดช่วงชีวิต';
  static const subPeriodsLabel = 'ดาวแทรกในช่วงนี้';
  static const annualTaksaLabel = 'ทักษาจรรายปีในช่วงนี้';
  static const mahabhutLabel = 'ตำแหน่งมหาภูต';

  @override
  State<ThaiMirrorLifeTimelineSection> createState() =>
      _ThaiMirrorLifeTimelineSectionState();
}

class _ThaiMirrorLifeTimelineSectionState
    extends State<ThaiMirrorLifeTimelineSection> {
  late int _expanded;

  // Distinct, calm accents keyed by planet index (0..7).
  static const _accents = <Color>[
    Color(0xFF5E81AC), // saturn-ish slate blue
    Color(0xFF8A6FB0), // jupiter violet
    Color(0xFFB07A9E), // rahu mauve
    Color(0xFFC98AA6), // venus rose
    Color(0xFFD9A05B), // sun amber
    Color(0xFF6FA8A0), // moon teal
    Color(0xFFC56B6B), // mars terracotta
    Color(0xFF7FA46B), // mercury sage
  ];

  Color _accent(int index) => _accents[index % _accents.length];

  List<ThaiMirrorLifePeriodState> get _displayPeriods {
    final all = widget.state.periods;
    if (widget.lifeMapMode || !widget.relevantPeriodsOnly) return all;
    return RelevantLifePeriodsSelector.select(
      periods: all,
      isCurrent: (p) => p.isCurrent,
      isPast: (p) => p.isPast,
    );
  }

  List<ThaiMirrorTimelineSegmentState> get _displaySegments {
    final all = widget.state.segments;
    if (widget.lifeMapMode || !widget.relevantPeriodsOnly) return all;
    return RelevantLifePeriodsSelector.select(
      periods: all,
      isCurrent: (p) => p.isCurrent,
      isPast: (p) => p.isPast,
    );
  }

  @override
  void initState() {
    super.initState();
    // V1.2.1 compact / V1.2.3 Life Map: details start collapsed.
    if (widget.relevantPeriodsOnly || widget.lifeMapMode) {
      _expanded = -1;
      return;
    }
    final periods = widget.state.periods;
    _expanded = periods.indexWhere((p) => p.isCurrent);
    if (_expanded < 0) _expanded = 0;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = widget.state;
    final isWide = MediaQuery.sizeOf(context).width >= 768;
    final periods = _displayPeriods;
    final segments = _displaySegments;
    final compact = widget.relevantPeriodsOnly || widget.lifeMapMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline_rounded, size: 20, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.sectionTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          compact
              ? 'โฟกัสช่วงที่เกี่ยวข้องกับตอนนี้ '
                    '— ก่อนหน้า ปัจจุบัน และถัดไป'
              : state.sectionIntro,
          style: TextStyle(
            fontSize: 14.5,
            height: 1.7,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        _CurrentStageCard(
          stage: state.currentStage,
          accent: _accent(state.currentStage.accentIndex),
        ),
        if (state.currentAnalysis != null) ...[
          const SizedBox(height: 14),
          _CurrentAnalysisCard(
            analysis: state.currentAnalysis!,
            accent: _accent(state.currentStage.accentIndex),
          ),
        ],
        const SizedBox(height: 18),
        _TimelineStrip(segments: segments, accentOf: _accent),
        // Compact mode: next-period preview duplicates the "next" card — skip it.
        if (!compact && state.futurePreview != null) ...[
          const SizedBox(height: 18),
          _FuturePreviewCard(
            preview: state.futurePreview!,
            accent: _accent(state.currentStage.accentIndex),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          widget.lifeMapMode
              ? 'แปดช่วงดาวเสวยอายุ'
              : compact
              ? 'ช่วงชีวิตที่เกี่ยวข้อง'
              : 'ทุกช่วงชีวิตของคุณ',
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (periods.isEmpty)
          Text(
            'ยังไม่มีข้อมูลช่วงชีวิตสำหรับแสดง',
            style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
          )
        else
          for (var i = 0; i < periods.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _PeriodCard(
              period: periods[i],
              accent: _accent(periods[i].accentIndex),
              expanded: _expanded == i,
              isWide: isWide,
              showCollapsedSummary: compact,
              lifeMapMode: widget.lifeMapMode,
              onTap: () => setState(() => _expanded = _expanded == i ? -1 : i),
            ),
          ],
      ],
    );
  }
}

class _CurrentStageCard extends StatelessWidget {
  const _CurrentStageCard({required this.stage, required this.accent});

  final ThaiMirrorCurrentStageState stage;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.20),
            accent.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.my_location_rounded, size: 16, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stage.eyebrow,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            stage.phaseName,
            style: TextStyle(
              fontSize: 26,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${stage.planetLine}  •  อายุ ${stage.ageLabel}',
            style: TextStyle(fontSize: 13.5, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _ProgressBar(progress: stage.progress, accent: accent),
          const SizedBox(height: 8),
          Text(
            'เหลืออีกประมาณ ${stage.yearsRemaining} ปีก่อนเปลี่ยนช่วง',
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            stage.intro,
            style: TextStyle(
              fontSize: 15.5,
              height: 1.8,
              color: scheme.onSurface.withValues(alpha: 0.92),
            ),
          ),
          if (stage.previousLabel.isNotEmpty || stage.nextLabel.isNotEmpty) ...[
            const SizedBox(height: 16),
            if (stage.previousLabel.isNotEmpty)
              _NeighbourChip(
                icon: Icons.arrow_back_rounded,
                label: stage.previousLabel,
                accent: accent,
              ),
            if (stage.nextLabel.isNotEmpty) ...[
              const SizedBox(height: 8),
              _NeighbourChip(
                icon: Icons.arrow_forward_rounded,
                label: stage.nextLabel,
                accent: accent,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// V9 — "why this period matters" + dominant influences.
class _CurrentAnalysisCard extends StatelessWidget {
  const _CurrentAnalysisCard({required this.analysis, required this.accent});

  final ThaiMirrorCurrentAnalysisState analysis;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, size: 16, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  analysis.title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            analysis.stageLabel,
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
          if (analysis.dominantInfluences.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              analysis.dominantInfluences,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.75,
                color: scheme.onSurface.withValues(alpha: 0.9),
              ),
            ),
          ],
          for (final reason in analysis.reasons) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: scheme.onSurface.withValues(alpha: 0.88),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// V9 — next-period preview (transition, opportunities, challenges).
class _FuturePreviewCard extends StatelessWidget {
  const _FuturePreviewCard({required this.preview, required this.accent});

  final ThaiMirrorFuturePreviewState preview;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.10),
            accent.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.east_rounded, size: 16, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  preview.title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            preview.intro,
            style: TextStyle(
              fontSize: 15,
              height: 1.75,
              color: scheme.onSurface.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 8),
          _PreviewLine(
            icon: Icons.swap_horiz_rounded,
            color: accent,
            text: preview.transitionLabel,
          ),
          if (preview.elementShiftLine.isNotEmpty) ...[
            const SizedBox(height: 6),
            _PreviewLine(
              icon: Icons.auto_awesome_rounded,
              color: accent,
              text: preview.elementShiftLine,
            ),
          ],
          if (preview.opportunitiesLine.isNotEmpty) ...[
            const SizedBox(height: 6),
            _PreviewLine(
              icon: Icons.check_circle_rounded,
              color: accent,
              text: preview.opportunitiesLine,
            ),
          ],
          if (preview.challengesLine.isNotEmpty) ...[
            const SizedBox(height: 6),
            _PreviewLine(
              icon: Icons.error_outline_rounded,
              color: scheme.tertiary,
              text: preview.challengesLine,
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.7,
              color: scheme.onSurface.withValues(alpha: 0.88),
            ),
          ),
        ),
      ],
    );
  }
}

class _NeighbourChip extends StatelessWidget {
  const _NeighbourChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 15, color: accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Container(height: 8, color: scheme.surfaceContainerHighest),
          FractionallySizedBox(
            widthFactor: progress.clamp(0.02, 1.0),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStrip extends StatelessWidget {
  const _TimelineStrip({required this.segments, required this.accentOf});

  final List<ThaiMirrorTimelineSegmentState> segments;
  final Color Function(int) accentOf;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final seg in segments)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 86,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: seg.isPast
                            ? accentOf(seg.accentIndex).withValues(alpha: 0.35)
                            : seg.isCurrent
                            ? accentOf(seg.accentIndex)
                            : scheme.surfaceContainerHighest,
                        border: seg.isCurrent
                            ? Border.all(
                                color: accentOf(seg.accentIndex),
                                width: 2,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      seg.ageLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: seg.isCurrent
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: seg.isCurrent
                            ? accentOf(seg.accentIndex)
                            : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      seg.phaseName,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.3,
                        color: seg.isCurrent
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.period,
    required this.accent,
    required this.expanded,
    required this.isWide,
    required this.onTap,
    this.showCollapsedSummary = false,
    this.lifeMapMode = false,
  });

  final ThaiMirrorLifePeriodState period;
  final Color accent;
  final bool expanded;
  final bool isWide;
  final VoidCallback onTap;
  final bool showCollapsedSummary;
  final bool lifeMapMode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bucket = period.timeBucketLabel.isNotEmpty
        ? period.timeBucketLabel
        : (period.isCurrent ? 'ปัจจุบัน' : (period.isPast ? 'อดีต' : 'อนาคต'));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: period.isCurrent
            ? accent.withValues(alpha: 0.07)
            : scheme.surface,
        border: Border.all(
          color: period.isCurrent
              ? accent.withValues(alpha: 0.5)
              : scheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        period.ageLabel.split('–').first,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  period.phaseName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                              if (lifeMapMode) ...[
                                const SizedBox(width: 8),
                                _Badge(label: bucket, accent: accent),
                              ] else if (period.isCurrent) ...[
                                const SizedBox(width: 8),
                                _Badge(label: 'ตอนนี้', accent: accent),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'อายุ ${period.ageLabel}  •  ${period.planetLine}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
                if (showCollapsedSummary && !expanded) ...[
                  const SizedBox(height: 10),
                  Text(
                    period.whatChanges.isNotEmpty
                        ? period.whatChanges
                        : period.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: scheme.onSurface.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ThaiMirrorLifeTimelineSection.expandDetailsLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ],
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  crossFadeState: expanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: _PeriodDetail(
                    period: period,
                    accent: accent,
                    showExpandChrome: showCollapsedSummary,
                  ),
                  secondChild: const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PeriodDetail extends StatelessWidget {
  const _PeriodDetail({
    required this.period,
    required this.accent,
    this.showExpandChrome = false,
  });

  final ThaiMirrorLifePeriodState period;
  final Color accent;
  final bool showExpandChrome;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget para(String text) => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.5,
          height: 1.8,
          color: scheme.onSurface.withValues(alpha: 0.9),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Divider(color: scheme.outlineVariant.withValues(alpha: 0.6), height: 1),
        if (showExpandChrome) ...[
          const SizedBox(height: 8),
          Text(
            ThaiMirrorLifeTimelineSection.collapseDetailsLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
        if (period.stageLabel.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            period.stageLabel,
            key: const Key('thai_life_map_stage_label'),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
        if (period.mahabhutPositionLabel.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${ThaiMirrorLifeTimelineSection.mahabhutLabel}: '
            '${period.mahabhutPositionLabel}',
            key: const Key('thai_life_map_mahabhut_position'),
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        _SectionTitle(text: 'สรุปช่วงนี้', accent: accent),
        para(period.summary),
        if (period.whatChanges.isNotEmpty) ...[
          _SectionTitle(text: 'เรื่องที่เด่น', accent: accent),
          para(period.whatChanges),
        ],
        if (period.harder.isNotEmpty) ...[
          _SectionTitle(text: 'สิ่งที่ควรระวัง', accent: accent),
          para(period.harder),
        ],
        if ((period.advice.isNotEmpty ? period.advice : period.easier)
            .isNotEmpty) ...[
          _SectionTitle(
            text:
                period.stageLabel.contains('เด็ก') ||
                    period.stageLabel.contains('เรียน')
                ? 'แนวทางส่งเสริมในวัยนี้'
                : 'คำแนะนำสำหรับช่วงนี้',
            accent: accent,
          ),
          para(period.advice.isNotEmpty ? period.advice : period.easier),
        ],
        if (period.comparison.isNotEmpty) ...[
          _SectionTitle(text: 'ความเปลี่ยนแปลงจากช่วงก่อน', accent: accent),
          para(period.comparison),
        ],
        if (period.evidenceLine.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              period.evidenceLine,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                fontStyle: FontStyle.italic,
                color: scheme.onSurface.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
        // V1.2.6 — raw ดาวแทรก / ทักษาจร / score charts stay off user-facing UI.
        // Engine still computes them for audit / invited QA paths.
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: accent,
        ),
      ),
    );
  }
}
