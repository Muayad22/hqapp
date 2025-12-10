class QuizResult {
  final String id;
  final String userId;
  final String userName;
  final int score;
  final int totalQuestions;
  final DateTime createdAt;

  const QuizResult({
    required this.id,
    required this.userId,
    required this.userName,
    required this.score,
    required this.totalQuestions,
    required this.createdAt,
  });

  factory QuizResult.fromMap(String id, Map<String, dynamic> data) {
    return QuizResult(
      id: id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      score: (data['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 0,
      createdAt: data['createdAt'] is DateTime
          ? data['createdAt'] as DateTime
          : DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
                DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'score': score,
      'totalQuestions': totalQuestions,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

