import 'package:flutter/material.dart';

import '../product_funnel.dart';
import '../product_insight.dart';
import '../product_validation.dart';
import '../product_validation_events.dart';
import '../product_validation_recorder.dart';

/// Phase A — the **internal-only** product-validation dashboard.
///
/// Not part of the user experience and not linked from any user surface. It
/// reads the in-memory recorder and renders funnels + product insights so the
/// team can see whether users actually WOW, where they get curious/engaged, and
/// where they stop. Read-only over the data (plus a reset for a clean run).
class ProductValidationDashboard extends StatefulWidget {
  const ProductValidationDashboard({super.key, this.recorder});

  /// Defaults to the app-wide recorder; injectable for tests.
  final ProductValidationRecorder? recorder;

  @override
  State<ProductValidationDashboard> createState() =>
      _ProductValidationDashboardState();
}

class _ProductValidationDashboardState
    extends State<ProductValidationDashboard> {
  ProductValidationRecorder get _recorder =>
      widget.recorder ?? ProductValidation.recorder;

  @override
  Widget build(BuildContext context) {
    final insights = _recorder.insights();
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Validation · Internal'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Reset measurements',
            onPressed: () => setState(_recorder.reset),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text('${insights.sessionCount} sessions', style: text.titleMedium),
              const SizedBox(width: 12),
              if (insights.returnVisit)
                const Chip(label: Text('Return visits seen')),
            ],
          ),
          if (insights.sessionCount == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No sessions recorded yet. Walk the experience, '
                    'then refresh.'),
              ),
            )
          else ...[
            const SizedBox(height: 20),
            _sectionTitle('Engagement funnel'),
            _FunnelView(funnel: insights.funnel),
            const SizedBox(height: 24),
            _insightGroup('WOW', insights.ofKind(ProductInsightKind.wow)),
            _insightGroup(
                'Curiosity', insights.ofKind(ProductInsightKind.curiosity)),
            _insightGroup(
                'Engagement', insights.ofKind(ProductInsightKind.engagement)),
            _insightGroup(
                'Where users stop', insights.ofKind(ProductInsightKind.dropOff)),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      );

  Widget _insightGroup(String title, List<ProductInsight> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        for (final i in items) _InsightTile(insight: i),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _FunnelView extends StatelessWidget {
  const _FunnelView({required this.funnel});

  final ProductFunnel funnel;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (final stage in funnel.stages)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(stage.stage.label, style: text.bodyLarge),
                    Text(
                      '${stage.reachedCount}/${funnel.totalSessions} · '
                      '${(stage.conversionFromStart * 100).round()}%',
                      style: text.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: stage.conversionFromStart,
                    minHeight: 10,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
                if (stage.dropOffFromPrevious > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '−${stage.dropOffFromPrevious} from previous',
                      style: text.labelSmall?.copyWith(color: scheme.error),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight});

  final ProductInsight insight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(_icon(insight.kind), color: _color(insight.kind, scheme)),
        title: Text(insight.headline),
        subtitle: Text(insight.detail),
      ),
    );
  }

  IconData _icon(ProductInsightKind kind) {
    switch (kind) {
      case ProductInsightKind.wow:
        return Icons.auto_awesome_rounded;
      case ProductInsightKind.curiosity:
        return Icons.search_rounded;
      case ProductInsightKind.engagement:
        return Icons.favorite_rounded;
      case ProductInsightKind.dropOff:
        return Icons.trending_down_rounded;
    }
  }

  Color _color(ProductInsightKind kind, ColorScheme scheme) {
    switch (kind) {
      case ProductInsightKind.wow:
        return scheme.primary;
      case ProductInsightKind.curiosity:
        return scheme.tertiary;
      case ProductInsightKind.engagement:
        return scheme.secondary;
      case ProductInsightKind.dropOff:
        return scheme.error;
    }
  }
}
