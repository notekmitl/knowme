import 'package:flutter/material.dart';

import '../../prediction/prediction_section_model.dart';

/// V10.5 — Future Prediction section (the `PredictionWidget`).
///
/// Article-style, < 2-minute read. Sits between the Life Timeline and the
/// Signature Insight. Each horizon (ช่วงนี้ · 12 เดือนข้างหน้า · ช่วงชีวิตถัดไป)
/// is a scannable card: a one-line summary, the top opportunity, the top
/// caution and a qualitative confidence meter. Reasoning and the technical
/// planet evidence are tucked behind an expandable detail so the headline stays
/// jargon-free (no planet names, no astrology terminology up front).
class ThaiMirrorFuturePredictionSection extends StatelessWidget {
  const ThaiMirrorFuturePredictionSection({
    super.key,
    required this.state,
    this.detailedNarrativeMode = false,
  });

  final PredictionSectionModel state;

  /// Thai Beta V3: foreground the future and show all four requested domains.
  /// Defaults off so the standalone Thai Mirror presentation is unchanged.
  final bool detailedNarrativeMode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_graph_rounded,
              size: detailedNarrativeMode ? 24 : 20,
              color: scheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.sectionTitle,
                style: TextStyle(
                  fontSize: detailedNarrativeMode ? 24 : 20,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          detailedNarrativeMode
              ? state.detailedSectionIntro
              : state.sectionIntro,
          style: TextStyle(
            fontSize: 14.5,
            height: 1.7,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < state.windows.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _WindowCard(
            card: state.windows[i],
            highlighted: detailedNarrativeMode ? i == 1 : i == 0,
            detailedNarrativeMode: detailedNarrativeMode,
          ),
        ],
        if (state.transitionLine.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.trending_flat_rounded,
                  size: 16,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.transitionLine,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.7,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
        if ((detailedNarrativeMode
                ? state.detailedClosingAdvice
                : state.closingAdvice)
            .isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.favorite_rounded, size: 16, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    detailedNarrativeMode
                        ? state.detailedClosingAdvice
                        : state.closingAdvice,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.75,
                      color: scheme.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _WindowCard extends StatefulWidget {
  const _WindowCard({
    required this.card,
    required this.highlighted,
    required this.detailedNarrativeMode,
  });

  final PredictionWindowCardModel card;
  final bool highlighted;
  final bool detailedNarrativeMode;

  @override
  State<_WindowCard> createState() => _WindowCardState();
}

class _WindowCardState extends State<_WindowCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.detailedNarrativeMode && widget.highlighted;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = widget.card;
    final accent = scheme.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: widget.highlighted
            ? accent.withValues(alpha: 0.06)
            : scheme.surface,
        border: Border.all(
          color: widget.highlighted
              ? accent.withValues(alpha: 0.40)
              : scheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _WindowBadge(label: card.windowLabel, accent: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  card.timeframeLabel,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            card.summary,
            style: TextStyle(
              fontSize: 15.5,
              height: 1.75,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 12),
          _Line(
            icon: Icons.check_circle_rounded,
            color: accent,
            text: card.topOpportunity,
          ),
          const SizedBox(height: 8),
          _Line(
            icon: Icons.error_outline_rounded,
            color: scheme.tertiary,
            text: card.topRisk,
          ),
          if (widget.detailedNarrativeMode && card.domains.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'คำทำนายแยกตามด้านชีวิต',
              key: Key('thai_beta_prediction_domains_${card.windowLabel}'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < card.domains.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _DomainForecast(domain: card.domains[i], accent: accent),
            ],
          ],
          const SizedBox(height: 14),
          _ConfidenceMeter(
            label: card.confidenceLabel,
            level: card.confidenceLevel,
            accent: accent,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: accent,
              ),
              icon: Icon(
                _expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 18,
              ),
              label: Text(
                _expanded ? 'ย่อรายละเอียด' : 'ทำไมถึงเป็นแบบนี้',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _Detail(card: card, accent: accent),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _DomainForecast extends StatelessWidget {
  const _DomainForecast({required this.domain, required this.accent});

  final PredictionDomainModel domain;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            domain.title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            domain.body,
            style: TextStyle(
              fontSize: 14,
              height: 1.72,
              color: scheme.onSurface.withValues(alpha: 0.92),
            ),
          ),
          if (domain.caution.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              domain.caution,
              style: TextStyle(
                fontSize: 13,
                height: 1.65,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.card, required this.accent});

  final PredictionWindowCardModel card;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Divider(color: scheme.outlineVariant.withValues(alpha: 0.6), height: 1),
        const SizedBox(height: 10),
        _DetailRow(label: 'ทำไม', body: card.why),
        _DetailRow(label: 'ทำไมตอนนี้', body: card.whyNow),
        _DetailRow(label: 'สิ่งที่ควรจับตา', body: card.whatToWatch),
        if (card.evidenceDetail.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              card.evidenceDetail,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.7,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: scheme.onSurface.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowBadge extends StatelessWidget {
  const _WindowBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: accent,
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.color, required this.text});

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
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: scheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfidenceMeter extends StatelessWidget {
  const _ConfidenceMeter({
    required this.label,
    required this.level,
    required this.accent,
  });

  final String label;
  final int level;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ความชัดของแนวโน้ม',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Container(
                width: 18,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i < level ? accent : scheme.surfaceContainerHighest,
                ),
              ),
            ],
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
