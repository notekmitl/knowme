import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/features/astrology/application/birth_profile_readiness.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_state.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_widgets.dart';
import 'package:knowme/services/astrology_api_service.dart';
import 'package:knowme/services/profile_service.dart';
import 'package:provider/provider.dart';

import '../../providers/astrology_provider.dart';
import 'western_reader_v2_copy.dart';

typedef WesternResultGenerator =
    Future<AstrologyChartModel> Function(String uid);

class AstrologyResultPage extends StatefulWidget {
  const AstrologyResultPage({
    super.key,
    this.userId,
    this.preparedChart,
    this.generateChartForUser = _generateWesternChartForUser,
  });

  final String? userId;
  final AstrologyChartModel? preparedChart;
  final WesternResultGenerator generateChartForUser;

  @override
  State<AstrologyResultPage> createState() => _AstrologyResultPageState();
}

class _AstrologyResultPageState extends State<AstrologyResultPage> {
  static const _background = Color(0xFF09101F);

  bool _autoGenerating = false;
  Object? _generationError;

  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  String? get _uid {
    final supplied = widget.userId?.trim();
    if (supplied != null && supplied.isNotEmpty) return supplied;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;
    final provider = context.read<AstrologyProvider>();
    final prepared = widget.preparedChart;
    if (prepared != null && WesternReaderV2Copy.isCurrent(prepared)) {
      provider.usePreparedChart(prepared);
      return;
    }

    final uid = _uid;
    if (uid == null || uid.isEmpty) return;
    await provider.loadChart(uid);
    if (!mounted) return;
    final loaded = provider.chart;
    if (loaded != null && WesternReaderV2Copy.isCurrent(loaded)) return;

    await _generateAndUseChart(uid);
  }

  Future<void> _retryGeneration() async {
    final uid = _uid;
    if (!mounted || uid == null || uid.isEmpty) return;
    await _generateAndUseChart(uid);
  }

  Future<void> _generateAndUseChart(String uid) async {
    setState(() {
      _autoGenerating = true;
      _generationError = null;
    });
    try {
      final chart = await widget.generateChartForUser(uid);
      if (!WesternReaderV2Copy.isCurrent(chart)) {
        throw const FormatException(
          'Western API returned an unsupported chart contract',
        );
      }
      if (!mounted) return;
      context.read<AstrologyProvider>().usePreparedChart(chart);
    } catch (error, stack) {
      debugPrint('[AstrologyResultPage] Western generation failed: $error');
      debugPrint('[AstrologyResultPage] $stack');
      if (mounted) _generationError = error;
    } finally {
      if (mounted) setState(() => _autoGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AstrologyProvider>();
    final chart = provider.chart;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('ดวงตะวันตกของคุณ'),
      ),
      body: provider.isLoading || _autoGenerating
          ? AstrologyGenerationBody(
              title: AstrologyFlowCopy.generationTitle('ดวงตะวันตก'),
              body: 'กำลังคำนวณตำแหน่งดาว เรือนชีวิต และมุมสัมพันธ์สำคัญ',
            )
          : provider.error != null ||
                _generationError != null ||
                chart == null ||
                !WesternReaderV2Copy.isCurrent(chart)
          ? AstrologyFlowStateBody(
              state: AstrologyFlowState.failed,
              onPrimaryAction: _retryGeneration,
              primaryActionLabel: AstrologyFlowCopy.retryCta,
            )
          : _WesternReaderBody(chart: chart),
    );
  }
}

Future<AstrologyChartModel> _generateWesternChartForUser(String uid) async {
  final profile = await ProfileService().loadProfileForUid(uid);
  if (profile == null || !BirthProfileReadiness.isComplete(profile)) {
    throw StateError(
      'Western astrology requires a complete canonical birth profile',
    );
  }

  return AstrologyApiService.generateChart(
    uid: uid,
    birthDate: BirthProfileReadiness.apiBirthDate(profile),
    birthTime: profile.birthTime.trim(),
    timezone: profile.timezone.isNotEmpty ? profile.timezone : 'Asia/Bangkok',
    latitude: profile.latitude,
    longitude: profile.longitude,
  );
}

class _WesternReaderBody extends StatelessWidget {
  const _WesternReaderBody({required this.chart});

  final AstrologyChartModel chart;

  static const _navy = Color(0xFF111B34);
  static const _violet = Color(0xFF8B7CF6);
  static const _gold = Color(0xFFF2C66D);

