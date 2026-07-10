import 'package:flutter/material.dart';

import '../../application/thai_beta_store.dart';
import 'thai_beta_input_page.dart';

/// First screen of the Research flow — sets expectations (purpose, time,
/// privacy, participation) before asking for any personal data, to build trust
/// and improve completion.
class ThaiBetaLandingPage extends StatefulWidget {
  const ThaiBetaLandingPage({super.key, this.store});

  /// Injectable for tests; defaults to a real [ThaiBetaStore] at runtime.
  final ThaiBetaStore? store;

  @override
  State<ThaiBetaLandingPage> createState() => _ThaiBetaLandingPageState();
}

class _ThaiBetaLandingPageState extends State<ThaiBetaLandingPage> {
  int? _participants;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    final store = widget.store ?? ThaiBetaStore();
    final count = await store.participantCount();
    if (mounted) setState(() => _participants = count);
  }

  void _start() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ThaiBetaInputPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('ดูดวงไทย — งานวิจัย'),
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
                  'ร่วมพัฒนาโหราศาสตร์ไทยให้แม่นยำขึ้น',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'นี่คือระบบวิเคราะห์ดวงไทยที่อยู่ในช่วงเก็บข้อมูลวิจัย '
                  'เราอยากรู้ว่าผลวิเคราะห์ตรงกับคุณมากแค่ไหน',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant, height: 1.5),
                ),
                const SizedBox(height: 24),
                _InfoTile(
                  icon: Icons.flag_outlined,
                  title: 'จุดประสงค์',
                  body: 'วิเคราะห์ดวงไทยจากวัน เวลา และสถานที่เกิดของคุณ '
                      'แล้วเก็บความคิดเห็นเพื่อพัฒนาความแม่นยำของระบบ',
                ),
                _InfoTile(
                  icon: Icons.schedule_outlined,
                  title: 'ใช้เวลาโดยประมาณ',
                  body: 'ประมาณ 3–5 นาที (กรอกข้อมูล อ่านผล และให้ความคิดเห็น)',
                ),
                _InfoTile(
                  icon: Icons.lock_outline,
                  title: 'ความเป็นส่วนตัว',
                  body: 'ข้อมูลของคุณจะถูกใช้เพื่อการวิจัยและพัฒนาระบบเท่านั้น '
                      'และจะไม่ถูกเปิดเผยต่อสาธารณะ',
                ),
                _InfoTile(
                  icon: Icons.groups_outlined,
                  title: 'การเข้าร่วมงานวิจัย',
                  body: 'การเข้าร่วมเป็นไปโดยสมัครใจ '
                      'คุณจะได้รับรหัสอ้างอิงหลังส่งความคิดเห็น',
                ),
                if (_participants != null)
                  _InfoTile(
                    icon: Icons.people_alt_outlined,
                    title: 'จำนวนผู้เข้าร่วม',
                    body: 'มีผู้ร่วมงานวิจัยแล้ว '
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
          label: const Text('เริ่มการวิเคราะห์'),
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
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
