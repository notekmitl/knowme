import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis_clock.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_astrology_handoff.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_current_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/presentation/pages/astrology/astrology_result_page.dart';
import 'package:knowme/presentation/pages/bazi/bazi_result_page.dart';
import 'package:knowme/presentation/providers/astrology_provider.dart';
import 'package:knowme/presentation/providers/bazi_provider.dart';
import 'package:knowme/presentation/providers/locale_provider.dart';
import 'package:provider/provider.dart';

import 'thai_beta_astrology_sign_in_page.dart';
import 'thai_beta_summary_page.dart';

enum ThaiBetaAstrologySystem { thai, bazi, western }

typedef ThaiBetaSelectionAnalysisExecutor =
    Future<ThaiBetaAnalysis> Function(
      ThaiBetaInput input, {
      required DateTime startedAt,
      required DateTime asOf,
    });
typedef ThaiBetaAstrologyUserResolver =
    Future<String?> Function(BuildContext context);
typedef ThaiBetaAstrologySystemPreparer =
    Future<ThaiBetaPreparedAstrology> Function(
      String userId,
      ThaiBetaInput input,
      ThaiBetaAstrologySystem system,
    );
typedef ThaiBetaAstrologyDestinationBuilder =
    Widget Function(
      BuildContext context,
      String userId,
      ThaiBetaAstrologySystem system,
      ThaiBetaPreparedAstrology preparedResult,
    );

/// The single post-form decision point for Thai, Chinese BaZi, and the existing
/// Western natal system.
class ThaiBetaAstrologySelectionPage extends StatefulWidget {
  const ThaiBetaAstrologySelectionPage({
    super.key,
    required this.input,
    required this.startedAt,
    required this.submittedAt,
    required this.analysisExecutor,
    this.resolveUser = _resolveAuthenticatedUser,
    this.prepareSystem = _prepareSelectedSystem,
    this.destinationBuilder = _buildDestination,
  });

  final ThaiBetaInput input;
  final DateTime startedAt;
  final DateTime submittedAt;
  final ThaiBetaSelectionAnalysisExecutor analysisExecutor;
  final ThaiBetaAstrologyUserResolver resolveUser;
  final ThaiBetaAstrologySystemPreparer prepareSystem;
  final ThaiBetaAstrologyDestinationBuilder destinationBuilder;

  @override
  State<ThaiBetaAstrologySelectionPage> createState() =>
      _ThaiBetaAstrologySelectionPageState();
}

