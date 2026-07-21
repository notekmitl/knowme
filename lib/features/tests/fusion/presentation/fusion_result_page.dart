import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/features/tests/eq/application/eq_summary_builder.dart';
import 'package:knowme/features/tests/eq/application/eq_summary_loader.dart';
import 'package:knowme/features/tests/mbti/data/mbti_firestore_repository.dart';
import 'package:knowme/features/tests/mbti/presentation/mbti_result_localized_content.dart';
import 'package:knowme/features/tests/mbti_cognitive/data/mbti_cognitive_firestore_repository.dart';
import 'package:knowme/features/tests/mbti_cognitive/presentation/mbti_cognitive_result_content.dart';
import 'package:knowme/presentation/pages/astrology/astrology_hero_synthesis.dart';
import 'package:knowme/services/astrology_firestore_service.dart';

import '../application/fusion_builder.dart';
import '../application/fusion_lens_loader.dart';
import '../application/fusion_loader.dart';
import '../domain/fusion_lens_models.dart';

enum _FusionViewMode { synthesis, astrologyFirst, trueEmpty }

class _FusionLensStatus {
  const _FusionLensStatus({
    required this.id,
    required this.title,
    required this.completed,
  });

  final String id;
  final String title;
  final bool completed;
}

class _FusionLensSnapshotItem {
  const _FusionLensSnapshotItem({
    required this.title,
    required this.body,
    required this.completed,
  });

  final String title;
  final String body;
  final bool completed;
}

/// Fusion v1 — personal overview + lens synthesis.
class FusionResultPage extends StatefulWidget {
  const FusionResultPage({super.key});

  @override
  State<FusionResultPage> createState() => _FusionResultPageState();
}

class _FusionResultPageState extends State<FusionResultPage> {
  final _lensLoader = FusionLensLoader();
  final _fusionLoader = FusionLoader();
  final _astrologyFirestore = AstrologyFirestoreService();
  final _mbtiRepository = MbtiFirestoreRepositoryImpl();
  final _cognitiveRepository = MbtiCognitiveFirestoreRepositoryImpl();
  final _eqSummaryLoader = EqSummaryLoader();

  bool _loading = true;
  String? _error;
  FusionLensContent? _content;
  String? _birthDate;
  String? _birthTime;
  String? _birthPlace;
  List<_FusionLensStatus> _statusItems = const [];
  List<_FusionLensSnapshotItem> _snapshotItems = const [];
  _FusionViewMode _mode = _FusionViewMode.trueEmpty;

  static const _thMonths = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  static const _enMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _content = null;
      _birthDate = null;
      _birthTime = null;
      _birthPlace = null;
      _statusItems = const [];
      _snapshotItems = const [];
      _mode = _FusionViewMode.trueEmpty;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final rawInput = await _fusionLoader.load(uid: uid);

      var astrologyChart = rawInput.astrologyResult;
      if (astrologyChart == null && uid != null) {
        astrologyChart = await _astrologyFirestore.getWesternNatalChart(uid);
      }

      final astrologyReadyFromProfile = await _isAstrologyReadyFromProfile(uid);
      final hasAstrology = astrologyChart != null || astrologyReadyFromProfile;
      final astrologySummary = astrologyChart != null
          ? AstrologyHeroSynthesis.build(astrologyChart, lang: AppText.lang)
          : null;

      final lensInput = await _lensLoader.load();
      final content = lensInput.canSynthesize
          ? FusionBuilder.build(lensInput)
          : null;
      final profile = await _loadProfile(uid);
      final lensData = await _loadLensData(uid, astrologySummary);

