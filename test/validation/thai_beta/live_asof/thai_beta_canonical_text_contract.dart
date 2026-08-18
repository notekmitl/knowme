import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

final class CanonicalTextFixture {
  const CanonicalTextFixture({
    required this.path,
    required this.rawText,
    required this.normalizedText,
    required this.rawSha256,
    required this.normalizedSha256,
  });

  factory CanonicalTextFixture.read(String path) {
    final rawBytes = File(path).readAsBytesSync();
    final rawText = utf8.decode(rawBytes);
    final normalizedText = canonicalizeLineEndings(rawText);
    return CanonicalTextFixture(
      path: path,
      rawText: rawText,
      normalizedText: normalizedText,
      rawSha256: sha256.convert(rawBytes).toString(),
      normalizedSha256: sha256.convert(utf8.encode(normalizedText)).toString(),
    );
  }

  final String path;
  final String rawText;
  final String normalizedText;
  final String rawSha256;
  final String normalizedSha256;
}

String canonicalizeLineEndings(String value) =>
    value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

bool canonicalTextMatchesExactly({
  required String pipelineText,
  required String rawFixtureText,
}) =>
    !pipelineText.contains('\r') &&
    pipelineText == canonicalizeLineEndings(rawFixtureText);

CanonicalTextFixture expectCanonicalFixtureText({
  required String pipelineText,
  required String fixturePath,
  String? reason,
}) {
  final fixture = CanonicalTextFixture.read(fixturePath);
  expect(
    pipelineText,
    isNot(contains('\r')),
    reason: reason == null ? '$fixturePath pipeline contains CR' : '$reason CR',
  );
  expect(pipelineText, fixture.normalizedText, reason: reason ?? fixturePath);
  return fixture;
}
