import 'package:flutter/material.dart';

import '../../application/astrology_fusion_demo_loader.dart';
import 'astrology_fusion_result_page.dart';

/// Internal demo entry for validating Astrology Fusion value.
class AstrologyFusionDemoPage extends StatefulWidget {
  const AstrologyFusionDemoPage({super.key});

  @override
  State<AstrologyFusionDemoPage> createState() =>
      _AstrologyFusionDemoPageState();
}

class _AstrologyFusionDemoPageState extends State<AstrologyFusionDemoPage> {
  late Future<AstrologyFusionDemoLoadResult> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = AstrologyFusionDemoLoader.load();
  }

  Future<void> _reload() async {
    setState(() {
      _loadFuture = AstrologyFusionDemoLoader.load();
    });
    await _loadFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AstrologyFusionDemoLoadResult>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text('Astrology Fusion Demo')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Astrology Fusion Demo')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('โหลดไม่สำเร็จ: ${snapshot.error}'),
              ),
            ),
          );
        }

        final loadResult = snapshot.data;
        if (loadResult == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Astrology Fusion Demo')),
            body: const Center(child: Text('ไม่พบผลลัพธ์')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Astrology Fusion Demo'),
            actions: [
              IconButton(
                onPressed: _reload,
                tooltip: 'โหลดใหม่',
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Column(
            children: [
              MaterialBanner(
                content: Text(
                  switch (loadResult.source) {
                    AstrologyFusionDemoSource.snapshot =>
                      'โหลดจาก snapshot ที่บันทึกไว้ — ไม่ regenerate',
                    AstrologyFusionDemoSource.real =>
                      'สร้างใหม่จากข้อมูลจริง (Western / BaZi / Thai pipeline)',
                    AstrologyFusionDemoSource.mock =>
                      'โหมด mock fallback — ใช้เมื่อยังไม่มีข้อมูลจริง',
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: _reload,
                    child: const Text('โหลดใหม่'),
                  ),
                ],
              ),
              Expanded(
                child: AstrologyFusionResultPage(
                  result: loadResult.result,
                  showAppBar: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
