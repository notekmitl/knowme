// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/widgets.dart';

import '../test/validation/thai_beta/live_asof/thai_beta_cross_runtime_manifest.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final body = html.document.body!;
  body.children.clear();
  final status = html.DivElement()
    ..id = 'cross-runtime-status'
    ..text = 'running';
  body.append(status);
  try {
    final runLabel = Uri.base.queryParameters['run'] ?? 'chrome';
    final manifest = await buildCrossRuntimeManifest(runLabel: runLabel);
    final output = html.PreElement()
      ..id = 'cross-runtime-manifest'
      ..text = const JsonEncoder.withIndent('  ').convert(manifest);
    body.append(output);
    status.text = 'complete';
    body.dataset['crossRuntimeStatus'] = 'complete';
  } catch (error, stackTrace) {
    status.text = 'failed';
    body.dataset['crossRuntimeStatus'] = 'failed';
    body.append(
      html.PreElement()
        ..id = 'cross-runtime-error'
        ..text = '$error\n$stackTrace',
    );
  }
}
