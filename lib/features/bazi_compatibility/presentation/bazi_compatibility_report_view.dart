import 'package:flutter/material.dart';
import 'package:knowme/features/bazi_compatibility/domain/bazi_compatibility_report.dart';

class BaziCompatibilityReportView extends StatelessWidget {
  const BaziCompatibilityReportView({
    super.key,
    required this.report,
    this.onExport,
  });

  final BaziCompatibilityReport report;
  final Future<void> Function()? onExport;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            report.title,
            key: const Key('bazi-report-title'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(report.subtitle, style: const TextStyle(height: 1.45)),
          if (onExport != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                key: const Key('bazi-export-pdf'),
                onPressed: () => onExport!(),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('ส่งออก PDF'),
              ),
            ),
          ],
          const SizedBox(height: 8),
          for (final section in report.sections) ...[
            const SizedBox(height: 12),
            _SectionCard(section: section),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final BaziCompatibilityReportSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (section.intro case final intro?) ...[
              const SizedBox(height: 8),
              Text(intro, style: const TextStyle(height: 1.45)),
            ],
            for (final row in section.rows) ...[
              const SizedBox(height: 10),
              Text(
                row.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(row.value, style: const TextStyle(height: 1.4)),
            ],
            for (final note in section.notes) ...[
              const SizedBox(height: 10),
              Text('• $note', style: const TextStyle(height: 1.45)),
            ],
          ],
        ),
      ),
    );
  }
}
