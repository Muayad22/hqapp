class FeedbackEntry {
  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;

  const FeedbackEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
  });

  factory FeedbackEntry.fromMap(String id, Map<String, dynamic> data) {
    return FeedbackEntry(
      id: id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      message: data['message'] as String? ?? '',
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
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

