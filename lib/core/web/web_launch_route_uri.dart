/// Cross-platform launch-route resolver based on [Uri.base].
///
/// On the web, [Uri.base] reflects the live browser URL (including the hash
/// fragment and query string), so this works without depending on `dart:html`
/// or on the `dart.library.html` conditional import resolving correctly.
///
/// Supported forms:
///   https://host/#/thai-mirror/consumer-preview?profile=A   (hash route)
///   https://host/thai-mirror/consumer-preview?profile=A     (path route)
String? routeNameFromUriBase() {
  final Uri base;
  try {
    base = Uri.base;
  } catch (_) {
    return null;
  }

  // Hash route: everything after '#'. Uri.fragment strips the leading '#'.
  final fragment = base.fragment;
  if (fragment.isNotEmpty) {
    return fragment.startsWith('/') ? fragment : '/$fragment';
  }

  // Path route: include the query string so profile/viewport flags survive.
  return routeNameFromPathAndQuery(base.path, base.query);
}

/// Builds `/path` or `/path?query` from browser pathname + search.
String? routeNameFromPathAndQuery(String pathname, String? search) {
  final path = pathname.trim();
  if (path.isEmpty || path == '/') return null;

  final rawSearch = (search ?? '').trim();
  if (rawSearch.isEmpty) return path;

  final query = rawSearch.startsWith('?') ? rawSearch.substring(1) : rawSearch;
  return query.isEmpty ? path : '$path?$query';
}

/// Normalizes a route name string into path + query form.
Uri routeUriFromName(String name) {
  final normalized = name.startsWith('/') ? name : '/$name';
  return Uri.parse('https://local$normalized');
}
