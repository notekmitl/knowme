import 'dart:html' as html;

import 'web_launch_route_uri.dart';

/// Reads the browser launch URL for public preview deep links.
///
/// Order of preference:
/// 1. `data-knowme-launch-route` on `<html>` (set in `web/index.html` before Flutter)
/// 2. `sessionStorage['knowmeLaunchRoute']` (same early capture)
/// 3. Live [window.location] pathname/search (and hash when path is `/`)
/// 4. [Uri.base] fallback
///
/// Prefer DOM/sessionStorage over `dart:js` window properties — js interop context
/// is unreliable before [WidgetsFlutterBinding.ensureInitialized] completes.
String? webLaunchRouteName() {
  final fromEarlyCapture = _earlyCapturedLaunchRoute();
  if (fromEarlyCapture != null) return fromEarlyCapture;

  final location = html.window.location;
  final fromBrowser = routeNameFromPathAndQuery(
    location.pathname ?? '',
    location.search,
  );
  if (fromBrowser != null) return fromBrowser;

  final fragment = location.hash.trim();
  if (fragment.isNotEmpty) {
    final raw = fragment.startsWith('#') ? fragment.substring(1) : fragment;
    if (raw.isNotEmpty) {
      final normalized = raw.startsWith('/') ? raw : '/$raw';
      final uri = Uri.parse('https://local$normalized');
      final fromHash = routeNameFromPathAndQuery(
        uri.path,
        uri.hasQuery ? uri.query : '',
      );
      if (fromHash != null) return fromHash;
    }
  }

  return routeNameFromUriBase();
}

String? _earlyCapturedLaunchRoute() {
  try {
    final fromAttr =
        html.document.documentElement?.getAttribute('data-knowme-launch-route');
    final normalizedAttr = _normalizeCapturedRoute(fromAttr);
    if (normalizedAttr != null) return normalizedAttr;
  } catch (_) {}

  try {
    final fromStorage = html.window.sessionStorage['knowmeLaunchRoute'];
    final normalizedStorage = _normalizeCapturedRoute(fromStorage);
    if (normalizedStorage != null) return normalizedStorage;
  } catch (_) {}

  return null;
}

String? _normalizeCapturedRoute(String? raw) {
  if (raw == null) return null;
  final value = raw.trim();
  if (value.isEmpty || value == '/') return null;
  return value.startsWith('/') ? value : '/$value';
}
