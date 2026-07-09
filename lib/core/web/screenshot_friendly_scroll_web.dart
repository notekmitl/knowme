import 'dart:html' as html;
import 'dart:js' as js;

import 'screenshot_friendly_scroll_stub.dart';

/// Enables document-level scroll for GoFullPage / full-page capture extensions.
void enableScreenshotFriendlyScroll({double? contentHeightPx}) {
  html.document.documentElement?.classes.add('screenshot-friendly');
  if (contentHeightPx != null && contentHeightPx > 0) {
    syncScreenshotHostHeight(contentHeightPx);
  }
}

void syncScreenshotHostHeight(double contentHeightPx) {
  final heightPx = contentHeightPx.ceil();
  html.document.documentElement?.style.setProperty(
    '--thai-beta-report-content-height',
    '${heightPx}px',
  );

  if (js.context.hasProperty('__syncThaiBetaScreenshotHost')) {
    js.context.callMethod('__syncThaiBetaScreenshotHost', [heightPx]);
    return;
  }

  _applyHostHeightFallback(heightPx);
}

void _applyHostHeightFallback(int heightPx) {
  final minHeight = '${heightPx}px';
  final selectors = <String>[
    'body',
    'flt-glass-pane',
    'flutter-view',
    'flt-scene-host',
    '#flutter_target',
  ];
  for (final selector in selectors) {
    for (final element in html.document.querySelectorAll(selector)) {
      element.style.setProperty('height', 'auto', 'important');
      element.style.setProperty('min-height', minHeight, 'important');
      element.style.setProperty('overflow', 'visible', 'important');
      element.style.setProperty('overflow-y', 'visible', 'important');
    }
  }
}

ScreenshotHostDiagnostics? readScreenshotHostDiagnostics({
  double reportContentHeight = 0,
}) {
  final window = html.window;
  return ScreenshotHostDiagnostics(
    windowInnerHeight: window.innerHeight?.toDouble() ?? 0,
    documentScrollHeight:
        html.document.documentElement?.scrollHeight.toDouble() ?? 0,
    bodyScrollHeight: html.document.body?.scrollHeight.toDouble() ?? 0,
    reportContentHeight: reportContentHeight,
    screenshotModeActive: html.document.documentElement?.classes
            .contains('screenshot-friendly') ??
        false,
  );
}

void disableScreenshotFriendlyScroll() {
  html.document.documentElement?.classes.remove('screenshot-friendly');
  html.document.documentElement?.style.removeProperty(
    '--thai-beta-report-content-height',
  );
}
