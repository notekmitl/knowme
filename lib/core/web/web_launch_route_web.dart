import 'dart:html' as html;
import 'dart:js' as js;

import 'web_launch_route_uri.dart';

/// Reads the browser launch URL for public preview deep links.
///
/// Order of preference:
/// 1. [window.__knowmeLaunchRoute] captured in `web/index.html` before Flutter
///    boots (survives HashUrlStrategy / engine rewrites).
/// 2. Live [window.location] pathname/search (and hash fragment when path is `/`).
/// 3. [Uri.base] fallback.
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
    if (!js.context.hasProperty('__knowmeLaunchRoute')) return null;
    final raw = js.context['__knowmeLaunchRoute'];
    if (raw is! String) return null;
    final value = raw.trim();
    if (value.isEmpty || value == '/') return null;
    return value.startsWith('/') ? value : '/$value';
  } catch (_) {
    return null;
  }
}
