import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/data/test_modules.dart';

import 'package:knowme/domain/models/test_category.dart';
import 'package:knowme/domain/models/test_module.dart';

import 'package:knowme/features/tests/eq/eq_routes.dart';
import 'package:knowme/features/tests/mbti/domain/mbti_models.dart';
import 'package:knowme/features/tests/mbti/mbti_routes.dart';
import 'package:knowme/features/tests/mbti_cognitive/mbti_cognitive_routes.dart';
import 'package:knowme/features/tests/mbti_summary/application/mbti_summary_loader.dart';
import 'package:knowme/features/tests/mbti_summary/mbti_summary_routes.dart';
import 'package:knowme/features/tests/mbti_summary/presentation/mbti_summary_gate_page.dart';

import 'universal_test_page.dart';

/// Primary MBTI catalog module — [MbtiMiniTestPage] progressive flow, Firestore `mbti_mini`.
const String _mbtiProgressiveModuleId = 'mbti_progressive';

/// Legacy catalog id (hidden by default); same progressive entry for rollback safety.
const String _mbtiMiniLegacyModuleId = 'mbti_mini';
const String _mbtiCognitiveModuleId = 'mbti_cognitive';
const String _mbtiSummaryModuleId = 'mbti_summary';
const Set<String> _eqFeatureModuleIds = {
  'eq_awareness',
  'eq_regulation',
  'eq_empathy',
  'eq_social',
  'eq_decision',
  'eq_stress',
};

bool _moduleIdOpensProgressiveMbti(String id) =>
    id == _mbtiProgressiveModuleId || id == _mbtiMiniLegacyModuleId;

void _openProgressiveMbtiTest(BuildContext context) {
  Navigator.push(context, MbtiRoutes.miniTestRoute());
}

void _openCognitiveMbtiTest(BuildContext context) {
  Navigator.push(context, MbtiCognitiveRoutes.testRoute());
}

void _openEqFeatureTest(BuildContext context, String moduleId) {
  final route = EqRoutes.routeForModuleId(moduleId);
  if (route != null) {
    Navigator.push(context, route);
  }
}

Future<void> _openMbtiSummary(BuildContext context, String? uid) async {
  if (uid == null) {
    Navigator.push(
      context,
      MbtiSummaryRoutes.gateRoute(),
    );
    return;
  }

  final loader = MbtiSummaryLoader();
  final availability = await loader.loadAvailability(uid);
  if (!context.mounted) return;

  if (availability.canOpenFusion) {
    Navigator.push(context, MbtiSummaryRoutes.fusionRoute());
  } else {
    Navigator.push(
      context,
      MbtiSummaryRoutes.gateRoute(
        args: MbtiSummaryGateArgs(availability: availability),
      ),
    );
  }
}

class TestModuleListPage extends StatelessWidget {
  final TestCategory category;

  const TestModuleListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final lang = AppText.lang;

    final modules = testModules
        .where((m) => category.modules.contains(m.id))
        .toList();

    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.title[lang] ?? category.title["en"] ?? ""),
      ),
      body: ListView.builder(
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final TestModule module = modules[index];

          if (module.id == _mbtiProgressiveModuleId) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _MbtiProgressiveCatalogCard(uid: uid),
            );
          }

          if (module.id == _mbtiSummaryModuleId) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _MbtiSummaryCatalogCard(uid: uid),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _LegacyModuleCatalogCard(module: module, uid: uid),
          );
        },
      ),
    );
  }
}

/// Catalog tile for primary MBTI module ([_mbtiProgressiveModuleId]); progress from `tests/mbti_mini`.
class _MbtiProgressiveCatalogCard extends StatelessWidget {
  final String? uid;

  const _MbtiProgressiveCatalogCard({required this.uid});

  static int _answeredFromData(Map<String, dynamic>? data) {
    if (data == null) return 0;
    if (data.containsKey('answered')) {
      return (data['answered'] as num?)?.toInt() ?? 0;
    }
    final raw = data['answers'];
    if (raw is Map) return raw.length;
    return 0;
  }

  /// Fills within each segment only (visual); [answered] unchanged semantically.
  static double _fillMini(int answered) {
    if (answered <= 0) return 0;
    return (answered / mbtiMiniCheckpoint).clamp(0.0, 1.0);
  }

  static double _fillStandard(int answered) {
    if (answered <= mbtiMiniCheckpoint) return 0;
    return ((answered - mbtiMiniCheckpoint) / (mbtiStandardCheckpoint - mbtiMiniCheckpoint))
        .clamp(0.0, 1.0);
  }

  static double _fillAccurate(int answered) {
    if (answered <= mbtiStandardCheckpoint) return 0;
    return ((answered - mbtiStandardCheckpoint) /
            (mbtiAccurateCheckpoint - mbtiStandardCheckpoint))
        .clamp(0.0, 1.0);
  }

