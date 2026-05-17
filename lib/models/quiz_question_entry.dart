/// Quiz question stored in Firebase under quizContent/{category}/questions.

class QuizQuestionEntry {

  final String id;

  final String category;

  final String questionEn;

  final String questionAr;

  final List<String> optionsEn;

  final List<String> optionsAr;

  final int correctIndex;

  final String explanationEn;

  final String explanationAr;



  const QuizQuestionEntry({

    required this.id,

    required this.category,

    required this.questionEn,

    required this.questionAr,

    required this.optionsEn,

    required this.optionsAr,

    required this.correctIndex,

    this.explanationEn = '',

    this.explanationAr = '',

  });



  factory QuizQuestionEntry.fromMap({

    required String id,

    required String category,

    required Map<String, dynamic> data,

  }) {

    return QuizQuestionEntry(

      id: id,

      category: category,

      questionEn: data['questionEn']?.toString() ?? '',

      questionAr: data['questionAr']?.toString() ?? '',

      optionsEn: _parseOptions(data['optionsEn']),

      optionsAr: _parseOptions(data['optionsAr']),

      correctIndex: _parseIndex(data['correctIndex']),

      explanationEn: data['explanationEn']?.toString() ?? '',

      explanationAr: data['explanationAr']?.toString() ?? '',

    );

  }



  Map<String, dynamic> toMap() => {

    'questionEn': questionEn,

    'questionAr': questionAr,

    'optionsEn': optionsEn,

    'optionsAr': optionsAr,

    'correctIndex': correctIndex,

    'explanationEn': explanationEn,

    'explanationAr': explanationAr,

  };



  static List<String> _parseOptions(dynamic raw) {

    if (raw is List) {

      return raw.map((e) => e.toString()).toList();

    }

    if (raw is Map) {

      final entries = raw.entries.toList()

        ..sort((a, b) {

          final ai = int.tryParse(a.key.toString()) ?? 0;

          final bi = int.tryParse(b.key.toString()) ?? 0;

          return ai.compareTo(bi);

        });

      return entries.map((e) => e.value.toString()).toList();

    }

    return [];

  }



  static int _parseIndex(dynamic raw) {

    if (raw is int) return raw;

    if (raw is num) return raw.toInt();

    return int.tryParse(raw?.toString() ?? '') ?? 0;

  }

}



/// Built-in quiz category keys in Firebase.

class QuizCategories {

  static const general = 'general';

  static const imamRoom = 'imam_room';



  static const all = [general, imamRoom];

}


