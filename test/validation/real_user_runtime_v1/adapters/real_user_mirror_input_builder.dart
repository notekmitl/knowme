import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/mirror_v3/contracts/knowme_mirror_identity_contract.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_astrology_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_bazi_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_engine_input.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_theme_signal.dart';
import 'package:knowme/features/mirror_v3/models/knowme_mirror_lineage_chain.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_load_result.dart';
import 'package:knowme/features/runtime_integration/adapters/runtime_astrology_mirror_signal_merger.dart';
import 'package:knowme/features/runtime_integration/adapters/runtime_thai_theme_loader.dart';
import 'package:knowme/features/runtime_integration/pipeline/runtime_mirror_input_builder.dart';

import '../models/real_user_export_record.dart';
import 'real_user_lens_loader.dart';

/// Validation-only mirror input builder for exported Firestore users.
abstract final class RealUserMirrorInputBuilder {
  static KnowMeMirrorEngineInput? buildAstrologyInput(
    RealUserExportRecord user, {
    DateTime? generatedAt,
  }) {
    final birthData = RealUserProfileParser.toThaiBirthData(user.profile);
    if (birthData == null) return null;

    final themeBundle = RuntimeThaiThemeLoader.loadFromBirthData(birthData);
    final thaiSignals = KnowMeMirrorAstrologyAdapter.extract(themeBundle);

    final baziMap = user.baziChartMap();
    final baziSignals = baziMap == null
        ? const <KnowMeMirrorThemeSignal>[]
        : KnowMeMirrorBaziAdapter.extract(BaziChartModel.fromMap(baziMap));

    final signals = baziSignals.isEmpty
        ? thaiSignals
        : RuntimeAstrologyMirrorSignalMerger.merge(thaiSignals, baziSignals);

    final now = (generatedAt ?? themeBundle.generatedAt).toUtc();
    final lineage = KnowMeMirrorLineageChain(
      mirrorScopeId: KnowMeMirrorIdentityContract.mirrorScopeId(
        astrologyThemeSnapshotId: themeBundle.bundleId,
      ),
      astrologyThemeSnapshotId: themeBundle.bundleId,
      astrologyThemeBundleId: themeBundle.bundleId,
      astrologyMeaningSnapshotId: themeBundle.sourceInterpretationBundleId,
      personalityOnly: false,
      sourceSnapshotVersions: {
        'thai_astrology': 'thai_theme_v2',
        if (baziMap != null)
          'chinese_bazi': (baziMap['version'] as String?) ?? 'bazi_v1',
      },
    );

    return KnowMeMirrorEngineInput(
      lineage: lineage,
      signals: signals,
      generatedAt: now,
    );
  }

  static KnowMeMirrorEngineInput? buildPersonalityInput(
    RealUserExportRecord user, {
    DateTime? generatedAt,
  }) {
    final lensLoad = RealUserLensLoader.load(user);
    if (lensLoad.availableSnapshots.isEmpty) return null;

    return RuntimeMirrorInputBuilder.buildPersonalityInput(
      lensLoad: lensLoad,
      generatedAt: generatedAt,
    );
  }
}

abstract final class RealUserProfileParser {
  static ThaiBirthData? toThaiBirthData(Map<String, dynamic>? profile) {
    if (profile == null) return null;

    final birthDateRaw = profile['birthDate']?.toString().trim() ?? '';
    if (birthDateRaw.isEmpty) return null;

    final parsedDate = DateTime.tryParse(birthDateRaw);
    if (parsedDate == null) return null;

    final birthTimeRaw = profile['birthTime']?.toString().trim() ?? '';
    final hasBirthTime = birthTimeRaw.isNotEmpty && birthTimeRaw != 'unknown';
    var hour = 12;
    var minute = 0;
    if (hasBirthTime) {
      final parts = birthTimeRaw.split(':');
      hour = int.tryParse(parts.first) ?? 12;
      minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    }

    final latitude = (profile['latitude'] as num?)?.toDouble() ?? 13.7563;
    final longitude = (profile['longitude'] as num?)?.toDouble() ?? 100.5018;
    final timezone = profile['timezone']?.toString() ?? 'Asia/Bangkok';

    return ThaiBirthData(
      localDateTime: DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        hour,
        minute,
      ),
      timeZoneOffset: _offsetForTimezone(timezone),
      latitude: latitude,
      longitude: longitude,
      hasBirthTime: hasBirthTime,
    );
  }

  static Duration _offsetForTimezone(String timezone) {
    final normalized = timezone.toLowerCase();
    if (normalized.contains('bangkok') || normalized == 'asia/bangkok') {
      return const Duration(hours: 7);
    }
    return Duration.zero;
  }
}
