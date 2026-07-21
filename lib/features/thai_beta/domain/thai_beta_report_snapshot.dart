import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';

/// Builds a JSON-safe snapshot of the Thai report the user actually saw.
///
/// Captures both the structured engine profile and the rendered consumer copy,
/// so feedback ("which part felt accurate?") can be correlated with content.
abstract final class ThaiBetaReportSnapshot {
  static Map<String, dynamic> build({
    required ThaiAstrologyProfile profile,
    required ThaiMirrorConsumerViewState view,
  }) {
    return {
      'profile': {
        'calculationStandardVersion': profile.calculationStandardVersion,
        'hasBirthTime': profile.hasBirthTime,
        'lagnaKey': profile.lagnaKey,
        'lagnaLordKey': profile.lagnaLordKey,
        'dominantMyanmarKey': profile.dominantMyanmarKey,
        'myanmarKeys': profile.myanmarKeys,
        'mahabhutaPositionKeys': profile.mahabhutaPositionKeys,
        'row4Sum': profile.row4Sum,
        'siderealAscendantDeg': profile.siderealAscendantDeg,
        'warnings': profile.warnings.map((w) => w.code).toList(),
      },
      'report': {
        'heroHeadline': view.hero.headline,
        'heroSummary': view.hero.summary,
        'heroTags': view.hero.tags,
        'signatureInsight': view.signatureInsight.body,
        'strengths':
            view.strengths.cards.map((c) => c.title).toList(),
        'cautions': view.cautions.cards.map((c) => c.title).toList(),
        'adviceTitle': view.advice.title,
        'lifeDashboard': view.lifeDashboard
            .map((i) => {'label': i.label, 'status': i.status.name})
            .toList(),
        'narrativeSections':
            view.narrativeSections.map((s) => s.label).toList(),
        'reflectionPoints': view.reflectionSummary.points,
        'closingMessage': view.closingMessage.message,
      },
    };
  }
}
