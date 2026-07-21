import 'package:knowme/features/runtime/fusion/fusion_confidence.dart';

import 'mirror_view_models.dart';

/// P3 — all surface copy for the Mirror Experience.
///
/// One rule governs this file: **explain life, not astrology**. No planet names,
/// no engine names, no system terminology ever appears here. Copy is warm and
/// emotion-first; the numbers live behind expandable sections in the widgets.
abstract final class MirrorCopy {
  // --- Stage headlines -----------------------------------------------------

  static const String homeTitle = 'Your life, reflected';
  static const String homeBody =
      'A calm, honest look at where your life is right now — and what the '
      'season ahead may be asking of you. No jargon. Just you.';
  static const String homeCta = 'Begin';

  static const String currentLifeHeadline = 'Where your life stands now';
  static const String predictionHeadline = 'The season ahead';
  static const String decisionHeadline = 'If you are weighing a move';
  static const String askMoreTitle = 'Want to go deeper?';
  static const String askMoreBody =
      'Pick what is on your mind. Each answer opens a gentle next question — '
      'you never have to type a thing.';
  static const String reflectionHeadline = 'A moment to reflect';
  static const String reflectionPrompt =
      'Which part of this felt most true for you today?';

  static const String continueCta = 'Continue';
  static const String startOverCta = 'Start again';
  static const String whyLabel = 'What this is based on';

  // --- Life-area titles (domain key → plain language) ----------------------

  static String areaTitle(String domainKey) {
    switch (domainKey) {
      case 'career':
        return 'Work & Direction';
      case 'money':
        return 'Money & Security';
      case 'love':
        return 'Relationships';
      case 'health':
        return 'Health & Energy';
      case 'growth':
        return 'Personal Growth';
      case 'opportunity':
        return 'New Openings';
      case 'pressure':
        return 'Pressure Points';
      default:
        if (domainKey.isEmpty) return 'Life';
        return domainKey[0].toUpperCase() + domainKey.substring(1);
    }
  }

  // --- Tone & clarity ------------------------------------------------------

  static String toneSummary(MirrorTone tone) {
    switch (tone) {
      case MirrorTone.strong:
        return 'A real source of momentum right now.';
      case MirrorTone.steady:
        return 'Holding steady — no big swings.';
      case MirrorTone.tender:
        return 'Asking for a little more care.';
    }
  }

  static String toneWord(MirrorTone tone) {
    switch (tone) {
      case MirrorTone.strong:
        return 'Flowing';
      case MirrorTone.steady:
        return 'Steady';
      case MirrorTone.tender:
        return 'Tender';
    }
  }

  static String clarityLabel(FusionConfidenceBand band) {
    switch (band) {
      case FusionConfidenceBand.low:
        return 'still taking shape';
      case FusionConfidenceBand.moderate:
        return 'coming into focus';
      case FusionConfidenceBand.high:
        return 'clear';
    }
  }

  // --- Bodies derived from the lead area -----------------------------------

  static String insightBody(MirrorLifeArea? lead) {
    if (lead == null) {
      return 'Your life is in a quiet, in-between moment. Nothing is shouting '
          'for your attention — a good time to choose your own focus.';
    }
    switch (lead.tone) {
      case MirrorTone.strong:
        return '${lead.title} is carrying real momentum for you right now. '
            'It is a natural place to lean in.';
      case MirrorTone.steady:
        return '${lead.title} is the quiet centre of your life right now — '
            'steady, dependable, no drama.';
      case MirrorTone.tender:
        return '${lead.title} is asking for some gentleness right now. '
            'Small, kind attention goes a long way here.';
    }
  }

  static String predictionBody(MirrorLifeArea? lead) {
    if (lead == null) {
      return 'The season ahead looks open and unhurried. Few strong currents — '
          'space for you to set the direction.';
    }
    switch (lead.tone) {
      case MirrorTone.strong:
        return 'In the season ahead, ${lead.title.toLowerCase()} looks likely '
            'to keep opening up. Worth preparing to say yes.';
      case MirrorTone.steady:
        return 'The season ahead looks steady around '
            '${lead.title.toLowerCase()} — more continuity than change.';
      case MirrorTone.tender:
        return 'The season ahead may keep ${lead.title.toLowerCase()} a little '
            'sensitive. Gentle pacing will serve you well.';
    }
  }

