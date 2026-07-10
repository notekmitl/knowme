/// Aggregate diagnostics for screenshot-mode verification (non-web: unavailable).
class ScreenshotHostDiagnostics {
  const ScreenshotHostDiagnostics({
    required this.windowInnerHeight,
    required this.documentScrollHeight,
    required this.bodyScrollHeight,
    required this.reportContentHeight,
    required this.appliedHostHeight,
    required this.screenshotModeActive,
  });

  final double windowInnerHeight;
  final double documentScrollHeight;
  final double bodyScrollHeight;
  final double reportContentHeight;
  final double appliedHostHeight;
  final bool screenshotModeActive;
}

/// No-op on non-web platforms.
void enableScreenshotFriendlyScroll({double? contentHeightPx}) {}

void resetScreenshotHostHeight() {}

void syncScreenshotHostHeight(double contentHeightPx) {}

double readAppliedHostHeightPx() => 0;

double computeScreenshotHostHeight({
  required double contentHeightPx,
  required double topPaddingPx,
  double hostPaddingPx = 80,
  double? windowInnerHeightPx,
}) {
  final measured = contentHeightPx + topPaddingPx + hostPaddingPx;
  final viewport = windowInnerHeightPx ?? 0;
  if (viewport <= 0) return measured;
  return measured > viewport ? measured : viewport;
}

ScreenshotHostDiagnostics? readScreenshotHostDiagnostics({
  double reportContentHeight = 0,
}) =>
    null;

void disableScreenshotFriendlyScroll() {}
