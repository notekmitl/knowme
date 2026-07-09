import 'dart:html' as html;

/// Enables document-level scroll for GoFullPage / full-page capture extensions.
void enableScreenshotFriendlyScroll() {
  html.document.documentElement?.classes.add('screenshot-friendly');
}

void disableScreenshotFriendlyScroll() {
  html.document.documentElement?.classes.remove('screenshot-friendly');
}
