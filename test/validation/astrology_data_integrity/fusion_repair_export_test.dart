import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_lens_probe.dart';
import 'package:knowme/features/astrology/fusion/application/source_lens_version_resolver.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_real_input.dart';
import 'package:knowme/features/astrology/fusion/domain/models/fusion_snapshot_codec.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

void main() {
  test('exports fusion snapshot for repair batch', () {
    final inputPath = Platform.environment['FUSION_INPUT_PATH'];
    final outputPath = Platform.environment['FUSION_OUTPUT_PATH'];
    expect(inputPath, isNotNull);
    expect(outputPath, isNotNull);

    final raw = jsonDecode(File(inputPath!).readAsStringSync()) as Map<String, dynamic>;
    final profile = ProfileModel.fromMap(
      Map<String, dynamic>.from(raw['profile'] as Map),
    );
    final westernMap = raw['western'] as Map<String, dynamic>?;
    final baziMap = raw['bazi'] as Map<String, dynamic>?;

    expect(westernMap, isNotNull);
    expect(baziMap, isNotNull);

    final western = AstrologyChartModel.fromMap(westernMap!);
    final bazi = BaziChartModel.fromMap(baziMap!);
    final birthData = FirestoreAstrologyFusionLensProbe.thaiBirthDataFromProfile(profile);
    final thai = birthData == null
        ? null
        : ThaiMirrorPipeline.generate(birthData).mirrorResult;

    final input = AstrologyFusionRealInput(
      western: western,
      bazi: bazi,
      thai: thai,
    );
    final versions = SourceLensVersionResolver.fromInput(input);
    final snapshot = AstrologyFusionGenerator.generateSnapshot(
      input,
      sourceLensVersions: versions,
    );

    final encoded = _toJsonSafe(FusionSnapshotCodec.toMap(snapshot));
    File(outputPath!).writeAsStringSync(jsonEncode(encoded));
  });
}

dynamic _toJsonSafe(dynamic value) {
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), _toJsonSafe(val)));
  }
  if (value is List) {
    return value.map(_toJsonSafe).toList();
  }
  final type = value.runtimeType.toString();
  if (type == 'Timestamp') {
    return (value as dynamic).toDate().toUtc().toIso8601String();
  }
  return value;
}
