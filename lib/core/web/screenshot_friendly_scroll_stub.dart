/// Aggregate diagnostics for screenshot-mode verification (non-web: unavailable).
class ScreenshotHostDiagnostics {
  const ScreenshotHostDiagnostics({
    required this.windowInnerHeight,
    required this.documentScrollHeight,
    required this.bodyScrollHeight,
    required this.reportContentHeight,
    required this.screenshotModeActive,
  });

  final double windowInnerHeight;
  final double documentScrollHeight;
  final double bodyScrollHeight;
  final double reportContentHeight;
  final bool screenshotModeActive;
}

/// No-op on non-web platforms.
void enableScreenshotFriendlyScroll({double? contentHeightPx}) {}

void resetScreenshotHostHeight() {}

void syncScreenshotHostHeight(double contentHeightPx) {}

ScreenshotHostDiagnostics? readScreenshotHostDiagnostics({
  double reportContentHeight = 0,
}) =>
    null;

void disableScreenshotFriendlyScroll() {}
