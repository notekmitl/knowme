import 'package:flutter/material.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_pdf_assets.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_pdf_exporter.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_report_builder.dart';
import 'package:knowme/features/bazi_compatibility/presentation/bazi_compatibility_report_view.dart';
import 'package:printing/printing.dart';

class BaziCompatibilityOwnerPage extends StatefulWidget {
  const BaziCompatibilityOwnerPage({
    super.key,
    this.initialCase = BaziOwnerCase.known,
  });

  final BaziOwnerCase initialCase;

  @override
  State<BaziCompatibilityOwnerPage> createState() =>
      _BaziCompatibilityOwnerPageState();
}

class _BaziCompatibilityOwnerPageState
    extends State<BaziCompatibilityOwnerPage> {
  late BaziOwnerCase _ownerCase = widget.initialCase;

  Future<void> _export() async {
    final report = BaziCompatibilityReportBuilder.build(
      BaziCompatibilityOwnerFixtures.chart(_ownerCase),
    );
    final bytes = await BaziCompatibilityPdfExporter.build(
      report: report,
      fonts: await BaziCompatibilityPdfAssets.load(),
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'knowme-bazi-${_ownerCase.id}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final chart = BaziCompatibilityOwnerFixtures.chart(_ownerCase);
    return Scaffold(
      appBar: AppBar(title: const Text('BaZi V1 · Owner Testing')),
      body: Column(
        children: [
          Container(
            key: const Key('bazi-owner-fixture-banner'),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFFFF3CD),
            child: const Text(
              'Owner fixture เท่านั้น · ไม่เรียก API · ไม่เขียนข้อมูลผู้ใช้ · ไม่ใช่ Production',
              textAlign: TextAlign.center,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
            child: Row(
              children: [
                for (final ownerCase in BaziOwnerCase.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(ownerCase.label),
                      selected: ownerCase == _ownerCase,
                      onSelected: (_) => setState(() => _ownerCase = ownerCase),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: BaziCompatibilityReportView(
              report: BaziCompatibilityReportBuilder.build(chart),
              onExport: _export,
            ),
          ),
        ],
      ),
    );
  }
}
