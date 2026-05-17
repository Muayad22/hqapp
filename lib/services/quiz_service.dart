import 'dart:math';

import 'package:hqapp/models/quiz_question_entry.dart';
import 'package:hqapp/services/firestore_service.dart';

class QuizQuestion {
  final String id;
  final String questionEn;
  final String questionAr;
  final List<String> optionsEn;
  final List<String> optionsAr;
  final int correctAnswerIndex;
  final String explanationEn;
  final String explanationAr;

  QuizQuestion({
    required this.id,
    required this.questionEn,
    required this.questionAr,
    required this.optionsEn,
    required this.optionsAr,
    required this.correctAnswerIndex,
    this.explanationEn = '',
    this.explanationAr = '',
  });

  factory QuizQuestion.fromEntry(QuizQuestionEntry e) {
    return QuizQuestion(
      id: e.id,
      questionEn: e.questionEn,
      questionAr: e.questionAr,
      optionsEn: e.optionsEn,
      optionsAr: e.optionsAr,
      correctAnswerIndex: e.correctIndex,
      explanationEn: e.explanationEn,
      explanationAr: e.explanationAr,
    );
  }

  String questionFor(String languageCode) =>
      languageCode == 'ar' ? questionAr : questionEn;

  List<String> optionsFor(String languageCode) =>
      languageCode == 'ar' ? optionsAr : optionsEn;

  String explanationFor(String languageCode) =>
      languageCode == 'ar' ? explanationAr : explanationEn;

  bool get hasExplanation =>
      explanationEn.trim().isNotEmpty || explanationAr.trim().isNotEmpty;
}

class QuizService {
  static Future<List<QuizQuestion>> loadQuestions(
    String category, {
    int count = 5,
  }) async {
    final snap = await FirestoreService.quizQuestionsStream(category).first;
    if (snap.isEmpty) return [];
    final all = snap.map(QuizQuestion.fromEntry).toList();
    final random = Random();
    all.shuffle(random);
    return all.take(count.clamp(1, all.length)).toList();
  }
}
