import '../constants/thai_content_resolver_version.dart';
import '../enums/thai_content_fragment_kind.dart';

/// Frozen C0 contracts for Content Lookup Layer.
abstract final class ThaiContentLookupContract {
  static const resolverVersion =
      ThaiContentResolverVersionContract.resolverVersion;

  /// C0 fragment kinds emitted by default lookup policy.
  static const supportedFragmentKinds = <ThaiContentFragmentKind>[
    ThaiContentFragmentKind.title,
    ThaiContentFragmentKind.coreNature,
  ];

  /// Delimiter for [ThaiContentBundleIdentityContract.resolutionBundleId].
  static const bundleIdDelimiter = '|';

  /// Lookup/catalog warning codes (C0).
  static const warningSectionNotFound = 'CONTENT_SECTION_NOT_FOUND';
  static const warningFragmentFieldEmpty = 'CONTENT_FRAGMENT_FIELD_EMPTY';
}
