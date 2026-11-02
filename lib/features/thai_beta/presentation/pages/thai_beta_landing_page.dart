import 'package:flutter/material.dart';
import 'package:knowme/core/config/api_config.dart';
import 'package:knowme/features/astrology/fusion/presentation/trial_visual_design.dart';

import '../../application/thai_beta_store.dart';
import 'thai_beta_input_page.dart';

/// First screen of the Research flow — sets expectations (purpose, time,
/// privacy, participation) before asking for any personal data, to build trust
/// and improve completion.
class ThaiBetaLandingPage extends StatefulWidget {
  const ThaiBetaLandingPage({
    super.key,
    this.store,
    this.anonymousTrial = ApiConfig.isOverallTrial,
  });

  /// Injectable for tests; defaults to a real [ThaiBetaStore] at runtime.
  final ThaiBetaStore? store;
  final bool anonymousTrial;

  @override
  State<ThaiBetaLandingPage> createState() => _ThaiBetaLandingPageState();
}

class _ThaiBetaLandingPageState extends State<ThaiBetaLandingPage> {
  int? _participants;

  @override
  void initState() {
    super.initState();
    if (!widget.anonymousTrial) _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    final store = widget.store ?? ThaiBetaStore();
    final count = await store.participantCount();
    if (mounted) setState(() => _participants = count);
  }

