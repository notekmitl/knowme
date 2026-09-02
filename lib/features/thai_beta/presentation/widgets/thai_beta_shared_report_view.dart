import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_download.dart';

const _reportDomainHeadings = {
  'การงาน',
  'การเงิน',
  'ความรัก',
  'สุขภาพ',
  'โชคลาภ',
};

abstract final class ThaiBetaAnnualInfographicCapture {
  static const logicalSize = Size(360, 640);
  static const pixelRatio = 3.0;
  static const targetWidth = 1080;
  static const targetHeight = 1920;

  static Future<Uint8List> png(GlobalKey boundaryKey) async {
    final boundary = boundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary || !boundary.hasSize) {
      throw StateError('Annual infographic is not ready for export.');
    }
    final image = boundary.toImageSync(pixelRatio: pixelRatio);
    if (image.width != targetWidth || image.height != targetHeight) {
      throw StateError(
        'Unexpected infographic size ${image.width}x${image.height}.',
      );
    }
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('Unable to encode infographic PNG.');
    return data.buffer.asUint8List();
  }
}

abstract final class ThaiBetaAnnualInfographicLayoutKeys {
  static const title = Key('annual-infographic-title');
  static const theme = Key('annual-infographic-theme');
  static const overview = Key('annual-infographic-overview');
  static const ornament = Key('annual-infographic-ornament');
  static const opportunity = Key('annual-infographic-opportunity');
  static const caution = Key('annual-infographic-caution');
  static const advice = Key('annual-infographic-advice');
  static const disclaimer = Key('annual-infographic-disclaimer');

  static Key category(String id) => Key('annual-infographic-category-$id');
}

class ThaiBetaSharedReportView extends StatelessWidget {
  const ThaiBetaSharedReportView({
    super.key,
    required this.document,
    required this.infographicBoundaryKey,
    this.badges = const [],
  });

