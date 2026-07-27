import 'thai_detected_event.dart';
import 'thai_evidence_item.dart';

/// V1.3.5 structured detailed report (evidence + composed Thai sections).
class ThaiDetailedReportModel {
  const ThaiDetailedReportModel({
    required this.lifetimeTopics,
    required this.pastPeriods,
    required this.currentReading,
    required this.futurePeriods,
    required this.closingAdvice,
    required this.allEvidence,
    required this.allEvents,
  });

  final List<ThaiTopicReading> lifetimeTopics;
  final List<ThaiPeriodReading> pastPeriods;
  final ThaiCurrentReading currentReading;
  final List<ThaiPeriodReading> futurePeriods;
  final ThaiClosingAdvice closingAdvice;
  final List<ThaiEvidenceItem> allEvidence;
  final List<ThaiDetectedEvent> allEvents;
}

class ThaiTopicReading {
  const ThaiTopicReading({
    required this.topicId,
    required this.title,
    required this.evidenceFound,
    required this.prediction,
    required this.evidenceIds,
  });

  final String topicId;
  final String title;
  final String evidenceFound;
  final String prediction;
  final List<String> evidenceIds;
}

class ThaiPeriodReading {
  const ThaiPeriodReading({
    required this.periodIndex,
    required this.ageLabel,
    required this.phaseName,
    required this.planetLine,
    required this.evidenceFound,
    required this.prediction,
    required this.events,
    required this.evidenceIds,
    required this.isPast,
    required this.isFuture,
  });

  final int periodIndex;
  final String ageLabel;
  final String phaseName;
  final String planetLine;
  final String evidenceFound;
  final String prediction;
  final List<ThaiEventReading> events;
  final List<String> evidenceIds;
  final bool isPast;
  final bool isFuture;
}

class ThaiEventReading {
  const ThaiEventReading({
    required this.body,
    required this.evidenceIds,
    this.conflictNote = '',
  });

  final String body;
  final List<String> evidenceIds;
  final String conflictNote;
}

class ThaiCurrentReading {
  const ThaiCurrentReading({
    required this.evidenceFound,
    required this.prediction,
    required this.evidenceIds,
    required this.birthdayYearLabel,
    required this.periodAgeLabel,
    required this.conflictNote,
  });

  final String evidenceFound;
  final String prediction;
  final List<String> evidenceIds;
  final String birthdayYearLabel;
  final String periodAgeLabel;
  final String conflictNote;
}

class ThaiClosingAdvice {
  const ThaiClosingAdvice({
    required this.recommendations,
    required this.cautions,
    required this.healthDisclaimer,
    required this.evidenceIds,
  });

  final String recommendations;
  final String cautions;
  final String healthDisclaimer;
  final List<String> evidenceIds;
}

/// UI-facing flatten of [ThaiDetailedReportModel] (strings only).
class ThaiMirrorDetailedReportState {
  const ThaiMirrorDetailedReportState({
    required this.lifetimeTopics,
    required this.pastPeriods,
    required this.currentReading,
    required this.futurePeriods,
    required this.closingAdvice,
  });

  final List<ThaiMirrorTopicBlockState> lifetimeTopics;
  final List<ThaiMirrorPeriodDetailState> pastPeriods;
  final ThaiMirrorCurrentDetailState currentReading;
  final List<ThaiMirrorPeriodDetailState> futurePeriods;
  final ThaiMirrorClosingAdviceState closingAdvice;
}

class ThaiMirrorTopicBlockState {
  const ThaiMirrorTopicBlockState({
    required this.title,
    required this.evidenceFound,
    required this.prediction,
  });

  final String title;
  final String evidenceFound;
  final String prediction;
}

class ThaiMirrorPeriodDetailState {
  const ThaiMirrorPeriodDetailState({
    required this.ageLabel,
    required this.phaseName,
    required this.planetLine,
    required this.evidenceFound,
    required this.prediction,
    required this.eventLines,
  });

  final String ageLabel;
  final String phaseName;
  final String planetLine;
  final String evidenceFound;
  final String prediction;
  final List<String> eventLines;
}

class ThaiMirrorCurrentDetailState {
  const ThaiMirrorCurrentDetailState({
    required this.evidenceFound,
    required this.prediction,
    required this.conflictNote,
  });

  final String evidenceFound;
  final String prediction;
  final String conflictNote;
}

class ThaiMirrorClosingAdviceState {
  const ThaiMirrorClosingAdviceState({
    required this.recommendations,
    required this.cautions,
    required this.healthDisclaimer,
  });

  final String recommendations;
  final String cautions;
  final String healthDisclaimer;
}
