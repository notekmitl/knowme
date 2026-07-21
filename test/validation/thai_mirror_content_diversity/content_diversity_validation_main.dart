import 'content_diversity_validation_runner.dart';

void main() {
  final report = ContentDiversityValidationRunner.validate();
  // ignore: avoid_print
  print(report);
}
