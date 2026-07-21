import 'thai_beta_perceived_method.dart';

/// User feedback captured after reading the Thai report.
class ThaiBetaFeedback {
  const ThaiBetaFeedback({
    required this.overallRating,
    required this.mostAccurate,
    required this.leastAccurate,
    required this.wantMoreAnalysis,
    required this.recommendReason,
    required this.perceivedMethod,
    required this.consentGiven,
    this.perceivedMethodOther,
  });

  /// 1–5 stars.
  final int overallRating;

  /// "Which part felt most accurate?"
  final String mostAccurate;

  /// "Which part did not reflect you well?"
  final String leastAccurate;

  /// "What would you like the system to analyze more?"
  final String wantMoreAnalysis;

  /// "Why would you recommend this system to a friend?"
  final String recommendReason;

  /// "What do you think this system is using to analyze you?"
  final ThaiBetaPerceivedMethod perceivedMethod;

  /// Free text when [perceivedMethod] is `other`.
  final String? perceivedMethodOther;

  /// Required consent to store the submission for research.
  final bool consentGiven;

  Map<String, dynamic> toMap() {
    return {
      'overallRating': overallRating,
      'mostAccurate': mostAccurate,
      'leastAccurate': leastAccurate,
      'wantMoreAnalysis': wantMoreAnalysis,
      'recommendReason': recommendReason,
      'perceivedMethod': perceivedMethod.wireId,
      'perceivedMethodOther': perceivedMethodOther,
      'consentGiven': consentGiven,
    };
  }

  factory ThaiBetaFeedback.fromMap(Map<String, dynamic> map) {
    return ThaiBetaFeedback(
      overallRating: (map['overallRating'] as num?)?.toInt() ?? 0,
      mostAccurate: (map['mostAccurate'] ?? '').toString(),
      leastAccurate: (map['leastAccurate'] ?? '').toString(),
      wantMoreAnalysis: (map['wantMoreAnalysis'] ?? '').toString(),
      recommendReason: (map['recommendReason'] ?? '').toString(),
      perceivedMethod:
          ThaiBetaPerceivedMethod.fromWireId(map['perceivedMethod']?.toString()),
      perceivedMethodOther: map['perceivedMethodOther']?.toString(),
      consentGiven: map['consentGiven'] == true,
    );
  }
}
