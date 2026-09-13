import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:knowme/features/astrology/application/astrology_generation_coordinator.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_state.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_widgets.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_pdf_assets.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_pdf_exporter.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_report_builder.dart';
import 'package:knowme/features/bazi_compatibility/presentation/bazi_compatibility_report_view.dart';
import 'package:knowme/presentation/providers/bazi_provider.dart';
import 'package:knowme/presentation/providers/locale_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class BaziResultPage extends StatefulWidget {
  const BaziResultPage({super.key, this.userId, this.generationCoordinator});

  /// When set (for example in tests), skips the Firebase Auth uid lookup.
  final String? userId;
  final AstrologyGenerationCoordinator? generationCoordinator;

  @override
  State<BaziResultPage> createState() => _BaziResultPageState();
}

class _BaziResultPageState extends State<BaziResultPage> {
  AstrologyGenerationCoordinator? _coordinator;
  bool _autoGenerating = true;
  bool _baziReady = false;

  AstrologyGenerationCoordinator get _generationCoordinator =>
      widget.generationCoordinator ??
      (_coordinator ??= AstrologyGenerationCoordinator());

  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    final uid = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (!mounted) return;
    if (uid == null || uid.isEmpty) {
      setState(() => _autoGenerating = false);
      return;
    }

    final provider = context.read<BaziProvider>();
    await provider.loadChart(uid);
    if (!mounted) return;

    try {
      final snapshot = await _generationCoordinator.ensureGenerated(
        uid,
        retrySystemId: 'bazi',
      );
      if (!mounted) return;
      _baziReady = snapshot.system('bazi').isReady;
      if (_baziReady) await provider.loadChart(uid);
    } catch (_) {
      _baziReady = false;
    } finally {
      if (mounted) setState(() => _autoGenerating = false);
    }
  }

  Future<void> _retryGeneration() async {
    final uid = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (!mounted || uid == null || uid.isEmpty) return;
    setState(() {
      _autoGenerating = true;
      _baziReady = false;
    });
    try {
      final snapshot = await _generationCoordinator.ensureGenerated(
        uid,
        retrySystemId: 'bazi',
      );
      if (!mounted) return;
      _baziReady = snapshot.system('bazi').isReady;
      if (_baziReady) await context.read<BaziProvider>().loadChart(uid);
    } catch (_) {
      _baziReady = false;
    } finally {
      if (mounted) setState(() => _autoGenerating = false);
    }
  }

  Future<void> _exportPdf(String languageCode) async {
    final chart = context.read<BaziProvider>().chart;
    if (chart == null) return;
    try {
      final fonts = await BaziCompatibilityPdfAssets.load();
      final bytes = await BaziCompatibilityPdfExporter.build(
        report: BaziCompatibilityReportBuilder.build(
          chart,
          languageCode: languageCode,
        ),
        fonts: fonts,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'knowme-bazi-compatibility-v1.pdf',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ส่งออก PDF ไม่สำเร็จ: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<LocaleProvider>().locale.languageCode;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0F8),
        title: const Text('KnowMe BaZi Compatibility V1'),
      ),
      body: Consumer<BaziProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading || _autoGenerating) {
            return AstrologyGenerationBody(
              title: AstrologyFlowCopy.generationTitle('ดวงปาจื้อ'),
              body: AstrologyFlowCopy.generationBody('ดวงปาจื้อ'),
            );
          }
          if (!_baziReady || provider.error != null || provider.chart == null) {
            return AstrologyFlowStateBody(
              state: AstrologyFlowState.failed,
              onPrimaryAction: _retryGeneration,
              primaryActionLabel: AstrologyFlowCopy.retryCta,
            );
          }

          final report = BaziCompatibilityReportBuilder.build(
            provider.chart!,
            languageCode: languageCode,
          );
          return BaziCompatibilityReportView(
            report: report,
            onExport: () => _exportPdf(languageCode),
          );
        },
      ),
    );
  }
}
