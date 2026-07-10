import 'package:flutter/material.dart';

import '../widgets/thai_beta_progress_bar.dart';
import 'thai_beta_landing_page.dart';

/// Final screen after a successful feedback submission: thanks the participant,
/// shows their Reference ID, and invites them back after future improvements.
class ThaiBetaCompletionPage extends StatelessWidget {
  const ThaiBetaCompletionPage({super.key, required this.researchId});

  final String researchId;

  void _restart(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const ThaiBetaLandingPage()),
      (route) => false,
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
        child: Column(
          children: [
            const ThaiBetaProgressBar(current: ThaiBetaStep.feedback),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 72, color: scheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'ขอบคุณที่ร่วมงานวิจัย!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'เราได้รับความคิดเห็นของคุณแล้ว '
                        'ความคิดเห็นนี้จะช่วยให้เราพัฒนาการวิเคราะห์โหราศาสตร์ไทย'
                        'ให้แม่นยำยิ่งขึ้น',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        color: scheme.primaryContainer.withValues(alpha: 0.5),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 16),
                          child: Column(
                            children: [
                              Text('รหัสอ้างอิง (Reference ID)',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: scheme.onPrimaryContainer,
                                  )),
                              const SizedBox(height: 6),
                              SelectableText(
                                researchId,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'ระบบนี้กำลังพัฒนาอย่างต่อเนื่อง '
                        'หากมีการปรับปรุงในอนาคต เรายินดีให้คุณกลับมาลองอีกครั้ง',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: OutlinedButton.icon(
          onPressed: () => _restart(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('เริ่มการวิเคราะห์ใหม่'),
        ),
      ),
    );
  }
}
