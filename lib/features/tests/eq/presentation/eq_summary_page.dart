import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../application/eq_summary_builder.dart';
import '../application/eq_summary_loader.dart';
import '../domain/eq_summary_models.dart';

/// Read-only EQ overview when all six mini results exist in `results/*`.
class EqSummaryPage extends StatefulWidget {
  const EqSummaryPage({super.key});

  @override
  State<EqSummaryPage> createState() => _EqSummaryPageState();
}

class _EqSummaryPageState extends State<EqSummaryPage> {
  final _loader = EqSummaryLoader();

  bool _loading = true;
  String? _error;
  EqSummaryContent? _content;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _content = null;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppText.t('eq_summary_locked_description');
      });
      return;
    }

    try {
      final input = await _loader.loadInput(uid);
      if (!input.hasAllSix) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = AppText.t('eq_summary_locked_description');
        });
        return;
      }

      final content = EqSummaryBuilder.build(input);
      if (!mounted) return;
      setState(() {
        _content = content;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('eq_summary_title')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, height: 1.45),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                  children: [
                    Text(
                      AppText.t('eq_summary_title'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest
                            .withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _NarrativeBody(
                        paragraphs: _content!.narrative.split('\n\n'),
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppText.t('eq_summary_guidance_title'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _content!.guidance,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: scheme.onSurface.withValues(alpha: 0.92),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _content!.disclosure,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: muted,
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _NarrativeBody extends StatelessWidget {
  const _NarrativeBody({
    required this.paragraphs,
    required this.color,
  });

  final List<String> paragraphs;
  final Color color;

  static const _paragraphStyle = TextStyle(fontSize: 16, height: 1.55);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < paragraphs.length; i++) {
      if (i > 0) children.add(const SizedBox(height: 16));
      children.add(
        Text(
          paragraphs[i],
          style: _paragraphStyle.copyWith(color: color),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
