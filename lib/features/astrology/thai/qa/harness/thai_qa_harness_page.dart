import 'package:flutter/material.dart';

import '../../core/life_period/life_period_engine.dart';
import '../../foundation/models/thai_birth_data.dart';
import '../../knowledge/canon/integration/thai_canon_evidence_repository.dart';
import '../../mirror/presentation/thai_mirror_consumer_presenter.dart';
import '../../mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import '../../mirror/runtime/thai_mirror_pipeline.dart';
import 'thai_qa_harness_profiles.dart';
import 'thai_qa_harness_spec.dart';

/// The permanent Thai Astrology QA Harness.
///
/// It renders the **production** consumer report — same pipeline
/// (`ThaiMirrorPipeline.generate`), same presenter
/// (`ThaiMirrorConsumerPresenter`), same page (`ThaiMirrorResultPage`) — and
/// only *frames* it according to a [ThaiQaHarnessSpec] (profile, age, viewport,
/// theme, locale, scenario). There is no duplicate report UI: the harness is a
/// thin, declarative wrapper used for visual QA and screenshot regression, and
/// is reusable as the template for Western / Chinese / Fusion / Future / Compat.
class ThaiQaHarnessPage extends StatefulWidget {
  const ThaiQaHarnessPage({super.key, required this.spec});

  final ThaiQaHarnessSpec spec;

  @override
  State<ThaiQaHarnessPage> createState() => _ThaiQaHarnessPageState();
}

class _ThaiQaHarnessPageState extends State<ThaiQaHarnessPage> {
  late Future<void> _canonReady;

  @override
  void initState() {
    super.initState();
    _canonReady = ThaiCanonEvidenceRepository.loadFromAsset();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _canonReady,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildHarness(context);
      },
    );
  }

  Widget _buildHarness(BuildContext context) {
    final spec = widget.spec;
    final profile = ThaiQaHarnessProfiles.byId(spec.profileId);
    final birthData = _birthDataFor(profile.birthData, spec);

    // SAME pipeline as production.
    final result = ThaiMirrorPipeline.generate(birthData);
    final mirrorResult = result.mirrorResult;

    if (mirrorResult == null) {
      return _HarnessError(
        message: result.errorMessage ?? 'Pipeline returned no result.',
      );
    }

    // Age / future-scenario override re-derives the Life Timeline evidence from
    // the same engine, at a chosen "as of" date.
    final lifePeriods = LifePeriodEngine.fromBirthDate(
      birthData.dateOnly,
      asOf: _asOfFor(birthData, spec),
    );

    final consumer = ThaiMirrorConsumerPresenter.present(
      mirrorResult,
      lifePeriods: lifePeriods,
      profile: result.profile,
      birthData: result.birthData,
      canonIndex: ThaiCanonEvidenceRepository.cachedIndexOrNull,
    );

    Widget page = ThaiMirrorResultPage(consumerState: consumer);

    // Theme frame (light/dark) — reuses the production seed colour.
    page = Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7E57C2),
          brightness: spec.brightness,
        ),
        useMaterial3: true,
      ),
      child: page,
    );

    // Locale frame (th/en).
    page = Localizations.override(
      context: context,
      locale: spec.locale,
      child: page,
    );

    // Viewport frame (desktop/tablet/mobile) — constrains width AND overrides
    // MediaQuery so the production page's own responsive breakpoints react.
    final width = spec.viewport.width;
    if (width != null) {
      final mq = MediaQuery.of(context);
      page = ColoredBox(
        color: const Color(0xFF202124),
        child: Center(
          child: SizedBox(
            width: width,
            child: MediaQuery(
              data: mq.copyWith(size: Size(width, mq.size.height)),
              child: page,
            ),
          ),
        ),
      );
    }

    return page;
  }

  static ThaiBirthData _birthDataFor(ThaiBirthData base, ThaiQaHarnessSpec spec) {
    if (!spec.forceNoBirthTime || !base.hasBirthTime) return base;
    return ThaiBirthData(
      localDateTime: base.localDateTime,
      timeZoneOffset: base.timeZoneOffset,
      latitude: base.latitude,
      longitude: base.longitude,
      hasBirthTime: false,
    );
  }

  static DateTime _asOfFor(ThaiBirthData birthData, ThaiQaHarnessSpec spec) {
    final birth = birthData.dateOnly;
    if (spec.ageOverride != null) {
      return DateTime(birth.year + spec.ageOverride!, birth.month, birth.day);
    }
    final now = DateTime.now();
    if (spec.futureYears != null) {
      return DateTime(now.year + spec.futureYears!, now.month, now.day);
    }
    return now;
  }
}

class _HarnessError extends StatelessWidget {
  const _HarnessError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
