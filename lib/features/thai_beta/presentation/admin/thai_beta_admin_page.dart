import 'package:flutter/material.dart';

import '../../application/thai_beta_dashboard.dart';
import '../../application/thai_beta_store.dart';
import '../../domain/thai_beta_record.dart';
import 'thai_beta_detail_page.dart';

/// `/internal/thai-beta` — internal review tool for beta submissions.
class ThaiBetaAdminPage extends StatefulWidget {
  const ThaiBetaAdminPage({super.key, this.store});

  final ThaiBetaStore? store;

  @override
  State<ThaiBetaAdminPage> createState() => _ThaiBetaAdminPageState();
}

class _ThaiBetaAdminPageState extends State<ThaiBetaAdminPage> {
  late final ThaiBetaStore _store = widget.store ?? ThaiBetaStore();
  late Future<List<ThaiBetaRecord>> _future;

  int? _ratingFilter;
  String? _versionFilter;
  final _dateQuery = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = _store.recent();
  }

  @override
  void dispose() {
    _dateQuery.dispose();
    super.dispose();
  }

  List<ThaiBetaRecord> _applyFilters(List<ThaiBetaRecord> all) {
    final q = _dateQuery.text.trim();
    return all.where((r) {
      if (_ratingFilter != null && r.rating != _ratingFilter) return false;
      if (_versionFilter != null && r.thaiFoundationVersion != _versionFilter) {
        return false;
      }
      if (q.isNotEmpty && !r.thaiAstrologicalDate.contains(q)) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thai Astrology Research — Internal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _future = _store.recent()),
          ),
        ],
      ),
      body: FutureBuilder<List<ThaiBetaRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data ?? const <ThaiBetaRecord>[];
          if (all.isEmpty) {
            return const Center(child: Text('ยังไม่มีข้อมูล feedback'));
          }

          final dashboard = ThaiBetaDashboard.fromRecords(all);
          final versions = {for (final r in all) r.thaiFoundationVersion}.toList()
            ..sort();
          final filtered = _applyFilters(all);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _DashboardCard(dashboard: dashboard),
                  const SizedBox(height: 16),
                  _Filters(
                    rating: _ratingFilter,
                    version: _versionFilter,
                    versions: versions,
                    dateController: _dateQuery,
                    onRating: (v) => setState(() => _ratingFilter = v),
                    onVersion: (v) => setState(() => _versionFilter = v),
                    onDateChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Text('ผลลัพธ์ ${filtered.length} รายการ',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  for (final record in filtered)
                    _RecordTile(
                      record: record,
                      onOpen: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ThaiBetaDetailPage(record: record),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.dashboard});

  final ThaiBetaDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxBar = dashboard.ratingDistribution.values
        .fold<int>(1, (m, v) => v > m ? v : m);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ภาพรวม', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Metric(label: 'Feedback ทั้งหมด', value: '${dashboard.total}'),
                _Metric(
                  label: 'คะแนนเฉลี่ย',
                  value: dashboard.averageRating.toStringAsFixed(2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('การกระจายคะแนน', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (var star = 5; star >= 1; star--)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text('$star★')),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final count =
                              dashboard.ratingDistribution[star] ?? 0;
                          return Stack(
                            children: [
                              Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              Container(
                                height: 14,
                                width: c.maxWidth * (count / maxBar),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 28,
                      child: Text('${dashboard.ratingDistribution[star] ?? 0}',
                          textAlign: TextAlign.end),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _ThemeList(
              title: 'หัวข้อที่ตรงที่สุด',
              themes: dashboard.mostAccurateTopics,
            ),
            _ThemeList(
              title: 'คำติที่พบบ่อย',
              themes: dashboard.mostCommonComplaints,
            ),
            _ThemeList(
              title: 'สิ่งที่อยากให้วิเคราะห์เพิ่ม',
              themes: dashboard.mostRequestedImprovements,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeList extends StatelessWidget {
  const _ThemeList({required this.title, required this.themes});

  final String title;
  final List<ThaiBetaTextTheme> themes;

  @override
  Widget build(BuildContext context) {
    if (themes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in themes)
                Chip(
                  label: Text('${t.term} (${t.count})'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: theme.textTheme.headlineMedium),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.rating,
    required this.version,
    required this.versions,
    required this.dateController,
    required this.onRating,
    required this.onVersion,
    required this.onDateChanged,
  });

  final int? rating;
  final String? version;
  final List<String> versions;
  final TextEditingController dateController;
  final ValueChanged<int?> onRating;
  final ValueChanged<String?> onVersion;
  final VoidCallback onDateChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<int?>(
            initialValue: rating,
            decoration: const InputDecoration(
              labelText: 'คะแนน',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('ทั้งหมด')),
              for (var i = 5; i >= 1; i--)
                DropdownMenuItem(value: i, child: Text('$i ★')),
            ],
            onChanged: onRating,
          ),
        ),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<String?>(
            initialValue: version,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Engine version',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('ทั้งหมด')),
              for (final v in versions)
                DropdownMenuItem(value: v, child: Text(v)),
            ],
            onChanged: onVersion,
          ),
        ),
        SizedBox(
          width: 200,
          child: TextField(
            controller: dateController,
            decoration: const InputDecoration(
              labelText: 'วันโหราศาสตร์ไทย (yyyy-mm-dd)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => onDateChanged(),
          ),
        ),
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.onOpen});

  final ThaiBetaRecord record;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final created = record.createdAt;
    final createdLabel = created == null
        ? ''
        : '${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')} ${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';
    final durationLabel = record.durationSeconds == null
        ? ''
        : ' · ${record.durationSeconds}s';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onOpen,
        leading: CircleAvatar(child: Text('${record.rating}')),
        title: Text(
          '${record.researchId ?? '—'} · '
          '${record.input.fullName.isEmpty ? '(ไม่มีชื่อ)' : record.input.fullName}',
        ),
        subtitle: Text(
          'วันไทย ${record.thaiAstrologicalDate} · ${record.thaiFoundationVersion}'
          '$durationLabel${createdLabel.isEmpty ? '' : ' · $createdLabel'}',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
