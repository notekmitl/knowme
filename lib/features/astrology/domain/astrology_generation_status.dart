/// Unified generation status for all astrology systems.
enum AstrologyGenerationStatus {
  notReady,
  queued,
  generating,
  completed,
  failed,
}

/// Status for a single astrology system (Thai / BaZi / Western / Fusion).
class AstrologySystemSnapshot {
  const AstrologySystemSnapshot({
    required this.systemId,
    required this.status,
    this.errorMessage,
  });

  final String systemId;
  final AstrologyGenerationStatus status;
  final String? errorMessage;

  bool get isReady => status == AstrologyGenerationStatus.completed;
  bool get isBusy =>
      status == AstrologyGenerationStatus.queued ||
      status == AstrologyGenerationStatus.generating;
}

/// Full astrology generation state across four systems.
class AstrologyGenerationSnapshot {
  const AstrologyGenerationSnapshot({
    required this.birthProfileComplete,
    required this.systems,
  });

  static const totalSystems = 4;
  static const systemIds = ['thai', 'bazi', 'western', 'fusion'];

  final bool birthProfileComplete;
  final Map<String, AstrologySystemSnapshot> systems;

  int get completedCount =>
      systems.values.where((s) => s.status == AstrologyGenerationStatus.completed).length;

  bool get isGenerating =>
      systems.values.any((s) => s.isBusy);

  bool get hasFailures =>
      systems.values.any((s) => s.status == AstrologyGenerationStatus.failed);

  AstrologySystemSnapshot system(String id) =>
      systems[id] ??
      AstrologySystemSnapshot(
        systemId: id,
        status: AstrologyGenerationStatus.notReady,
      );

  AstrologyGenerationSnapshot withSystem(AstrologySystemSnapshot system) {
    final next = Map<String, AstrologySystemSnapshot>.from(systems);
    next[system.systemId] = system;
    return AstrologyGenerationSnapshot(
      birthProfileComplete: birthProfileComplete,
      systems: next,
    );
  }
}
