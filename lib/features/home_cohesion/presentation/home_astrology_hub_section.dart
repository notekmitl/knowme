import 'package:flutter/material.dart';

import 'package:knowme/features/astrology/application/astrology_generation_presentation.dart';
import 'package:knowme/features/astrology/domain/astrology_generation_status.dart';

import 'home_screen_v3_models.dart';
import 'home_v3_copy.dart';
import 'home_v35_design.dart';

/// Primary astrology destination on Home — large, unmistakable.
class HomeAstrologyHubSection extends StatelessWidget {
  const HomeAstrologyHubSection({
    super.key,
    required this.hub,
    required this.onOpenSystem,
    required this.onOpenFusion,
    required this.onEditProfile,
    this.onRetrySystem,
  });

  final HomeAstrologyHubSectionData hub;
  final void Function(String systemId) onOpenSystem;
  final VoidCallback onOpenFusion;
  final VoidCallback onEditProfile;
  final void Function(String systemId)? onRetrySystem;

  static const _systemVisuals = <String, ({IconData icon, Color color, Color tint})>{
    'thai': (
      icon: Icons.wb_twilight_rounded,
      color: Color(0xFFE8A547),
      tint: Color(0xFFFFF4E5),
    ),
    'bazi': (
      icon: Icons.balance_rounded,
      color: Color(0xFF5CB88A),
      tint: Color(0xFFE8F7EF),
    ),
    'western': (
      icon: Icons.nightlight_round,
      color: Color(0xFF7B9FE8),
      tint: Color(0xFFEEF3FC),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1B4E),
            Color(0xFF1A1030),
            Color(0xFF120A22),
          ],
        ),
        borderRadius: BorderRadius.circular(HomeV35Design.heroRadius),
        boxShadow: [HomeV35Design.heroShadow],
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('🔮', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HomeV3Copy.astrologyHubTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      HomeV3Copy.astrologyHubSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 520;
              final cardWidth = isWide
                  ? (constraints.maxWidth - HomeV35Design.cardGap) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: HomeV35Design.cardGap,
                runSpacing: HomeV35Design.cardGap,
                children: [
                  for (final system in hub.systems)
                    SizedBox(
                      width: cardWidth,
                      child: _AstrologySystemCard(
                        system: system,
                        visual: _systemVisuals[system.id],
                        onTap: () => _handleSystemTap(system),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: HomeV35Design.cardGap),
          _FusionCard(
            hub: hub,
            onTap: () => _handleFusionTap(),
          ),
        ],
      ),
    );
  }

  void _handleSystemTap(HomeAstrologySystemItemData system) {
    if (system.generationStatus == AstrologyGenerationStatus.notReady) {
      onEditProfile();
      return;
    }
    if (AstrologyGenerationPresentation.canRetry(
      AstrologySystemSnapshot(
        systemId: system.id,
        status: system.generationStatus,
      ),
    )) {
      onRetrySystem?.call(system.id);
      return;
    }
    if (!AstrologyGenerationPresentation.canOpen(
      AstrologySystemSnapshot(
        systemId: system.id,
        status: system.generationStatus,
      ),
    )) {
      return;
    }
    onOpenSystem(system.id);
  }

  void _handleFusionTap() {
    final fusion = AstrologySystemSnapshot(
      systemId: 'fusion',
      status: hub.fusionGenerationStatus,
    );
    if (fusion.status == AstrologyGenerationStatus.notReady) {
      onEditProfile();
      return;
    }
    if (AstrologyGenerationPresentation.canRetry(fusion)) {
      onRetrySystem?.call('fusion');
      return;
    }
    if (!AstrologyGenerationPresentation.canOpen(fusion)) return;
    onOpenFusion();
  }
}

class _AstrologySystemCard extends StatelessWidget {
  const _AstrologySystemCard({
    required this.system,
    required this.visual,
    required this.onTap,
  });

  final HomeAstrologySystemItemData system;
  final ({IconData icon, Color color, Color tint})? visual;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ready = system.generationStatus == AstrologyGenerationStatus.completed;
    final busy = AstrologyGenerationPresentation.isBusy(
      AstrologySystemSnapshot(
        systemId: system.id,
        status: system.generationStatus,
      ),
    );
    final failed =
        system.generationStatus == AstrologyGenerationStatus.failed;
    final accent = visual?.color ?? HomeV35Design.goldAccent;
    final tint = visual?.tint ?? HomeV35Design.purpleSoft;
    final subtitle = system.statusMessage;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
            border: Border.all(
              color: ready ? accent.withValues(alpha: 0.35) : Colors.white,
              width: ready ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      visual?.icon ?? Icons.star_rounded,
                      color: accent,
                      size: 26,
                    ),
                  ),
                  const Spacer(),
                  if (ready)
                    Icon(Icons.check_circle_rounded, color: accent, size: 22)
                  else if (busy)
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accent,
                      ),
                    )
                  else if (failed)
                    Icon(Icons.error_outline_rounded, color: accent, size: 22),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                system.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: HomeV35Design.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: ready
                      ? HomeV35Design.textSecondary
                      : HomeV35Design.textPrimary,
                  fontWeight: ready ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _ActionChip(label: system.actionLabel, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _FusionCard extends StatelessWidget {
  const _FusionCard({
    required this.hub,
    required this.onTap,
  });

  final HomeAstrologyHubSectionData hub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ready =
        hub.fusionGenerationStatus == AstrologyGenerationStatus.completed;
    final busy = AstrologyGenerationPresentation.isBusy(
      AstrologySystemSnapshot(
        systemId: 'fusion',
        status: hub.fusionGenerationStatus,
      ),
    );
    final subtitle = hub.fusionStatusMessage;

    return Material(
      color: HomeV35Design.goldCta.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
            border: Border.all(
              color: HomeV35Design.goldCta.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: HomeV35Design.goldCta.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  color: HomeV35Design.goldCta,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hub.fusionTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight:
                            ready ? FontWeight.w400 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ActionChip(
                label: hub.fusionActionLabel,
                color: HomeV35Design.goldCta,
                lightText: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.color,
    this.lightText = false,
  });

  final String label;
  final Color color;
  final bool lightText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: lightText ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: lightText ? HomeV35Design.goldCtaText : color,
        ),
      ),
    );
  }
}
