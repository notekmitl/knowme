import 'ipip/ipip_extraversion.dart';
import 'ipip/ipip_agreeableness.dart';
import 'ipip/ipip_conscientiousness.dart';
import 'ipip/ipip_neuroticism.dart';
import 'ipip/ipip_openness.dart';

import '../../../domain/models/test_question.dart';

final List<TestQuestion> ipip120Questions = [
  ...ipipExtraversion,
  ...ipipAgreeableness,
  ...ipipConscientiousness,
  ...ipipNeuroticism,
  ...ipipOpenness,
];