  @override
  Widget build(BuildContext context) {
    final sections = WesternReaderV2Copy.sections(chart);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF09101F), Color(0xFF121D38), Color(0xFF21183C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SelectionArea(
        child: SingleChildScrollView(
          key: const Key('western-reader-v2-scroll'),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _hero(),
                  const SizedBox(height: 18),
                  _bigThree(),
                  const SizedBox(height: 30),
                  const _SectionHeading(
                    eyebrow: 'คำอ่านหลัก',
                    title: 'อ่านเป็นเรื่องชีวิต ไม่ใช่ป้ายราศี',
                    subtitle:
                        'เริ่มจากพฤติกรรมที่พบได้จริง ผลที่มักเกิด และวิธีใช้ให้เป็นประโยชน์',
                  ),
                  const SizedBox(height: 14),
                  for (final section in sections) ...[
                    _ReadingCard(section: section),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 20),
                  _chartStructure(),
                  const SizedBox(height: 24),
                  _methodAndDisclaimer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      key: const Key('western-reader-v2-hero'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _navy.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _violet.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'คำอ่านดวงกำเนิดตะวันตก',
            style: TextStyle(
              color: _gold,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'แผนที่ชีวิตแบบตะวันตก',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            WesternReaderV2Copy.overview(chart),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 17,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigThree() {
    return _SurfaceCard(
      key: const Key('western-reader-v2-big-three-basis'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ที่มาของภาพรวม', style: _cardTitleStyle),
          const SizedBox(height: 8),
          Text(
            'ดวงอาทิตย์ราศี${WesternReaderV2Copy.signLabel(chart.big3['sun'])} · '
            'ดวงจันทร์ราศี${WesternReaderV2Copy.signLabel(chart.big3['moon'])} · '
            'ลัคนาราศี${WesternReaderV2Copy.signLabel(chart.big3['rising'])}',
            style: _bodyStyle,
          ),
          const SizedBox(height: 6),
          const Text(
            'คำอ่านด้านบนพิจารณาทั้งสามตำแหน่งร่วมกัน; รายการนี้เป็นข้อมูลอ้างอิง ไม่ใช่คำอ่านแยกสามป้าย',
            style: _supportStyle,
          ),
        ],
      ),
    );
  }

  Widget _chartStructure() {
    return _SurfaceCard(
      key: const Key('western-reader-v2-chart-structure'),
      padding: EdgeInsets.zero,
      child: Theme(
        data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          iconColor: _gold,
          collapsedIconColor: Colors.white70,
          title: const Text(
            'ข้อมูลทางโหราศาสตร์ที่ใช้ประกอบคำอ่าน',
            style: _cardTitleStyle,
          ),
          subtitle: const Text(
            'เปิดดูสมดุลธาตุ ดาวเด่น เรือน และมุมดาวเมื่ออยากตรวจที่มารายละเอียด',
            style: _supportStyle,
          ),
          children: [
            _balances(),
            const SizedBox(height: 12),
            _dominance(),
            const SizedBox(height: 12),
            _aspects(),
            const SizedBox(height: 12),
            _planetDetails(),
          ],
        ),
      ),
    );
  }

  Widget _balances() {
    return _SurfaceCard(
      key: const Key('western-reader-v2-balances'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('สมดุลพลังหลัก', style: _cardTitleStyle),
          const SizedBox(height: 6),
          const Text(
            'เปอร์เซ็นต์คือสัดส่วนน้ำหนักภายในดวงนี้ ใช้เปรียบเทียบกันเอง ไม่ใช่คะแนนดี–ไม่ดี',
            style: _supportStyle,
          ),
          const SizedBox(height: 18),
          _BalanceGroup(
            title: 'ธาตุ',
            values: WesternReaderV2Copy.balance(chart, 'elements'),
            label: WesternReaderV2Copy.elementLabel,
          ),
          const SizedBox(height: 18),
          _BalanceGroup(
            title: 'จังหวะการขับเคลื่อน',
            values: WesternReaderV2Copy.balance(chart, 'modalities'),
            label: WesternReaderV2Copy.modalityLabel,
          ),
          const SizedBox(height: 18),
          _BalanceGroup(
            title: 'ทิศทางพลัง',
            values: WesternReaderV2Copy.balance(chart, 'polarities'),
            label: WesternReaderV2Copy.polarityLabel,
          ),
        ],
      ),
    );
  }

  Widget _dominance() {
    final planets = WesternReaderV2Copy.analysisList(chart, 'dominant_planets');
    final houses = WesternReaderV2Copy.analysisList(chart, 'house_emphasis');
    return _SurfaceCard(
      key: const Key('western-reader-v2-dominance'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ดาวและเรือนที่มีน้ำหนัก', style: _cardTitleStyle),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in planets.take(3))
                _Tag(
                  text:
                      '${WesternReaderV2Copy.planetLabel(item['planet'])} · '
                      'ราศี${WesternReaderV2Copy.signLabel(item['sign'])}',
                  highlighted: item == planets.first,
                ),
            ],
          ),
          const SizedBox(height: 16),
          for (final item in houses.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'เรือน ${item['house']} · '
                '${WesternReaderV2Copy.houseLabel((item['house'] as num).round())}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _aspects() {
    final aspects = chart.aspects.take(6).toList();
    return _SurfaceCard(
      key: const Key('western-reader-v2-aspects'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('มุมดาวสำคัญ', style: _cardTitleStyle),
          const SizedBox(height: 6),
          const Text(
            'เรียงจากมุมที่ใกล้จุดสมบูรณ์ที่สุด จึงมีน้ำหนักต่อรูปแบบชีวิตมากกว่า',
            style: _supportStyle,
          ),
          const SizedBox(height: 14),
          if (aspects.isEmpty)
            const Text('ไม่พบมุมดาวหลักในระยะที่กำหนด', style: _bodyStyle)
          else
            for (final item in aspects)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: CircleAvatar(radius: 3, backgroundColor: _gold),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${WesternReaderV2Copy.planetLabel(item['planet1'])} '
                        '${WesternReaderV2Copy.aspectLabel(item['aspect'])} '
                        '${WesternReaderV2Copy.planetLabel(item['planet2'])} '
                        '· คลาด ${(item['orb'] as num?)?.toStringAsFixed(1) ?? '—'}°',
                        style: _bodyStyle,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _planetDetails() {
    return _SurfaceCard(
      key: const Key('western-reader-v2-planets'),
      padding: EdgeInsets.zero,
      child: Theme(
        data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          iconColor: _gold,
          collapsedIconColor: Colors.white70,
          title: const Text('ตำแหน่งดาวทั้งหมด', style: _cardTitleStyle),
          subtitle: const Text(
            'เปิดดูราศี เรือน และสถานะถอยหลังของดาว',
            style: _supportStyle,
          ),
          children: [
            for (final entry in chart.planets.entries)
              _PlanetRow(planet: entry.key, data: entry.value),
          ],
        ),
      ),
    );
  }

  Widget _methodAndDisclaimer() {
    return Container(
      key: const Key('western-reader-v2-method'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('วิธีคำนวณ', style: _cardTitleStyle),
          const SizedBox(height: 8),
          Text(WesternReaderV2Copy.method(chart), style: _supportStyle),
          const SizedBox(height: 18),
          const Text('ข้อจำกัดของคำอ่าน', style: _cardTitleStyle),
          const SizedBox(height: 8),
          Text(WesternReaderV2Copy.disclaimer(chart), style: _supportStyle),
        ],
      ),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.section});

  final WesternReaderSection section;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      key: Key('western-reader-v2-section-${section.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title, style: _cardTitleStyle),
          const SizedBox(height: 9),
          Text(section.body, style: _bodyStyle),
          if (section.basis.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('ที่มาทางโหราศาสตร์: ${section.basis}', style: _supportStyle),
          ],
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: _WesternReaderBody._gold,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: _supportStyle),
      ],
    );
  }
}

class _BalanceGroup extends StatelessWidget {
  const _BalanceGroup({
    required this.title,
    required this.values,
    required this.label,
  });

