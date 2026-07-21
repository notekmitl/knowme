import '../content/models/thai_content_section.dart';
import '../content/registry/thai_content_registry.dart';
import '../foundation/models/profile_warning.dart';
import '../interpretation/enums/thai_meaning_predicate.dart';
import '../interpretation/models/thai_interpretation_bundle.dart';
import '../interpretation/models/thai_interpretation_fact.dart';
import 'contracts/thai_content_fragment_identity_contract.dart';
import 'contracts/thai_content_lookup_contract.dart';
import 'enums/thai_content_fragment_kind.dart';
import 'mapper/thai_fact_to_content_key_mapper.dart';
import 'models/thai_content_fragment.dart';
import 'models/thai_content_resolution_bundle.dart';

class ThaiContentLookupEngineResult {
  const ThaiContentLookupEngineResult({
    required this.bundle,
    required this.warnings,
  });

  final ThaiContentResolutionBundle bundle;
  final List<ProfileWarning> warnings;
}

/// Resolves [ThaiInterpretationFact] values into readable content fragments.
abstract final class ThaiContentLookupEngine {
  static const warningKeyUnresolved = 'CONTENT_KEY_UNRESOLVED';

  static ThaiContentLookupEngineResult lookup(
    ThaiInterpretationBundle bundle,
  ) {
    final fragments = <ThaiContentFragment>[];
    final warnings = <ProfileWarning>[];

    for (final fact in bundle.facts) {
      if (!ThaiFactToContentKeyMapper.canResolve(fact)) {
        continue;
      }

      final contentKey = ThaiFactToContentKeyMapper.resolveKey(fact);
      if (contentKey == null) {
        warnings.add(_keyUnresolvedWarning(fact));
        continue;
      }

      final section = ThaiContentRegistry.resolve(contentKey);
      if (section == null) {
        warnings.add(_sectionNotFoundWarning(fact, contentKey));
        continue;
      }

      for (final kind in ThaiContentLookupContract.supportedFragmentKinds) {
        final text = _textForKind(section, kind);
        if (text == null || text.trim().isEmpty) {
          continue;
        }

        fragments.add(
          ThaiContentFragment(
            resolutionId: resolutionId(
              fact: fact,
              fragmentKind: kind,
            ),
            fragmentKind: kind,
            text: text.trim(),
            sourceFactId: fact.factId,
            contentKey: contentKey,
            contentVersion: section.version,
          ),
        );
      }
    }

    fragments.sort((a, b) => a.resolutionId.compareTo(b.resolutionId));

    final resolutionBundle = ThaiContentResolutionBundle(
      resolutionBundleId: resolutionBundleId(
        sourceInterpretationBundleId: bundle.bundleId,
      ),
      sourceInterpretationBundleId: bundle.bundleId,
      resolverVersion: ThaiContentLookupContract.resolverVersion,
      resolvedAt: DateTime.now().toUtc(),
      fragments: List<ThaiContentFragment>.unmodifiable(fragments),
      warnings: List<ProfileWarning>.unmodifiable(warnings),
    );

    return ThaiContentLookupEngineResult(
      bundle: resolutionBundle,
      warnings: resolutionBundle.warnings,
    );
  }

  static String resolutionId({
    required ThaiInterpretationFact fact,
    required ThaiContentFragmentKind fragmentKind,
    int? fragmentIndex,
  }) {
    final contextSuffix = _formatContextSuffix(fact.context);
    final contextSegment = contextSuffix.isEmpty ? '' : ':$contextSuffix';
    final indexSegment = fragmentIndex == null ? '' : ':$fragmentIndex';
    return '${fact.predicate.id}:${fact.objectRef}$contextSegment:'
        '${fragmentKind.id}$indexSegment';
  }

  static String _formatContextSuffix(Map<String, String> context) {
    if (context.isEmpty) {
      return '';
    }

    final keys = context.keys.toList()..sort();
    return '${ThaiContentFragmentIdentityContract.contextSuffixPrefix}'
        '${keys.map((key) => '$key=${context[key]}').join(',')}';
  }

  static String resolutionBundleId({
    required String sourceInterpretationBundleId,
  }) {
    return '$sourceInterpretationBundleId'
        '${ThaiContentLookupContract.bundleIdDelimiter}'
        '${ThaiContentLookupContract.resolverVersion}';
  }

  static String? _textForKind(
    ThaiContentSection section,
    ThaiContentFragmentKind kind,
  ) {
    return switch (kind) {
      ThaiContentFragmentKind.title => section.title,
      ThaiContentFragmentKind.coreNature => section.coreNature,
      ThaiContentFragmentKind.summary ||
      ThaiContentFragmentKind.strength ||
      ThaiContentFragmentKind.challenge ||
      ThaiContentFragmentKind.growthPath =>
        null,
    };
  }

  static ProfileWarning _keyUnresolvedWarning(ThaiInterpretationFact fact) {
    return ProfileWarning(
      code: warningKeyUnresolved,
      severity: ProfileWarningSeverity.medium,
      message: 'Content key unresolved for ${fact.factId}',
      affectedFields: [fact.factId],
    );
  }

  static ProfileWarning _sectionNotFoundWarning(
    ThaiInterpretationFact fact,
    String contentKey,
  ) {
    return ProfileWarning(
      code: ThaiContentLookupContract.warningSectionNotFound,
      severity: ProfileWarningSeverity.medium,
      message: 'Content section not found for key $contentKey (${fact.factId})',
      affectedFields: [fact.factId, contentKey],
    );
  }
}
