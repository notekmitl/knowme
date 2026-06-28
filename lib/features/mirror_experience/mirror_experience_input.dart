/// P3 — the input the Mirror Experience needs to read a life.
///
/// Deliberately minimal and **system-agnostic**: a birth date and an optional
/// "as of" date. It carries no astrology types, no planet, no engine concept —
/// the experience hands this to the Fusion Runtime and renders what comes back.
class MirrorExperienceInput {
  const MirrorExperienceInput({
    required this.birthDate,
    this.asOf,
  });

  final DateTime birthDate;
  final DateTime? asOf;
}
