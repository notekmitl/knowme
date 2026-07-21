import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'thai_mirror_population_analyzer.dart';
import 'thai_mirror_population_report.dart';

/// Internal screen for running 120-profile Population QA.
class ThaiMirrorPopulationQaScreen extends StatefulWidget {
  const ThaiMirrorPopulationQaScreen({super.key});

  @override
  State<ThaiMirrorPopulationQaScreen> createState() =>
      _ThaiMirrorPopulationQaScreenState();
}

class _ThaiMirrorPopulationQaScreenState
    extends State<ThaiMirrorPopulationQaScreen> {
  late Future<ThaiMirrorPopulationReport> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = Future.microtask(ThaiMirrorPopulationAnalyzer.analyze);
  }

  void _rerun() {
    setState(() {
      _reportFuture = Future.microtask(ThaiMirrorPopulationAnalyzer.analyze);
    });
  }

  Future<void> _copyReport(ThaiMirrorPopulationReport report) async {
    await Clipboard.setData(ClipboardData(text: report.toMarkdown()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('คัดลอกรายงานแล้ว')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thai Mirror Population QA'),
        actions: [
          IconButton(
            tooltip: 'รันใหม่',
            onPressed: _rerun,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<ThaiMirrorPopulationReport>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('กำลังรัน pipeline 120 profiles...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final report = snapshot.data!;
          return Column(
            children: [
              _SummaryHeader(report: report),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    report.toMarkdown(),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<ThaiMirrorPopulationReport>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _copyReport(snapshot.data!),
            icon: const Icon(Icons.copy),
            label: const Text('Copy Report'),
          );
        },
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.report});

  final ThaiMirrorPopulationReport report;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final biasColor =
        report.hasAbnormalConcentration ? scheme.error : scheme.primary;

    return Material(
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            _StatChip(
              label: 'Profiles',
              value: '${report.profileCount}',
            ),
            const SizedBox(width: 8),
            _StatChip(
              label: 'Success',
              value: '${report.successCount}',
            ),
            const SizedBox(width: 8),
            _StatChip(
              label: 'No time',
              value: '${(report.noBirthTimeRatio * 100).toStringAsFixed(0)}%',
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: biasColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: biasColor),
              ),
              child: Text(
                report.hasAbnormalConcentration
                    ? 'Bias detected'
                    : 'No abnormal bias',
                style: TextStyle(
                  color: biasColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
