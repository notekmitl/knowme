import 'package:flutter/material.dart';

import '../mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import '../mirror/runtime/thai_mirror_pipeline.dart';
import '../mirror/runtime/thai_mirror_pipeline_result.dart';
import 'thai_mirror_qa_profile.dart';
import 'thai_mirror_qa_profiles.dart';
import 'thai_mirror_qa_report.dart';

/// Internal QA screen for batch-inspecting Thai Mirror pipeline output.
class ThaiMirrorQaScreen extends StatefulWidget {
  const ThaiMirrorQaScreen({super.key});

  @override
  State<ThaiMirrorQaScreen> createState() => _ThaiMirrorQaScreenState();
}

class _ThaiMirrorQaScreenState extends State<ThaiMirrorQaScreen> {
  int _currentIndex = 0;
  late Future<ThaiMirrorPipelineResult> _pipelineFuture;
  List<ThaiMirrorQaReport> _reports = const [];
  bool _dashboardLoading = true;

  ThaiMirrorQaProfile get _currentProfile => ThaiMirrorQaProfiles.all[_currentIndex];

  @override
  void initState() {
    super.initState();
    _pipelineFuture = _runPipeline(_currentProfile);
    _loadDashboard();
  }

  Future<ThaiMirrorPipelineResult> _runPipeline(ThaiMirrorQaProfile profile) {
    return Future.microtask(
      () => ThaiMirrorPipeline.generate(profile.birthData),
    );
  }

  Future<void> _loadDashboard() async {
    final reports = <ThaiMirrorQaReport>[];
    for (final profile in ThaiMirrorQaProfiles.all) {
      reports.add(ThaiMirrorQaReport.generate(profile));
    }

    if (!mounted) return;
    setState(() {
      _reports = reports;
      _dashboardLoading = false;
    });
  }

  void _selectIndex(int index) {
    setState(() {
      _currentIndex = index;
      _pipelineFuture = _runPipeline(_currentProfile);
    });
  }

  void _goNext() {
    _selectIndex(ThaiMirrorQaProfiles.nextIndex(_currentIndex));
  }

  void _goPrevious() {
    _selectIndex(ThaiMirrorQaProfiles.previousIndex(_currentIndex));
  }

  int _countFor(ThaiMirrorQaStatus status) {
    return _reports.where((report) => report.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final profile = _currentProfile;
    final currentReport = _reports.isEmpty
        ? null
        : _reports.firstWhere(
            (report) => report.profileId == profile.id,
            orElse: () => _reports[_currentIndex],
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thai Mirror QA'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DashboardBar(
            loading: _dashboardLoading,
            passCount: _countFor(ThaiMirrorQaStatus.pass),
            warningCount: _countFor(ThaiMirrorQaStatus.warning),
            failCount: _countFor(ThaiMirrorQaStatus.fail),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.id} · ${profile.birthDataSummary}',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (profile.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.notes,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
                    ),
                  ),
                ],
                if (currentReport != null) ...[
                  const SizedBox(height: 8),
                  _ReportChip(report: currentReport),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: ThaiMirrorQaProfiles.all.length < 2 ? null : _goPrevious,
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: ThaiMirrorQaProfiles.all.length < 2 ? null : _goNext,
                  child: const Text('Next'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: profile.id,
                      items: ThaiMirrorQaProfiles.all
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text('${item.id} · ${item.label}'),
                            ),
                          )
                          .toList(),
                      onChanged: (id) {
                        if (id == null) return;
                        _selectIndex(ThaiMirrorQaProfiles.indexOfId(id));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<ThaiMirrorPipelineResult>(
              future: _pipelineFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final result = snapshot.data;
                if (result == null || result.isFailure) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        result?.errorMessage ?? 'Pipeline returned no result.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ThaiMirrorResultPage(viewState: result.viewState!);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBar extends StatelessWidget {
  const _DashboardBar({
    required this.loading,
    required this.passCount,
    required this.warningCount,
    required this.failCount,
  });

  final bool loading;
  final int passCount;
  final int warningCount;
  final int failCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: loading
            ? Text(
                'Running QA validation across ${ThaiMirrorQaProfiles.all.length} profiles…',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              )
            : Row(
                children: [
                  _StatusPill(label: 'Pass', count: passCount, color: scheme.primary),
                  const SizedBox(width: 8),
                  _StatusPill(
                    label: 'Warning',
                    count: warningCount,
                    color: scheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(
                    label: 'Fail',
                    count: failCount,
                    color: scheme.error.withValues(alpha: 0.85),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ReportChip extends StatelessWidget {
  const _ReportChip({required this.report});

  final ThaiMirrorQaReport report;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusLabel = switch (report.status) {
      ThaiMirrorQaStatus.pass => 'PASS',
      ThaiMirrorQaStatus.warning => 'WARNING',
      ThaiMirrorQaStatus.fail => 'FAIL',
    };

    return Text(
      '$statusLabel · themes ${report.topThemes.length} · sections ${report.sectionCount} · evidence ${report.evidenceCount} · warnings ${report.warningCount}',
      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
    );
  }
}
