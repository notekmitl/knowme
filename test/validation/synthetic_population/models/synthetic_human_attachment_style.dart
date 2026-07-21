/// Validation-only attachment dimension — not wired into production runtime.
enum SyntheticHumanAttachmentStyle {
  secure('secure'),
  anxious('anxious'),
  avoidant('avoidant'),
  fearful('fearful');

  const SyntheticHumanAttachmentStyle(this.key);
  final String key;
}
