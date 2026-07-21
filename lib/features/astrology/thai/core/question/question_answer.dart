import 'package:knowme/features/astrology/thai/core/decision/decision_action.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_tradeoff.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

import 'question_window.dart';

/// The structured stance of an answer. For yes/no intents this is derived from
/// the V11 verdict; informational intents (timing, opportunity, risk, prepare)
/// are [informational]. No copy — a presenter maps a stance to prose later.
enum QuestionStance {
  /// Conditions favour acting now.
  yes,

  /// Act, but groundwork is needed first.
  prepareFirst,

  /// A later window is materially better.
  waitForBetterWindow,

  /// Risk outweighs reward in the foreseeable windows.
  avoid,

  /// The question is not a go/no-go (timing / opportunity / risk / prepare).
  informational,
}

/// V12 — the structured answer to a question. Evidence only: a [stance], the
/// underlying decision [action], and the focus the intent cares about (a
/// [focusWindow] for timing, a [focusDomain] for opportunity/risk, a
/// [focusTradeoff] for preparation). No copy anywhere.
class QuestionAnswer {
  const QuestionAnswer({
    required this.stance,
    required this.action,
    this.focusWindow,
    this.focusDomain,
    this.focusTradeoff,
  });

  final QuestionStance stance;

  /// The V11 verdict the answer rests on (always present, even when [stance] is
  /// [QuestionStance.informational]).
  final DecisionAction action;

  /// The window the answer points at (timing/yes-no intents).
  final QuestionWindow? focusWindow;

  /// The leading opportunity/risk domain (opportunity/risk/prepare intents).
  final LifeDomain? focusDomain;

  /// The headline tradeoff to weigh (prepare/yes-no intents).
  final DecisionTradeoff? focusTradeoff;
}
