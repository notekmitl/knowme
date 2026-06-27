/// Coarse band for the net transit impact.
enum TransitImpactBand {
  stronglyFavourable,
  favourable,
  neutral,
  unfavourable,
  stronglyUnfavourable,
}

/// V15 — the aggregate net effect of the current transit (−100..+100) plus its
/// band. This is *not* a prediction or a decision — it is the summed evidence
/// nudge the transit contributes. Evidence only.
class TransitImpact {
  const TransitImpact({required this.net, required this.band});

  factory TransitImpact.fromNet(int net) {
    final clamped = net < -100 ? -100 : (net > 100 ? 100 : net);
    return TransitImpact(net: clamped, band: _bandFor(clamped));
  }

  /// Net signed nudge (−100..+100).
  final int net;
  final TransitImpactBand band;

  static TransitImpactBand _bandFor(int net) {
    if (net >= 30) return TransitImpactBand.stronglyFavourable;
    if (net >= 10) return TransitImpactBand.favourable;
    if (net > -10) return TransitImpactBand.neutral;
    if (net > -30) return TransitImpactBand.unfavourable;
    return TransitImpactBand.stronglyUnfavourable;
  }
}
