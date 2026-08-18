// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

void triggerBrowserPrint() {
  html.window.print();
}

void installBrowserPrintMarkup(String markup, String css) {
  removeBrowserPrintMarkup();
  final style = html.StyleElement()
    ..id = 'knowme-print-style'
    ..text = css;
  final root = html.DivElement()
    ..id = 'knowme-print-root'
    ..setInnerHtml(markup, treeSanitizer: html.NodeTreeSanitizer.trusted);
  html.document.head?.append(style);
  html.document.body?.append(root);
}

void removeBrowserPrintMarkup() {
  html.document.getElementById('knowme-print-root')?.remove();
  html.document.getElementById('knowme-print-style')?.remove();
}
