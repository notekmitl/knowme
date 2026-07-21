import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../data/eq_firestore_repository.dart';
import '../domain/eq_models.dart';
import '../domain/eq_test_type.dart';
import '../eq_routes.dart';
import 'eq_result_page.dart';

/// EQ ecosystem entry — one card per mini test (`results/*` is source of truth).
class EqHomePage extends StatefulWidget {
  const EqHomePage({super.key});

  static const modules = <EqTestType>[
    EqTestType.awareness,
    EqTestType.regulation,
    EqTestType.empathy,
    EqTestType.social,
    EqTestType.stress,
    EqTestType.decision,
  ];

  @override
  State<EqHomePage> createState() => _EqHomePageState();
}

enum EqCardStatus { loading, completed, continueTest, start }

class EqModuleSnapshot {
  const EqModuleSnapshot({
    required this.type,
    required this.status,
    this.result,
    this.answered,
    this.total,
  });

  final EqTestType type;
  final EqCardStatus status;
  final EqResultSummary? result;
  final int? answered;
  final int? total;
}

class _EqHomePageState extends State<EqHomePage> {
  final _repository = EqFirestoreRepositoryImpl();

  String? _error;
  List<EqModuleSnapshot> _snapshots = _placeholderSnapshots();
  int _loadGeneration = 0;

  static List<EqModuleSnapshot> _placeholderSnapshots() => [
        for (final type in EqHomePage.modules)
          EqModuleSnapshot(type: type, status: EqCardStatus.loading),
      ];

  bool get _hydrating => _snapshots.any((s) => s.status == EqCardStatus.loading);

