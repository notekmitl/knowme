import 'mbti_routes.dart';
import 'domain/mbti_models.dart';

/// Catalog metadata for MBTI mini — not collected by app bootstrap yet.
class MbtiModuleRegistration {
  const MbtiModuleRegistration();

  String get testId => mbtiMiniTestId;

  String get displayNameKey => 'mbti_mini_title';

  String get descriptionKey => 'mbti_mini_description';

  String get entryRouteName => MbtiRoutes.miniPath;

  int get questionCount => mbtiMiniQuestionCount;

  bool isEnabled() => true;
}
