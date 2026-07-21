import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:math' as math;

import 'screenshot_friendly_scroll_stub.dart';

const _hostHeightVar = '--thai-beta-report-host-height';
const _legacyHeightVar = '--thai-beta-report-content-height';

const _flutterHostSelectors = <String>[
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

/// Clears document/html/body/host height overrides before measuring content.
void resetScreenshotHostHeight() {
  final root = html.document.documentElement;
  root?.style.removeProperty(_hostHeightVar);
  root?.style.removeProperty(_legacyHeightVar);

  if (js.context.hasProperty('__resetThaiBetaScreenshotHost')) {
    js.context.callMethod('__resetThaiBetaScreenshotHost');
    return;
  }

  _resetDocumentHeightFallback();
}

void syncScreenshotHostHeight(double contentHeightPx) {
  final heightPx = contentHeightPx.ceil().clamp(1, 1 << 20);

  final root = html.document.documentElement;
  root?.style.setProperty(_hostHeightVar, '${heightPx}px');
  root?.style.setProperty(_legacyHeightVar, '${heightPx}px');

  if (js.context.hasProperty('__syncThaiBetaScreenshotHost')) {
    js.context.callMethod('__syncThaiBetaScreenshotHost', [heightPx]);
    return;
  }

  _applyDocumentHeightFallback(heightPx);
}

void _clearElementHeightStyles(html.Element element) {
  element.style.removeProperty('height');
  element.style.removeProperty('min-height');
  element.style.removeProperty('max-height');
  element.style.removeProperty('overflow');
  element.style.removeProperty('overflow-y');
  element.style.removeProperty('overflow-x');
  element.style.removeProperty('contain');
}

void _resetDocumentHeightFallback() {
  final root = html.document.documentElement;
  final body = html.document.body;
  if (root != null) _clearElementHeightStyles(root);
  if (body != null) _clearElementHeightStyles(body);

  for (final selector in _flutterHostSelectors) {
    for (final element in html.document.querySelectorAll(selector)) {
      _clearElementHeightStyles(element);
    }
  }
}

void _applyDocumentHeightFallback(int heightPx) {
  final heightValue = '${heightPx}px';
  final root = html.document.documentElement;
  final body = html.document.body;

  for (final element in [root, body]) {
    if (element == null) continue;
    element.style.setProperty('height', 'auto', 'important');
    element.style.setProperty('min-height', heightValue, 'important');
    element.style.setProperty('max-height', 'none', 'important');
    if (identical(element, body)) {
      element.style.setProperty('overflow', 'visible', 'important');
    } else {
      element.style.setProperty('overflow-y', 'auto', 'important');
      element.style.setProperty('overflow-x', 'hidden', 'important');
    }
  }

  for (final selector in _flutterHostSelectors) {
    for (final element in html.document.querySelectorAll(selector)) {
      element.style.setProperty('height', 'auto', 'important');
      element.style.setProperty('min-height', heightValue, 'important');
      element.style.setProperty('max-height', 'none', 'important');
      element.style.setProperty('overflow', 'visible', 'important');
      element.style.setProperty('overflow-y', 'visible', 'important');
      element.style.setProperty('contain', 'none', 'important');
    }
  }
}

double readAppliedHostHeightPx() {
  final root = html.document.documentElement;
  final raw = root?.style.getPropertyValue(_hostHeightVar) ??
      root?.style.getPropertyValue(_legacyHeightVar) ??
      '';
  final parsed = double.tryParse(raw.replaceAll('px', '').trim());
  return parsed ?? 0;
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
    appliedHostHeight: readAppliedHostHeightPx(),
    screenshotModeActive: html.document.documentElement?.classes
            .contains('screenshot-friendly') ??
        false,
  );
}

/// Computes the host height from measured report content (web-only callers).
double computeScreenshotHostHeight({
  required double contentHeightPx,
  required double topPaddingPx,
  double hostPaddingPx = 80,
  double? windowInnerHeightPx,
}) {
  final measured = contentHeightPx + topPaddingPx + hostPaddingPx;
  final viewport = windowInnerHeightPx ??
      html.window.innerHeight?.toDouble() ??
      0;
  if (viewport <= 0) return measured;
  return math.max(measured, viewport);
}

void disableScreenshotFriendlyScroll() {
  html.document.documentElement?.classes.remove('screenshot-friendly');
  resetScreenshotHostHeight();
}
