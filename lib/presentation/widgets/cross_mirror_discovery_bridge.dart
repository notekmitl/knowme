import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/features/astrology/fusion/presentation/astrology_fusion_routes.dart';
import 'package:knowme/features/personality_mirror/personality_mirror_routes.dart';

/// Reflective cross-family discovery link (CL-3) — no synthesis.
enum CrossMirrorBridgeTarget {
  personalityMirror,
  astrologyFusion,
}

class CrossMirrorDiscoveryBridge extends StatelessWidget {
  const CrossMirrorDiscoveryBridge({
    super.key,
    required this.target,
  });

  final CrossMirrorBridgeTarget target;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final (bodyKey, ctaKey) = switch (target) {
      CrossMirrorBridgeTarget.personalityMirror => (
          'cross_mirror_bridge_astrology_to_personality_body',
          'cross_mirror_bridge_astrology_to_personality_cta',
        ),
      CrossMirrorBridgeTarget.astrologyFusion => (
          'cross_mirror_bridge_personality_to_astrology_body',
          'cross_mirror_bridge_personality_to_astrology_cta',
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppText.t(bodyKey),
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: muted,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _open(context),
              child: Text(AppText.t(ctaKey)),
            ),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context) {
    switch (target) {
      case CrossMirrorBridgeTarget.personalityMirror:
        PersonalityMirrorRoutes.open(context);
      case CrossMirrorBridgeTarget.astrologyFusion:
        AstrologyFusionRoutes.openResult(context);
    }
  }
}
