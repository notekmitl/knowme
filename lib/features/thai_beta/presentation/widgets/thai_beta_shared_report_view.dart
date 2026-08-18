import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_download.dart';

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
    final image = await boundary.toImage(pixelRatio: pixelRatio);
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
        children.add(
          const Padding(
            key: Key('thai_birth_profile_timeline_divider'),
            padding: EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Divider(),
          ),
        );
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
    final isTimeline = section.kind == ThaiBetaReportExportSectionKind.timeline;
    final isDisclaimer =
        section.kind == ThaiBetaReportExportSectionKind.disclaimer;
    final background = isTimeline
        ? const Color(0xfff3f1ea)
        : isDisclaimer
        ? const Color(0xfffff7e8)
        : theme.colorScheme.surface;
    final phaseLabel = switch (section.title) {
      'อดีตของคุณ' => 'อดีต',
      'ช่วงปัจจุบัน' => 'ปัจจุบัน',
      'แนวโน้มระยะยาว' => 'อนาคต',
      _ => null,
    };

    return Container(
      key: ValueKey(section.id),
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDisclaimer
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
              color: const Color(0xff18203f),
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
            const SizedBox(height: 9),
            Text(
              section.paragraphs[index],
              key: ValueKey(section.paragraphIds[index]),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.62),
            ),
          ],
        ],
      ),
    );
  }
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
        filename: 'knowme-annual-horoscope-${data.buddhistYear}.png',
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
            'ภาพสรุปรายปี',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Semantics(
            image: true,
            label:
                '${data.title} สรุปการงาน การเงิน ความรัก สุขภาพ โอกาสและข้อควรระวัง',
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
    const navy = Color(0xff101832);
    const indigo = Color(0xff1b2852);
    const gold = Color(0xffc7a760);
    const cream = Color(0xfffff8e8);
    const ivory = Color(0xfff5f0e4);
    const teal = Color(0xff2d8f86);
    const amber = Color(0xffa55f35);

    return Container(
      key: const Key('thai_annual_infographic_canvas'),
      width: ThaiBetaAnnualInfographicCapture.logicalSize.width,
      height: ThaiBetaAnnualInfographicCapture.logicalSize.height,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: const BoxDecoration(color: navy),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: cream,
          height: 1.28,
          fontFamily: 'KnowMeNotoSansThai',
          fontFamilyFallback: ['KnowMeNotoSans'],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const _InfographicGlyph(name: 'spark', color: gold, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              data.theme,
              maxLines: 2,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: gold,
                fontSize: data.theme.length > 96
                    ? 8.3
                    : data.theme.length > 72
                    ? 9.2
                    : 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              data.overview,
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: const TextStyle(color: ivory, fontSize: 9.5),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < data.categories.length;
                    index++
                  ) ...[
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final category = data.categories[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: ivory,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: gold.withValues(alpha: .55),
                              ),
                            ),
                            child: Row(
                              children: [
                                _InfographicGlyph(
                                  name: category.iconName,
                                  color: indigo,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: 48,
                                  child: Text(
                                    category.title,
                                    style: const TextStyle(
                                      color: indigo,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    category.summary,
                                    maxLines: 2,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      color: navy,
                                      fontSize: category.summary.length > 100
                                          ? 7.2
                                          : category.summary.length > 76
                                          ? 7.8
                                          : 8.4,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    if (index < data.categories.length - 1)
                      const SizedBox(height: 6),
                  ],
                ],
              ),
            ),
            const Expanded(child: _ConstellationDivider()),
            const SizedBox(height: 7),
            _Band(
              iconName: 'opportunity',
              label: 'โอกาสดี',
              value: data.opportunity,
              color: teal,
            ),
            const SizedBox(height: 6),
            _Band(
              iconName: 'shield',
              label: 'ควรระวัง',
              value: data.caution,
              color: amber,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: indigo,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: gold.withValues(alpha: .5)),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'คำแนะนำสำคัญ  ',
                      style: TextStyle(
                        color: gold,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: data.primaryAdvice,
                      style: TextStyle(
                        color: cream,
                        fontSize: data.primaryAdvice.length > 120 ? 7.2 : 8,
                      ),
                    ),
                  ],
                ),
                maxLines: 3,
                overflow: TextOverflow.visible,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              data.disclaimer,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: const TextStyle(color: Color(0xffd8d3c8), fontSize: 7.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConstellationDivider extends StatelessWidget {
  const _ConstellationDivider();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _ConstellationPainter(),
      size: Size(double.infinity, double.infinity),
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  const _ConstellationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final line = Paint()
      ..color = const Color(0xffc7a760).withValues(alpha: .28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7;
    final dot = Paint()
      ..color = const Color(0xffc7a760).withValues(alpha: .55)
      ..style = PaintingStyle.fill;
    final center = Offset(size.width * .5, size.height * .52);
    final radius = size.height * .34;
    canvas.drawCircle(center, radius, line);
    canvas.drawCircle(center, radius * .72, line);
    final points = <Offset>[
      Offset(center.dx - radius * .86, center.dy + radius * .12),
      Offset(center.dx - radius * .42, center.dy - radius * .58),
      Offset(center.dx, center.dy - radius * .18),
      Offset(center.dx + radius * .36, center.dy - radius * .7),
      Offset(center.dx + radius * .82, center.dy + radius * .18),
      Offset(center.dx + radius * .2, center.dy + radius * .66),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, line);
    for (final point in points) {
      canvas.drawCircle(point, 2.1, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) => false;
}

class _Band extends StatelessWidget {
  const _Band({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfographicGlyph(name: iconName, color: Colors.white, size: 15),
          const SizedBox(width: 7),
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: Colors.white,
                fontSize: value.length > 100 ? 8 : 8.6,
                height: 1.25,
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
