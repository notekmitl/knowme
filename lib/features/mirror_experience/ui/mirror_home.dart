import 'package:flutter/material.dart';

import 'package:knowme/features/runtime/fusion/fusion_runtime.dart';

import '../mirror_copy.dart';
import '../mirror_experience_input.dart';
import 'mirror_journey.dart';

/// P3 — the entry surface of the Global Mirror Experience.
///
/// The first real product screen powered by the Runtime Platform. Warm, calm,
/// emotion-first; no astrology terminology, no engine names. From here the user
/// steps into the guided [MirrorJourney].
class MirrorHome extends StatelessWidget {
  const MirrorHome({
    super.key,
    required this.input,
    required this.runtime,
  });

  final MirrorExperienceInput input;
  final FusionRuntime runtime;

  void _begin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MirrorJourney(input: input, runtime: runtime),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.45),
              scheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.auto_awesome_rounded,
                          color: scheme.primary, size: 32),
                    ),
                    const SizedBox(height: 24),
                    Text(MirrorCopy.homeTitle, style: text.headlineMedium),
                    const SizedBox(height: 14),
                    Text(
                      MirrorCopy.homeBody,
                      style: text.bodyLarge
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _begin(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(MirrorCopy.homeCta),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
