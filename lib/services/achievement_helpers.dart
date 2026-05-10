import 'package:hqapp/models/quiz_result.dart';

/// Shared rules so the achievements screen and leaderboard points stay aligned.
class AchievementThresholds {
  AchievementThresholds._();

  static const int quizMaster = 3;
  static const int historyExpert = 5;
  static const int dedicated = 10;
  static const int scholar = 15;
  static const int masterExplorer = 25;

  static const int speedDemonMinSameDay = 2;
  static const int weeklyWindowQuizzes = 3;
  static const int streakPerfectTotal = 2;
  static const int quickThinkerMinQuizzes = 8;

  static const int firstScan = 1;
  static const int keenScanner = 5;
}

int _maxQuizzesOnSameDay(List<QuizResult> results) {
  if (results.isEmpty) return 0;
  final counts = <String, int>{};
  for (final r in results) {
    final d = r.createdAt;
    final key = '${d.year}-${d.month}-${d.day}';
    counts[key] = (counts[key] ?? 0) + 1;
  }
  var max = 0;
  for (final v in counts.values) {
    if (v > max) max = v;
  }
  return max;
}

int _quizzesInLast7Days(List<QuizResult> results) {
  final cutoff = DateTime.now().subtract(const Duration(days: 7));
  return results.where((r) => !r.createdAt.isBefore(cutoff)).length;
}

int _lifetimePerfectCount(List<QuizResult> results) {
  return results
      .where((r) => r.totalQuestions > 0 && r.score == r.totalQuestions)
      .length;
}

/// Total points for leaderboard (sum of unlocked achievement point values).
int achievementLeaderboardPoints(List<QuizResult> quizResults, int scanCount) {
  final qc = quizResults.length;
  final hasFullMark = quizResults.any(
    (r) => r.totalQuestions > 0 && r.score == r.totalQuestions,
  );
  final hasFlawlessSmall = quizResults.any(
    (r) => r.totalQuestions >= 3 && r.score == r.totalQuestions,
  );
  final perfectLifetime =
      _lifetimePerfectCount(quizResults) >=
      AchievementThresholds.streakPerfectTotal;
  final sameDayMax = _maxQuizzesOnSameDay(quizResults);
  final last7 = _quizzesInLast7Days(quizResults);

  var total = 0;

  if (qc >= 1) total += 50;
  if (hasFullMark) total += 100;
  if (qc >= AchievementThresholds.quizMaster) total += 150;
  if (qc >= AchievementThresholds.historyExpert) total += 250;
  if (hasFlawlessSmall) total += 200;
  if (qc >= AchievementThresholds.dedicated) total += 300;
  if (sameDayMax >= AchievementThresholds.speedDemonMinSameDay) {
    total += 175;
  }
  if (qc >= AchievementThresholds.scholar) total += 400;
  if (perfectLifetime) total += 350;
  if (qc >= AchievementThresholds.masterExplorer) total += 500;
  if (qc >= AchievementThresholds.quickThinkerMinQuizzes) total += 125;
  if (last7 >= AchievementThresholds.weeklyWindowQuizzes) total += 275;
  if (scanCount >= AchievementThresholds.firstScan) total += 60;
  if (scanCount >= AchievementThresholds.keenScanner) total += 120;

  return total;
}

int achievementPointsForId(int id) {
  switch (id) {
    case 1:
      return 50;
    case 2:
      return 100;
    case 3:
      return 150;
    case 4:
      return 250;
    case 5:
      return 200;
    case 6:
      return 300;
    case 7:
      return 175;
    case 8:
      return 400;
    case 9:
      return 350;
    case 10:
      return 500;
    case 11:
      return 125;
    case 12:
      return 275;
    case 13:
      return 60;
    case 14:
      return 120;
    default:
      return 0;
  }
}

bool achievementUnlocked({
  required int id,
  required List<QuizResult> quizResults,
  required int scanCount,
}) {
  final qc = quizResults.length;
  final hasFullMark = quizResults.any(
    (r) => r.totalQuestions > 0 && r.score == r.totalQuestions,
  );
  final hasFlawlessSmall = quizResults.any(
    (r) => r.totalQuestions >= 3 && r.score == r.totalQuestions,
  );
  final perfectLifetime =
      _lifetimePerfectCount(quizResults) >=
      AchievementThresholds.streakPerfectTotal;
  final sameDayMax = _maxQuizzesOnSameDay(quizResults);
  final last7 = _quizzesInLast7Days(quizResults);

  switch (id) {
    case 1:
      return qc >= 1;
    case 2:
      return hasFullMark;
    case 3:
      return qc >= AchievementThresholds.quizMaster;
    case 4:
      return qc >= AchievementThresholds.historyExpert;
    case 5:
      return hasFlawlessSmall;
    case 6:
      return qc >= AchievementThresholds.dedicated;
    case 7:
      return sameDayMax >= AchievementThresholds.speedDemonMinSameDay;
    case 8:
      return qc >= AchievementThresholds.scholar;
    case 9:
      return perfectLifetime;
    case 10:
      return qc >= AchievementThresholds.masterExplorer;
    case 11:
      return qc >= AchievementThresholds.quickThinkerMinQuizzes;
    case 12:
      return last7 >= AchievementThresholds.weeklyWindowQuizzes;
    case 13:
      return scanCount >= AchievementThresholds.firstScan;
    case 14:
      return scanCount >= AchievementThresholds.keenScanner;
    default:
      return false;
  }
}
