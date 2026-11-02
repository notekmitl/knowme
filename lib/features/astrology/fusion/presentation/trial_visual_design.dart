import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Presentation only. All chart values and readings remain in the supplied
/// calculation models; these illustrations contain no astrological data.
abstract final class TrialVisualDesign {
  static const gold = Color(0xFFD7B878);
  static const text = Color(0xFFF4F1E8);
  static const muted = Color(0xFFBAC1CC);
  static const overall = Color(0xFF100F20);
  static const thai = Color(0xFF071D1A);
  static const chinese = Color(0xFF1D1115);
  static const western = Color(0xFF0C142C);

  static const overallArt = 'assets/trial_visual/overall.webp';
  static const thaiArt = 'assets/trial_visual/thai.webp';
  static const chineseArt = 'assets/trial_visual/chinese.webp';
  static const westernArt = 'assets/trial_visual/western.webp';

  static ThemeData theme(Color background) => ThemeData.dark().copyWith(
    textTheme: ThemeData.dark().textTheme.apply(
      fontFamily: 'KnowMeNotoSansThai',
    ),
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.dark(
      primary: gold,
      onPrimary: overall,
      surface: background,
      onSurface: text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: text,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF242334),
      labelStyle: const TextStyle(color: muted),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF676174)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gold, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: overall,
        minimumSize: const Size(0, 48),
      ),
    ),
  );
}

class TrialArtworkBanner extends StatelessWidget {
  const TrialArtworkBanner({
    super.key,
    required this.asset,
    this.height = 190,
    this.alignment = Alignment.center,
  });

  final String asset;
  final double height;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: _TrialArtworkImage(asset, fit: BoxFit.cover, alignment: alignment),
    ),
  );
}

/// A single illustrated surface for live chart facts and their decorative art.
/// The dark wash keeps the computed text readable without baking it into art.
class TrialIllustratedHero extends StatelessWidget {
  const TrialIllustratedHero({
    super.key,
    required this.asset,
    required this.background,
    required this.child,
    this.alignment = Alignment.center,
  });

  final String asset;
  final Color background;
  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Stack(
      children: [
        Positioned.fill(
          child: _TrialArtworkImage(
            asset,
            fit: BoxFit.cover,
            alignment: alignment,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, .28, .64, 1],
                colors: [
                  background.withValues(alpha: .94),
                  background.withValues(alpha: .30),
                  background.withValues(alpha: .73),
                  background,
                ],
              ),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.all(18), child: child),
      ],
    ),
  );
}

/// Paint decorative trial art through a browser image element on web. In a
/// WebGL-less CanvasKit fallback, Image.asset left art unpainted even though
/// the browser decoded the same files successfully.
class _TrialArtworkImage extends StatelessWidget {
  const _TrialArtworkImage(
    this.asset, {
    required this.fit,
    required this.alignment,
  });

  final String asset;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: kIsWeb
        ? Image.network(
            'assets/$asset',
            fit: fit,
            alignment: alignment,
            excludeFromSemantics: true,
            webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          )
        : Image.asset(
            asset,
            fit: fit,
            alignment: alignment,
            excludeFromSemantics: true,
          ),
  );
}

enum TrialReaderTab { overall, thai, chinese, western }

class TrialFlowSteps extends StatelessWidget {
  const TrialFlowSteps({super.key, required this.current});

  final int current;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Row(
          children: [
            _step('1', 'ข้อมูลเกิด', current == 1),
            const Expanded(
              child: Divider(
                color: TrialVisualDesign.gold,
                indent: 12,
                endIndent: 12,
              ),
            ),
            _step('2', 'อ่านดวงรวม', current == 2),
          ],
        ),
      ),
    ),
  );

  Widget _step(String number, String label, bool active) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(
        radius: 14,
        backgroundColor: active
            ? TrialVisualDesign.gold
            : const Color(0xFF3D3949),
        child: Text(
          number,
          style: TextStyle(
            color: active ? TrialVisualDesign.overall : TrialVisualDesign.text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(
          color: active ? TrialVisualDesign.text : TrialVisualDesign.muted,
          fontSize: 13,
        ),
      ),
    ],
  );
}

/// One reader switcher per page: the parent places it at the bottom on phones
/// and at the top on wider screens. The callbacks reuse prepared chart models.
class TrialReaderNavigation extends StatelessWidget {
  const TrialReaderNavigation({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.background,
    this.desktop = false,
  });

  final TrialReaderTab selected;
  final ValueChanged<TrialReaderTab> onSelect;
  final Color background;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    const items = <(TrialReaderTab, String, IconData, Key)>[
      (
        TrialReaderTab.overall,
        'ดวงรวม',
        Icons.wb_sunny_outlined,
        Key('overall-open-overall'),
      ),
      (
        TrialReaderTab.thai,
        'ไทย',
        Icons.temple_buddhist_outlined,
        Key('overall-open-thai'),
      ),
      (
        TrialReaderTab.chinese,
        'จีน',
        Icons.auto_awesome_outlined,
        Key('overall-open-bazi'),
      ),
      (
        TrialReaderTab.western,
        'ตะวันตก',
        Icons.nights_stay_outlined,
        Key('overall-open-western'),
      ),
    ];
    final row = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: Border(
          top: desktop
              ? BorderSide.none
              : const BorderSide(color: Color(0x334D5364)),
          bottom: desktop
              ? const BorderSide(color: Color(0x334D5364))
              : BorderSide.none,
        ),
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Row(
            children: [
              for (final (tab, label, icon, key) in items)
                Expanded(
                  child: InkWell(
                    key: key,
                    onTap: tab == selected ? null : () => onSelect(tab),
                    child: Container(
                      constraints: BoxConstraints(minHeight: desktop ? 48 : 60),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: tab == selected
                                ? TrialVisualDesign.gold
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!desktop)
                            Icon(
                              icon,
                              color: tab == selected
                                  ? TrialVisualDesign.gold
                                  : TrialVisualDesign.muted,
                              size: 22,
                            ),
                          if (!desktop) const SizedBox(height: 2),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: tab == selected
                                  ? TrialVisualDesign.gold
                                  : TrialVisualDesign.muted,
                              fontSize: desktop ? 15 : 12,
                              fontWeight: tab == selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return desktop
        ? SizedBox(height: 48, child: row)
        : SafeArea(top: false, child: SizedBox(height: 64, child: row));
  }
}
