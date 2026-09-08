// Local evidence harness only. No Firebase initialization or reader-copy override.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

@JS('__or5rDocument')
external set evidenceDocument(JSString value);
@JS('__or5rExportPdf')
external set exportCallback(JSFunction value);
@JS('__or5rPdfBase64')
external set pdfBytes(JSString value);
@JS('__or5rPdfError')
external set pdfError(JSString value);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final unknown = Uri.base.queryParameters['mode'] == 'unknown';
  final input = ThaiBetaInput(
    firstName: 'Acceptance',
    lastName: 'Fixture',
    birthDate: DateTime(1982, 6, 6),
    birthHour: unknown ? null : 0,
    birthMinute: unknown ? 0 : 35,
    birthTimeUnknown: unknown,
    province: 'เชียงใหม่',
    provinceKey: 'chiang mai',
    gender: 'ชาย',
  );
  final asOf = DateTime(2026, 8, 29);
  final analysis = ThaiBetaAnalysisRunner.run(
    input,
    startedAt: asOf,
    asOf: asOf,
  );
  final document = ThaiBetaReportExportDocument.candidate(analysis);
  evidenceDocument = jsonEncode({
    'input': input.toMap(),
    'asOf': asOf.toIso8601String(),
    'timezoneContract': 'Asia/Bangkok civil date',
    'title': document.title,
    'subtitle': document.subtitle,
    'sections': [
      for (final s in document.sections)
        {'id': s.id, 'title': s.title, 'paragraphs': s.paragraphs},
    ],
    'infographicOmitted': document.infographic == null,
  }).toJS;
  Future<void> export() async {
    try {
      final image =
          html.document.querySelector('#knowme-print-root img')
              as html.ImageElement?;
      final png = image == null
          ? null
          : base64Decode(image.src!.split(',').last);
      final bytes = await ThaiBetaReportPdfExporter.buildBytes(
        document,
        infographicPng: png,
      );
      pdfBytes = base64Encode(bytes).toJS;
    } catch (error) {
      pdfError = error.toString().toJS;
    }
  }

  exportCallback = (() {
    unawaited(export());
  }).toJS;
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1b2852)),
        useMaterial3: true,
      ),
      home: ThaiBetaReportPage(
        analysis: analysis,
        audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        screenshotModeOverride: true,
        showCaptureModeBanner: true,
        captureBannerMessage:
            'OR5R local runtime evidence — not Owner content acceptance',
      ),
    ),
  );
}
