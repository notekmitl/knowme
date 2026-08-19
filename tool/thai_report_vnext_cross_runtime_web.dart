// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import 'thai_report_vnext_cross_runtime_manifest.dart';

void main() {
  final manifest = encodeThaiReportVnextCrossRuntimeManifest();
  html.document.body!
    ..children.clear()
    ..append(
      html.PreElement()
        ..id = 'manifest'
        ..text = manifest,
    );
  html.document.body!.dataset['status'] = 'complete';
}