  final String title;
  final Map<String, int> values;
  final String Function(String) label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        for (final entry in values.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(label(entry.key), style: _supportStyle),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: entry.value.clamp(0, 100) / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: const AlwaysStoppedAnimation(
                        _WesternReaderBody._violet,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 38,
                  child: Text(
                    '${entry.value}%',
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PlanetRow extends StatelessWidget {
  const _PlanetRow({required this.planet, required this.data});

  final String planet;
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    final map = data is Map ? data as Map : const {};
    final degree = map['degree'];
    final retrograde = map['retrograde'] == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              WesternReaderV2Copy.planetLabel(planet),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              'ราศี${WesternReaderV2Copy.signLabel(map['sign'])} '
              '${degree is num ? degree.toStringAsFixed(1) : '—'}° '
              '· เรือน ${map['house'] ?? '—'}${retrograde ? ' · ถอยหลัง' : ''}',
              textAlign: TextAlign.end,
              style: _supportStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, this.highlighted = false});

  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: highlighted
            ? _WesternReaderBody._gold.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlighted
              ? _WesternReaderBody._gold.withValues(alpha: 0.42)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: highlighted ? _WesternReaderBody._gold : Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _WesternReaderBody._navy.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}

const _cardTitleStyle = TextStyle(
  color: Colors.white,
  fontSize: 18,
  fontWeight: FontWeight.w800,
  height: 1.35,
);

const _bodyStyle = TextStyle(color: Colors.white, fontSize: 15.5, height: 1.7);

const _supportStyle = TextStyle(
  color: Colors.white70,
  fontSize: 13.5,
  height: 1.55,
);
