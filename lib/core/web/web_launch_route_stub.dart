import 'web_launch_route_uri.dart';

/// Non-web (or html-unavailable) builds still resolve the launch route from
/// [Uri.base], which on the web reflects the live browser URL. Using the shared
/// [routeNameFromUriBase] keeps deep-link detection working even if the
/// conditional import happens to pick this file on a web build.
String? webLaunchRouteName() => routeNameFromUriBase();