  bool get _summaryUnlocked {
    if (_hydrating) return false;
    if (FirebaseAuth.instance.currentUser?.uid == null) return false;
    if (_snapshots.length != EqHomePage.modules.length) return false;
    return _snapshots.every((s) => s.status == EqCardStatus.completed);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showLoadingIndicator = true}) async {
    final generation = ++_loadGeneration;
    setState(() {
      _error = null;
      if (showLoadingIndicator && _snapshots.isEmpty) {
        _snapshots = _placeholderSnapshots();
      }
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final out = <EqModuleSnapshot>[];

    try {
      for (final type in EqHomePage.modules) {
        out.add(await _snapshotFor(uid, type));
      }
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _snapshots = out;
      });
    } catch (e) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<EqModuleSnapshot> _snapshotFor(String? uid, EqTestType type) async {
    if (uid == null) {
      return EqModuleSnapshot(type: type, status: EqCardStatus.start);
    }

    final testId = type.testId;
    final result = await _repository.loadLatestResult(uid, testId);
    if (result != null) {
      return EqModuleSnapshot(
        type: type,
        status: EqCardStatus.completed,
        result: result,
      );
    }

    final session = await _repository.loadSession(uid, testId);
    if (session != null && session.answers.isNotEmpty) {
      return EqModuleSnapshot(
        type: type,
        status: EqCardStatus.continueTest,
        answered: session.answered,
        total: session.total,
      );
    }

    return EqModuleSnapshot(type: type, status: EqCardStatus.start);
  }

  Future<void> _openModule(EqModuleSnapshot snap) async {
    if (snap.status == EqCardStatus.loading) return;
    switch (snap.status) {
      case EqCardStatus.loading:
        return;
      case EqCardStatus.completed:
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (_) => EqResultPage(
              summary: snap.result!,
              testType: snap.type,
            ),
          ),
        );
      case EqCardStatus.continueTest:
      case EqCardStatus.start:
        final route = EqRoutes.routeForTestType(snap.type);
        if (route != null) {
          final result = await Navigator.push<Object?>(context, route);
          if (result is EqTestProgressHint && mounted) {
            _applyProgressHint(result);
          }
        }
    }
    if (mounted) await _load(showLoadingIndicator: false);
  }

  Future<void> _openSummary() async {
    if (!_summaryUnlocked) return;
    await Navigator.push<void>(context, EqRoutes.summary());
    if (mounted) await _load(showLoadingIndicator: false);
  }

  void _applyProgressHint(EqTestProgressHint hint) {
    setState(() {
      _snapshots = [
        for (final snap in _snapshots)
          if (snap.type == hint.testType && snap.status != EqCardStatus.completed)
            EqModuleSnapshot(
              type: hint.testType,
              status: EqCardStatus.continueTest,
              answered: hint.answered,
              total: hint.total,
            )
          else
            snap,
      ];
    });
  }

  String _titleKey(EqTestType type) => '${type.testId}_title';
  String _descriptionKey(EqTestType type) => '${type.testId}_description';

  String _statusLabel(EqModuleSnapshot snap) {
    if (snap.status == EqCardStatus.loading) {
      return AppText.t('eq_home_status_loading');
    }
    if (snap.status == EqCardStatus.continueTest &&
        snap.answered != null &&
        snap.total != null &&
        snap.total! > 0) {
      return AppText.t('eq_home_status_continue_progress')
          .replaceAll('{answered}', '${snap.answered}')
          .replaceAll('{total}', '${snap.total}');
    }
    return switch (snap.status) {
      EqCardStatus.loading => AppText.t('eq_home_status_loading'),
      EqCardStatus.completed => AppText.t('eq_home_status_completed'),
      EqCardStatus.continueTest => AppText.t('eq_home_status_continue'),
      EqCardStatus.start => AppText.t('eq_home_status_start'),
    };
  }

  String _ctaLabel(EqCardStatus status) => switch (status) {
        EqCardStatus.loading => '',
        EqCardStatus.completed => AppText.t('eq_home_cta_view_result'),
        EqCardStatus.continueTest => AppText.t('eq_home_cta_continue'),
        EqCardStatus.start => AppText.t('eq_home_cta_start'),
      };

  Color _statusColor(EqCardStatus status) => switch (status) {
        EqCardStatus.loading => Colors.blueGrey,
        EqCardStatus.completed => Colors.green,
        EqCardStatus.continueTest => Colors.orange,
        EqCardStatus.start => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    final summaryLoading = _hydrating;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('eq_home_title')),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              AppText.t('eq_home_subtitle'),
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Center(
                child: FilledButton(
                  onPressed: _load,
                  child: Text(AppText.t('eq_home_retry')),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 16),
            for (final snap in _snapshots) ...[
              _EqModuleCard(
                title: AppText.t(_titleKey(snap.type)),
                description: AppText.t(_descriptionKey(snap.type)),
                statusLabel: _statusLabel(snap),
                statusColor: _statusColor(snap.status),
                ctaLabel: _ctaLabel(snap.status),
                onTap: snap.status == EqCardStatus.loading
                    ? null
                    : () => _openModule(snap),
                showChevron: snap.status != EqCardStatus.loading,
              ),
              const SizedBox(height: 10),
            ],
            _EqModuleCard(
              title: AppText.t('eq_summary_locked_title'),
              description: summaryLoading
                  ? AppText.t('eq_summary_locked_description')
                  : _summaryUnlocked
                      ? AppText.t('eq_summary_available_description')
                      : AppText.t('eq_summary_locked_description'),
              statusLabel: summaryLoading
                  ? AppText.t('eq_home_status_loading')
                  : _summaryUnlocked
                      ? AppText.t('eq_home_status_completed')
                      : AppText.t('eq_summary_status_locked'),
              statusColor: summaryLoading
                  ? Colors.blueGrey
                  : _summaryUnlocked
                      ? Colors.green
                      : Colors.grey,
              ctaLabel: summaryLoading
                  ? ''
                  : _summaryUnlocked
                      ? AppText.t('eq_home_cta_view_result')
                      : AppText.t('eq_summary_cta_locked'),
              onTap: !summaryLoading && _summaryUnlocked ? _openSummary : null,
              showChevron: !summaryLoading && _summaryUnlocked,
            ),
          ],
        ),
      ),
    );
  }
}

class _EqModuleCard extends StatelessWidget {
  const _EqModuleCard({
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.statusColor,
    required this.ctaLabel,
    required this.onTap,
    this.showChevron = true,
  });

  final String title;
  final String description;
  final String statusLabel;
  final Color statusColor;
  final String ctaLabel;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final ctaColor = onTap != null ? primary : Colors.grey;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                ctaLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ctaColor,
                ),
              ),
              if (showChevron)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: ctaColor,
                ),
            ],
          ),
        ],
      ),
    );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: onTap != null
          ? InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: content,
            )
          : content,
    );
  }
}