  /// Filled “active” node only while answering within a tier (not on exact checkpoint totals).
  static bool _nodeInProgressToward(int checkpoint, int answered) {
    if (checkpoint == mbtiMiniCheckpoint) {
      return answered > 0 && answered < mbtiMiniCheckpoint;
    }
    if (checkpoint == mbtiStandardCheckpoint) {
      return answered > mbtiMiniCheckpoint && answered < mbtiStandardCheckpoint;
    }
    if (checkpoint == mbtiAccurateCheckpoint) {
      return answered > mbtiStandardCheckpoint && answered < mbtiAccurateCheckpoint;
    }
    return false;
  }

  static Widget _checkpointNode({
    required int checkpoint,
    required int answered,
    required Color segmentColor,
    required Color trackMuted,
  }) {
    const double diameter = 22;
    final done = answered >= checkpoint;
    final inProgress = _nodeInProgressToward(checkpoint, answered);

    if (done) {
      return Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: segmentColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: segmentColor.withValues(alpha: 0.35),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }
    if (inProgress) {
      return Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: segmentColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: segmentColor.withValues(alpha: 0.4),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      );
    }
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: trackMuted, width: 2),
      ),
    );
  }

  /// Cognitive-style bar: [ClipRRect] + height 10 + radius 10. Completed tier = solid segment color.
  static Widget _segmentBar({
    required bool tierComplete,
    required double fill,
    required Color segmentColor,
    required Color trackMuted,
  }) {
    if (tierComplete) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 10,
          width: double.infinity,
          child: ColoredBox(color: segmentColor),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 10,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: trackMuted),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fill.clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: ColoredBox(color: segmentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Segmented bar + nodes + labels (same bar height / clip style as cognitive card).
  static Widget _progressiveCheckpointBar({
    required int answered,
    required Color muted,
    required Color primary,
  }) {
    final green = Colors.green.shade600;
    final amber = Colors.amber.shade700;
    final track = Colors.grey.shade300;
    final f16 = _fillMini(answered);
    final f40 = _fillStandard(answered);
    final f80 = _fillAccurate(answered);
    final tier16Done = answered >= mbtiMiniCheckpoint;
    final tier40Done = answered >= mbtiStandardCheckpoint;
    final tier80Done = answered >= mbtiAccurateCheckpoint;

    TextStyle labelStyle(int checkpoint) {
      final done = answered >= checkpoint;
      final inProg = _nodeInProgressToward(checkpoint, answered);
      if (done) {
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: muted,
        );
      }
      if (inProg) {
        final Color c = checkpoint == mbtiMiniCheckpoint
            ? Colors.green.shade700
            : checkpoint == mbtiStandardCheckpoint
                ? Colors.amber.shade800
                : primary;
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: c,
        );
      }
      return TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: muted.withValues(alpha: 0.85),
      );
    }

    Widget column({
      required int checkpoint,
      required Color segmentColor,
      required bool tierComplete,
      required double fill,
    }) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: _checkpointNode(
                  checkpoint: checkpoint,
                  answered: answered,
                  segmentColor: segmentColor,
                  trackMuted: track,
                ),
              ),
              const SizedBox(height: 8),
              _segmentBar(
                tierComplete: tierComplete,
                fill: fill,
                segmentColor: segmentColor,
                trackMuted: track,
              ),
              const SizedBox(height: 6),
              Text(
                '$checkpoint',
                textAlign: TextAlign.center,
                style: labelStyle(checkpoint),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  column(
                    checkpoint: mbtiMiniCheckpoint,
                    segmentColor: green,
                    tierComplete: tier16Done,
                    fill: f16,
                  ),
                  column(
                    checkpoint: mbtiStandardCheckpoint,
                    segmentColor: amber,
                    tierComplete: tier40Done,
                    fill: f40,
                  ),
                  column(
                    checkpoint: mbtiAccurateCheckpoint,
                    segmentColor: primary,
                    tierComplete: tier80Done,
                    fill: f80,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInner(
    BuildContext context, {
    required int answered,
  }) {
    final lang = AppText.lang;
    final theme = Theme.of(context);
    final muted = Colors.grey.shade600;
    final primary = theme.colorScheme.primary;
    final displayAnswered = answered.clamp(0, mbtiAccurateCheckpoint);

    late String status;
    late Color statusColor;
    if (displayAnswered >= mbtiAccurateCheckpoint) {
      status = lang == 'th' ? '✓ ทำเสร็จแล้ว' : '✓ Completed';
      statusColor = Colors.green;
    } else if (displayAnswered > 0) {
      status = lang == 'th' ? '▶ ทำต่อ' : '▶ Continue';
      statusColor = Colors.orange;
    } else {
      status = lang == 'th' ? '○ ยังไม่เริ่ม' : '○ Not started';
      statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openProgressiveMbtiTest(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppText.t('mbti_progressive_title'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppText.t('mbti_progressive_description'),
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _progressiveCheckpointBar(
                answered: answered,
                muted: muted,
                primary: primary,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$displayAnswered / $mbtiAccurateCheckpoint ${lang == 'th' ? 'ข้อ' : 'questions'}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return _buildInner(context, answered: 0);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tests')
          .doc(mbtiMiniTestId)
          .snapshots(),
      builder: (context, snapshot) {
        int answered = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data();
          answered = _answeredFromData(data);
        }
        return _buildInner(context, answered: answered);
      },
    );
  }
}

class _LegacyModuleCatalogCard extends StatelessWidget {
  final TestModule module;
  final String? uid;

  const _LegacyModuleCatalogCard({required this.module, required this.uid});

  @override
  Widget build(BuildContext context) {
    final lang = AppText.lang;

    if (uid == null) {
      return _buildCard(
        context,
        lang: lang,
        module: module,
        answered: 0,
        total: module.questionCount,
        completed: false,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tests')
          .doc(module.id)
          .snapshots(),
      builder: (context, snapshot) {
        int answered = 0;
        int total = module.questionCount;
        bool completed = false;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data();
          if (data != null) {
            answered = (data['answered'] as num?)?.toInt() ?? 0;
            total = (data['total'] as num?)?.toInt() ?? module.questionCount;
            completed = data['completed'] == true;
          }
        }

        final double percent = total == 0 ? 0 : answered / total;

        late String status;
        late Color statusColor;

        if (completed) {
          status = lang == 'th' ? '✓ ทำเสร็จแล้ว' : '✓ Completed';
          statusColor = Colors.green;
        } else if (answered > 0) {
          status = lang == 'th' ? '▶ ทำต่อ' : '▶ Continue';
          statusColor = Colors.orange;
        } else {
          status = lang == 'th' ? '○ ยังไม่เริ่ม' : '○ Not started';
          statusColor = Colors.grey;
        }

        return _buildCard(
          context,
          lang: lang,
          module: module,
          answered: answered,
          total: total,
          completed: completed,
          percent: percent,
          status: status,
          statusColor: statusColor,
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String lang,
    required TestModule module,
    required int answered,
    required int total,
    required bool completed,
    double? percent,
    String? status,
    Color? statusColor,
  }) {
    final p = percent ?? (total == 0 ? 0.0 : answered / total);
    final st = status ??
        (completed
            ? (lang == 'th' ? '✓ ทำเสร็จแล้ว' : '✓ Completed')
            : answered > 0
                ? (lang == 'th' ? '▶ ทำต่อ' : '▶ Continue')
                : (lang == 'th' ? '○ ยังไม่เริ่ม' : '○ Not started'));
    final sc = statusColor ??
        (completed
            ? Colors.green
            : answered > 0
                ? Colors.orange
                : Colors.grey);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (_moduleIdOpensProgressiveMbti(module.id)) {
            _openProgressiveMbtiTest(context);
          } else if (module.id == _mbtiCognitiveModuleId) {
            _openCognitiveMbtiTest(context);
          } else if (_eqFeatureModuleIds.contains(module.id)) {
            _openEqFeatureTest(context, module.id);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UniversalTestPage(module: module),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppText.t(module.titleKey),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppText.t(module.descriptionKey),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: p,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$answered / $total ${lang == 'th' ? 'ข้อ' : 'questions'}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: sc.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      st,
                      style: TextStyle(
                        color: sc,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Catalog tile for MBTI Summary fusion (read-only; no test flow).
class _MbtiSummaryCatalogCard extends StatelessWidget {
  final String? uid;

  const _MbtiSummaryCatalogCard({required this.uid});

  @override
  Widget build(BuildContext context) {
    final lang = AppText.lang;
    final module = testModules.firstWhere((m) => m.id == _mbtiSummaryModuleId);

    if (uid == null) {
      return _summaryCard(
        context,
        module: module,
        lang: lang,
        status: AppText.t('mbti_sum_catalog_locked'),
        statusColor: Colors.grey,
        enabled: true,
        onTap: () => _openMbtiSummary(context, null),
      );
    }

    return FutureBuilder(
      future: MbtiSummaryLoader().loadAvailability(uid!),
      builder: (context, snapshot) {
        final availability = snapshot.data;
        final ready = availability?.canOpenFusion ?? false;

        late String status;
        late Color statusColor;

        if (snapshot.connectionState == ConnectionState.waiting) {
          status = lang == 'th' ? 'กำลังตรวจสอบ…' : 'Checking…';
          statusColor = Colors.grey;
        } else if (ready) {
          status = AppText.t('mbti_sum_catalog_ready');
          statusColor = Colors.green;
        } else {
          status = AppText.t('mbti_sum_catalog_locked');
          statusColor = Colors.orange;
        }

        return _summaryCard(
          context,
          module: module,
          lang: lang,
          status: status,
          statusColor: statusColor,
          enabled: true,
          onTap: () => _openMbtiSummary(context, uid),
        );
      },
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required TestModule module,
    required String lang,
    required String status,
    required Color statusColor,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.deepPurple.shade700,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppText.t(module.titleKey),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppText.t(module.descriptionKey),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppText.t('mbti_sum_catalog_no_questions'),
                    style: const TextStyle(fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
