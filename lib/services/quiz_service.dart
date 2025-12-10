import 'dart:math';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

class QuizService {
  static final List<QuizQuestion> _questions = [
    // English Questions
    QuizQuestion(
      question: "When was Nizwa Castle built?",
      options: ["17th century", "12th century", "15th century", "19th century"],
      correctAnswerIndex: 0,
      explanation:
          "Nizwa Castle was built in the 17th century by Imam Sultan bin Saif al Ya'arubi.",
    ),
    QuizQuestion(
      question: "What is the main architectural feature of Nizwa Castle?",
      options: [
        "Round tower",
        "Square tower",
        "Triangular tower",
        "Hexagonal tower",
      ],
      correctAnswerIndex: 0,
      explanation:
          "Nizwa Castle is famous for its massive round tower, which is one of the largest in Oman.",
    ),
    QuizQuestion(
      question: "What was the primary purpose of Nizwa Castle?",
      options: [
        "Royal residence",
        "Military fortress",
        "Trading post",
        "Religious center",
      ],
      correctAnswerIndex: 1,
      explanation:
          "Nizwa Castle served as a military fortress and administrative center for the region.",
    ),
    QuizQuestion(
      question: "How many floors does the main tower of Nizwa Castle have?",
      options: ["5 floors", "7 floors", "3 floors", "9 floors"],
      correctAnswerIndex: 1,
      explanation:
          "The main round tower has 7 floors, each serving different purposes.",
    ),
    QuizQuestion(
      question: "What material was primarily used to build Nizwa Castle?",
      options: ["Marble", "Mud brick and stone", "Concrete", "Wood"],
      correctAnswerIndex: 1,
      explanation:
          "Nizwa Castle was built using traditional Omani mud brick and stone construction techniques.",
    ),
    QuizQuestion(
      question: "Which dynasty ruled from Nizwa Castle?",
      options: ["Al Bu Said", "Al Ya'aruba", "Al Nabhani", "Al Busaidi"],
      correctAnswerIndex: 1,
      explanation:
          "The Al Ya'aruba dynasty ruled from Nizwa Castle during the 17th and 18th centuries.",
    ),
    QuizQuestion(
      question: "What is the diameter of Nizwa Castle's main tower?",
      options: ["25 meters", "35 meters", "45 meters", "55 meters"],
      correctAnswerIndex: 2,
      explanation:
          "The main round tower has a diameter of approximately 45 meters.",
    ),
    QuizQuestion(
      question: "What defensive feature does Nizwa Castle have?",
      options: ["Moat", "Drawbridge", "Murder holes", "All of the above"],
      correctAnswerIndex: 3,
      explanation:
          "Nizwa Castle has all these defensive features: moat, drawbridge, and murder holes.",
    ),
    QuizQuestion(
      question: "What is located at the top of Nizwa Castle's tower?",
      options: ["Garden", "Observation deck", "Prayer room", "Storage room"],
      correctAnswerIndex: 1,
      explanation:
          "The top of the tower features an observation deck with panoramic views of the surrounding area.",
    ),
    QuizQuestion(
      question: "Which city is Nizwa Castle located in?",
      options: ["Muscat", "Salalah", "Nizwa", "Sohar"],
      correctAnswerIndex: 2,
      explanation:
          "Nizwa Castle is located in the city of Nizwa, which was once the capital of Oman.",
    ),
  ];

  static List<QuizQuestion> getRandomQuestions(int count) {
    final random = Random();
    final shuffled = List<QuizQuestion>.from(_questions)..shuffle(random);
    return shuffled.take(count).toList();
  }

  static QuizQuestion getRandomQuestion() {
    final questions = getRandomQuestions(1);
    return questions.isNotEmpty ? questions.first : _questions.first;
  }
}
