import 'package:flutter/material.dart';

import '../../application/core_reading/thai_birth_profile_core_reading.dart';

class ThaiBirthProfileCoreReadingSection extends StatelessWidget {
  const ThaiBirthProfileCoreReadingSection({super.key, required this.reading});

  final ThaiBirthProfileCoreReading reading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      key: const Key('thai_birth_profile_core_reading'),
      container: true,
      label: reading.title,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reading.title,
                key: const Key('thai_birth_profile_title'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(reading.subtitle),
              const SizedBox(height: 24),
              for (var i = 0; i < reading.sections.length; i++) ...[
                _CoreReadingCard(
                  key: ValueKey('thai_birth_profile_section_$i'),
                  section: reading.sections[i],
                ),
                if (i != reading.sections.length - 1)
                  const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CoreReadingCard extends StatelessWidget {
  const _CoreReadingCard({super.key, required this.section});

  final ThaiBirthProfileCoreSection section;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (section.found.isNotEmpty)
              _LabeledParagraphs(
                label: 'หลักจากพื้นดวง',
                values: section.found,
              ),
            if (section.reading.isNotEmpty)
              _LabeledParagraphs(
                label: 'คำอ่านพื้นดวง',
                values: section.reading,
              ),
            if (section.strength.isNotEmpty)
              _LabeledParagraphs(label: 'จุดแข็ง', values: [section.strength]),
            if (section.caution.isNotEmpty)
              _LabeledParagraphs(
                label: 'สิ่งที่ควรระวัง',
                values: [section.caution],
              ),
            if (section.action.isNotEmpty)
              _LabeledParagraphs(
                label: 'แนวทางใช้ประโยชน์',
                values: [section.action],
              ),
          ],
        ),
      ),
    );
  }
}

class _LabeledParagraphs extends StatelessWidget {
  const _LabeledParagraphs({required this.label, required this.values});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          for (final value in values)
            if (value.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(value),
              ),
        ],
      ),
    );
  }
}
