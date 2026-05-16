class FeedbackEntry {
  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;

  /// 1–5 stars when present; older documents may omit this field.
  final int? rating;

  const FeedbackEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
    this.rating,
  });

  static int? _parseRating(Object? raw) {
    if (raw == null) return null;
    final n = raw is int
        ? raw
        : (raw is num ? raw.toInt() : int.tryParse(raw.toString()));
    if (n == null || n < 1 || n > 5) return null;
    return n;
  }

  bool get isGuest => userId == 'guest';

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
      rating: _parseRating(data['rating']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      if (rating != null) 'rating': rating,
    };
  }
}
