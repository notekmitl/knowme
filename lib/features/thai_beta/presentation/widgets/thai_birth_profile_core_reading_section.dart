import 'package:flutter/material.dart';

import '../../application/core_reading/thai_birth_profile_core_reading.dart';

class ThaiBirthProfileCoreReadingSection extends StatelessWidget {
  const ThaiBirthProfileCoreReadingSection({
    super.key,
    required this.reading,
    this.showMethodology = true,
  });

  final ThaiBirthProfileCoreReading reading;
  final bool showMethodology;

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
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
              Text(reading.subtitle, style: const TextStyle(height: 1.55)),
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
              if (showMethodology) ...[
                const SizedBox(height: 20),
                _MethodologyExpansion(section: methodology),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ThaiBirthProfileMethodologySection extends StatelessWidget {
  const ThaiBirthProfileMethodologySection({super.key, required this.reading});

  final ThaiBirthProfileCoreReading reading;

  @override
  Widget build(BuildContext context) {
    final methodology = reading.sections.singleWhere(
      (section) => section.isMethodology,
    );
    return _MethodologyExpansion(section: methodology);
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
            if (section.factRows.isNotEmpty) ...[
              _ComputedFactTable(rows: section.factRows),
              if (section.paragraphs.isNotEmpty) const SizedBox(height: 14),
            ],
            for (var i = 0; i < section.paragraphs.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == section.paragraphs.length - 1 ? 0 : 10,
                ),
                child: Text(
                  section.paragraphs[i],
                  style: const TextStyle(height: 1.65),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ComputedFactTable extends StatelessWidget {
  const _ComputedFactTable({required this.rows});

  final List<ThaiBirthProfileCoreFactRow> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final headerStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: scheme.onSurface,
    );
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(height: 1.5);

    Widget cell(String text, TextStyle? style) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Text(text, style: style),
    );

    return Table(
      key: const Key('thai_birth_profile_chart_facts'),
      border: TableBorder.all(color: scheme.outlineVariant),
      columnWidths: const {
        0: FlexColumnWidth(1.15),
        1: FlexColumnWidth(1.45),
        2: FlexColumnWidth(2.4),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(color: scheme.surfaceContainerHighest),
          children: [
            cell('จุดสำคัญ', headerStyle),
            cell('ตำแหน่ง', headerStyle),
            cell('ความหมายหลัก', headerStyle),
          ],
        ),
        for (final row in rows)
          TableRow(
            children: [
              cell(row.label, bodyStyle?.copyWith(fontWeight: FontWeight.w700)),
              cell(row.value, bodyStyle),
              cell(row.meaning, bodyStyle),
            ],
          ),
      ],
    );
  }
}

class ThaiBirthProfileCoreOmissionsSection extends StatelessWidget {
  const ThaiBirthProfileCoreOmissionsSection({
    super.key,
    required this.omissions,
  });

  final List<ThaiBirthProfileCoreOmission> omissions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      key: const Key('thai_birth_profile_omissions'),
      container: true,
      label: ThaiBirthProfileCoreReadingCopy.omissionsTitle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ThaiBirthProfileCoreReadingCopy.omissionsTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'ระบบตัดหัวข้อต่อไปนี้ออกแทนการเติมคำทำนายที่ไม่มีข้อมูลรองรับ',
                style: TextStyle(height: 1.55),
              ),
              const SizedBox(height: 10),
              for (final omission in omissions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '• ${omission.publicText}',
                    style: const TextStyle(height: 1.55),
                  ),
                ),
            ],
          ),
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
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ข้อมูลวัน เวลา และสถานที่เกิด · วิธีนับวันทางโหราศาสตร์ไทย',
              style: TextStyle(fontWeight: FontWeight.w700, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          if (section.factRows.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ThaiBirthProfileCoreReadingCopy.chartStructureTitle,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            _ComputedFactTable(rows: section.factRows),
            if (section.paragraphs.isNotEmpty) const SizedBox(height: 14),
          ],
          for (var i = 0; i < section.paragraphs.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == section.paragraphs.length - 1 ? 0 : 10,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  section.paragraphs[i],
                  style: const TextStyle(height: 1.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
