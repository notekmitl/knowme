import 'package:flutter/material.dart';

import '../../models/thai_mirror_consumer_view_state.dart';
import 'thai_mirror_rich_text.dart';

/// Long-form narrative life report (V3 content + V4 polish + V5 storytelling).
///
/// Reads as one continuous article: each life area is connected to the next by
/// a bridging line, and within a section the copy follows an emotional rhythm —
/// quote, reflection, discovery, plain-language reasoning, a concrete scene and
/// a reflective question — rather than a uniform wall of text.
class ThaiMirrorNarrativeReportSection extends StatelessWidget {
  const ThaiMirrorNarrativeReportSection({
    super.key,
    required this.sections,
  });

  static const titleTh = 'เรื่องราวของคุณ ทีละด้าน';
  static const subtitleTh =
      'อ่านต่อเนื่องไปเรื่อย ๆ แต่ละด้านเชื่อมโยงกัน เหมือนเล่าเรื่องของคุณคนเดียว';

  final List<ThaiMirrorNarrativeSectionState> sections;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleTh,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.3,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitleTh,
          style: TextStyle(
            fontSize: 14,
            height: 1.55,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < sections.length; i++) ...[
          if (sections[i].hasTransition)
            _Transition(text: sections[i].transitionIn, accent: sections[i].accent)
          else
            const SizedBox(height: 28),
          _NarrativeCard(section: sections[i]),
        ],
      ],
    );
  }
}

/// A bridging line that connects the previous section into the next.
class _Transition extends StatelessWidget {
  const _Transition({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 30, 4, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 22,
              height: 2,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                fontStyle: FontStyle.italic,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NarrativeCard extends StatelessWidget {
  const _NarrativeCard({required this.section});

  final ThaiMirrorNarrativeSectionState section;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = section;
    final accent = s.accent;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(s.icon, size: 24, color: accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.pullQuote.isNotEmpty) ...[
                  _PullQuote(text: s.pullQuote, accent: accent),
                  const SizedBox(height: 18),
                ],
                ThaiMirrorRichText(
                  s.overview,
                  emphasisColor: accent,
                  baseStyle: TextStyle(
                    fontSize: 15.5,
                    height: 1.72,
                    color: scheme.onSurface.withValues(alpha: 0.9),
                  ),
                ),
                if (s.hasTension) ...[
                  const SizedBox(height: 18),
                  _TensionCallout(text: s.tension, accent: accent),
                ],
                if (s.hasDiscovery) ...[
                  const SizedBox(height: 18),
                  _DiscoveryCallout(text: s.discovery, accent: accent),
                ],
                if (s.hasReasoning) ...[
                  const SizedBox(height: 20),
                  _ReasoningBlock(
                    title: s.reasoningTitle,
                    signals: s.reasoningSignals,
                    accent: accent,
                  ),
                ],
                if (s.whyItAppears.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ThaiMirrorRichText(
                    s.whyItAppears,
                    emphasisColor: accent,
                    baseStyle: TextStyle(
                      fontSize: 14.5,
                      height: 1.68,
                      color: scheme.onSurface.withValues(alpha: 0.78),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _block(
                  context,
                  accent: accent,
                  label: 'ลองนำไปใช้',
                  body: s.advice,
                ),
                if (s.example.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _ExampleScene(text: s.example, accent: accent),
                ],
                if (s.hasReflectionQuestion) ...[
                  const SizedBox(height: 18),
                  _ReflectionQuestion(text: s.reflectionQuestion, accent: accent),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _block(
    BuildContext context, {
    required Color accent,
    required String label,
    required String body,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ThaiMirrorRichText(
          body,
          emphasisColor: accent,
          baseStyle: TextStyle(
            fontSize: 14.5,
            height: 1.68,
            color: scheme.onSurface.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _PullQuote extends StatelessWidget {
  const _PullQuote({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: accent.withValues(alpha: 0.08),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(color: accent, child: const SizedBox(width: 4)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
                  child: Text(
                    '“$text”',
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An internal-conflict observation — the "two sides in you" pause.
class _TensionCallout extends StatelessWidget {
  const _TensionCallout({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows_rounded, size: 16, color: accent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'สองด้านในตัวคุณ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              height: 1.66,
              fontStyle: FontStyle.italic,
              color: scheme.onSurface.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

/// A "you may never have noticed..." discovery moment.
class _DiscoveryCallout extends StatelessWidget {
  const _DiscoveryCallout({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 18, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: 0.88),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plain-language "why this feels true" — header + signal pills, no jargon.
class _ReasoningBlock extends StatelessWidget {
  const _ReasoningBlock({
    required this.title,
    required this.signals,
    required this.accent,
  });

  final String title;
  final List<String> signals;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            height: 1.5,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < signals.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_circle_rounded,
                          size: 16, color: accent),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        signals[i],
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface.withValues(alpha: 0.82),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A concrete, scene-based example rendered as a quiet "real moment" card.
class _ExampleScene extends StatelessWidget {
  const _ExampleScene({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_outlined, size: 15, color: accent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'ภาพที่มักเกิดขึ้นจริง',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.62,
              fontStyle: FontStyle.italic,
              color: scheme.onSurface.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

/// A gentle reflective question to close the section.
class _ReflectionQuestion extends StatelessWidget {
  const _ReflectionQuestion({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            '?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}
