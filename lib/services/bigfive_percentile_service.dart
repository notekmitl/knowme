class BigFivePercentileService {
  static double percentile(double score) {
    if (score < 20) return 10;
    if (score < 30) return 20;
    if (score < 40) return 35;
    if (score < 50) return 50;
    if (score < 60) return 65;
    if (score < 70) return 75;
    if (score < 80) return 85;
    if (score < 90) return 93;

    return 97;
  }
}
