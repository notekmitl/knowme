/// Optional beta-safe telemetry hooks — no Canon ids or birth data.
abstract final class ThaiEvidenceBadgeBetaTelemetry {
  static void Function(String name, {Map<String, Object?>? props})? onEvent;

  static void badgeRendered({required String sectionId}) {
    onEvent?.call(
      'thai_evidence_badge_rendered',
      props: {'sectionId': sectionId},
    );
  }

  static void badgeSeen({required String sectionId}) {
    onEvent?.call(
      'thai_evidence_badge_seen',
      props: {'sectionId': sectionId},
    );
  }

  static void feedbackStarted() {
    onEvent?.call('thai_evidence_badge_feedback_started');
  }
}
