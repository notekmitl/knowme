import 'package:flutter/material.dart';

import 'home_screen_v2_models.dart';
import 'home_screen_v3_models.dart';
import 'home_v3_copy.dart';
import 'home_v3_psychology_tests_section.dart';
import 'home_v35_design.dart';

/// Astrology-first hub — systems, cross-system fusion, psychology expansion.
class HomeAstrologyHubSection extends StatelessWidget {
  const HomeAstrologyHubSection({
    super.key,
    required this.hub,
    required this.psychologyTests,
    required this.onOpenSystem,
    required this.onOpenFusion,
    required this.onPsychologyTest,
  });

  final HomeAstrologyHubSectionData hub;
  final HomePsychologyTestsSectionData psychologyTests;
  final void Function(String systemId) onOpenSystem;
  final VoidCallback onOpenFusion;
  final void Function(HomePsychologyTestItemData test) onPsychologyTest;

  static const _systemIcons = <String, (IconData, Color)>{
    'thai': (Icons.wb_twilight_rounded, Color(0xFFE8A547)),
    'bazi': (Icons.balance_rounded, Color(0xFF5CB88A)),
    'western': (Icons.nightlight_round, Color(0xFF7B9FE8)),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          icon: '🔮',
          title: HomeV3Copy.astrologyHubTitle,
        ),
        const SizedBox(height: 10),
        ...hub.systems.map((system) {
          final visual = _systemIcons[system.id];
          return Padding(
            padding: const EdgeInsets.only(bottom: HomeV35Design.cardGap),
            child: _HubTile(
              title: system.title,
              description: system.description,
              icon: visual?.$1 ?? Icons.star_rounded,
              color: visual?.$2 ?? HomeV35Design.purpleAccent,
              enabled: system.isAvailable,
              onTap: () => onOpenSystem(system.id),
            ),
          );
        }),
        const SizedBox(height: HomeV35Design.sectionGap - HomeV35Design.cardGap),
        _SectionHeader(
          icon: '✨',
          title: HomeV3Copy.crossSystemSectionTitle,
        ),
        const SizedBox(height: 10),
        _HubTile(
          title: hub.fusionTitle,
          description: hub.fusionDescription,
          icon: Icons.layers_rounded,
          color: HomeV35Design.purpleAccent,
          enabled: hub.fusionAvailable,
          onTap: onOpenFusion,
        ),
        const SizedBox(height: HomeV35Design.sectionGap),
        _SectionHeader(
          icon: '🧠',
          title: HomeV3Copy.psychologyExpansionTitle,
          subtitle: HomeV3Copy.psychologyExpansionSubtitle,
        ),
        const SizedBox(height: 10),
        HomeV3PsychologyTestsSection(
          data: psychologyTests,
          onTestAction: onPsychologyTest,
          showSectionHeader: false,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final String icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HomeV35Design.textPrimary,
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 13,
              color: HomeV35Design.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeV35Design.surface,
      borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
            boxShadow: enabled ? [HomeV35Design.cardShadow] : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: enabled ? 0.14 : 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: enabled ? color : HomeV35Design.textMuted,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? HomeV35Design.textPrimary
                            : HomeV35Design.textMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: enabled
                            ? HomeV35Design.textSecondary
                            : HomeV35Design.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: enabled ? HomeV35Design.textMuted : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
