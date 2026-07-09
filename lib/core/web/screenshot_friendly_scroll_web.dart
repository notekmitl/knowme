import 'dart:html' as html;
import 'dart:js' as js;

import 'screenshot_friendly_scroll_stub.dart';

const _hostSelectors = <String>[
  'flt-glass-pane',
  'flutter-view',
  'flt-scene-host',
  '#flutter_target',
];

/// Enables document-level scroll for GoFullPage / full-page capture extensions.
void enableScreenshotFriendlyScroll({double? contentHeightPx}) {
  html.document.documentElement?.classes.add('screenshot-friendly');
  if (contentHeightPx != null && contentHeightPx > 0) {
    syncScreenshotHostHeight(contentHeightPx);
  }
}

/// Clears host height overrides before a fresh content measurement.
void resetScreenshotHostHeight() {
  html.document.documentElement?.style.removeProperty(
    '--thai-beta-report-content-height',
  );

  if (js.context.hasProperty('__resetThaiBetaScreenshotHost')) {
    js.context.callMethod('__resetThaiBetaScreenshotHost');
    return;
  }

  _resetHostHeightFallback();
}

void syncScreenshotHostHeight(double contentHeightPx) {
  final windowHeight = html.window.innerHeight?.toDouble() ?? 0;
  // Use measured content + padding; floor at viewport so short pages still scroll.
  final heightPx = contentHeightPx.ceil().clamp(
        windowHeight > 0 ? windowHeight.ceil() : 1,
        1 << 20,
      );

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

void _resetHostHeightFallback() {
  for (final selector in _hostSelectors) {
    for (final element in html.document.querySelectorAll(selector)) {
      element.style.removeProperty('height');
      element.style.removeProperty('min-height');
      element.style.removeProperty('overflow');
      element.style.removeProperty('overflow-y');
      element.style.removeProperty('contain');
    }
  }
}

void _applyHostHeightFallback(int heightPx) {
  final minHeight = '${heightPx}px';
  for (final selector in _hostSelectors) {
    for (final element in html.document.querySelectorAll(selector)) {
      element.style.setProperty('height', 'auto', 'important');
      element.style.setProperty('min-height', minHeight, 'important');
      element.style.setProperty('overflow', 'visible', 'important');
      element.style.setProperty('overflow-y', 'visible', 'important');
      element.style.setProperty('contain', 'none', 'important');
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
  resetScreenshotHostHeight();
}