      if (!mounted) return;
      setState(() {
        _content = content;
        _birthDate = profile.$1;
        _birthTime = profile.$2;
        _birthPlace = profile.$3;
        _statusItems = lensData.$1;
        _snapshotItems = lensData.$2;
        _loading = false;
        _mode = content != null
            ? _FusionViewMode.synthesis
            : hasAstrology
                ? _FusionViewMode.astrologyFirst
                : _FusionViewMode.trueEmpty;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<(String?, String?, String?)> _loadProfile(String? uid) async {
    if (uid == null || uid.isEmpty) return (null, null, null);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('main')
          .get();
      final data = doc.data();
      if (data == null) return (null, null, null);
      return (
        (data['birthDate'] as String?)?.trim(),
        (data['birthTime'] as String?)?.trim(),
        (data['birthPlace'] as String?)?.trim(),
      );
    } catch (_) {
      return (null, null, null);
    }
  }

  Future<(List<_FusionLensStatus>, List<_FusionLensSnapshotItem>)> _loadLensData(
    String? uid,
    String? astrologySummary,
  ) async {
    final astrologyText = _firstParagraph(
      astrologySummary ?? AppText.t('fusion_v11_astro_fallback'),
    );
    var mbtiDone = false;
    var cognitiveDone = false;
    var eqDone = false;
    var loveStyleDone = false;
    String? mbtiText;
    String? cognitiveText;
    String? eqText;
    String? loveStyleText;

    if (uid != null && uid.isNotEmpty) {
      try {
        final mbti = await _mbtiRepository.loadLatestResult(uid);
        if (mbti != null) {
          mbtiDone = true;
          mbtiText = MbtiResultLocalizedContent(
            typeCode: mbti.type,
            lang: AppText.lang,
          ).summary(AppText.t('fusion_v11_mbti_fallback'));
        }
      } catch (_) {}

      try {
        final cognitive = await _cognitiveRepository.loadLatestResult(uid);
        if (cognitive != null) {
          cognitiveDone = true;
          final lines =
              MbtiCognitiveResultContent.thinkingStyleLines(cognitive.topFour);
          cognitiveText = lines.isNotEmpty
              ? lines.first
              : AppText.t('fusion_v11_cognitive_fallback');
        }
      } catch (_) {}

      try {
        final eqInput = await _eqSummaryLoader.loadInput(uid);
        final eqContent = EqSummaryBuilder.build(eqInput);
        if (eqContent != null) {
          eqDone = true;
          eqText = _firstParagraph(eqContent.narrative);
        }
      } catch (_) {}

      try {
        final attachment = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('results')
            .doc('attachment')
            .get();
        if (attachment.exists && (attachment.data() ?? {}).isNotEmpty) {
          loveStyleDone = true;
          loveStyleText = AppText.t('fusion_v11_love_style_done');
        }
      } catch (_) {}
    }

    final status = <_FusionLensStatus>[
      _FusionLensStatus(
        id: 'mbti',
        title: AppText.t('fusion_v11_lens_mbti'),
        completed: mbtiDone,
      ),
      _FusionLensStatus(
        id: 'eq',
        title: AppText.t('fusion_v11_lens_eq'),
        completed: eqDone,
      ),
      _FusionLensStatus(
        id: 'cognitive',
        title: AppText.t('fusion_v11_lens_cognitive'),
        completed: cognitiveDone,
      ),
      _FusionLensStatus(
        id: 'love_style',
        title: AppText.t('fusion_v11_lens_love_style'),
        completed: loveStyleDone,
      ),
    ];

    final snapshots = <_FusionLensSnapshotItem>[
      _FusionLensSnapshotItem(
        title: AppText.t('fusion_v11_lens_astrology'),
        body: astrologyText,
        completed: true,
      ),
      if (mbtiDone && mbtiText != null)
        _FusionLensSnapshotItem(
          title: AppText.t('fusion_v11_lens_mbti'),
          body: mbtiText,
          completed: true,
        ),
      if (eqDone && eqText != null)
        _FusionLensSnapshotItem(
          title: AppText.t('fusion_v11_lens_eq'),
          body: eqText,
          completed: true,
        ),
      if (cognitiveDone && cognitiveText != null)
        _FusionLensSnapshotItem(
          title: AppText.t('fusion_v11_lens_cognitive'),
          body: cognitiveText,
          completed: true,
        ),
      if (loveStyleDone && loveStyleText != null)
        _FusionLensSnapshotItem(
          title: AppText.t('fusion_v11_lens_love_style'),
          body: loveStyleText,
          completed: true,
        ),
    ];

    return (status, snapshots);
  }

  String _firstParagraph(String text) {
    final out = text
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    return out.isNotEmpty ? out.first : text;
  }

  String _formatBirthDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw.trim());
      if (AppText.lang == 'th') {
        return '${dt.day} ${_thMonths[dt.month - 1]} ${dt.year}';
      }
      return '${_enMonths[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      final cleaned = raw.split('T').first.trim();
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(cleaned)) {
        final parts = cleaned.split('-');
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final d = int.parse(parts[2]);
        if (AppText.lang == 'th') {
          return '$d ${_thMonths[m - 1]} $y';
        }
        return '${_enMonths[m - 1]} $d, $y';
      }
      return raw.trim();
    }
  }

  String _formatBirthTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final parts = raw.trim().split(':');
    if (parts.isEmpty) return raw.trim();
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String _formatBirthLine() {
    final datePart = _formatBirthDate(_birthDate);
    final timePart = _formatBirthTime(_birthTime);
    if (datePart.isEmpty && timePart.isEmpty) return '';
    if (datePart.isEmpty) return timePart;
    if (timePart.isEmpty) return datePart;
    final suffix = AppText.lang == 'th' ? ' น.' : '';
    return '$datePart • $timePart$suffix';
  }

  String _formatBirthPlace(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    var place = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (AppText.lang == 'th') {
      place = place
          .replaceAll(
            RegExp(r',\s*Thailand\s*$', caseSensitive: false),
            ' ประเทศไทย',
          )
          .replaceAll(
            RegExp(r'\bThailand\b', caseSensitive: false),
            'ประเทศไทย',
          )
          .replaceAll(', ประเทศไทย', ' ประเทศไทย')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }
    return place;
  }

  Future<bool> _isAstrologyReadyFromProfile(String? uid) async {
    if (uid == null || uid.isEmpty) return false;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('main')
          .get();
      final data = doc.data();
      if (data == null) return false;

      final hasBirthDate = (data['birthDate'] as String?)?.trim().isNotEmpty == true;
      final hasBirthTime = (data['birthTime'] as String?)?.trim().isNotEmpty == true;
      final latitude = data['latitude'];
      final longitude = data['longitude'];
      final hasLocation = latitude is num && longitude is num;
      return hasBirthDate && hasBirthTime && hasLocation;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('fusion_v11_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
            tooltip: AppText.t('fusion_v11_reload'),
          ),
        ],
      ),
      body: _buildBody(context, muted),
    );
  }

  Widget _buildBody(BuildContext context, Color muted) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppText.t('fusion_v11_load_error'),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.red),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                child: Text(AppText.t('fusion_v11_reload')),
              ),
            ],
          ),
        ),
      );
    }

    return switch (_mode) {
      _FusionViewMode.synthesis => _buildSynthesisView(context, muted),
      _FusionViewMode.astrologyFirst => _buildAstrologyFirstView(context, muted),
      _FusionViewMode.trueEmpty => _buildTrueEmptyView(),
    };
  }

  Widget _buildSynthesisView(BuildContext context, Color muted) {
    if (_content == null) return _buildTrueEmptyView();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
      children: [
        ..._overviewSections(context, muted),
        const SizedBox(height: 40),
        _sectionHeading(context, AppText.t('fusion_v11_synthesis_title'), size: 16),
        const SizedBox(height: 16),
        _sectionBlock(
          context,
          title: AppText.t('fusion_v11_agreement_title'),
          body: _content!.agreement,
          compact: true,
        ),
        const SizedBox(height: 16),
        _sectionBlock(
          context,
          title: AppText.t('fusion_v11_tension_title'),
          body: _content!.tension,
          compact: true,
        ),
        const SizedBox(height: 16),
        _sectionBlock(
          context,
          title: AppText.t('fusion_v11_synthesis_together_title'),
          body: _content!.synthesis,
          compact: true,
        ),
        const SizedBox(height: 28),
        _disclosureText(context, _content!.disclosure, muted),
      ],
    );
  }

  Widget _buildAstrologyFirstView(BuildContext context, Color muted) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
      children: [
        ..._overviewSections(context, muted),
        const SizedBox(height: 40),
        _sectionHeading(context, AppText.t('fusion_v11_synthesis_title'), size: 16),
        const SizedBox(height: 16),
        _sectionBlock(
          context,
          body: AppText.t('fusion_v11_next_lens_body'),
        ),
        const SizedBox(height: 28),
        _disclosureText(context, AppText.t('fusion_v11_disclosure'), muted),
      ],
    );
  }

  List<Widget> _overviewSections(
    BuildContext context,
    Color muted,
  ) {
    return [
      _foundationSection(context),
      const SizedBox(height: 40),
      _snapshotsSection(context),
      const SizedBox(height: 36),
      _statusSection(context, muted),
    ];
  }

  Widget _buildTrueEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppText.t('fusion_v11_true_empty_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              AppText.t('fusion_v11_true_empty_body'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _disclosureText(BuildContext context, String text, Color muted) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.5,
        height: 1.5,
        color: muted.withValues(alpha: 0.92),
      ),
    );
  }

  Widget _sectionHeading(
    BuildContext context,
    String title, {
    double size = 17,
    FontWeight weight = FontWeight.w600,
  }) {
    return Text(
      title,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        height: 1.35,
        letterSpacing: -0.15,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _sectionBlock(
    BuildContext context, {
    String? title,
    required String body,
    bool compact = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: compact ? 15 : 16,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: scheme.onSurface.withValues(alpha: compact ? 0.88 : 1),
            ),
          ),
          SizedBox(height: compact ? 10 : 12),
        ],
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            compact ? 16 : 18,
            compact ? 16 : 20,
            compact ? 16 : 18,
            compact ? 16 : 20,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            body,
            style: TextStyle(
              fontSize: compact ? 15 : 15.5,
              height: 1.62,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _foundationSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final birthLine = _formatBirthLine();
    final placeLine = _formatBirthPlace(_birthPlace);
    final hasMeta = birthLine.isNotEmpty || placeLine.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          context,
          AppText.t('fusion_v11_foundation_title'),
          size: 18.5,
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(14),
          ),
          child: hasMeta
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (birthLine.isNotEmpty)
                      _foundationMetaRow(
                        context,
                        label: AppText.t('fusion_v11_birth_label'),
                        value: birthLine,
                      ),
                    if (placeLine.isNotEmpty)
                      _foundationMetaRow(
                        context,
                        label: AppText.t('fusion_v11_birth_place_label'),
                        value: placeLine,
                        isLast: true,
                      ),
                  ],
                )
              : Text(
                  AppText.t('fusion_v11_foundation_hint'),
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.55,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _foundationMetaRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isLast = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.3,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.5,
              height: 1.5,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusSection(BuildContext context, Color muted) {
    final done = _statusItems.where((s) => s.completed).toList();
    final pending = _statusItems.where((s) => !s.completed).toList();
    final noneDone = done.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(context, AppText.t('fusion_v11_status_title'), size: 15, weight: FontWeight.w500),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(12),
          ),
          child: noneDone && pending.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.t('fusion_v11_status_empty_explored'),
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.45,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pending.map((s) => s.title).join(' • '),
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.45,
                        color: muted.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.t('fusion_v11_status_done'),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      done.map((s) => s.title).join(' • '),
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.45,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (pending.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        AppText.t('fusion_v11_status_pending'),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pending.map((s) => s.title).join(' • '),
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.45,
                          color: muted.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _snapshotsSection(BuildContext context) {
    final completed = _snapshotItems.where((s) => s.completed).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(context, AppText.t('fusion_v11_snapshots_title'), size: 17),
        const SizedBox(height: 18),
        for (var i = 0; i < completed.length; i++) ...[
          _snapshotCard(context, completed[i]),
          if (i < completed.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _snapshotCard(BuildContext context, _FusionLensSnapshotItem item) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.body,
            style: TextStyle(
              fontSize: 15.5,
              height: 1.62,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