  void _start() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ThaiBetaInputPage()));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.anonymousTrial) return _buildTrialLanding(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.anonymousTrial ? 'ทดลองดูดวงรวม' : 'ดูดวงไทย — งานวิจัย',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                Icon(Icons.auto_awesome, size: 44, color: scheme.primary),
                const SizedBox(height: 12),
                Text(
                  widget.anonymousTrial
                      ? 'ทดลองอ่านดวงจากสามศาสตร์'
                      : 'ร่วมพัฒนาโหราศาสตร์ไทยให้แม่นยำขึ้น',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.anonymousTrial
                      ? 'กรอกข้อมูลเกิดเพื่ออ่านภาพรวมจากไทย จีน และตะวันตก '
                            'แล้วเลือกอ่านแต่ละศาสตร์ได้'
                      : 'นี่คือระบบวิเคราะห์ดวงไทยที่อยู่ในช่วงเก็บข้อมูลวิจัย '
                            'เราอยากรู้ว่าผลวิเคราะห์ตรงกับคุณมากแค่ไหน',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _InfoTile(
                  icon: Icons.flag_outlined,
                  title: 'จุดประสงค์',
                  body: widget.anonymousTrial
                      ? 'คำนวณจากข้อมูลเกิดที่กรอก และแสดงคำอ่านดวงรวมกับดวงรายศาสตร์'
                      : 'วิเคราะห์ดวงไทยจากวัน เวลา และสถานที่เกิดของคุณ '
                            'แล้วเก็บความคิดเห็นเพื่อพัฒนาความแม่นยำของระบบ',
                ),
                _InfoTile(
                  icon: Icons.schedule_outlined,
                  title: 'ใช้เวลาโดยประมาณ',
                  body: widget.anonymousTrial
                      ? 'ประมาณ 3–5 นาที (กรอกข้อมูลและอ่านผล)'
                      : 'ประมาณ 3–5 นาที (กรอกข้อมูล อ่านผล และให้ความคิดเห็น)',
                ),
                _InfoTile(
                  icon: Icons.lock_outline,
                  title: 'ความเป็นส่วนตัว',
                  body: widget.anonymousTrial
                      ? 'ข้อมูลเกิดจะส่งไปยังบริการคำนวณ แล้วแสดงผลในหน้านี้ '
                            'โดยไม่บันทึกลงบัญชีหรือฐานข้อมูลของระบบ'
                      : 'ข้อมูลของคุณจะถูกใช้เพื่อการวิจัยและพัฒนาระบบเท่านั้น '
                            'และจะไม่ถูกเปิดเผยต่อสาธารณะ',
                ),
                if (!widget.anonymousTrial)
                  _InfoTile(
                    icon: Icons.groups_outlined,
                    title: 'การเข้าร่วมงานวิจัย',
                    body:
                        'การเข้าร่วมเป็นไปโดยสมัครใจ '
                        'คุณจะได้รับรหัสอ้างอิงหลังส่งความคิดเห็น',
                  ),
                if (!widget.anonymousTrial && _participants != null)
                  _InfoTile(
                    icon: Icons.people_alt_outlined,
                    title: 'จำนวนผู้เข้าร่วม',
                    body:
                        'มีผู้ร่วมงานวิจัยแล้ว '
                        '${_formatCount(_participants!)} คน',
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: FilledButton.icon(
          onPressed: _start,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(
            widget.anonymousTrial ? 'เริ่มทดลองดูดวง' : 'เริ่มการวิเคราะห์',
          ),
        ),
      ),
    );
  }

  Widget _buildTrialLanding(BuildContext context) {
    final theme = TrialVisualDesign.theme(TrialVisualDesign.overall);
    final wideScreen = MediaQuery.sizeOf(context).width >= 800;
    final headline = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'สามศาสตร์ · พื้นดวงเดียว',
          style: TextStyle(
            color: TrialVisualDesign.gold,
            fontSize: wideScreen ? 15 : 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'อ่านชีวิตผ่านสามมุมมอง',
          style: TextStyle(
            color: TrialVisualDesign.text,
            fontSize: wideScreen ? 40 : 27,
            height: wideScreen ? 1.2 : 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'กรอกข้อมูลเกิดครั้งเดียว แล้วอ่านดวงรวมพร้อมเลือกดูไทย จีน และตะวันตก',
          style: TextStyle(
            color: TrialVisualDesign.muted,
            fontSize: wideScreen ? 17 : 16,
            height: wideScreen ? 1.55 : 1.6,
          ),
        ),
      ],
    );
    final artwork = TrialArtworkBanner(
      asset: TrialVisualDesign.overallArt,
      height: wideScreen ? 550 : 250,
      alignment: wideScreen
          ? const Alignment(0, -0.7)
          : const Alignment(0, -0.2),
    );
    final steps = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (number, title, detail) in const [
          ('01', 'กรอกข้อมูลเกิด', 'วัน เวลา และจังหวัดที่เกิด'),
          ('02', 'อ่านดวงรวม', 'คำอ่านรายด้านจากหลักฐานที่ระบบคำนวณได้'),
          ('03', 'เลือกดูรายศาสตร์', 'สำรวจมุมไทย จีน และตะวันตกต่อได้'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF211C31),
                border: Border.all(color: const Color(0x665E536A)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: const TextStyle(
                      color: TrialVisualDesign.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: TrialVisualDesign.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          detail,
                          style: const TextStyle(
                            color: TrialVisualDesign.muted,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
    const privacy = Text(
      'ข้อมูลเกิดส่งไปยังบริการคำนวณแยกเพื่อแสดงผลในหน้านี้ '
      'โดยไม่บันทึกลงบัญชีหรือฐานข้อมูลของระบบ',
      style: TextStyle(color: TrialVisualDesign.muted, height: 1.6),
    );
    final startButton = FilledButton.icon(
      onPressed: _start,
      icon: const Icon(Icons.arrow_forward_rounded),
      label: const Text('เริ่มดูดวงรวม'),
    );
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: wideScreen ? 0 : null,
          title: wideScreen
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'KnowMe',
                        style: TextStyle(
                          color: TrialVisualDesign.gold,
                          fontFamily: 'serif',
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                )
              : const Text(
                  'KnowMe',
                  style: TextStyle(
                    color: TrialVisualDesign.gold,
                    fontFamily: 'serif',
                    fontSize: 25,
                  ),
                ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wideScreen ? 1220 : 1040),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 800;
                  return ListView(
                    padding: EdgeInsets.fromLTRB(20, wide ? 18 : 14, 20, 24),
                    children: [
                      if (wide)
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 42,
                          ),
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(child: artwork),
                                const SizedBox(width: 44),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      headline,
                                      const SizedBox(height: 24),
                                      steps,
                                      const SizedBox(height: 8),
                                      SizedBox(height: 52, child: startButton),
                                      const SizedBox(height: 14),
                                      privacy,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        headline,
                        const SizedBox(height: 16),
                        artwork,
                        const SizedBox(height: 20),
                        steps,
                        const SizedBox(height: 8),
                        privacy,
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: wideScreen
            ? null
            : SafeArea(
                minimum: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: SizedBox(width: double.infinity, child: startButton),
                  ),
                ),
              ),
      ),
    );
  }

  static String _formatCount(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
