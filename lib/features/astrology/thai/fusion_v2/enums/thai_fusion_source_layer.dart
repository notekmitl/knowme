/// Source layer for [ThaiFusionEvidence].
enum ThaiFusionSourceLayer {
  mirror,
  theme,
  interpretation,
}

extension ThaiFusionSourceLayerLabels on ThaiFusionSourceLayer {
  String get id {
    return switch (this) {
      ThaiFusionSourceLayer.mirror => 'mirror',
      ThaiFusionSourceLayer.theme => 'theme',
      ThaiFusionSourceLayer.interpretation => 'interpretation',
    };
  }
}

ThaiFusionSourceLayer? parseThaiFusionSourceLayer(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final layer in ThaiFusionSourceLayer.values) {
    if (layer.id == normalized) {
      return layer;
    }
  }
  return null;
}
