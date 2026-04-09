import 'dart:math';

class QuizQuestion {
  final String questionEn;
  final String questionAr;
  final List<String> optionsEn;
  final List<String> optionsAr;
  final int correctAnswerIndex;
  final String explanationEn;
  final String explanationAr;

  QuizQuestion({
    required this.questionEn,
    required this.questionAr,
    required this.optionsEn,
    required this.optionsAr,
    required this.correctAnswerIndex,
    required this.explanationEn,
    required this.explanationAr,
  });

  String questionFor(String languageCode) =>
      languageCode == 'ar' ? questionAr : questionEn;

  List<String> optionsFor(String languageCode) =>
      languageCode == 'ar' ? optionsAr : optionsEn;

  String explanationFor(String languageCode) =>
      languageCode == 'ar' ? explanationAr : explanationEn;
}

class QuizService {
  static final List<QuizQuestion> _questions = [
    QuizQuestion(
      questionEn: "When was Nizwa Castle built?",
      questionAr: "متى تم بناء قلعة نزوى؟",
      optionsEn: ["17th century", "12th century", "15th century", "19th century"],
      optionsAr: ["القرن السابع عشر", "القرن الثاني عشر", "القرن الخامس عشر", "القرن التاسع عشر"],
      correctAnswerIndex: 0,
      explanationEn:
          "Nizwa Castle was built in the 17th century by Imam Sultan bin Saif al Ya'arubi.",
      explanationAr:
          "تم بناء قلعة نزوى في القرن السابع عشر على يد الإمام سلطان بن سيف اليعربي.",
    ),
    QuizQuestion(
      questionEn: "What is the main architectural feature of Nizwa Castle?",
      questionAr: "ما هي أبرز الملامح المعمارية في قلعة نزوى؟",
      optionsEn: [
        "Round tower",
        "Square tower",
        "Triangular tower",
        "Hexagonal tower",
      ],
      optionsAr: [
        "برج دائري",
        "برج مربع",
        "برج مثلث",
        "برج سداسي",
      ],
      correctAnswerIndex: 0,
      explanationEn:
          "Nizwa Castle is famous for its massive round tower, which is one of the largest in Oman.",
      explanationAr:
          "تشتهر قلعة نزوى ببرجها الدائري الضخم الذي يُعد من أكبر الأبراج في عُمان.",
    ),
    QuizQuestion(
      questionEn: "What was the primary purpose of Nizwa Castle?",
      questionAr: "ما كان الغرض الأساسي من قلعة نزوى؟",
      optionsEn: [
        "Royal residence",
        "Military fortress",
        "Trading post",
        "Religious center",
      ],
      optionsAr: [
        "مقر إقامة ملكي",
        "حصن عسكري",
        "محطة تجارية",
        "مركز ديني",
      ],
      correctAnswerIndex: 1,
      explanationEn:
          "Nizwa Castle served as a military fortress and administrative center for the region.",
      explanationAr:
          "كانت قلعة نزوى حصناً عسكرياً ومركزاً إدارياً للمنطقة.",
    ),
    QuizQuestion(
      questionEn: "How many floors does the main tower of Nizwa Castle have?",
      questionAr: "كم عدد طوابق البرج الرئيسي في قلعة نزوى؟",
      optionsEn: ["5 floors", "7 floors", "3 floors", "9 floors"],
      optionsAr: ["5 طوابق", "7 طوابق", "3 طوابق", "9 طوابق"],
      correctAnswerIndex: 1,
      explanationEn:
          "The main round tower has 7 floors, each serving different purposes.",
      explanationAr:
          "يضم البرج الدائري الرئيسي 7 طوابق، ولكل طابق استخدامات مختلفة.",
    ),
    QuizQuestion(
      questionEn: "What material was primarily used to build Nizwa Castle?",
      questionAr: "ما هي المواد الأساسية التي استُخدمت في بناء قلعة نزوى؟",
      optionsEn: ["Marble", "Mud brick and stone", "Concrete", "Wood"],
      optionsAr: ["الرخام", "الطوب الطيني والحجر", "الخرسانة", "الخشب"],
      correctAnswerIndex: 1,
      explanationEn:
          "Nizwa Castle was built using traditional Omani mud brick and stone construction techniques.",
      explanationAr:
          "بُنيت قلعة نزوى باستخدام تقنيات البناء العُمانية التقليدية بالطوب الطيني والحجر.",
    ),
    QuizQuestion(
      questionEn: "Which dynasty ruled from Nizwa Castle?",
      questionAr: "أي سلالة حكمت من قلعة نزوى؟",
      optionsEn: ["Al Bu Said", "Al Ya'aruba", "Al Nabhani", "Al Busaidi"],
      optionsAr: ["آل بوسعيد", "اليعاربة", "النباهنة", "آل بوسعيد"],
      correctAnswerIndex: 1,
      explanationEn:
          "The Al Ya'aruba dynasty ruled from Nizwa Castle during the 17th and 18th centuries.",
      explanationAr:
          "حكمت سلالة اليعاربة من قلعة نزوى خلال القرنين السابع عشر والثامن عشر.",
    ),
    QuizQuestion(
      questionEn: "What is the diameter of Nizwa Castle's main tower?",
      questionAr: "ما هو قطر البرج الرئيسي في قلعة نزوى؟",
      optionsEn: ["25 meters", "35 meters", "45 meters", "55 meters"],
      optionsAr: ["25 متراً", "35 متراً", "45 متراً", "55 متراً"],
      correctAnswerIndex: 2,
      explanationEn:
          "The main round tower has a diameter of approximately 45 meters.",
      explanationAr:
          "يبلغ قطر البرج الدائري الرئيسي حوالي 45 متراً.",
    ),
    QuizQuestion(
      questionEn: "What defensive feature does Nizwa Castle have?",
      questionAr: "ما هي وسائل الدفاع الموجودة في قلعة نزوى؟",
      optionsEn: ["Moat", "Drawbridge", "Murder holes", "All of the above"],
      optionsAr: ["خندق", "جسر متحرك", "فتحات دفاعية", "جميع ما سبق"],
      correctAnswerIndex: 3,
      explanationEn:
          "Nizwa Castle has all these defensive features: moat, drawbridge, and murder holes.",
      explanationAr:
          "تضم قلعة نزوى وسائل دفاع متعددة مثل الخندق والجسر المتحرك والفتحات الدفاعية.",
    ),
    QuizQuestion(
      questionEn: "What is located at the top of Nizwa Castle's tower?",
      questionAr: "ماذا يوجد في أعلى برج قلعة نزوى؟",
      optionsEn: ["Garden", "Observation deck", "Prayer room", "Storage room"],
      optionsAr: ["حديقة", "منصة مراقبة", "غرفة صلاة", "مخزن"],
      correctAnswerIndex: 1,
      explanationEn:
          "The top of the tower features an observation deck with panoramic views of the surrounding area.",
      explanationAr:
          "يوجد في أعلى البرج منصة مراقبة توفر إطلالات بانورامية على المنطقة المحيطة.",
    ),
    QuizQuestion(
      questionEn: "Which city is Nizwa Castle located in?",
      questionAr: "في أي مدينة تقع قلعة نزوى؟",
      optionsEn: ["Muscat", "Salalah", "Nizwa", "Sohar"],
      optionsAr: ["مسقط", "صلالة", "نزوى", "صحار"],
      correctAnswerIndex: 2,
      explanationEn:
          "Nizwa Castle is located in the city of Nizwa, which was once the capital of Oman.",
      explanationAr:
          "تقع قلعة نزوى في مدينة نزوى التي كانت في وقتٍ ما عاصمة عُمان.",
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
