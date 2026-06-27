import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

import 'conversation_memory.dart';
import 'conversation_state.dart';

/// V16 — a guided-conversation session for one chart.
///
/// Immutable value object: it holds the chart anchors (the inputs every runtime
/// call needs), the current [state] and the [memory]. The `ConversationFlow`
/// produces a new session for each step. No UI, no persistence.
class ConversationSession {
  const ConversationSession({
    required this.birthDate,
    this.lagnaLord,
    this.asOf,
    this.state = const ConversationState(),
    this.memory = const ConversationMemory(),
  });

  /// Starts a fresh session for a chart (empty state and memory).
  factory ConversationSession.start({
    required DateTime birthDate,
    LifePlanet? lagnaLord,
    DateTime? asOf,
  }) =>
      ConversationSession(
        birthDate: birthDate,
        lagnaLord: lagnaLord,
        asOf: asOf,
      );

  final DateTime birthDate;
  final LifePlanet? lagnaLord;
  final DateTime? asOf;

  final ConversationState state;
  final ConversationMemory memory;

  ConversationSession copyWith({
    ConversationState? state,
    ConversationMemory? memory,
  }) =>
      ConversationSession(
        birthDate: birthDate,
        lagnaLord: lagnaLord,
        asOf: asOf,
        state: state ?? this.state,
        memory: memory ?? this.memory,
      );
}