  final ThaiBetaReportExportDocument document;
  final GlobalKey infographicBoundaryKey;
  final List<ThaiPublicEvidenceBadgeBetaViewModel> badges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[
      if (badges.isNotEmpty) ...[
        ThaiBetaEvidenceBadgePanel(badges: badges),
        const SizedBox(height: 14),
      ],
      Container(
        key: const Key('thai_shared_report_header'),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
        decoration: const BoxDecoration(
          color: Color(0xff111936),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: const Color(0xfff7f0df),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              document.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xffd8c99f),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
    ];

    var infographicInserted = false;
    var timelineStarted = false;
    var sourceMarked = false;
    for (
      var sectionIndex = 0;
      sectionIndex < document.sections.length;
      sectionIndex++
    ) {
      final section = document.sections[sectionIndex];
      if (badges.isNotEmpty &&
          (section.title == 'ที่มาของคำวิเคราะห์' ||
              section.title == 'รายละเอียดหลักฐาน')) {
        continue;
      }
      Widget sectionWidget = _SharedReportSection(section: section);
      if (!timelineStarted &&
          section.kind == ThaiBetaReportExportSectionKind.timeline) {
        timelineStarted = true;
        sectionWidget = KeyedSubtree(
          key: const Key('thai_consumer_life_timeline'),
          child: sectionWidget,
        );
      }
      if (!sourceMarked && section.title == 'ที่มาของผลวิเคราะห์') {
        sourceMarked = true;
        sectionWidget = KeyedSubtree(
          key: const Key('thai_consumer_source'),
          child: sectionWidget,
        );
      }
      if (section.title == ThaiBirthProfileCoreReadingCopy.omissionsTitle) {
        sectionWidget = KeyedSubtree(
          key: const Key('thai_birth_profile_omissions'),
          child: sectionWidget,
        );
      }
      children.add(sectionWidget);
      if (!infographicInserted &&
          document.infographic != null &&
          sectionIndex == document.infographicInsertionSectionIndex) {
        children.add(
          ThaiBetaAnnualInfographicPanel(
            data: document.infographic!,
            boundaryKey: infographicBoundaryKey,
          ),
        );
        infographicInserted = true;
      }
    }
    if (!infographicInserted && document.infographic != null) {
      children.add(
        ThaiBetaAnnualInfographicPanel(
          data: document.infographic!,
          boundaryKey: infographicBoundaryKey,
        ),
      );
    }

    return Semantics(
      container: true,
      label: 'รายงานโหราไทยฉบับเต็ม',
      child: Column(
        key: const Key('thai_shared_report_presentation'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _SharedReportSection extends StatelessWidget {
  const _SharedReportSection({required this.section});

  final ThaiBetaReportExportSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isChapter = section.kind == ThaiBetaReportExportSectionKind.chapter;
    final isTimeline = section.kind == ThaiBetaReportExportSectionKind.timeline;
    final isDisclaimer =
        section.kind == ThaiBetaReportExportSectionKind.disclaimer;
    final background = isChapter
        ? const Color(0xff18203f)
        : isTimeline
        ? const Color(0xfff3f1ea)
        : isDisclaimer
        ? const Color(0xfffff7e8)
        : theme.colorScheme.surface;
    final phaseLabel = switch (section.title) {
      'คำทำนายอดีต' => 'อดีต',
      final title when title.startsWith('คำทำนายปัจจุบัน') => 'ปัจจุบัน',
      final title when title.startsWith('ช่วงชีวิตถัดไป') => 'อนาคต',
      'อดีตของคุณ' => 'อดีต',
      'ช่วงปัจจุบัน' => 'ปัจจุบัน',
      'จังหวะชีวิตระยะต่อไป' => 'อนาคต',
      _ => null,
    };

    return Container(
      key: ValueKey(section.id),
      margin: EdgeInsets.fromLTRB(18, isChapter ? 12 : 0, 18, 14),
      padding: EdgeInsets.fromLTRB(18, isChapter ? 20 : 18, 18, 18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isChapter
              ? const Color(0xffc7a760)
              : isDisclaimer
              ? const Color(0xffd7a84d)
              : const Color(0xffddd9cd),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (phaseLabel != null) ...[
            Text(
              phaseLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xff96702e),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
          ],
          Text(
            section.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isChapter
                  ? const Color(0xfffff8e8)
                  : const Color(0xff18203f),
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          if (section.title == 'อดีตของคุณ') ...[
            const SizedBox(height: 8),
            Text(
              'เรื่องสำคัญของช่วงนี้',
              style: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xff4b536c),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          for (var index = 0; index < section.paragraphs.length; index++) ...[
            SizedBox(height: isChapter ? 6 : 9),
            if (_reportDomainHeadings.contains(
              section.paragraphs[index].trim(),
            ))
              Row(
                key: ValueKey(section.paragraphIds[index]),
                children: [
                  Icon(
                    _domainIcon(section.paragraphs[index]),
                    size: 18,
                    color: const Color(0xff96702e),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    section.paragraphs[index],
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: const Color(0xff18203f),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )
            else
              Text(
                section.paragraphs[index],
                key: ValueKey(section.paragraphIds[index]),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isChapter ? const Color(0xffddd4bd) : null,
                  height: isChapter ? 1.48 : 1.62,
                ),
              ),
          ],
        ],
      ),
    );
  }

  IconData _domainIcon(String label) => switch (label.trim()) {
    'การงาน' => Icons.work_outline,
    'การเงิน' => Icons.savings_outlined,
    'ความรัก' => Icons.favorite_border,
    'สุขภาพ' => Icons.self_improvement,
    'โชคลาภ' => Icons.auto_awesome_outlined,
    _ => Icons.circle_outlined,
  };
}

class ThaiBetaAnnualInfographicPanel extends StatelessWidget {
  const ThaiBetaAnnualInfographicPanel({
    super.key,
    required this.data,
    required this.boundaryKey,
  });

  final ThaiBetaAnnualInfographicData data;
  final GlobalKey boundaryKey;

  Future<void> _save(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final bytes = await ThaiBetaAnnualInfographicCapture.png(boundaryKey);
      final downloaded = await downloadBytesAsFile(
        bytes: bytes,
        filename: 'knowme-12-month-outlook-${data.buddhistYear}.png',
      );
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            downloaded
                ? 'บันทึกภาพขนาด 1080 × 1920 แล้ว'
                : 'อุปกรณ์นี้ไม่รองรับการบันทึกภาพอัตโนมัติ',
          ),
        ),
      );
    } catch (_) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('ยังไม่สามารถบันทึกภาพได้ กรุณาลองใหม่')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('thai_annual_infographic_section'),
      margin: const EdgeInsets.fromLTRB(18, 6, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ภาพสรุป 12 เดือนข้างหน้า',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Semantics(
            image: true,
            label:
                '${data.title} ช่วง ${data.periodLabel} สรุปการงาน การเงิน ความรัก สุขภาพ โอกาสและข้อควรระวัง',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: _AnnualInfographicCanvas(data: data),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            key: const Key('thai_annual_infographic_save'),
            onPressed: () => _save(context),
            icon: const Icon(Icons.download_outlined),
            label: const Text('บันทึกภาพ'),
          ),
        ],
      ),
    );
  }
}

