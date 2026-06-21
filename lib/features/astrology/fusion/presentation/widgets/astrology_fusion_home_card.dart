import 'package:flutter/material.dart';

import '../../analytics/fusion_analytics.dart';
import '../../application/astrology_fusion_entry_service.dart';
import '../../domain/entities/astrology_fusion_entry_status.dart';
import '../../domain/entities/astrology_fusion_status.dart';
import '../astrology_fusion_routes.dart';

class AstrologyFusionHomeCard extends StatefulWidget {
  const AstrologyFusionHomeCard({
    super.key,
    required this.entryState,
    this.onOpen,
  });

  final AstrologyFusionEntryState entryState;
  final VoidCallback? onOpen;

  @override
  State<AstrologyFusionHomeCard> createState() => _AstrologyFusionHomeCardState();
}

class _AstrologyFusionHomeCardState extends State<AstrologyFusionHomeCard> {
  bool _seenReported = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reportSeenIfNeeded();
  }

  @override
  void didUpdateWidget(covariant AstrologyFusionHomeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reportSeenIfNeeded();
  }

  void _reportSeenIfNeeded() {
    if (_seenReported) return;
    _seenReported = true;
    FusionAnalytics.tracker.trackFusionCardSeen(
      status: widget.entryState.readiness.status.name,
      lensCount: widget.entryState.readiness.completedLensCount,
    );
  }

  void _handleOpen(BuildContext context) {
    FusionAnalytics.tracker.trackFusionCardClicked(
      status: widget.entryState.readiness.status.name,
      lensCount: widget.entryState.readiness.completedLensCount,
    );
    if (widget.onOpen != null) {
      widget.onOpen!();
      return;
    }
    AstrologyFusionRoutes.openResult(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Astrology Fusion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _bodyForStatus(widget.entryState.readiness.status),
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (widget.entryState.readiness.status !=
                AstrologyFusionEntryStatus.unavailable) ...[
              const SizedBox(height: 10),
              Text(
                '${widget.entryState.readiness.completedLensCount}/${widget.entryState.readiness.totalLensCount} ศาสตร์พร้อม',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              _SnapshotBadge(status: widget.entryState.snapshotStatus),
            ],
            if (widget.entryState.canOpen) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _handleOpen(context),
                child: const Text('ดูผลลัพธ์'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _bodyForStatus(AstrologyFusionEntryStatus status) {
    return switch (status) {
      AstrologyFusionEntryStatus.unavailable =>
        'เริ่มต้นด้วยการทำดวงอย่างน้อย 1 ระบบ',
      AstrologyFusionEntryStatus.partiallyAvailable =>
        'Fusion เริ่มทำงานได้แล้ว\nเพิ่มศาสตร์อื่นเพื่อมุมมองที่หลากหลายขึ้น',
      AstrologyFusionEntryStatus.available => 'Fusion พร้อมแล้ว',
    };
  }
}

class _SnapshotBadge extends StatelessWidget {
  const _SnapshotBadge({required this.status});

  final AstrologyFusionStatus? status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      AstrologyFusionStatus.upToDate => 'Up To Date',
      AstrologyFusionStatus.outdated => 'Needs Refresh',
      AstrologyFusionStatus.notGenerated => 'Needs Refresh',
      null => 'Needs Refresh',
    };

    final color = status == AstrologyFusionStatus.upToDate
        ? Colors.green.shade700
        : Colors.orange.shade800;

    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
