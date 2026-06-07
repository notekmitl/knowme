import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:provider/provider.dart';

import '../../providers/bazi_provider.dart';
import '../../providers/locale_provider.dart';
import 'bazi_result_copy.dart';

class BaziResultPage extends StatefulWidget {
  const BaziResultPage({super.key, this.userId});

  /// When set (e.g. tests), skips [FirebaseAuth] lookup.
  final String? userId;

  @override
  State<BaziResultPage> createState() => _BaziResultPageState();
}

class _BaziResultPageState extends State<BaziResultPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final uid = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.isEmpty) return;
      context.read<BaziProvider>().loadChart(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleProvider>().locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(BaziResultCopy.pageTitle(lang)),
      ),
      body: Consumer<BaziProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _messageBody(
              title: BaziResultCopy.errorTitle(lang),
              body: provider.error!,
            );
          }

          final chart = provider.chart;
          if (chart == null) {
            return _messageBody(
              title: BaziResultCopy.pageTitle(lang),
              body: BaziResultCopy.emptyMessage(lang),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _heroSection(chart, lang),
                const SizedBox(height: 20),
                _sectionCard(
                  title: BaziResultCopy.bigThreeTitle(lang),
                  child: _bigThree(chart, lang),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  title: BaziResultCopy.fourPillarsTitle(lang),
                  child: _fourPillars(chart, lang),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  title: BaziResultCopy.elementBalanceTitle(lang),
                  child: _elementBalance(chart, lang),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  title: BaziResultCopy.metadataTitle(lang),
                  child: _metadata(chart),
                ),
                const SizedBox(height: 20),
                Text(
                  BaziResultCopy.disclosure(lang),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _messageBody({required String title, required String body}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroSection(BaziChartModel chart, String lang) {
    final dm = chart.dayMaster;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              BaziResultCopy.heroSubtitle(lang),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              BaziResultCopy.dayMasterTitle(dm, lang),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              dm.pillarLabel,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dm.stemRoman,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bigThree(BaziChartModel chart, String lang) {
    return Column(
      children: [
        _infoRow(
          BaziResultCopy.dayMasterLabel(lang),
          BaziResultCopy.dayMasterTitle(chart.dayMaster, lang),
        ),
        const SizedBox(height: 12),
        _infoRow(
          BaziResultCopy.yearAnimalLabel(lang),
          '${chart.yearAnimal.en} (${chart.yearAnimal.zh})',
        ),
        const SizedBox(height: 12),
        _infoRow(
          BaziResultCopy.dominantElementLabel(lang),
          chart.dominantElement == null
              ? '—'
              : BaziResultCopy.elementLabel(chart.dominantElement!, lang),
        ),
      ],
    );
  }

  Widget _fourPillars(BaziChartModel chart, String lang) {
    final items = [
      ('year', chart.pillars.year),
      ('month', chart.pillars.month),
      ('day', chart.pillars.day),
      ('hour', chart.pillars.hour),
    ];

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _pillarRow(
            BaziResultCopy.pillarRole(items[i].$1, lang),
            items[i].$2,
            lang,
          ),
        ],
      ],
    );
  }

  Widget _pillarRow(String role, BaziPillar pillar, String lang) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            role,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pillar.pillarLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${BaziResultCopy.elementLabel(pillar.stemElement, lang)} / '
                '${BaziResultCopy.elementLabel(pillar.branchElement, lang)}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _elementBalance(BaziChartModel chart, String lang) {
    final balance = chart.elementBalance;
    final maxCount = [
      balance.wood,
      balance.fire,
      balance.earth,
      balance.metal,
      balance.water,
    ].fold<int>(0, (a, b) => a > b ? a : b);

    final entries = [
      ('wood', balance.wood),
      ('fire', balance.fire),
      ('earth', balance.earth),
      ('metal', balance.metal),
      ('water', balance.water),
    ];

    return Column(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _elementBar(
            label: BaziResultCopy.elementLabel(entries[i].$1, lang),
            count: entries[i].$2,
            maxCount: maxCount == 0 ? 1 : maxCount,
          ),
        ],
      ],
    );
  }

  Widget _elementBar({
    required String label,
    required int count,
    required int maxCount,
  }) {
    final fraction = count / maxCount;
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF7E57C2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 24,
          child: Text(
            '$count',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _metadata(BaziChartModel chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('version', chart.version),
        const SizedBox(height: 8),
        _infoRow('engine_version', chart.engineVersion),
        const SizedBox(height: 8),
        _infoRow('generated_at', chart.generatedAt),
      ],
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
