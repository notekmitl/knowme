/// Frozen identity formula for [ThaiContentFragment.resolutionId].
///
/// Generation logic is implemented in C1+ — C0 stores the field only.
abstract final class ThaiContentFragmentIdentityContract {
  /// `{predicate.id}:{objectRef}[:{contextSuffix}]:{fragmentKind.id}[:{fragmentIndex}]`
  ///
  /// [contextSuffix] is empty when context is empty; otherwise
  /// `ctx-{k}={v},...` with keys in lexicographic order.
  ///
  /// Excluded from identity: resolverVersion, contentKey, text, factId.
  static const resolutionIdFormula =
      '{predicate.id}:{objectRef}[:{contextSuffix}]:{fragmentKind.id}[:{fragmentIndex}]';

  static const contextSuffixPrefix = 'ctx-';
  static const segmentDelimiter = ':';
}
