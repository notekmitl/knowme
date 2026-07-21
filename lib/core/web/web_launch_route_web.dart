import 'dart:html' as html;

import 'web_launch_route_uri.dart';

/// Reads the browser launch URL (hash or path) for public preview deep links.
///
/// Prefer [window.location] pathname/search because [Uri.base] on Flutter web
/// can report `/` at isolate startup even when the browser URL is a deep path.
String? webLaunchRouteName() {
  final location = html.window.location;
  final fromBrowser = routeNameFromPathAndQuery(
    location.pathname ?? '',
    location.search,
  );
  if (fromBrowser != null) return fromBrowser;
  return routeNameFromUriBase();
}
