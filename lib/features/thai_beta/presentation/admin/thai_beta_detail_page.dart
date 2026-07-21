import 'package:flutter/material.dart';

import '../../domain/thai_beta_record.dart';

/// Read-only detail: Raw Input → Normalized Birth → Report Snapshot → Feedback.
class ThaiBetaDetailPage extends StatelessWidget {
  const ThaiBetaDetailPage({super.key, required this.record});

  final ThaiBetaRecord record;

  @override
  Widget build(BuildContext context) {
    final input = record.input;
    final n = record.normalizedBirth;
    final f = record.feedback;
    final v = record.engineVersions;

    final duration = record.durationSeconds == null
        ? '-'
        : '${record.durationSeconds} วินาที';

    return Scaffold(
      appBar: AppBar(title: Text(record.researchId ?? (input.fullName.isEmpty ? 'รายละเอียด' : input.fullName))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(title: 'Research Metadata', rows: [
                ('Research ID', record.researchId ?? '-'),
                ('Duration', duration),
                ('Report Hash (SHA-256)',
                    record.reportHash.isEmpty ? '-' : record.reportHash),
                ('Submitted At', _fmt(record.submittedAt)),
                ('Started At', _fmt(record.startedAt)),
              ]),
              _Section(title: 'Raw Input', rows: [
                ('ชื่อ', input.fullName),
                ('เพศ', input.gender ?? '-'),
                ('วันเกิด', n.rawBirthDate),
                ('เวลาเกิด', n.birthTime.isEmpty ? 'ไม่ระบุ' : n.birthTime),
                ('ไม่ทราบเวลาเกิด', input.birthTimeUnknown ? 'ใช่' : 'ไม่'),
                ('จังหวัด', n.province.isEmpty ? '-' : n.province),
              ]),
              _Section(title: 'Normalized Birth', rows: [
                ('Sunrise', n.sunriseAvailable ? n.sunrise : 'คำนวณไม่ได้'),
                ('Thai Astrological Date', n.thaiAstrologicalDate),
                ('Used Previous Day', n.usedPreviousDay ? 'ใช่' : 'ไม่'),
                ('Timezone',
                    '${n.timeZoneId} (UTC${n.utcOffsetHours >= 0 ? '+' : ''}${n.utcOffsetHours.toStringAsFixed(0)})'),
                ('Coordinates',
                    '${n.latitude.toStringAsFixed(4)}, ${n.longitude.toStringAsFixed(4)}'),
                ('Location source', n.locationSource),
                ('Reasons', n.reasons.join(', ')),
              ]),
              _Section(title: 'Engine Versions', rows: [
                ('Thai Foundation', v.thaiFoundationVersion),
                ('Birth Normalization', v.birthNormalizationVersion),
                ('Beta Schema', v.betaSchemaVersion),
              ]),
              _Section(title: 'Feedback', rows: [
                ('คะแนน', '${f.overallRating} / 5'),
                ('ตรงที่สุด', f.mostAccurate.isEmpty ? '-' : f.mostAccurate),
                ('ไม่ตรง', f.leastAccurate.isEmpty ? '-' : f.leastAccurate),
                ('อยากให้วิเคราะห์เพิ่ม',
                    f.wantMoreAnalysis.isEmpty ? '-' : f.wantMoreAnalysis),
                ('เหตุผลที่จะแนะนำให้เพื่อน',
                    f.recommendReason.isEmpty ? '-' : f.recommendReason),
                (
                  'คิดว่าใช้อะไรวิเคราะห์',
                  f.perceivedMethod.labelTh +
                      (f.perceivedMethodOther == null ||
                              f.perceivedMethodOther!.isEmpty
                          ? ''
                          : ' (${f.perceivedMethodOther})')
                ),
                ('ยินยอม', f.consentGiven ? 'ใช่' : 'ไม่'),
              ]),
              _ReportSnapshotSection(snapshot: record.reportSnapshot),
            ],
          ),
        ),
      ),
    );
  }
}

String _fmt(DateTime? d) {
  if (d == null) return '-';
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const Divider(),
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(label,
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(value),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportSnapshotSection extends StatelessWidget {
  const _ReportSnapshotSection({required this.snapshot});

  final Map<String, dynamic> snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final report = Map<String, dynamic>.from(
        snapshot['report'] as Map? ?? const {});
    final profile = Map<String, dynamic>.from(
        snapshot['profile'] as Map? ?? const {});

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thai Report Snapshot', style: theme.textTheme.titleMedium),
            const Divider(),
            if (report['heroHeadline'] != null) ...[
              Text('${report['heroHeadline']}',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
            ],
            if (report['heroSummary'] != null)
              Text('${report['heroSummary']}'),
            const SizedBox(height: 12),
            _KeyValueLines(map: profile, title: 'Profile'),
            const SizedBox(height: 8),
            _KeyValueLines(map: report, title: 'Report sections'),
          ],
        ),
      ),
    );
  }
}

class _KeyValueLines extends StatelessWidget {
  const _KeyValueLines({required this.map, required this.title});

  final Map<String, dynamic> map;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        for (final entry in map.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '${entry.key}: ${_format(entry.value)}',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  static String _format(dynamic value) {
    if (value is List) return value.join(', ');
    return '$value';
  }
}
