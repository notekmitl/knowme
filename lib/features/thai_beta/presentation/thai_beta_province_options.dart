import 'package:knowme/features/birth_normalization/application/thai_provinces.dart';

/// A selectable Thai province for the research form.
///
/// [resolverKey] matches Birth Normalization's province table (lowercase
/// English) so coordinates resolve; [labelTh] is what the user sees and what we
/// display in the summary/debug panels.
class ThaiBetaProvinceOption {
  const ThaiBetaProvinceOption(this.resolverKey, this.labelTh);
  final String resolverKey;
  final String labelTh;
}

/// All 77 Thai provinces, derived from the canonical Birth Normalization table
/// ([kThaiProvincesAll]) so the selectable set can never drift from the
/// resolvable set. Sorted by Thai name for the picker.
final List<ThaiBetaProvinceOption> kThaiBetaProvinces = [
  for (final p in kThaiProvincesAll)
    ThaiBetaProvinceOption(p.key, p.nameTh),
]..sort((a, b) => a.labelTh.compareTo(b.labelTh));