class _ThaiBetaAstrologySelectionPageState
    extends State<ThaiBetaAstrologySelectionPage> {
  ThaiBetaAstrologySystem? _busySystem;

  bool get _westernReady =>
      widget.input.hasBirthTime &&
      (widget.input.provinceKey?.trim().isNotEmpty ?? false);

  Future<void> _select(ThaiBetaAstrologySystem system) async {
    if (_busySystem != null) return;
    if (system == ThaiBetaAstrologySystem.western && !_westernReady) return;
    setState(() => _busySystem = system);

    try {
      if (system == ThaiBetaAstrologySystem.thai) {
        final analysis = await widget.analysisExecutor(
          widget.input,
          startedAt: widget.startedAt,
          asOf: ThaiBetaAnalysisClock.asBangkokCivil(widget.submittedAt),
        );
        if (!mounted) return;
        ThaiBetaCurrentAnalysis.set(analysis);
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ThaiBetaSummaryPage(analysis: analysis),
          ),
        );
        return;
      }

      final userId = await widget.resolveUser(context);
      if (!mounted || userId == null || userId.trim().isEmpty) return;
      final preparedResult = await widget.prepareSystem(
        userId,
        widget.input,
        system,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => widget.destinationBuilder(
            context,
            userId,
            system,
            preparedResult,
          ),
        ),
      );
    } catch (error, stack) {
      debugPrint('[ThaiBetaAstrologySelection] $system failed: $error');
      debugPrint('[ThaiBetaAstrologySelection] $stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            system == ThaiBetaAstrologySystem.thai
                ? 'สร้างผลโหราศาสตร์ไทยไม่สำเร็จ กรุณาลองอีกครั้ง'
                : 'สร้างดวงที่เลือกไม่สำเร็จ กรุณาลองอีกครั้ง',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busySystem = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final input = widget.input;
    final date = input.birthDate;
    final timeLabel = input.hasBirthTime
        ? '${input.birthHour!.toString().padLeft(2, '0')}:'
              '${input.birthMinute.toString().padLeft(2, '0')}'
        : 'ไม่ทราบเวลาเกิด';

    return Scaffold(
      appBar: AppBar(title: const Text('เลือกศาสตร์ที่ต้องการดู')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              children: [
                Text(
                  'อยากดูดวงแบบไหน?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ใช้ข้อมูลเกิดชุดเดียวกัน แล้วเลือกศาสตร์ที่ต้องการอ่านได้เลย',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  key: const Key('astrology-selection-birth-summary'),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${input.fullName} · ${date.day}/${date.month}/${date.year} · '
                    '$timeLabel${input.province == null ? '' : ' · ${input.province}'}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 18),
                _AstrologySystemCard(
                  key: const Key('astrology-system-thai'),
                  icon: Icons.temple_buddhist_outlined,
                  title: 'โหราศาสตร์ไทย',
                  description:
                      'อ่านพื้นดวงไทยและช่วงชีวิตด้วยระบบที่ผ่าน Owner QA แล้ว',
                  buttonKey: const Key('astrology-select-thai'),
                  buttonLabel: 'ดูดวงไทย',
                  busy: _busySystem == ThaiBetaAstrologySystem.thai,
                  enabled: _busySystem == null,
                  onPressed: () => _select(ThaiBetaAstrologySystem.thai),
                ),
                const SizedBox(height: 14),
                _AstrologySystemCard(
                  key: const Key('astrology-system-bazi'),
                  icon: Icons.auto_awesome_outlined,
                  title: 'โหราศาสตร์จีน · ปาจื้อ (BaZi)',
                  description: input.hasBirthTime
                      ? 'อ่านพื้นดวงจากสี่เสา พร้อมคำอ่านการงาน การเงิน ความสัมพันธ์ จุดแข็ง และสิ่งที่ควรระวัง'
                      : 'อ่านจากสามเสาที่ตรวจยืนยันได้ โดยตัดเสาชั่วโมงและข้อมูลที่ต้องใช้เวลาเกิดออก',
                  buttonKey: const Key('astrology-select-bazi'),
                  buttonLabel: 'ดูโหราจีน',
                  busy: _busySystem == ThaiBetaAstrologySystem.bazi,
                  enabled: _busySystem == null,
                  onPressed: () => _select(ThaiBetaAstrologySystem.bazi),
                ),
                const SizedBox(height: 14),
                _AstrologySystemCard(
                  key: const Key('astrology-system-western'),
                  icon: Icons.public_outlined,
                  title: 'โหราศาสตร์ตะวันตก (ยุโรป)',
                  description: _westernReady
                      ? 'อ่านดวงกำเนิดแบบตะวันตกทั้ง Big 3 ธาตุ ดาวเด่น เรือนชีวิต และมุมดาวสำคัญ'
                      : 'ต้องทราบเวลาเกิดและเลือกจังหวัดก่อน จึงคำนวณลัคนาและเรือนได้โดยไม่เดา',
                  buttonKey: const Key('astrology-select-western'),
                  buttonLabel: 'ดูโหราตะวันตก',
                  busy: _busySystem == ThaiBetaAstrologySystem.western,
                  enabled: _busySystem == null && _westernReady,
                  onPressed: () => _select(ThaiBetaAstrologySystem.western),
                ),
                const SizedBox(height: 18),
                Text(
                  'โหราจีนและโหราตะวันตกจะให้เข้าสู่ระบบก่อน เพื่อผูกผลคำนวณกับเจ้าของข้อมูลและป้องกันการเขียนผลข้ามบัญชี',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AstrologySystemCard extends StatelessWidget {
  const _AstrologySystemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonKey,
    required this.buttonLabel,
    required this.busy,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final Key buttonKey;
  final String buttonLabel;
  final bool busy;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: Icon(icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton(
              key: buttonKey,
              onPressed: enabled ? onPressed : null,
              child: busy
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> _resolveAuthenticatedUser(BuildContext context) async {
  final current = FirebaseAuth.instance.currentUser;
  if (current != null) return current.uid;
  final userId = await Navigator.of(context).push<String>(
    MaterialPageRoute<String>(
      builder: (_) => const ThaiBetaAstrologySignInPage(),
    ),
  );
  final verified = FirebaseAuth.instance.currentUser;
  return userId != null && verified?.uid == userId ? userId : null;
}

Future<ThaiBetaPreparedAstrology> _prepareSelectedSystem(
  String userId,
  ThaiBetaInput input,
  ThaiBetaAstrologySystem system,
) {
  return ThaiBetaAstrologyHandoff().prepare(
    userId: userId,
    input: input,
    systemId: switch (system) {
      ThaiBetaAstrologySystem.bazi => 'bazi',
      ThaiBetaAstrologySystem.western => 'western',
      ThaiBetaAstrologySystem.thai => throw StateError(
        'Thai analysis does not use the signed-in handoff',
      ),
    },
  );
}

Widget _buildDestination(
  BuildContext _,
  String userId,
  ThaiBetaAstrologySystem system,
  ThaiBetaPreparedAstrology preparedResult,
) {
  return switch (system) {
    ThaiBetaAstrologySystem.bazi => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BaziProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: BaziResultPage(
        userId: userId,
        preparedResult: true,
        preparedChart: preparedResult.baziChart,
      ),
    ),
    ThaiBetaAstrologySystem.western => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AstrologyProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: AstrologyResultPage(
        userId: userId,
        preparedChart: preparedResult.westernChart,
      ),
    ),
    ThaiBetaAstrologySystem.thai => throw StateError(
      'Thai analysis has its own destination',
    ),
  };
}