  static String leanHeadline(MirrorLean lean) {
    switch (lean) {
      case MirrorLean.goFor:
        return 'This looks like a good time to move';
      case MirrorLean.prepare:
        return 'Worth preparing before you move';
      case MirrorLean.wait:
        return 'Gentler to wait a little';
    }
  }

  static String decisionBody(MirrorDecisionLeanInput input) {
    final area = input.focusTitle.toLowerCase();
    switch (input.lean) {
      case MirrorLean.goFor:
        return 'If you have been weighing something around $area, the signs are '
            'supportive. You can move with some confidence.';
      case MirrorLean.prepare:
        return 'If you have been weighing something around $area, lay the '
            'groundwork first. The move is sound — the timing rewards patience.';
      case MirrorLean.wait:
        return 'If you have been weighing something around $area, there is no '
            'rush. Let things settle before you commit.';
    }
  }

  static String reflectionBody(MirrorLifeArea? lead) {
    if (lead == null) {
      return 'You have looked honestly at where things stand. That awareness '
          'itself is the quiet advantage.';
    }
    return 'You have seen where your energy is flowing and where it is asking '
        'for care. Carry just one of these gently into your week.';
  }

  // --- Daily Mirror (Phase C) ----------------------------------------------

  static const String dailyTitle = 'Today';
  static const String dailyGreeting = "Here is today's gentle read on your life.";

  static const String opportunityLabel = "Today's opening";
  static const String cautionLabel = 'Go gently with';
  static const String focusLabel = 'Worth your focus';
  static const String actionLabel = 'One small step';

  static const String dailyConversationTitle = 'Something on your mind?';
  static const String dailyConversationBody =
      'Ask about your day in a tap. No typing — just pick what matters and '
      'follow where it leads.';
  static const String dailyConversationCta = 'Ask about your day';
  static const String dailyJourneyCta = 'See the fuller reflection';
  static const String dailyMoreDetails = 'More details';
  static const String dailyActionDoneCta = "I'll do this";
  static const String dailyActionDoneAck = 'Nice — small steps count.';

  /// A short, human date line ("Sunday · 28 June").
  static String dailyDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final wd = weekdays[(date.weekday - 1) % 7];
    final mo = months[(date.month - 1) % 12];
    return '$wd · ${date.day} $mo';
  }

  static String dailyOpportunity(MirrorLifeArea? area) {
    if (area == null) {
      return 'No single area is pulling ahead today — a calm, open canvas. '
          'Pick the opening that matters most to you.';
    }
    return '${area.title} is where the light is today. A small move here is '
        'likely to be met halfway.';
  }

  static String dailyCaution(MirrorLifeArea? area) {
    if (area == null) {
      return 'Nothing is asking for caution today. Keep your usual pace and '
          'trust your footing.';
    }
    return '${area.title} is a little tender right now. Slow down here and be '
        'kind with yourself before pushing.';
  }

  static String dailyFocus(MirrorLifeArea area, MirrorLean lean) {
    final subject = area.title.toLowerCase();
    switch (lean) {
      case MirrorLean.goFor:
        return 'Put your energy into $subject today — the timing is on your '
            'side.';
      case MirrorLean.prepare:
        return 'Give $subject your attention, but lay groundwork rather than '
            'leaping. Quiet progress counts.';
      case MirrorLean.wait:
        return 'Hold $subject lightly today. A watchful, unhurried focus serves '
            'you better than a big push.';
    }
  }

  static String dailyAction(MirrorLifeArea focus, MirrorLean lean) {
    final subject = focus.title.toLowerCase();
    switch (lean) {
      case MirrorLean.goFor:
        return 'Take one concrete step on $subject today — send the message, '
            'make the ask, start the thing.';
      case MirrorLean.prepare:
        return 'Spend ten quiet minutes preparing for $subject — a list, a '
            'plan, a first draft.';
      case MirrorLean.wait:
        return 'Rather than act on $subject, jot down what you are waiting for. '
            'Clarity now, action later.';
    }
  }
}

/// Small input bundle so copy can phrase a decision without importing widgets.
class MirrorDecisionLeanInput {
  const MirrorDecisionLeanInput({required this.lean, required this.focusTitle});

  final MirrorLean lean;
  final String focusTitle;
}
