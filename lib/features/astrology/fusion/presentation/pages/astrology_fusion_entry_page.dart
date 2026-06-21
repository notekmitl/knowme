import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../analytics/fusion_validation_session.dart';
import '../../application/astrology_fusion_loader.dart';
import '../../application/astrology_fusion_readiness_service.dart';
import '../../domain/models/astrology_fusion_readiness.dart';
import 'astrology_fusion_result_page.dart';

/// Production entry — loads snapshot or regenerates, then shows fusion result.
class AstrologyFusionEntryPage extends StatefulWidget {
  const AstrologyFusionEntryPage({
    super.key,
    this.loader,
    this.readinessService,
  });

  final AstrologyFusionLoader? loader;
  final AstrologyFusionReadinessService? readinessService;

  @override
  State<AstrologyFusionEntryPage> createState() =>
      _AstrologyFusionEntryPageState();
}

class _AstrologyFusionEntryPageState extends State<AstrologyFusionEntryPage> {
  late Future<_EntryPayload> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<_EntryPayload> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('ต้องเข้าสู่ระบบก่อนเปิด Astrology Fusion');
    }

    final loader = widget.loader ?? AstrologyFusionLoader();
    final readinessService =
        widget.readinessService ?? AstrologyFusionReadinessService();
    final output = await loader.load(uid: uid);
    final readiness = await readinessService.evaluate(uid);

    return _EntryPayload(
      output: output,
      readiness: readiness,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EntryPayload>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Astrology Fusion')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('โหลดไม่สำเร็จ: ${snapshot.error}'),
              ),
            ),
          );
        }

        final payload = snapshot.data;
        if (payload == null) {
          return const Scaffold(
            body: Center(child: Text('ไม่พบผลลัพธ์')),
          );
        }

        return AstrologyFusionResultPage(
          result: payload.output.result,
          readiness: payload.readiness,
          validationSession: FusionValidationSession(
            lensCount: payload.output.lensCount,
          ),
        );
      },
    );
  }
}

class _EntryPayload {
  const _EntryPayload({
    required this.output,
    required this.readiness,
  });

  final AstrologyFusionLoadOutput output;
  final AstrologyFusionReadiness readiness;
}