class _AnnualInfographicCanvas extends StatelessWidget {
  const _AnnualInfographicCanvas({required this.data});

  final ThaiBetaAnnualInfographicData data;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xff0d1530);
    const deepIndigo = Color(0xff18254f);
    const gold = Color(0xffc7a760);
    const cream = Color(0xfffff8e8);
    const ivory = Color(0xfff5f0e4);
    const teal = Color(0xff2d8f86);
    const amber = Color(0xffa55f35);

    return Container(
      key: const Key('thai_annual_infographic_canvas'),
      width: ThaiBetaAnnualInfographicCapture.logicalSize.width,
      height: ThaiBetaAnnualInfographicCapture.logicalSize.height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff0d1530), Color(0xff17244a), Color(0xff0f1936)],
        ),
        border: Border.all(color: gold.withValues(alpha: .42), width: 1.2),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: cream,
          height: 1.28,
          fontFamily: 'KnowMeNotoSansThai',
          fontFamilyFallback: ['KnowMeNotoSans'],
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 72,
              right: -22,
              width: 172,
              height: 172,
              child: Opacity(opacity: .22, child: _ThaiAnnualOrnament()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'KNOWME  •  รายงานโหราไทย',
                    style: TextStyle(
                      color: gold,
                      fontSize: 8.4,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .6,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const _InfographicGlyph(
                        name: 'spark',
                        color: gold,
                        size: 20,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          data.title,
                          key: ThaiBetaAnnualInfographicLayoutKeys.title,
                          style: const TextStyle(
                            color: cream,
                            fontSize: 20.5,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      key: ThaiBetaAnnualInfographicLayoutKeys.overview,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: gold.withValues(alpha: .45)),
                      ),
                      child: Text(
                        data.overview,
                        style: const TextStyle(
                          color: ivory,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 72,
                    padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
                    decoration: BoxDecoration(
                      color: deepIndigo.withValues(alpha: .88),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: gold.withValues(alpha: .38)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ประเด็นหลักของช่วงนี้',
                          style: TextStyle(
                            color: gold,
                            fontSize: 8.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              data.theme,
                              key: ThaiBetaAnnualInfographicLayoutKeys.theme,
                              style: const TextStyle(
                                color: cream,
                                fontSize: 8.9,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 106,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _InfographicCategoryRow(
                            category: data.categories[0],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfographicCategoryRow(
                            category: data.categories[1],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 106,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _InfographicCategoryRow(
                            category: data.categories[2],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfographicCategoryRow(
                            category: data.categories[3],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 96,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _Band(
                            key:
                                ThaiBetaAnnualInfographicLayoutKeys.opportunity,
                            iconName: 'opportunity',
                            label: 'โอกาสที่ควรใช้',
                            value: data.opportunity,
                            color: teal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _Band(
                            key: ThaiBetaAnnualInfographicLayoutKeys.caution,
                            iconName: 'shield',
                            label: 'เรื่องที่ควรระวัง',
                            value: data.caution,
                            color: amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    key: ThaiBetaAnnualInfographicLayoutKeys.advice,
                    height: 74,
                    padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xff202f60),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: gold.withValues(alpha: .65)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'สิ่งสำคัญที่ควรทำ',
                          style: TextStyle(
                            color: gold,
                            fontSize: 8.4,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              data.primaryAdvice,
                              style: const TextStyle(
                                color: cream,
                                fontSize: 7.9,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.disclaimer,
                    key: ThaiBetaAnnualInfographicLayoutKeys.disclaimer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xffd8d3c8),
                      fontSize: 7.8,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfographicCategoryRow extends StatelessWidget {
  const _InfographicCategoryRow({required this.category});

  final ThaiBetaAnnualInfographicCategory category;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xff101832);
    const indigo = Color(0xff1b2852);
    const gold = Color(0xffc7a760);
    const ivory = Color(0xfffffbf2);
    return Container(
      key: ThaiBetaAnnualInfographicLayoutKeys.category(category.id),
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
      decoration: BoxDecoration(
        color: ivory.withValues(alpha: .97),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold.withValues(alpha: .62)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _InfographicGlyph(
                  name: category.iconName,
                  color: indigo,
                  size: 14,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  category.title,
                  style: const TextStyle(
                    color: indigo,
                    fontSize: 9.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                category.summary,
                style: const TextStyle(
                  color: navy,
                  fontSize: 7.8,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThaiAnnualOrnament extends StatelessWidget {
  const _ThaiAnnualOrnament();

  @override
  Widget build(BuildContext context) => const SizedBox.expand(
    key: ThaiBetaAnnualInfographicLayoutKeys.ornament,
    child: CustomPaint(painter: _ThaiAnnualOrnamentPainter()),
  );
}

class _ThaiAnnualOrnamentPainter extends CustomPainter {
  const _ThaiAnnualOrnamentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height < 12) return;
    final gold = const Color(0xffc7a760);
    final stroke = Paint()
      ..color = gold.withValues(alpha: .42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final wash = Paint()
      ..color = gold.withValues(alpha: .055)
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final preferredRadius = size.width * .16;
    final availableRadius = size.height * .43;
    final radius = preferredRadius < availableRadius
        ? preferredRadius
        : availableRadius;
    final petalWidth = radius * .42;
    final petalHeight = radius;
    for (var turn = 0; turn < 8; turn++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(turn * .7853981633974483);
      final petal = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-petalWidth, -petalHeight * .54, 0, -petalHeight)
        ..quadraticBezierTo(petalWidth, -petalHeight * .54, 0, 0)
        ..close();
      canvas.drawPath(petal, wash);
      canvas.drawPath(petal, stroke);
      canvas.restore();
    }

    final core = Path()
      ..moveTo(center.dx, center.dy - radius * .22)
      ..lineTo(center.dx + radius * .22, center.dy)
      ..lineTo(center.dx, center.dy + radius * .22)
      ..lineTo(center.dx - radius * .22, center.dy)
      ..close();
    canvas.drawPath(core, wash);
    canvas.drawPath(core, stroke);
  }

  @override
  bool shouldRepaint(covariant _ThaiAnnualOrnamentPainter oldDelegate) => false;
}

class _Band extends StatelessWidget {
  const _Band({
    super.key,
    required this.iconName,
    required this.label,
    required this.value,
    required this.color,
  });

  final String iconName;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: .25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _InfographicGlyph(name: iconName, color: Colors.white, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7.8,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfographicGlyph extends StatelessWidget {
  const _InfographicGlyph({
    required this.name,
    required this.color,
    required this.size,
  });

  final String name;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _InfographicGlyphPainter(name: name, color: color),
    size: Size.square(size),
  );
}

class _InfographicGlyphPainter extends CustomPainter {
  const _InfographicGlyphPainter({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;
    switch (name) {
      case 'spark':
        canvas.drawLine(
          Offset(w * .5, h * .08),
          Offset(w * .5, h * .92),
          paint,
        );
        canvas.drawLine(
          Offset(w * .08, h * .5),
          Offset(w * .92, h * .5),
          paint,
        );
        canvas.drawLine(Offset(w * .2, h * .2), Offset(w * .8, h * .8), paint);
        canvas.drawLine(Offset(w * .8, h * .2), Offset(w * .2, h * .8), paint);
        break;
      case 'work':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * .08, h * .3, w * .84, h * .58),
            Radius.circular(w * .08),
          ),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(w * .34, h * .12, w * .32, h * .2),
          paint,
        );
        canvas.drawLine(
          Offset(w * .08, h * .55),
          Offset(w * .92, h * .55),
          paint,
        );
        break;
      case 'savings':
        canvas.drawOval(
          Rect.fromLTWH(w * .12, h * .3, w * .76, h * .58),
          paint,
        );
        canvas.drawLine(
          Offset(w * .28, h * .2),
          Offset(w * .72, h * .2),
          paint,
        );
        canvas.drawLine(
          Offset(w * .5, h * .42),
          Offset(w * .5, h * .76),
          paint,
        );
        canvas.drawArc(
          Rect.fromLTWH(w * .36, h * .4, w * .28, h * .2),
          1.1,
          3.8,
          false,
          paint,
        );
        break;
      case 'favorite':
        final path = Path()
          ..moveTo(w * .5, h * .86)
          ..cubicTo(w * .12, h * .62, w * .08, h * .25, w * .32, h * .2)
          ..cubicTo(w * .44, h * .17, w * .5, h * .28, w * .5, h * .28)
          ..cubicTo(w * .5, h * .28, w * .56, h * .17, w * .68, h * .2)
          ..cubicTo(w * .92, h * .25, w * .88, h * .62, w * .5, h * .86);
        canvas.drawPath(path, paint);
        break;
      case 'self_improvement':
        canvas.drawCircle(Offset(w * .5, h * .22), w * .11, paint);
        canvas.drawLine(
          Offset(w * .5, h * .34),
          Offset(w * .5, h * .62),
          paint,
        );
        canvas.drawLine(
          Offset(w * .5, h * .45),
          Offset(w * .2, h * .62),
          paint,
        );
        canvas.drawLine(
          Offset(w * .5, h * .45),
          Offset(w * .8, h * .62),
          paint,
        );
        canvas.drawLine(
          Offset(w * .5, h * .62),
          Offset(w * .28, h * .88),
          paint,
        );
        canvas.drawLine(
          Offset(w * .5, h * .62),
          Offset(w * .72, h * .88),
          paint,
        );
        break;
      case 'opportunity':
        final path = Path()
          ..moveTo(w * .1, h * .8)
          ..lineTo(w * .42, h * .48)
          ..lineTo(w * .62, h * .66)
          ..lineTo(w * .9, h * .2)
          ..moveTo(w * .68, h * .2)
          ..lineTo(w * .9, h * .2)
          ..lineTo(w * .9, h * .43);
        canvas.drawPath(path, paint);
        break;
      case 'shield':
        final path = Path()
          ..moveTo(w * .5, h * .08)
          ..lineTo(w * .86, h * .22)
          ..lineTo(w * .8, h * .62)
          ..quadraticBezierTo(w * .68, h * .84, w * .5, h * .92)
          ..quadraticBezierTo(w * .32, h * .84, w * .2, h * .62)
          ..lineTo(w * .14, h * .22)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _InfographicGlyphPainter oldDelegate) =>
      oldDelegate.name != name || oldDelegate.color != color;
}
