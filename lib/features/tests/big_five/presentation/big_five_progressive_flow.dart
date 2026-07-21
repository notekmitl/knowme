import 'package:flutter/material.dart';

import '../application/big_five_session_state.dart';
import '../big_five_routes.dart';
import '../domain/big_five_models.dart';

/// Navigation helpers for the progressive Big Five test (10 → 44 → 80).
abstract final class BigFiveProgressiveFlow {
  /// Opens the test flow (pushes on the current navigator stack).
  static Future<void> openTest(BuildContext context) {
    return Navigator.of(context).push(BigFiveRoutes.testRoute());
  }

  /// Replaces the current route with the active test segment.
  static void replaceWithTest(
    BuildContext context, {
    bool continueToStandardCheckpoint = false,
    bool continueToDeepCheckpoint = false,
    Map<String, int>? restoredAnswers,
  }) {
    Navigator.of(context).pushReplacement(
      BigFiveRoutes.testRoute(
        continueToStandardCheckpoint: continueToStandardCheckpoint,
        continueToDeepCheckpoint: continueToDeepCheckpoint,
        restoredAnswers: restoredAnswers,
      ),
    );
  }

  /// Replaces the current route with Result V1 and wires depth continue actions.
  static void replaceWithResult(
    BuildContext context, {
    required BigFiveResultSummary summary,
    required BigFiveSessionState session,
  }) {
    final pendingAnswers = session.canOfferAnyContinue
        ? Map<String, int>.from(session.answers)
        : null;

    Navigator.of(context).pushReplacement(
      BigFiveRoutes.resultRoute(
        summary: summary,
        canContinueToStandard: session.canOfferStandardContinue,
        canContinueToDeep: session.canOfferDeepContinue,
        pendingAnswersForContinue: pendingAnswers,
      ),
    );
  }
}
