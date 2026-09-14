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
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6E1D32), Color(0xFF3D245F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '八字 · FOUR PILLARS',
                  style: TextStyle(
                    color: Color(0xFFFFD88A),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  report.title,
                  key: const Key('bazi-report-title'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  report.subtitle,
                  style: const TextStyle(color: Color(0xFFF4EAF4), height: 1.5),
                ),
                if (onExport != null) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('bazi-export-pdf'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD88A),
                      foregroundColor: const Color(0xFF3D245F),
                    ),
                    onPressed: () => onExport!(),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('เก็บคำทำนายเป็น PDF'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final section in report.sections) ...[
            const SizedBox(height: 12),
            _SectionCard(
              section: section,
              highlighted:
                  section.title.contains('คำทำนายพื้นดวง') ||
                  section.title.contains('Natal tendencies'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, required this.highlighted});

  final BaziCompatibilityReportSection section;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: highlighted
          ? Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.42)
          : null,
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
            for (final paragraph in section.paragraphs) ...[
              const SizedBox(height: 10),
              Text(paragraph, style: const TextStyle(height: 1.5)),
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
