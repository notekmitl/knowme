import 'package:flutter/material.dart';

import '../../application/core_reading/thai_birth_profile_core_reading.dart';

class ThaiBirthProfileCoreReadingSection extends StatelessWidget {
  const ThaiBirthProfileCoreReadingSection({super.key, required this.reading});

  final ThaiBirthProfileCoreReading reading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final narrativeSections = reading.sections
        .where((section) => !section.isMethodology)
        .toList(growable: false);
    final methodology = reading.sections.singleWhere(
      (section) => section.isMethodology,
    );

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
              const SizedBox(height: 28),
              for (var i = 0; i < narrativeSections.length; i++) ...[
                _NarrativeSection(
                  key: ValueKey('thai_birth_profile_section_$i'),
                  section: narrativeSections[i],
                  isLead: i == 0,
                ),
                if (i != narrativeSections.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
              ],
              const SizedBox(height: 20),
              _MethodologyExpansion(section: methodology),
            ],
          ),
        ),
      ),
    );
  }
}

class _NarrativeSection extends StatelessWidget {
  const _NarrativeSection({
    super.key,
    required this.section,
    required this.isLead,
  });

  final ThaiBirthProfileCoreSection section;
  final bool isLead;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: isLead
          ? BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: .28),
              borderRadius: BorderRadius.circular(18),
            )
          : const BoxDecoration(),
      child: Padding(
        padding: isLead ? const EdgeInsets.all(16) : EdgeInsets.zero,
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
            for (var i = 0; i < section.paragraphs.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == section.paragraphs.length - 1 ? 0 : 10,
                ),
                child: Text(section.paragraphs[i]),
              ),
          ],
        ),
      ),
    );
  }
}

class _MethodologyExpansion extends StatelessWidget {
  const _MethodologyExpansion({required this.section});

  final ThaiBirthProfileCoreSection section;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ExpansionTile(
        key: const Key('thai_birth_profile_methodology'),
        initiallyExpanded: false,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          section.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (var i = 0; i < section.paragraphs.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == section.paragraphs.length - 1 ? 0 : 10,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(section.paragraphs[i]),
              ),
            ),
        ],
      ),
    );
  }
}
