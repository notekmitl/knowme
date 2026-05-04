import '../data/mbti/mbti_types.dart';
import 'package:knowme/domain/models/mbti_type.dart';

class MbtiTypeService {
  static MbtiType? getType(String type) {
    return mbtiTypes[type];
  }
}
